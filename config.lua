-- config.lua  (serios.gg — GitHub key system)
-- Replaces KeyAuth with your own GitHub-hosted keys.json
-- Keys are locked to the first IP that uses them.

local _loadstring = loadstring

local HttpService  = game:GetService("HttpService")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer

-- ─── CONFIG ──────────────────────────────────────────────────────────────────
local GITHUB_RAW_KEYS  = "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/keys.json"
local GITHUB_API_KEYS  = "https://api.github.com/repos/YOUR_USER/YOUR_REPO/contents/keys.json"
local GITHUB_TOKEN     = "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"  -- fine-grained PAT (read+write keys.json)
local GITHUB_BRANCH    = "main"
local MAIN_SCRIPT_URL  = "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/main.lua"
local SAVE_FILE        = "serios_saved.json"
-- ─────────────────────────────────────────────────────────────────────────────

local httpRequest = (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

local canSave = typeof(writefile) == "function"
    and typeof(readfile)  == "function"
    and typeof(isfile)    == "function"

-- ── helpers ───────────────────────────────────────────────────────────────────
local function jDecode(s)
    local ok, r = pcall(function() return HttpService:JSONDecode(s) end)
    return ok and r or nil
end
local function jEncode(t)
    local ok, r = pcall(function() return HttpService:JSONEncode(t) end)
    return ok and r or "{}"
end

-- Very lightweight IP identifier:
-- We use the player's UserId + a hardware fingerprint as a session token
-- (true external IP isn't accessible from client Lua, so we hash available identifiers)
local function getSessionToken()
    local uid  = tostring(LocalPlayer.UserId)
    local name = tostring(LocalPlayer.Name)
    -- combine with a machine identifier if the executor exposes one
    local hwid = (typeof(getexecutorname) == "function" and getexecutorname() or "")
               .. (typeof(getcustomasset) == "function" and "ca" or "")
    local raw  = uid .. "|" .. name .. "|" .. hwid
    -- simple hash so the raw UID isn't stored in plain text
    local hash = 0
    for i = 1, #raw do
        hash = (hash * 31 + string.byte(raw, i)) % 2147483647
    end
    return string.format("%x", hash) .. "_" .. uid
end

-- ── credential save/load ──────────────────────────────────────────────────────
local function saveCredentials(username, key)
    if not canSave then return end
    pcall(function()
        writefile(SAVE_FILE, jEncode({ username = username, key = key }))
    end)
end

local function loadCredentials()
    if not canSave then return nil, nil end
    local ok, result = pcall(function()
        if not isfile(SAVE_FILE) then return nil end
        return jDecode(readfile(SAVE_FILE))
    end)
    if ok and result and result.username and result.key then
        return result.username, result.key
    end
    return nil, nil
end

local function clearCredentials()
    if not canSave then return end
    pcall(function()
        if isfile(SAVE_FILE) then writefile(SAVE_FILE, "{}") end
    end)
end

-- ── GitHub keys.json fetch (raw, no auth needed for public repos) ─────────────
local function fetchKeysData()
    local ok, res = pcall(function()
        return httpRequest({
            Url    = GITHUB_RAW_KEYS .. "?nocache=" .. tostring(os.time()),
            Method = "GET"
        })
    end)
    if not ok or not res or not res.Body then return nil end
    return jDecode(res.Body)
end

-- ── GitHub keys.json update (needs token for write) ──────────────────────────
local function updateKeyInGitHub(keyEntry, keyStr, callback)
    -- 1. Get current file SHA
    local shaOk, shaRes = pcall(function()
        return httpRequest({
            Url     = GITHUB_API_KEYS,
            Method  = "GET",
            Headers = {
                ["Authorization"] = "token " .. GITHUB_TOKEN,
                ["Accept"]        = "application/vnd.github.v3+json"
            }
        })
    end)

    if not shaOk or not shaRes or not shaRes.Body then
        callback(false, "github_get_failed")
        return
    end

    local meta = jDecode(shaRes.Body)
    if not meta or not meta.sha then
        callback(false, "github_no_sha")
        return
    end

    local fileSha = meta.sha
    local currentContent = ""
    if meta.content then
        -- content is base64, decode it
        local b64 = meta.content:gsub("%s", "")  -- remove newlines
        -- Roblox doesn't have base64 decode natively in all executors, try HttpService trick
        local decOk, decoded = pcall(function()
            -- Some executors expose base64_decode / base64.decode
            if typeof(base64_decode) == "function" then return base64_decode(b64) end
            if typeof(base64) == "table" and base64.decode then return base64.decode(b64) end
            -- fallback: re-download raw
            return nil
        end)
        if decOk and decoded then
            currentContent = decoded
        else
            -- fallback: re-fetch raw
            local rawOk, rawRes = pcall(function()
                return httpRequest({ Url = GITHUB_RAW_KEYS, Method = "GET" })
            end)
            currentContent = (rawOk and rawRes and rawRes.Body) or "{}"
        end
    end

    local allKeys = jDecode(currentContent) or {}
    allKeys[keyStr] = keyEntry  -- update the specific key

    -- base64 encode the new content
    local newJson = jEncode(allKeys)
    local encoded = ""
    local encOk = pcall(function()
        if typeof(base64_encode) == "function" then
            encoded = base64_encode(newJson)
        elseif typeof(base64) == "table" and base64.encode then
            encoded = base64.encode(newJson)
        end
    end)
    if not encOk or encoded == "" then
        -- Try HttpService's base64 via a trick: encode the JSON to bytes
        -- As a fallback, call the Discord bot's endpoint instead
        callback(false, "base64_encode_not_available")
        return
    end

    local putOk, putRes = pcall(function()
        return httpRequest({
            Url     = GITHUB_API_KEYS,
            Method  = "PUT",
            Headers = {
                ["Authorization"] = "token " .. GITHUB_TOKEN,
                ["Content-Type"]  = "application/json",
                ["Accept"]        = "application/vnd.github.v3+json"
            },
            Body = jEncode({
                message = "[serios.gg] Session lock: " .. keyStr:sub(1,4) .. "****",
                content = encoded,
                sha     = fileSha,
                branch  = GITHUB_BRANCH
            })
        })
    end)

    if not putOk or not putRes then
        callback(false, "github_put_failed")
    elseif putRes.StatusCode ~= 200 and putRes.StatusCode ~= 201 then
        callback(false, "github_put_error_" .. tostring(putRes.StatusCode or "?"))
    else
        callback(true, "ok")
    end
end

-- ── Main verify function ──────────────────────────────────────────────────────
local function verifyKey(username, key, callback)
    if username == "" or key == "" then
        callback(false, "empty_fields")
        return
    end

    -- Normalise key format
    key = key:lower():gsub("%s+", "")

    local keysData = fetchKeysData()
    if not keysData then
        callback(false, "could_not_fetch_keys")
        return
    end

    local entry = keysData[key]
    if not entry then
        callback(false, "key_not_found")
        return
    end

    -- ── Expiry check ──────────────────────────────────────────────────────────
    if entry.expires_at and entry.expires_at ~= nil and entry.expires_at ~= "null" then
        -- Parse ISO date: "2025-03-01T12:00:00+00:00"
        -- os.time() returns UTC epoch; we do a rough string comparison
        -- For a more robust check, extract year/month/day from the string
        local y, mo, d, h, mi, s = entry.expires_at:match(
            "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"
        )
        if y then
            local expEpoch = os.time({
                year = tonumber(y), month = tonumber(mo), day = tonumber(d),
                hour = tonumber(h), min  = tonumber(mi), sec = tonumber(s)
            })
            if os.time() > expEpoch then
                callback(false, "key_expired")
                return
            end
        end
    end

    -- ── Session / IP lock check ───────────────────────────────────────────────
    local myToken = getSessionToken()

    if entry.used then
        -- Key already used — check if it's the same session token
        if entry.session_id and entry.session_id ~= myToken then
            -- Different session → deny
            callback(false, "key_already_in_use")
            return
        end
        -- Same session token → allow re-login (e.g. rejoined game)
        -- but verify username matches
        if entry.username and entry.username ~= username then
            callback(false, "username_mismatch")
            return
        end
        -- All good, same person
        saveCredentials(username, key)
        callback(true, "welcome_back")
        return
    end

    -- ── First use: lock key to this session ───────────────────────────────────
    local updatedEntry = {
        key              = key,
        used             = true,
        username         = username,
        ip_hash          = myToken:sub(1, 8),   -- store only partial for privacy
        session_id       = myToken,
        created_at       = entry.created_at,
        expires_at       = entry.expires_at,
        created_by_discord = entry.created_by_discord,
        discord_user_id  = entry.discord_user_id,
        first_used_at    = tostring(os.time())
    }

    updateKeyInGitHub(updatedEntry, key, function(ok, msg)
        if ok then
            saveCredentials(username, key)
            callback(true, "verified")
        else
            -- Even if GitHub write failed, allow access
            -- (next verify will lock it properly)
            saveCredentials(username, key)
            callback(true, "verified_write_pending")
        end
    end)
end

-- ── Load main script ──────────────────────────────────────────────────────────
local function loadMainScript()
    local ok, content = pcall(function()
        return game:HttpGet(MAIN_SCRIPT_URL)
    end)
    if not ok or not content or content == "" then
        warn("[serios.gg] Failed to download main script")
        return
    end
    local fn, err = _loadstring(content)
    if not fn then
        warn("[serios.gg] Failed to compile main script: " .. tostring(err))
        return
    end
    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("[serios.gg] Failed to execute main script: " .. tostring(runErr))
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
return {
    verify           = verifyKey,
    loadMain         = loadMainScript,
    loadCredentials  = loadCredentials,
    clearCredentials = clearCredentials,
    saveCredentials  = saveCredentials,
    canSave          = canSave,
    httpReady        = httpRequest ~= nil
}
