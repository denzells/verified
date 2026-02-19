-- config.lua
local _loadstring = loadstring  -- captura loadstring del executor ANTES de cualquier pcall

local HttpService = game:GetService("HttpService")

local KeyAuthConfig = {
    Name    = "serios.gg",
    OwnerID = "UPGTkUDkee",
    Version = "1.0"
}
local KeyAuthURL      = "https://keyauth.win/api/1.2/"
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/denzells/panel/main/main.lua"

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local SAVE_FILE = "serios_saved.json"
local canSave   = typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"

local function jsonDecode(str)
    local ok, result = pcall(function() return HttpService:JSONDecode(str) end)
    if ok then return result else return nil end
end

local function saveCredentials(username, key, expiry)
    if not canSave then return end
    pcall(function()
        writefile(SAVE_FILE, HttpService:JSONEncode({
            username = username,
            key      = key,
            expiry   = expiry
        }))
    end)
end

local function loadCredentials()
    if not canSave then return nil, nil end
    local ok, result = pcall(function()
        if not isfile(SAVE_FILE) then return nil end
        return HttpService:JSONDecode(readfile(SAVE_FILE))
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

local function verifyWithKeyAuth(username, key, callback)
    if username == "" or key == "" then
        callback(false, "empty")
        return
    end

    local initOk, initRes = pcall(function()
        return httpRequest({
            Url     = KeyAuthURL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
            Body    = "type=init&name=" .. KeyAuthConfig.Name .. "&ownerid=" .. KeyAuthConfig.OwnerID .. "&version=" .. KeyAuthConfig.Version
        })
    end)

    if not initOk or not initRes or not initRes.Body then
        callback(false, "connection_error")
        return
    end

    local initData = jsonDecode(initRes.Body)
    if not initData then callback(false, "parse_error_init") return end
    if not initData.success then callback(false, "init_failed: " .. tostring(initData.message or "unknown")) return end
    if not initData.sessionid then callback(false, "no_sessionid") return end

    local loginOk, loginRes = pcall(function()
        return httpRequest({
            Url     = KeyAuthURL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
            Body    = "type=login&username=" .. username .. "&pass=" .. key .. "&sessionid=" .. initData.sessionid .. "&name=" .. KeyAuthConfig.Name .. "&ownerid=" .. KeyAuthConfig.OwnerID
        })
    end)

    if not loginOk or not loginRes or not loginRes.Body then
        callback(false, "connection_error")
        return
    end

    local loginData = jsonDecode(loginRes.Body)
    if not loginData then callback(false, "parse_error_login") return end

    if loginData.success then
        local expiry = "N/A"
        if loginData.info and loginData.info.subscriptions and loginData.info.subscriptions[1] then
            expiry = loginData.info.subscriptions[1].expiry or "N/A"
        end
        saveCredentials(username, key, expiry)
    end

    callback(loginData.success, loginData.message or (loginData.success and "Verified" or "invalid"))
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
    verify           = verifyWithKeyAuth,
    loadMain         = loadMainScript,
    loadCredentials  = loadCredentials,
    clearCredentials = clearCredentials,
    canSave          = canSave,
    httpReady        = httpRequest ~= nil
}
