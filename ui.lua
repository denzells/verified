-- VERIFICATION PANEL — UI
-- File: ui.lua

local _loadstring = loadstring  -- captura loadstring del executor ANTES de cualquier pcall

local CONFIG_URL = "https://raw.githubusercontent.com/denzells/verified/main/config.lua"

local Config
local content
local httpOk = pcall(function() content = game:HttpGet(CONFIG_URL) end)
if not httpOk or not content or content == "" then
    warn("[brutality.gg] Failed to download config.lua")
    return
end
local fn, compErr = _loadstring(content)
if not fn then
    warn("[brutality.gg] Failed to compile config.lua: " .. tostring(compErr))
    return
end
local runOk, runResult = pcall(fn)
if not runOk then
    warn("[brutality.gg] Failed to execute config.lua: " .. tostring(runResult))
    return
end
Config = runResult
if not Config then warn("[brutality.gg] config.lua did not return a value") return end
if not Config.httpReady then warn("[brutality.gg] HTTP not available in this executor.") return end

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer

local ICON_USERNAME = "rbxassetid://75066739039083"
local ICON_KEY      = "rbxassetid://126448589402910"

local C = {
    WIN   = Color3.fromRGB(12, 12, 12),
    TBAR  = Color3.fromRGB(8, 8, 8),
    LINE  = Color3.fromRGB(42, 42, 42),
    RED   = Color3.fromRGB(255, 255, 255),
    WHITE = Color3.fromRGB(235, 235, 235),
    GRAY  = Color3.fromRGB(110, 110, 110),
    MUTED = Color3.fromRGB(55, 55, 55),
    INPUT = Color3.fromRGB(18, 18, 18),
    GREEN = Color3.fromRGB(50, 200, 80),
    YELLOW= Color3.fromRGB(255, 200, 50),
    SAVED = Color3.fromRGB(50, 150, 255),
}

local function mk(cls, props, parent)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do pcall(function() obj[k] = v end) end
    if parent then obj.Parent = parent end
    return obj
end

local function rnd(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
end

local function tween(obj, time, props, easing, direction)
    local t = TweenService:Create(obj,
        TweenInfo.new(time, easing or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then return end

local old = PlayerGui:FindFirstChild("PanelBase")
if old then old:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name           = "PanelBase"
SG.ResetOnSpawn   = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent         = PlayerGui

local WW, WH = 320, 280
local TH = 42

local Win = mk("Frame", {
    Size = UDim2.new(0, WW, 0, WH), Position = UDim2.new(0.5, -WW/2, 0.5, -WH/2),
    BackgroundColor3 = C.WIN, BackgroundTransparency = 0,
    BorderSizePixel = 0, ClipsDescendants = false, ZIndex = 3,
}, SG)
rnd(14, Win)

local WinStroke = mk("UIStroke", { Color = C.LINE, Thickness = 1, Transparency = 0 }, Win)

local TBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, TH), BackgroundColor3 = C.TBAR,
    BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 6,
    ClipsDescendants = false, Active = true,
}, Win)
rnd(14, TBar)
mk("Frame", {
    Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = C.TBAR, BackgroundTransparency = 0,
    BorderSizePixel = 0, ZIndex = 5, Active = false,
}, TBar)

local rdot = mk("Frame", {
    Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 14, 0.5, -5),
    BackgroundColor3 = C.RED, BorderSizePixel = 0, ZIndex = 8,
}, TBar)
rnd(5, rdot)

local title1 = mk("TextLabel", {
    Text = "brutality.gg", Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = C.WHITE, BackgroundTransparency = 1,
    Size = UDim2.new(0, 100, 0, TH), Position = UDim2.new(0, 30, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
}, TBar)

local title2 = mk("TextLabel", {
    Text = "|", Font = Enum.Font.GothamBold, TextSize = 16,
    TextColor3 = C.RED, BackgroundTransparency = 1,
    Size = UDim2.new(0, 14, 0, TH), Position = UDim2.new(0, 133, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
}, TBar)

local MinB = mk("TextButton", {
    Text = "─", Font = Enum.Font.GothamBold, TextSize = 16,
    TextColor3 = C.GRAY, BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, 36, 0, TH), Position = UDim2.new(0, WW-72, 0, 0),
    ZIndex = 8, AutoButtonColor = false,
}, TBar)

local ClsB = mk("TextButton", {
    Text = "×", Font = Enum.Font.GothamBold, TextSize = 22,
    TextColor3 = C.GRAY, BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, 36, 0, TH), Position = UDim2.new(0, WW-36, 0, 0),
    ZIndex = 8, AutoButtonColor = false,
}, TBar)

ClsB.MouseEnter:Connect(function() tween(ClsB, 0.1, {TextColor3 = C.RED}) end)
ClsB.MouseLeave:Connect(function() tween(ClsB, 0.1, {TextColor3 = C.GRAY}) end)
MinB.MouseEnter:Connect(function() tween(MinB, 0.1, {TextColor3 = C.WHITE}) end)
MinB.MouseLeave:Connect(function() tween(MinB, 0.1, {TextColor3 = C.GRAY}) end)

local Body = mk("Frame", {
    Size = UDim2.new(1, -40, 1, -TH-60), Position = UDim2.new(0, 20, 0, TH+20),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4,
}, Win)

local function CreateInput(parent, labelText, yPos, isPassword, iconId)
    local container = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 56), Position = UDim2.new(0, 0, 0, yPos),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, parent)
    mk("TextLabel", {
        Text = labelText, Font = Enum.Font.GothamSemibold, TextSize = 10,
        TextColor3 = C.WHITE, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
    }, container)
    local inputBg = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = C.INPUT, BackgroundTransparency = 0.2,
        BorderSizePixel = 0, ZIndex = 6,
    }, container)
    rnd(6, inputBg)
    mk("UIStroke", {Color = C.LINE, Thickness = 1, Transparency = 0.6}, inputBg)

    local iconSize, iconPad = 18, 8
    local icon = mk("ImageLabel", {
        Image = iconId, Size = UDim2.new(0, iconSize, 0, iconSize),
        Position = UDim2.new(0, iconPad, 0.5, -iconSize/2),
        BackgroundTransparency = 1, ImageColor3 = C.MUTED, ZIndex = 8,
    }, inputBg)
    local separator = mk("Frame", {
        Name = "InputSeparator",
        Size = UDim2.new(0, 1, 0, 16), Position = UDim2.new(0, iconPad + iconSize + 6, 0.5, -8),
        BackgroundColor3 = C.LINE, BackgroundTransparency = 0.3,
        BorderSizePixel = 0, ZIndex = 8,
    }, inputBg)
    local textOffsetLeft = iconPad + iconSize + 14
    local input = mk("TextBox", {
        Text = "", Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = C.WHITE, PlaceholderText = labelText,
        PlaceholderColor3 = C.MUTED, BackgroundTransparency = 1,
        Size = UDim2.new(1, -(textOffsetLeft + 8), 1, 0),
        Position = UDim2.new(0, textOffsetLeft, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false, ZIndex = 7,
    }, inputBg)

    local realText = ""
    if isPassword then
        input.TextEditable = true
        input.FocusLost:Connect(function() input.Text = string.rep("•", #realText) end)
        input:GetPropertyChangedSignal("Text"):Connect(function()
            if input:IsFocused() then realText = input.Text end
        end)
    end

    input.Focused:Connect(function()
        tween(inputBg, 0.15, {BackgroundColor3 = Color3.fromRGB(22,22,22), BackgroundTransparency = 0.1})
        tween(icon, 0.15, {ImageColor3 = C.WHITE})
        local stroke = inputBg:FindFirstChildOfClass("UIStroke")
        if stroke then tween(stroke, 0.15, {Color = C.RED, Transparency = 0.4}) end
    end)
    input.FocusLost:Connect(function()
        tween(inputBg, 0.15, {BackgroundColor3 = C.INPUT, BackgroundTransparency = 0.2})
        tween(icon, 0.15, {ImageColor3 = C.MUTED})
        local stroke = inputBg:FindFirstChildOfClass("UIStroke")
        if stroke then tween(stroke, 0.15, {Color = C.LINE, Transparency = 0.6}) end
    end)

    local function getRealText() return isPassword and realText or input.Text end
    local function fill(text)
        if isPassword then realText = text; input.Text = string.rep("•", #text)
        else input.Text = text end
    end
    return input, container, getRealText, inputBg, fill, icon, separator
end

local usernameInput, userContainer, getUsernameText, userBg, fillUsername, userIcon, userSep =
    CreateInput(Body, "Username", 0,  false, ICON_USERNAME)
local keyInput, keyContainer, getKeyText, keyBg, fillKey, keyIcon, keySep =
    CreateInput(Body, "Key",      66, true,  ICON_KEY)

local savedBadge = mk("Frame", {
    Size = UDim2.new(0, 120, 0, 20), Position = UDim2.new(0, 0, 0, 130),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20), BackgroundTransparency = 1,
    BorderSizePixel = 0, ZIndex = 6, Visible = true,
}, Body)
rnd(5, savedBadge)
local savedBadgeStroke = mk("UIStroke", {Color = C.SAVED, Thickness = 1, Transparency = 1}, savedBadge)
local savedBadgeLabel = mk("TextLabel", {
    Text = "● Credentials saved", Font = Enum.Font.GothamSemibold, TextSize = 9,
    TextColor3 = C.SAVED, BackgroundTransparency = 1, TextTransparency = 1,
    Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 8, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
}, savedBadge)
local clearBtn = mk("TextButton", {
    Text = "×", Font = Enum.Font.GothamBold, TextSize = 12,
    TextColor3 = C.GRAY, BackgroundTransparency = 1, TextTransparency = 1,
    BorderSizePixel = 0, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0),
    ZIndex = 8, AutoButtonColor = false,
}, savedBadge)
clearBtn.MouseEnter:Connect(function() tween(clearBtn, 0.1, {TextColor3 = C.RED}) end)
clearBtn.MouseLeave:Connect(function() tween(clearBtn, 0.1, {TextColor3 = C.GRAY}) end)

local verifyBtn = mk("TextButton", {
    Text = "Verify", Font = Enum.Font.GothamBold, TextSize = 11,
    TextColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = C.RED,
    BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 6,
    Size = UDim2.new(0.5, -5, 0, 34), Position = UDim2.new(0.25, 0, 0, 162),
    AutoButtonColor = false,
}, Body)
rnd(6, verifyBtn)
mk("UIStroke", {Color = Color3.fromRGB(200, 200, 200), Thickness = 1, Transparency = 0.4}, verifyBtn)

local statusContainer = mk("Frame", {
    Size = UDim2.new(0, 46, 0, 10), Position = UDim2.new(0, 149, 0.5, -5),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 8,
}, TBar)
local circles = {}
for i = 1, 3 do
    local circle = mk("Frame", {
        Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, (i-1)*18, 0, 0),
        BackgroundColor3 = C.WHITE, BackgroundTransparency = 0.3,
        BorderSizePixel = 0, ZIndex = 9,
    }, statusContainer)
    rnd(5, circle)
    circles[i] = circle
end

local function resetCircles()
    for _, c in ipairs(circles) do tween(c, 0.2, {BackgroundColor3 = C.WHITE, BackgroundTransparency = 0.3}) end
end
local function animateCircles(color)
    for i, c in ipairs(circles) do
        task.delay((i-1)*0.08, function() tween(c, 0.3, {BackgroundColor3 = color, BackgroundTransparency = 0}) end)
    end
    task.delay(1, resetCircles)
end

local hasSavedData = false
local tryLoadSaved
local animateBodyElements

clearBtn.MouseButton1Click:Connect(function()
    Config.clearCredentials()
    hasSavedData = false
    usernameInput.Text = ""
    keyInput.Text = ""
    tween(savedBadge,       0.2, {BackgroundTransparency = 1})
    tween(savedBadgeStroke, 0.2, {Transparency = 1})
    tween(savedBadgeLabel,  0.2, {TextTransparency = 1})
    tween(clearBtn,         0.2, {TextTransparency = 1})
end)

verifyBtn.MouseButton1Click:Connect(function()
    local username = getUsernameText()
    local key      = getKeyText()
    tween(verifyBtn, 0.08, {Size = UDim2.new(0.5, -9, 0, 30)})
    task.delay(0.08, function() tween(verifyBtn, 0.12, {Size = UDim2.new(0.5, -5, 0, 34)}) end)
    verifyBtn.Active = false
    verifyBtn.Text   = "Verifying..."

    Config.verify(username, key, function(success, message)
        verifyBtn.Active = true
        verifyBtn.Text   = "Verify"
        if username == "" or key == "" then
            animateCircles(C.RED)
        elseif success then
            animateCircles(C.GREEN)
            task.delay(0.8, function()
                local fadeT = 0.45
                tween(Win, fadeT, {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0, WW*0.92, 0, WH*0.92),
                    Position = UDim2.new(0.5, -(WW*0.92)/2, 0.5, -(WH*0.92)/2 + 14),
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                tween(WinStroke, fadeT, {Transparency = 1}, Enum.EasingStyle.Sine)
                tween(rdot,      fadeT, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine)
                tween(title1,    fadeT*0.6, {TextTransparency = 1}, Enum.EasingStyle.Sine)
                tween(title2,    fadeT*0.6, {TextTransparency = 1}, Enum.EasingStyle.Sine)
                tween(MinB,      fadeT*0.6, {TextTransparency = 1}, Enum.EasingStyle.Sine)
                tween(ClsB,      fadeT*0.6, {TextTransparency = 1}, Enum.EasingStyle.Sine)
                for _, c in ipairs(circles) do tween(c, fadeT, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine) end
                animateBodyElements(false)
                task.delay(fadeT + 0.05, function() SG:Destroy(); Config.loadMain() end)
            end)
        else
            if hasSavedData then
                Config.clearCredentials()
                hasSavedData = false
                tween(savedBadge,       0.2, {BackgroundTransparency = 1})
                tween(savedBadgeStroke, 0.2, {Transparency = 1})
                tween(savedBadgeLabel,  0.2, {TextTransparency = 1})
                tween(clearBtn,         0.2, {TextTransparency = 1})
            end
            animateCircles(C.YELLOW)
        end
    end)
end)

do
    local dragging, mStart, wStart = false, Vector2.new(), Vector2.new()
    local DragHit = mk("TextButton", {
        Text = "", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, -72, 1, 0), ZIndex = 50, AutoButtonColor = false,
    }, TBar)
    DragHit.MouseButton1Down:Connect(function()
        local mp = UIS:GetMouseLocation()
        dragging = true; mStart = mp
        wStart = Vector2.new(Win.Position.X.Offset, Win.Position.Y.Offset)
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mp = UIS:GetMouseLocation(); local d = mp - mStart
        local tx, ty = wStart.X + d.X, wStart.Y + d.Y
        local cx, cy = Win.Position.X.Offset, Win.Position.Y.Offset
        local nx = cx + (tx-cx)*0.5; local ny = cy + (ty-cy)*0.5
        if math.abs(nx-tx) < 0.3 then nx = tx end
        if math.abs(ny-ty) < 0.3 then ny = ty end
        Win.Position = UDim2.new(0.5, nx, 0.5, ny)
    end)
end

animateBodyElements = function(show)
    local targetT = show and 0 or 1
    local function animLabels(container)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("TextLabel") then tween(child, 0.2, {TextTransparency = targetT}) end
        end
    end
    local function animInputBg(container)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") then
                tween(child, 0.2, {BackgroundTransparency = show and 0.2 or 1})
                local stroke = child:FindFirstChildOfClass("UIStroke")
                if stroke then tween(stroke, 0.2, {Transparency = show and 0.6 or 1}) end
                local textbox = child:FindFirstChildOfClass("TextBox")
                if textbox then tween(textbox, 0.2, {TextTransparency = targetT, PlaceholderColor3 = show and C.MUTED or Color3.fromRGB(0,0,0)}) end
                local img = child:FindFirstChildOfClass("ImageLabel")
                if img then tween(img, 0.2, {ImageTransparency = targetT}) end
                local sep = child:FindFirstChild("InputSeparator")
                if sep then tween(sep, 0.2, {BackgroundTransparency = show and 0.3 or 1}) end
            end
        end
    end
    animLabels(userContainer); animLabels(keyContainer)
    animInputBg(userContainer); animInputBg(keyContainer)
    local badgeT = (show and hasSavedData) and 0 or 1
    tween(savedBadge,       0.2, {BackgroundTransparency = badgeT == 0 and 0.3 or 1})
    tween(savedBadgeStroke, 0.2, {Transparency           = badgeT == 0 and 0.5 or 1})
    tween(savedBadgeLabel,  0.2, {TextTransparency       = badgeT})
    tween(clearBtn,         0.2, {TextTransparency       = badgeT})
    tween(verifyBtn, 0.2, {
        BackgroundTransparency = show and 0.1 or 1, TextTransparency = targetT,
        Size = show and UDim2.new(0.5, -5, 0, 34) or UDim2.new(0.5, -5, 0, 0),
    })
    local btnStroke = verifyBtn:FindFirstChildOfClass("UIStroke")
    if btnStroke then tween(btnStroke, 0.2, {Transparency = show and 0.4 or 1}) end
end

tryLoadSaved = function()
    local savedUser, savedKey = Config.loadCredentials()
    if savedUser and savedKey and savedUser ~= "" and savedKey ~= "" then
        fillUsername(savedUser); fillKey(savedKey)
        hasSavedData = true
        animateBodyElements(true)
        tween(userIcon, 0.4, {ImageColor3 = C.SAVED}); tween(keyIcon, 0.4, {ImageColor3 = C.SAVED})
        task.delay(2, function()
            tween(userIcon, 0.4, {ImageColor3 = C.MUTED}); tween(keyIcon, 0.4, {ImageColor3 = C.MUTED})
        end)
    end
end

local minimized, animating = false, false
MinB.MouseButton1Click:Connect(function()
    if animating then return end
    animating = true; minimized = not minimized
    if minimized then
        animateBodyElements(false)
        tween(Body, 0.3,  {Size = UDim2.new(1,-40,0,0)}, Enum.EasingStyle.Quint)
        tween(Win,  0.3,  {Size = UDim2.new(0,WW,0,TH)}, Enum.EasingStyle.Quint)
        tween(title1, 0.2, {TextTransparency = 0.5}); tween(title2, 0.2, {TextTransparency = 0.5})
        task.delay(0.35, function() animating = false end)
    else
        tween(Win,  0.35, {Size = UDim2.new(0,WW,0,WH)}, Enum.EasingStyle.Quint)
        tween(Body, 0.35, {Size = UDim2.new(1,-40,1,-TH-60)}, Enum.EasingStyle.Quint)
        tween(title1, 0.25, {TextTransparency = 0}); tween(title2, 0.25, {TextTransparency = 0})
        task.delay(0.15, function() animateBodyElements(true) end)
        task.delay(0.5,  function() animating = false end)
    end
    MinB.Text = minimized and "□" or "─"
end)

local function doClose()
    if animating then return end
    animating = true; Win.Active = false
    local fadeT = 0.4
    tween(Win, fadeT, {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, WW*0.9, 0, WH*0.9),
        Position = UDim2.new(0.5, -(WW*0.9)/2, 0.5, -(WH*0.9)/2 + 12),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(WinStroke, fadeT, {Transparency = 1}, Enum.EasingStyle.Sine)
    tween(rdot,      fadeT, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine)
    tween(title1,    fadeT*0.5, {TextTransparency = 1}, Enum.EasingStyle.Sine)
    tween(title2,    fadeT*0.5, {TextTransparency = 1}, Enum.EasingStyle.Sine)
    tween(MinB,      fadeT*0.5, {TextTransparency = 1}, Enum.EasingStyle.Sine)
    tween(ClsB,      fadeT*0.5, {TextTransparency = 1}, Enum.EasingStyle.Sine)
    for _, c in ipairs(circles) do tween(c, fadeT, {BackgroundTransparency = 1}, Enum.EasingStyle.Sine) end
    animateBodyElements(false)
    task.delay(fadeT + 0.05, function() SG:Destroy() end)
end
ClsB.MouseButton1Click:Connect(doClose)

local hidden = false
UIS.InputBegan:Connect(function(i, gp)
    if gp or animating then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        hidden = not hidden
        if hidden then
            local fadeT = 0.3
            tween(Win, fadeT, {BackgroundTransparency=1, Size=UDim2.new(0,WW*0.95,0,WH*0.95), Position=UDim2.new(0.5,-(WW*0.95)/2,0.5,-(WH*0.95)/2+8)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            tween(WinStroke, fadeT, {Transparency=1}, Enum.EasingStyle.Sine)
            tween(rdot, fadeT, {BackgroundTransparency=1}, Enum.EasingStyle.Sine)
            tween(title1, fadeT, {TextTransparency=1}, Enum.EasingStyle.Sine)
            tween(title2, fadeT, {TextTransparency=1}, Enum.EasingStyle.Sine)
            tween(MinB, fadeT, {TextTransparency=1}, Enum.EasingStyle.Sine)
            tween(ClsB, fadeT, {TextTransparency=1}, Enum.EasingStyle.Sine)
            for _, c in ipairs(circles) do tween(c, fadeT, {BackgroundTransparency=1}, Enum.EasingStyle.Sine) end
            animateBodyElements(false)
            task.delay(fadeT+0.05, function() Win.Visible = false end)
        else
            Win.Visible = true
            Win.Size     = UDim2.new(0, WW*0.95, 0, WH*0.95)
            Win.Position = UDim2.new(0.5, -(WW*0.95)/2, 0.5, -(WH*0.95)/2+8)
            local fadeT = 0.35
            tween(Win, fadeT, {BackgroundTransparency=0, Size=UDim2.new(0,WW,0,WH), Position=UDim2.new(0.5,-WW/2,0.5,-WH/2)}, Enum.EasingStyle.Quint)
            tween(WinStroke, fadeT, {Transparency=0}, Enum.EasingStyle.Sine)
            tween(rdot, fadeT, {BackgroundTransparency=0}, Enum.EasingStyle.Sine)
            tween(title1, fadeT, {TextTransparency=0}, Enum.EasingStyle.Sine)
            tween(title2, fadeT, {TextTransparency=0}, Enum.EasingStyle.Sine)
            tween(MinB, fadeT, {TextTransparency=0}, Enum.EasingStyle.Sine)
            tween(ClsB, fadeT, {TextTransparency=0}, Enum.EasingStyle.Sine)
            for _, c in ipairs(circles) do tween(c, fadeT, {BackgroundTransparency=0.3}, Enum.EasingStyle.Sine) end
            task.delay(0.15, function() animateBodyElements(true) end)
        end
    end
    if i.KeyCode == Enum.KeyCode.End then doClose() end
end)

Win.Visible = false; Win.BackgroundTransparency = 1
Win.Size = UDim2.new(0, WW*0.88, 0, WH*0.88)
Win.Position = UDim2.new(0.5, -(WW*0.88)/2, 0.5, -(WH*0.88)/2+18)
WinStroke.Transparency = 1; rdot.BackgroundTransparency = 1
title1.TextTransparency = 1; title2.TextTransparency = 1
MinB.TextTransparency = 1; ClsB.TextTransparency = 1
for _, c in ipairs(circles) do c.BackgroundTransparency = 1 end
animateBodyElements(false)

task.defer(function()
    Win.Visible = true
    local t1 = 0.55
    tween(Win, t1, {BackgroundTransparency=0, Size=UDim2.new(0,WW*1.025,0,WH*1.025), Position=UDim2.new(0.5,-(WW*1.025)/2,0.5,-(WH*1.025)/2)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(WinStroke, t1*0.8, {Transparency=0}, Enum.EasingStyle.Sine)
    tween(rdot, t1*0.8, {BackgroundTransparency=0}, Enum.EasingStyle.Sine)
    task.delay(0.1,  function() tween(title1, 0.35, {TextTransparency=0}, Enum.EasingStyle.Quart) end)
    task.delay(0.18, function() tween(title2, 0.3,  {TextTransparency=0}, Enum.EasingStyle.Quart) end)
    task.delay(0.22, function() tween(MinB, 0.3, {TextTransparency=0}, Enum.EasingStyle.Quart); tween(ClsB, 0.3, {TextTransparency=0}, Enum.EasingStyle.Quart) end)
    task.delay(0.25, function()
        for i, c in ipairs(circles) do
            task.delay((i-1)*0.06, function() tween(c, 0.25, {BackgroundTransparency=0.3}, Enum.EasingStyle.Quart) end)
        end
    end)
    task.delay(t1, function()
        tween(Win, 0.2, {Size=UDim2.new(0,WW,0,WH), Position=UDim2.new(0.5,-WW/2,0.5,-WH/2)}, Enum.EasingStyle.Quint)
    end)
    task.delay(0.3, function() animateBodyElements(true); task.delay(0.1, tryLoadSaved) end)
end)
