-- CONFIGURACIÓN DE KEYAUTH
local KeyAuthConfig = {
    Name = "serios.gg",
    OwnerID = "UPGTkUDkee",
    Version = "1.0"
}

local KeyAuthURL = "https://keyauth.win/api/1.2/"

-- Función de verificación (SIN loadstring)
local function verifyWithKeyAuth(username, key, callback, httpRequest, HttpService)
    if username == "" or key == "" then
        callback(false, "empty")
        return
    end
    
    -- Inicializar
    local initData = "type=init&name=" .. KeyAuthConfig.Name .. "&ownerid=" .. KeyAuthConfig.OwnerID .. "&version=" .. KeyAuthConfig.Version
    
    local initSuccess, initResponse = pcall(function()
        return httpRequest({
            Url = KeyAuthURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
            Body = initData
        })
    end)
    
    if not initSuccess or not initResponse or not initResponse.Body then
        callback(false, "connection_error")
        return
    end
    
    local initData
    local parseSuccess = pcall(function()
        initData = HttpService:JSONDecode(initResponse.Body)
    end)
    
    if not parseSuccess or not initData.success or not initData.sessionid then
        callback(false, "init_failed")
        return
    end
    
    -- Login
    local loginData = "type=login&username=" .. username .. "&pass=" .. key .. "&sessionid=" .. initData.sessionid .. "&name=" .. KeyAuthConfig.Name .. "&ownerid=" .. KeyAuthConfig.OwnerID
    
    local loginSuccess, loginResponse = pcall(function()
        return httpRequest({
            Url = KeyAuthURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
            Body = loginData
        })
    end)
    
    if not loginSuccess or not loginResponse or not loginResponse.Body then
        callback(false, "connection_error")
        return
    end
    
    local loginData
    parseSuccess = pcall(function()
        loginData = HttpService:JSONDecode(loginResponse.Body)
    end)
    
    if not parseSuccess then
        callback(false, "parse_error")
        return
    end
    
    callback(loginData.success, loginData.message or (loginData.success and "Verified" or "invalid"))
end

return {
    Config = KeyAuthConfig,
    URL = KeyAuthURL,
    Verify = verifyWithKeyAuth
}
