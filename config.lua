-- config.lua  (serios.gg — GitHub key system)
local _loadstring = loadstring

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ─── CONFIG ──────────────────────────────────────────────────────────────────
local GITHUB_API_KEYS = "https://api.github.com/repos/denzells/panel/contents/keys.json"
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/denzells/panel/main/main.lua"
local SAVE_FILE       = "serios_saved.json"
-- ─────────────────────────────────────────────────────────────────────────────

local httpRequest = (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

local canSave = typeof(writefile) == "function"
    and typeof(readfile)  == "function"
    and typeof(isfile)    == "function"

local function jDecode(s)
    local ok, r = pcall(function() return HttpService:JSONDecode(s) end)
    return ok and r or nil
end
local function jEncode(t)
    local ok, r = pcall(function() return HttpService:JSONEncode(t) end)
    return ok and r or "{}"
end

local function b64decode(s)
    if crypt and crypt.base64_decode  then return crypt.base64_decode(s)        end
    if crypt and crypt.base64decode   then return crypt.base64decode(s)          end
    if base64_decode                  then return base64_decode(s)               end
    if base64 and base64.decode       then return base64.decode(s)               end
    if syn and syn.crypt and syn.crypt.base64 then return syn.crypt.base64.decode(s) end
    return nil
end

local function getSessionToken()
    local uid  = tostring(LocalPlayer.UserId)
    local name = tostring(LocalPlayer.Name)
    local hwid = (typeof(getexecutorname) == "function" and getexecutorname() or "")
    local raw  = uid .. "|" .. name .. "|" .. hwid
    local hash = 0
    for i = 1, #raw do
        hash = (hash * 31 + string.byte(raw, i)) % 2147483647
    end
    return string.format("%x", hash) .. "_" .. uid
end

-- Guarda username, key Y expiry para que settings.lua pueda leerlos
local function saveCredentials(username, key, expiry)
    if not canSave then return end
    pcall(function()
        writefile(SAVE_FILE, jEncode({
            username = username,
            key      = key,
            expiry   = expiry or "lifetime"
        }))
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

local function fetchKeysData()
    local ok, res = pcall(function()
        return httpRequest({
            Url     = GITHUB_API_KEYS,
            Method  = "GET",
            Headers = {
                ["Accept"]     = "application/vnd.github.v3+json",
                ["User-Agent"] = "serios-gg"
            }
        })
    end)

    if not ok or not res or not res.Body then
        warn("[serios.gg] fetchKeysData: request failed")
        return nil
    end

    local meta = jDecode(res.Body)
    if not meta or not meta.content then
        warn("[serios.gg] fetchKeysData: no content in response")
        return nil
    end

    local b64     = meta.content:gsub("%s+", "")
    local decoded = b64decode(b64)

    if not decoded then
        warn("[serios.gg] fetchKeysData: base64 decode failed")
        return nil
    end

    local data = jDecode(decoded)
    if not data then
        warn("[serios.gg] fetchKeysData: JSON decode failed")
        return nil
    end

    return data
end

-- Convierte ISO date "2025-03-01T12:00:00..." a unix epoch
local function isoToEpoch(isoStr)
    if not isoStr or isoStr == "null" or isoStr == "" then return nil end
    local y, mo, d, h, mi, s = isoStr:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    if not y then return nil end
    return os.time({
        year  = tonumber(y),  month  = tonumber(mo), day = tonumber(d),
        hour  = tonumber(h),  min    = tonumber(mi),  sec = tonumber(s)
    })
end

local function verifyKey(username, key, callback)
    if username == "" or key == "" then
        callback(false, "empty_fields")
        return
    end

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

    -- Expiry check
    local expEpoch = isoToEpoch(entry.expires_at)
    if expEpoch and os.time() > expEpoch then
        callback(false, "key_expired")
        return
    end

    -- Session lock check
    local myToken = getSessionToken()

    if entry.used then
        if entry.session_id and entry.session_id ~= myToken then
            callback(false, "key_already_in_use")
            return
        end
        if entry.username and entry.username ~= username then
            callback(false, "username_mismatch")
            return
        end
        -- Guardar con expiry actualizado
        saveCredentials(username, key, expEpoch and tostring(expEpoch) or "lifetime")
        callback(true, "welcome_back")
        return
    end

    -- Primera vez: guardar con expiry
    saveCredentials(username, key, expEpoch and tostring(expEpoch) or "lifetime")
    callback(true, "verified")
end

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

return {
    verify           = verifyKey,
    loadMain         = loadMainScript,
    loadCredentials  = loadCredentials,
    clearCredentials = clearCredentials,
    saveCredentials  = saveCredentials,
    canSave          = canSave,
    httpReady        = httpRequest ~= nil
}
