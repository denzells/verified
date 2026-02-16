-- CONFIGURACIÓN KEYAUTH + LOADER + GUARDADO DE CREDENCIALES
-- Archivo: config.lua

local HttpService = game:GetService("HttpService")

-- ══════════════════════════════════════════
--   KEYAUTH CONFIG
-- ══════════════════════════════════════════
local KeyAuthConfig = {
    Name    = "serios.gg",
    OwnerID = "UPGTkUDkee",
    Version = "1.0"
}
local KeyAuthURL = "https://keyauth.win/api/1.2/"

-- ══════════════════════════════════════════
--   LOADER
-- ══════════════════════════════════════════
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/denzells/panel/main/main.lua"

-- ══════════════════════════════════════════
--   HTTP REQUEST (compatibilidad multi-executor)
-- ══════════════════════════════════════════
local httpRequest = (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

-- ══════════════════════════════════════════
--   SISTEMA DE GUARDADO DE CREDENCIALES
-- ══════════════════════════════════════════
local SAVE_FILE = "serios_saved.json"

-- Detectar si el executor soporta writefile/readfile
local canSave = (typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function")

local function saveCredentials(username, key)
    if not canSave then return end
    local ok = pcall(function()
        local data = HttpService:JSONEncode({
            username = username,
            key      = key
        })
        writefile(SAVE_FILE, data)
    end)
    if not ok then
        warn("[serios.gg] No se pudieron guardar las credenciales.")
    end
end

local function loadCredentials()
    if not canSave then
        return nil, nil
    end

    local ok, result = pcall(function()
        if not isfile(SAVE_FILE) then return nil end
        local raw  = readfile(SAVE_FILE)
        local data = HttpService:JSONDecode(raw)
        return data
    end)

    if ok and result and result.username and result.key then
        return result.username, result.key
    end

    return nil, nil
end

local function clearCredentials()
    if not canSave then return end
    pcall(function()
        if isfile(SAVE_FILE) then
            writefile(SAVE_FILE, "{}")
        end
    end)
end

-- ══════════════════════════════════════════
--   FUNCIÓN DE VERIFICACIÓN
-- ══════════════════════════════════════════
local function verifyWithKeyAuth(username, key, callback)
    if username == "" or key == "" then
        callback(false, "empty")
        return
    end

    -- Paso 1: Inicializar sesión
    local initBody = "type=init"
        .. "&name="    .. KeyAuthConfig.Name
        .. "&ownerid=" .. KeyAuthConfig.OwnerID
        .. "&version=" .. KeyAuthConfig.Version

    local initOk, initRes = pcall(function()
        return httpRequest({
            Url     = KeyAuthURL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
            Body    = initBody
        })
    end)

    if not initOk or not initRes or not initRes.Body then
        callback(false, "connection_error")
        return
    end

    local initData
    local parseOk = pcall(function()
        initData = HttpService:JSONDecode(initRes.Body)
    end)

    if not parseOk or not initData.success or not initData.sessionid then
        callback(false, "init_failed")
        return
    end

    -- Paso 2: Login con username + key
    local loginBody = "type=login"
        .. "&username=" .. username
        .. "&pass="     .. key
        .. "&sessionid=" .. initData.sessionid
        .. "&name="     .. KeyAuthConfig.Name
        .. "&ownerid="  .. KeyAuthConfig.OwnerID

    local loginOk, loginRes = pcall(function()
        return httpRequest({
            Url     = KeyAuthURL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
            Body    = loginBody
        })
    end)

    if not loginOk or not loginRes or not loginRes.Body then
        callback(false, "connection_error")
        return
    end

    local loginData
    parseOk = pcall(function()
        loginData = HttpService:JSONDecode(loginRes.Body)
    end)

    if not parseOk then
        callback(false, "parse_error")
        return
    end

    -- Si el login fue exitoso, guardar credenciales
    if loginData.success then
        saveCredentials(username, key)
    end

    callback(loginData.success, loginData.message or (loginData.success and "Verified" or "invalid"))
end

-- ══════════════════════════════════════════
--   FUNCIÓN DE CARGA
-- ══════════════════════════════════════════
local function loadMainScript()
    local ok, err = pcall(function()
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
    end)
    if not ok then
        warn("[serios.gg] Error al cargar main.lua: " .. tostring(err))
    end
end

-- ══════════════════════════════════════════
--   EXPORTS
-- ══════════════════════════════════════════
return {
    verify           = verifyWithKeyAuth,
    loadMain         = loadMainScript,
    loadCredentials  = loadCredentials,
    clearCredentials = clearCredentials,
    canSave          = canSave,
    httpReady        = httpRequest ~= nil
}
