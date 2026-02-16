-- PANEL DE VERIFICACIÓN — UI
-- Archivo: ui.lua

-- ══════════════════════════════════════════
--   CARGAR CONFIG DESDE GITHUB
-- ══════════════════════════════════════════
local CONFIG_URL = "https://raw.githubusercontent.com/denzells/verified/main/config.lua"

local Config
local configOk, configErr = pcall(function()
    Config = loadstring(game:HttpGet(CONFIG_URL))()
end)

if not configOk or not Config then
    warn("[serios.gg] No se pudo cargar config.lua: " .. tostring(configErr))
    return
end

if not Config.httpReady then
    warn("[serios.gg] HTTP no disponible en este executor.")
    return
end

-- ══════════════════════════════════════════
--   SERVICIOS
-- ══════════════════════════════════════════
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer

-- ══════════════════════════════════════════
--   COLORES
-- ══════════════════════════════════════════
local C = {
    WIN    = Color3.fromRGB(12, 12, 12),
    TBAR   = Color3.fromRGB(8, 8, 8),
    LINE   = Color3.fromRGB(42, 42, 42),
    RED    = Color3.fromRGB(205, 30, 30),
    WHITE  = Color3.fromRGB(235, 235, 235),
    GRAY   = Color3.fromRGB(110, 110, 110),
    MUTED  = Color3.fromRGB(55, 55, 55),
    INPUT  = Color3.fromRGB(18, 18, 18),
    GREEN  = Color3.fromRGB(50, 200, 80),
    YELLOW = Color3.fromRGB(255, 200, 50),
    SAVED  = Color3.fromRGB(50, 150, 255), -- azul para indicar datos guardados
}

-- ══════════════════════════════════════════
--   UTILIDADES
-- ══════════════════════════════════════════
local function mk(cls, props, parent)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do
        pcall(function() obj[k] = v end)
    end
    if parent then obj.Parent = parent end
    return obj
end

local function rnd(radius, parent)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function tween(obj, time, props, easing, direction)
    local info = TweenInfo.new(
        time,
        easing    or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ══════════════════════════════════════════
--   CREAR GUI BASE
-- ══════════════════════════════════════════
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then return end

local old = PlayerGui:FindFirstChild("PanelBase")
if old then old:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name             = "PanelBase"
SG.ResetOnSpawn     = false
SG.IgnoreGuiInset   = true
SG.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
SG.Parent           = PlayerGui

-- ══════════════════════════════════════════
--   VENTANA PRINCIPAL
-- ══════════════════════════════════════════
local WW, WH = 320, 280   -- un poco más alto para el indicador de guardado
local TH = 42

local Win = mk("Frame", {
    Size                   = UDim2.new(0, WW, 0, WH),
    Position               = UDim2.new(0.5, -WW/2, 0.5, -WH/2),
    BackgroundColor3       = C.WIN,
    BackgroundTransparency = 0.15,
    BorderSizePixel        = 0,
    ClipsDescendants       = false,
    ZIndex                 = 3,
}, SG)
rnd(14, Win)

local WinStroke = mk("UIStroke", {
    Color        = C.LINE,
    Thickness    = 1,
    Transparency = 0.4
}, Win)

-- ══════════════════════════════════════════
--   TITLEBAR
-- ══════════════════════════════════════════
local TBar = mk("Frame", {
    Size                   = UDim2.new(1, 0, 0, TH),
    BackgroundColor3       = C.TBAR,
    BackgroundTransparency = 0.1,
    BorderSizePixel        = 0,
    ZIndex                 = 6,
    ClipsDescendants       = false,
    Active                 = true,
}, Win)
rnd(14, TBar)

mk("Frame", {
    Size                   = UDim2.new(1, 0, 0, 14),
    Position               = UDim2.new(0, 0, 1, -14),
    BackgroundColor3       = C.TBAR,
    BackgroundTransparency = 0.1,
    BorderSizePixel        = 0,
    ZIndex                 = 5,
    Active                 = false,
}, TBar)

local rdot = mk("Frame", {
    Size             = UDim2.new(0, 10, 0, 10),
    Position         = UDim2.new(0, 14, 0.5, -5),
    BackgroundColor3 = C.RED,
    BorderSizePixel  = 0,
    ZIndex           = 8
}, TBar)
rnd(5, rdot)

local title1 = mk("TextLabel", {
    Text                   = "serios.gg",
    Font                   = Enum.Font.GothamBold,
    TextSize               = 13,
    TextColor3             = C.WHITE,
    BackgroundTransparency = 1,
    Size                   = UDim2.new(0, 100, 0, TH),
    Position               = UDim2.new(0, 30, 0, 0),
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 8
}, TBar)

local title2 = mk("TextLabel", {
    Text                   = "|",
    Font                   = Enum.Font.GothamBold,
    TextSize               = 16,
    TextColor3             = C.RED,
    BackgroundTransparency = 1,
    Size                   = UDim2.new(0, 14, 0, TH),
    Position               = UDim2.new(0, 133, 0, 0),
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 8
}, TBar)

-- ══════════════════════════════════════════
--   BOTONES MINIMIZE / CLOSE
-- ══════════════════════════════════════════
local MinB = mk("TextButton", {
    Text                   = "─",
    Font                   = Enum.Font.GothamBold,
    TextSize               = 16,
    TextColor3             = C.GRAY,
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    Size                   = UDim2.new(0, 36, 0, TH),
    Position               = UDim2.new(0, WW-72, 0, 0),
    ZIndex                 = 8,
    AutoButtonColor        = false
}, TBar)

local ClsB = mk("TextButton", {
    Text                   = "×",
    Font                   = Enum.Font.GothamBold,
    TextSize               = 22,
    TextColor3             = C.GRAY,
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    Size                   = UDim2.new(0, 36, 0, TH),
    Position               = UDim2.new(0, WW-36, 0, 0),
    ZIndex                 = 8,
    AutoButtonColor        = false
}, TBar)

ClsB.MouseEnter:Connect(function() tween(ClsB, 0.1, {TextColor3 = C.RED}) end)
ClsB.MouseLeave:Connect(function() tween(ClsB, 0.1, {TextColor3 = C.GRAY}) end)
MinB.MouseEnter:Connect(function() tween(MinB, 0.1, {TextColor3 = C.WHITE}) end)
MinB.MouseLeave:Connect(function() tween(MinB, 0.1, {TextColor3 = C.GRAY}) end)

-- ══════════════════════════════════════════
--   BODY
-- ══════════════════════════════════════════
local Body = mk("Frame", {
    Size                   = UDim2.new(1, -40, 1, -TH-60),
    Position               = UDim2.new(0, 20, 0, TH+20),
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    ZIndex                 = 4,
}, Win)

-- ══════════════════════════════════════════
--   INPUTS
-- ══════════════════════════════════════════
local function CreateInput(parent, labelText, yPos, isPassword)
    local container = mk("Frame", {
        Size                   = UDim2.new(1, 0, 0, 56),
        Position               = UDim2.new(0, 0, 0, yPos),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ZIndex                 = 5
    }, parent)

    mk("TextLabel", {
        Text                   = labelText,
        Font                   = Enum.Font.GothamSemibold,
        TextSize               = 10,
        TextColor3             = C.WHITE,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 16),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 6
    }, container)

    local inputBg = mk("Frame", {
        Size                   = UDim2.new(1, 0, 0, 34),
        Position               = UDim2.new(0, 0, 0, 20),
        BackgroundColor3       = C.INPUT,
        BackgroundTransparency = 0.2,
        BorderSizePixel        = 0,
        ZIndex                 = 6
    }, container)
    rnd(6, inputBg)
    mk("UIStroke", {Color = C.LINE, Thickness = 1, Transparency = 0.6}, inputBg)

    local input = mk("TextBox", {
        Text                   = "",
        Font                   = Enum.Font.Gotham,
        TextSize               = 11,
        TextColor3             = C.WHITE,
        PlaceholderText        = labelText,
        PlaceholderColor3      = C.MUTED,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -16, 1, 0),
        Position               = UDim2.new(0, 8, 0, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ClearTextOnFocus       = false,
        ZIndex                 = 7
    }, inputBg)

    local realText = ""

    if isPassword then
        input.TextEditable = true
        input.FocusLost:Connect(function()
            input.Text = string.rep("•", #realText)
        end)
        input:GetPropertyChangedSignal("Text"):Connect(function()
            if input:IsFocused() then
                realText = input.Text
            end
        end)
    end

    input.Focused:Connect(function()
        tween(inputBg, 0.15, {BackgroundColor3 = Color3.fromRGB(22,22,22), BackgroundTransparency = 0.1})
        local stroke = inputBg:FindFirstChildOfClass("UIStroke")
        if stroke then tween(stroke, 0.15, {Color = C.RED, Transparency = 0.4}) end
    end)

    input.FocusLost:Connect(function()
        tween(inputBg, 0.15, {BackgroundColor3 = C.INPUT, BackgroundTransparency = 0.2})
        local stroke = inputBg:FindFirstChildOfClass("UIStroke")
        if stroke then tween(stroke, 0.15, {Color = C.LINE, Transparency = 0.6}) end
    end)

    local function getRealText()
        return isPassword and realText or input.Text
    end

    -- Función para rellenar desde fuera (auto-fill)
    local function fill(text)
        if isPassword then
            realText   = text
            input.Text = string.rep("•", #text)
        else
            input.Text = text
        end
    end

    return input, container, getRealText, inputBg, fill
end

local usernameInput, userContainer, getUsernameText, userBg, fillUsername = CreateInput(Body, "Username", 0,  false)
local keyInput,      keyContainer,  getKeyText,      keyBg,  fillKey      = CreateInput(Body, "Key",      66, true)

-- ══════════════════════════════════════════
--   INDICADOR "DATOS GUARDADOS"
-- ══════════════════════════════════════════
-- Pequeño badge que aparece si se cargaron datos guardados
local savedBadge = mk("Frame", {
    Size                   = UDim2.new(0, 110, 0, 20),
    Position               = UDim2.new(0, 0, 0, 130),
    BackgroundColor3       = Color3.fromRGB(20, 20, 20),
    BackgroundTransparency = 0.3,
    BorderSizePixel        = 0,
    ZIndex                 = 6,
    Visible                = false,
}, Body)
rnd(5, savedBadge)
mk("UIStroke", {Color = C.SAVED, Thickness = 1, Transparency = 0.5}, savedBadge)

mk("TextLabel", {
    Text                   = "● Datos guardados",
    Font                   = Enum.Font.GothamSemibold,
    TextSize               = 9,
    TextColor3             = C.SAVED,
    BackgroundTransparency = 1,
    Size                   = UDim2.new(1, -8, 1, 0),
    Position               = UDim2.new(0, 8, 0, 0),
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 7
}, savedBadge)

-- Botón pequeño para borrar datos guardados (×)
local clearBtn = mk("TextButton", {
    Text                   = "×",
    Font                   = Enum.Font.GothamBold,
    TextSize               = 12,
    TextColor3             = C.GRAY,
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    Size                   = UDim2.new(0, 20, 1, 0),
    Position               = UDim2.new(1, -20, 0, 0),
    ZIndex                 = 8,
    AutoButtonColor        = false,
}, savedBadge)

-- ══════════════════════════════════════════
--   BOTÓN VERIFY
-- ══════════════════════════════════════════
local verifyBtn = mk("TextButton", {
    Text                   = "Verify",
    Font                   = Enum.Font.GothamBold,
    TextSize               = 11,
    TextColor3             = C.WHITE,
    BackgroundColor3       = C.RED,
    BackgroundTransparency = 0.1,
    BorderSizePixel        = 0,
    ZIndex                 = 6,
    Size                   = UDim2.new(0.5, -5, 0, 34),
    Position               = UDim2.new(0.25, 0, 0, 162),
    AutoButtonColor        = false
}, Body)
rnd(6, verifyBtn)
mk("UIStroke", {Color = Color3.fromRGB(255,50,50), Thickness = 1, Transparency = 0.4}, verifyBtn)

-- ══════════════════════════════════════════
--   STATUS CIRCLES (titlebar)
-- ══════════════════════════════════════════
local statusContainer = mk("Frame", {
    Size                   = UDim2.new(0, 46, 0, 10),
    Position               = UDim2.new(0, 149, 0.5, -5),
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    ZIndex                 = 8
}, TBar)

local circles = {}
for i = 1, 3 do
    local circle = mk("Frame", {
        Size                   = UDim2.new(0, 10, 0, 10),
        Position               = UDim2.new(0, (i-1)*18, 0, 0),
        BackgroundColor3       = C.WHITE,
        BackgroundTransparency = 0.3,
        BorderSizePixel        = 0,
        ZIndex                 = 9
    }, statusContainer)
    rnd(5, circle)
    circles[i] = circle
end

local function resetCircles()
    for _, circle in ipairs(circles) do
        tween(circle, 0.2, {BackgroundColor3 = C.WHITE, BackgroundTransparency = 0.3})
    end
end

local function animateCircles(color)
    for i, circle in ipairs(circles) do
        task.delay((i-1) * 0.08, function()
            tween(circle, 0.3, {BackgroundColor3 = color, BackgroundTransparency = 0})
        end)
    end
    task.delay(1, resetCircles)
end

-- ══════════════════════════════════════════
--   AUTO-FILL CON CREDENCIALES GUARDADAS
-- ══════════════════════════════════════════
local hasSavedData = false

local function tryLoadSaved()
    local savedUser, savedKey = Config.loadCredentials()
    if savedUser and savedKey and savedUser ~= "" and savedKey ~= "" then
        fillUsername(savedUser)
        fillKey(savedKey)
        hasSavedData    = true
        savedBadge.Visible = true

        -- Resaltar los inputs en azul para indicar que están auto-rellenados
        local userStroke = userBg:FindFirstChildOfClass("UIStroke")
        local keyStroke  = keyBg:FindFirstChildOfClass("UIStroke")
        if userStroke then tween(userStroke, 0.4, {Color = C.SAVED, Transparency = 0.3}) end
        if keyStroke  then tween(keyStroke,  0.4, {Color = C.SAVED, Transparency = 0.3}) end

        -- Volver al color normal tras 2s
        task.delay(2, function()
            if userStroke then tween(userStroke, 0.4, {Color = C.LINE, Transparency = 0.6}) end
            if keyStroke  then tween(keyStroke,  0.4, {Color = C.LINE, Transparency = 0.6}) end
        end)
    end
end

-- Botón para limpiar datos guardados
clearBtn.MouseButton1Click:Connect(function()
    Config.clearCredentials()
    hasSavedData = false

    -- Limpiar campos
    usernameInput.Text = ""
    keyInput.Text      = ""

    -- Ocultar badge
    tween(savedBadge, 0.2, {BackgroundTransparency = 1})
    task.delay(0.2, function() savedBadge.Visible = false end)
end)

clearBtn.MouseEnter:Connect(function() tween(clearBtn, 0.1, {TextColor3 = C.RED}) end)
clearBtn.MouseLeave:Connect(function() tween(clearBtn, 0.1, {TextColor3 = C.GRAY}) end)

-- ══════════════════════════════════════════
--   LÓGICA DEL BOTÓN VERIFY
-- ══════════════════════════════════════════
verifyBtn.MouseButton1Click:Connect(function()
    local username = getUsernameText()
    local key      = getKeyText()

    tween(verifyBtn, 0.08, {Size = UDim2.new(0.5, -9, 0, 30)})
    task.delay(0.08, function()
        tween(verifyBtn, 0.12, {Size = UDim2.new(0.5, -5, 0, 34)})
    end)

    verifyBtn.Active = false
    verifyBtn.Text   = "Verifying..."

    Config.verify(username, key, function(success, message)
        verifyBtn.Active = true
        verifyBtn.Text   = "Verify"

        if username == "" or key == "" then
            animateCircles(C.RED)
        elseif success then
            animateCircles(C.GREEN)
            -- Las credenciales ya se guardan dentro de config.verify()
            task.delay(2, function()
                SG:Destroy()
                Config.loadMain()
            end)
        else
            -- Key inválida: borrar datos guardados para no rellenar basura la próxima vez
            if hasSavedData then
                Config.clearCredentials()
                hasSavedData       = false
                savedBadge.Visible = false
            end
            animateCircles(C.YELLOW)
        end
    end)
end)

-- ══════════════════════════════════════════
--   SISTEMA DE DRAG
-- ══════════════════════════════════════════
do
    local dragging = false
    local mStart   = Vector2.new()
    local wStart   = Vector2.new()

    local DragHit = mk("TextButton", {
        Text                   = "",
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, -72, 1, 0),
        Position               = UDim2.new(0, 0, 0, 0),
        ZIndex                 = 50,
        AutoButtonColor        = false,
    }, TBar)

    DragHit.MouseButton1Down:Connect(function()
        local mp = UIS:GetMouseLocation()
        dragging = true
        mStart   = mp
        wStart   = Vector2.new(Win.Position.X.Offset, Win.Position.Y.Offset)
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mp = UIS:GetMouseLocation()
        local d  = mp - mStart
        local tx = wStart.X + d.X
        local ty = wStart.Y + d.Y
        local cx = Win.Position.X.Offset
        local cy = Win.Position.Y.Offset
        local nx = cx + (tx - cx) * 0.5
        local ny = cy + (ty - cy) * 0.5
        if math.abs(nx - tx) < 0.3 then nx = tx end
        if math.abs(ny - ty) < 0.3 then ny = ty end
        Win.Position = UDim2.new(0.5, nx, 0.5, ny)
    end)
end

-- ══════════════════════════════════════════
--   ANIMACIÓN DE BODY (show/hide)
-- ══════════════════════════════════════════
local function animateBodyElements(show)
    local targetT = show and 0 or 1

    local function animLabels(container)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("TextLabel") then
                tween(child, 0.2, {TextTransparency = targetT})
            end
        end
    end

    local function animInputBg(container)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") then
                tween(child, 0.2, {BackgroundTransparency = show and 0.2 or 1})
                local stroke = child:FindFirstChildOfClass("UIStroke")
                if stroke then
                    tween(stroke, 0.2, {Transparency = show and 0.6 or 1})
                end
                local textbox = child:FindFirstChildOfClass("TextBox")
                if textbox then
                    tween(textbox, 0.2, {
                        TextTransparency  = targetT,
                        PlaceholderColor3 = show and C.MUTED or Color3.fromRGB(0,0,0)
                    })
                end
            end
        end
    end

    animLabels(userContainer)
    animLabels(keyContainer)
    animInputBg(userContainer)
    animInputBg(keyContainer)

    -- Badge de guardado
    if hasSavedData and savedBadge.Visible then
        tween(savedBadge, 0.2, {BackgroundTransparency = show and 0.3 or 1})
        local badgeLabel = savedBadge:FindFirstChildOfClass("TextLabel")
        if badgeLabel then tween(badgeLabel, 0.2, {TextTransparency = targetT}) end
        tween(clearBtn, 0.2, {TextTransparency = targetT})
    end

    tween(verifyBtn, 0.2, {
        BackgroundTransparency = show and 0.1 or 1,
        TextTransparency       = targetT,
        Size = show
            and UDim2.new(0.5, -5, 0, 34)
            or  UDim2.new(0.5, -5, 0, 0)
    })

    local btnStroke = verifyBtn:FindFirstChildOfClass("UIStroke")
    if btnStroke then
        tween(btnStroke, 0.2, {Transparency = show and 0.4 or 1})
    end
end

-- ══════════════════════════════════════════
--   MINIMIZE / CLOSE
-- ══════════════════════════════════════════
local minimized = false
local animating = false

MinB.MouseButton1Click:Connect(function()
    if animating then return end
    animating = true
    minimized = not minimized

    if minimized then
        animateBodyElements(false)
        tween(Body,      0.3,  {Size = UDim2.new(1, -40, 0, 0)},                                        Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(Win,       0.3,  {Size = UDim2.new(0, WW, 0, TH), BackgroundTransparency = 0.15},         Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(WinStroke, 0.25, {Transparency = 0.5})
        tween(title1,    0.2,  {TextTransparency = 0.5})
        task.delay(0.35, function() animating = false end)
    else
        tween(Win,       0.35, {Size = UDim2.new(0, WW, 0, WH), BackgroundTransparency = 0.15},         Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(Body,      0.35, {Size = UDim2.new(1, -40, 1, -TH-60)},                                   Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(WinStroke, 0.3,  {Transparency = 0.4})
        tween(title1,    0.25, {TextTransparency = 0})
        task.delay(0.15, function() animateBodyElements(true) end)
        task.delay(0.5,  function() animating = false end)
    end

    MinB.Text = minimized and "□" or "─"
end)

local function doClose()
    if animating then return end
    animating   = true
    Win.Active  = false

    animateBodyElements(false)
    tween(Body,   0.3,  {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0,TH)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(rdot,   0.2,  {BackgroundTransparency = 1})
    tween(title1, 0.2,  {TextTransparency = 1})
    tween(title2, 0.2,  {TextTransparency = 1})
    tween(MinB,   0.2,  {TextTransparency = 1})
    tween(ClsB,   0.2,  {TextTransparency = 1})

    for _, circle in ipairs(circles) do
        tween(circle, 0.2, {BackgroundTransparency = 1})
    end

    task.delay(0.4, function()
        tween(Win,       0.35, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(WinStroke, 0.3,  {Transparency = 1})
    end)
    task.delay(0.8, function() SG:Destroy() end)
end

ClsB.MouseButton1Click:Connect(doClose)

-- ══════════════════════════════════════════
--   HOTKEYS
-- ══════════════════════════════════════════
local hidden = false
UIS.InputBegan:Connect(function(i, gp)
    if gp or animating then return end

    if i.KeyCode == Enum.KeyCode.RightShift then
        hidden = not hidden
        if hidden then
            tween(Win,       0.2, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine)
            tween(WinStroke, 0.2, {Transparency = 1})
            animateBodyElements(false)
            for _, circle in ipairs(circles) do
                tween(circle, 0.2, {BackgroundTransparency = 1})
            end
            task.delay(0.2, function() Win.Visible = false end)
        else
            Win.Visible                = true
            Win.BackgroundTransparency = 1
            WinStroke.Transparency     = 1
            tween(Win,       0.25, {BackgroundTransparency = 0.15}, Enum.EasingStyle.Sine)
            tween(WinStroke, 0.25, {Transparency = 0.4})
            for _, circle in ipairs(circles) do
                tween(circle, 0.25, {BackgroundTransparency = 0.3})
            end
            task.delay(0.15, function() animateBodyElements(true) end)
        end
    end

    if i.KeyCode == Enum.KeyCode.End then
        doClose()
    end
end)

-- ══════════════════════════════════════════
--   ANIMACIÓN DE APERTURA
-- ══════════════════════════════════════════
Win.Size                   = UDim2.new(0, WW/3, 0, TH)
Win.BackgroundTransparency = 1
WinStroke.Transparency     = 1
Body.Size                  = UDim2.new(1, -40, 0, 0)
Body.Position              = UDim2.new(0, 20, 0, TH+20)
rdot.BackgroundTransparency  = 1
title1.TextTransparency    = 1
title2.TextTransparency    = 1
MinB.TextTransparency      = 1
ClsB.TextTransparency      = 1

for _, circle in ipairs(circles) do
    circle.BackgroundTransparency = 1
end
animateBodyElements(false)

tween(Win,       0.4,  {Size = UDim2.new(0, WW, 0, TH), BackgroundTransparency = 0.15}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
tween(WinStroke, 0.35, {Transparency = 0.4})

task.delay(0.1, function()
    tween(rdot,   0.3, {BackgroundTransparency = 0},   Enum.EasingStyle.Sine)
    task.delay(0.05, function() tween(title1, 0.3, {TextTransparency = 0}, Enum.EasingStyle.Sine) end)
    task.delay(0.08, function() tween(title2, 0.3, {TextTransparency = 0}, Enum.EasingStyle.Sine) end)
    task.delay(0.11, function()
        for i, circle in ipairs(circles) do
            task.delay((i-1)*0.05, function()
                tween(circle, 0.25, {BackgroundTransparency = 0.3}, Enum.EasingStyle.Sine)
            end)
        end
    end)
    task.delay(0.2, function()
        tween(MinB, 0.25, {TextTransparency = 0}, Enum.EasingStyle.Sine)
        tween(ClsB, 0.25, {TextTransparency = 0}, Enum.EasingStyle.Sine)
    end)
end)

task.delay(0.25, function()
    tween(Win,  0.45, {Size = UDim2.new(0, WW, 0, WH), BackgroundTransparency = 0.15}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(Body, 0.45, {Size = UDim2.new(1, -40, 1, -TH-60)},                           Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    task.delay(0.3, function()
        animateBodyElements(true)
        -- Intentar cargar credenciales guardadas una vez que el panel es visible
        task.delay(0.2, tryLoadSaved)
    end)
end)
