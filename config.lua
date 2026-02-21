-- config.lua  ·  serios.gg
-- Sistema de keys propio (GitHub como base de datos)
-- Una key = un usuario = una IP (sesión bloqueada por IP)

local _loadstring = loadstring

local HttpService  = game:GetService("HttpService")

-- ─── CONFIGURACIÓN ────────────────────────────────────────────────────────────
local GITHUB_RAW   = "https://raw.githubusercontent.com/denzells/verified/main/keys.json"
local GITHUB_API   = "https://api.github.com/repos/denzells/verified/contents/keys.json"
local GITHUB_TOKEN = "YOUR_GITHUB_TOKEN"   -- Token con permisos repo (solo lectura es suficiente para verificar)
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/denzells/panel/main/main.lua"
-- ──────────────────────────────────────────────────────────────────────────────

local httpRequest = (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

-- ─── PERSISTENCIA LOCAL ───────────────────────────────────────────────────────
local SAVE_FILE = "serios_saved.json"
local canSave   = typeof(writefile) == "function"
               and typeof(readfile) == "function"
               and typeof(isfile)   == "function"

local function jsonDecode(str)
    local ok, r = pcall(function() return HttpService:JSONDecode(str) end)
    return ok and r or nil
end

local function jsonEncode(t)
    local ok, r = pcall(function() return HttpService:JSONEncode(t) end)
    return ok and r or "{}"
end

local function saveCredentials(username, key)
    if not canSave then return end
    pcall(function()
        writefile(SAVE_FILE, jsonEncode({ username = username, key = key }))
    end)
end

local function loadCredentials()
    if not canSave then return nil, nil end
    local ok, result = pcall(function()
        if not isfile(SAVE_FILE) then return nil end
        return jsonDecode(readfile(SAVE_FILE))
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

-- ─── OBTENER IP PÚBLICA ───────────────────────────────────────────────────────
local function getPublicIP()
    local ok, res = pcall(function()
        return httpRequest({ Url = "https://api.ipify.org?format=json", Method = "GET" })
    end)
    if ok and res and res.Body then
        local data = jsonDecode(res.Body)
        if data and data.ip then return data.ip end
    end
    -- fallback
    local ok2, res2 = pcall(function()
        return httpRequest({ Url = "https://icanhazip.com", Method = "GET" })
    end)
    if ok2 and res2 and res2.Body then
        return res2.Body:gsub("%s+", "")
    end
    return "unknown"
end

-- ─── DESCARGAR KEYS DESDE GITHUB ─────────────────────────────────────────────
local function fetchKeysDB()
    -- Usamos la API de GitHub para tener el SHA y poder actualizar
    local ok, res = pcall(function()
        return httpRequest({
            Url     = GITHUB_API,
            Method  = "GET",
            Headers = {
                ["Authorization"] = "token " .. GITHUB_TOKEN,
                ["Accept"]        = "application/vnd.github.v3+json",
            }
        })
    end)
    if not ok or not res or not res.Body then return nil, nil end
    local meta = jsonDecode(res.Body)
    if not meta or not meta.content then return nil, nil end

    -- Decodificar base64
    local b64content = meta.content:gsub("%s", "")  -- quitar saltos de línea del base64
    local decoded
    local decOk = pcall(function()
        -- Roblox tiene base64 nativo en algunos ejecutores
        if typeof(base64) == "table" and base64.decode then
            decoded = base64.decode(b64content)
        else
            -- decodificación manual base64
            local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            local b64lookup = {}
            for i = 1, #b64chars do b64lookup[b64chars:sub(i,i)] = i-1 end
            local bytes = {}
            for i = 1, #b64content, 4 do
                local c1,c2,c3,c4 = b64content:sub(i,i), b64content:sub(i+1,i+1), b64content:sub(i+2,i+2), b64content:sub(i+3,i+3)
                local n = (b64lookup[c1] or 0)*262144 + (b64lookup[c2] or 0)*4096 + (b64lookup[c3] or 0)*64 + (b64lookup[c4] or 0)
                bytes[#bytes+1] = string.char(math.floor(n/65536) % 256)
                if c3 ~= "=" then bytes[#bytes+1] = string.char(math.floor(n/256) % 256) end
                if c4 ~= "=" then bytes[#bytes+1] = string.char(n % 256) end
            end
            decoded = table.concat(bytes)
        end
    end)
    if not decOk or not decoded then return nil, nil end

    local keysDB = jsonDecode(decoded)
    return keysDB, meta.sha
end

-- ─── SUBIR KEYS ACTUALIZADAS A GITHUB ────────────────────────────────────────
local function pushKeysDB(keysDB, sha)
    local content = jsonEncode(keysDB)
    -- Codificar en base64
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local encoded = {}
    for i = 1, #content, 3 do
        local b1 = content:byte(i) or 0
        local b2 = content:byte(i+1) or 0
        local b3 = content:byte(i+2) or 0
        local n = b1*65536 + b2*256 + b3
        encoded[#encoded+1] = b64chars:sub(math.floor(n/262144)%64+1, math.floor(n/262144)%64+1)
        encoded[#encoded+1] = b64chars:sub(math.floor(n/4096)%64+1,   math.floor(n/4096)%64+1)
        encoded[#encoded+1] = (i+1 <= #content) and b64chars:sub(math.floor(n/64)%64+1, math.floor(n/64)%64+1) or "="
        encoded[#encoded+1] = (i+2 <= #content) and b64chars:sub(n%64+1, n%64+1) or "="
    end
    local b64encoded = table.concat(encoded)

    local payload = jsonEncode({
        message = "session update",
        content = b64encoded,
        sha     = sha
    })

    local ok, res = pcall(function()
        return httpRequest({
            Url     = GITHUB_API,
            Method  = "PUT",
            Headers = {
                ["Authorization"] = "token " .. GITHUB_TOKEN,
                ["Content-Type"]  = "application/json",
                ["Accept"]        = "application/vnd.github.v3+json",
            },
            Body = payload
        })
    end)
    return ok and res and (res.StatusCode == 200 or res.StatusCode == 201)
end

-- ─── VERIFICACIÓN PRINCIPAL ───────────────────────────────────────────────────
local function verifyKey(username, key, callback)
    if username == "" or key == "" then
        callback(false, "empty_fields")
        return
    end

    -- 1. Obtener IP pública del cliente
    local clientIP = getPublicIP()

    -- 2. Descargar la base de datos de keys
    local keysDB, sha = fetchKeysDB()
    if not keysDB then
        callback(false, "connection_error")
        return
    end

    -- 3. Buscar la key
    local keyData = keysDB[key]
    if not keyData then
        callback(false, "invalid_key")
        return
    end

    -- 4. Verificar que el username coincide (si fue asignada a alguien)
    if keyData.username and keyData.username ~= "" then
        if keyData.username ~= username then
            callback(false, "username_mismatch")
            return
        end
    end

    -- 5. Verificar expiración
    -- expires_at viene en formato ISO 8601: "2025-03-01T12:00:00+00:00"
    -- Roblox no tiene un parser ISO fácil, así que comparamos con os.time si está disponible
    -- Si no, simplemente confiamos en el flag 'used'
    -- (Para mayor seguridad, el bot de Discord puede marcar expired=true cuando caduque)
    if keyData.expired == true then
        callback(false, "key_expired")
        return
    end

    -- 6. Verificar sesión bloqueada por IP
    local session = keyData.session or {}
    if keyData.used == true then
        local lockedIP = session.ip
        if lockedIP and lockedIP ~= "" and lockedIP ~= "unknown" then
            if clientIP ~= lockedIP then
                -- Otra IP intenta usar esta key → denegado
                callback(false, "session_locked:" .. lockedIP)
                return
            else
                -- Misma IP → permitir re-login (ya estaba autenticado)
                saveCredentials(username, key)
                callback(true, "session_resumed")
                return
            end
        end
    end

    -- 7. Primera vez usando la key → registrar sesión
    keyData.used = true
    keyData.username = username   -- vincular username si no tenía
    keyData.session = {
        ip       = clientIP,
        used_by  = username,
        used_at  = os.date and os.date("!%Y-%m-%dT%H:%M:%SZ") or "unknown",
        hwid     = game:GetService("RbxAnalyticsService") and tostring(game:GetService("RbxAnalyticsService"):GetClientId()) or "unknown"
    }
    keysDB[key] = keyData

    -- 8. Guardar la sesión en GitHub
    local pushed = pushKeysDB(keysDB, sha)
    if not pushed then
        -- Aunque no se pudo guardar en GitHub, igual dejamos pasar
        -- para no bloquear al usuario legítimo (podría ser lag de GitHub)
        warn("[serios.gg] Warning: no se pudo registrar sesión en GitHub")
    end

    saveCredentials(username, key)
    callback(true, "verified")
end

-- ─── CARGAR SCRIPT PRINCIPAL ──────────────────────────────────────────────────
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
    canSave          = canSave,
    httpReady        = httpRequest ~= nil
}
