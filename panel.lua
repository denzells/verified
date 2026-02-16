-- Cargar configuración
local KeyAuth = loadstring(game:HttpGet("https://raw.githubusercontent.com/tu-usuario/tu-repo/main/config.lua"))()

-- Verificar HTTP
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    return
end

-- Servicios
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Colors
local C = {
    WIN = Color3.fromRGB(12, 12, 12),
    TBAR = Color3.fromRGB(8, 8, 8),
    LINE = Color3.fromRGB(42, 42, 42),
    RED = Color3.fromRGB(205, 30, 30),
    WHITE = Color3.fromRGB(235, 235, 235),
    GRAY = Color3.fromRGB(110, 110, 110),
    MUTED = Color3.fromRGB(55, 55, 55),
    INPUT = Color3.fromRGB(18, 18, 18),
    GREEN = Color3.fromRGB(50, 200, 80),
    YELLOW = Color3.fromRGB(255, 200, 50),
}

-- Utilidades
local function mk(cls, p, par)
    local o = Instance.new(cls)
    for k,v in pairs(p) do pcall(function() o[k]=v end) end
    if par then o.Parent = par end
    return o
end

local function rnd(r, p) 
    mk("UICorner", {CornerRadius=UDim.new(0,r)}, p) 
end

local function tw(o,t,props,es,ed)
    TweenService:Create(o, TweenInfo.new(t, es or Enum.EasingStyle.Quart, ed or Enum.EasingDirection.Out), props):Play()
end

-- GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui",10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then return end

local old = PlayerGui:FindFirstChild("PanelBase")
if old then old:Destroy() end

local SG = mk("ScreenGui", {
    Name="PanelBase", 
    ResetOnSpawn=false,
    IgnoreGuiInset=true, 
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling
}, PlayerGui)

-- Ventana principal
local WW, WH = 320, 260
local TH = 42

local Win = mk("Frame", {
    Size=UDim2.new(0,WW,0,WH),
    Position=UDim2.new(0.5,-WW/2,0.5,-WH/2),
    BackgroundColor3=C.WIN,
    BackgroundTransparency=0.15,
    BorderSizePixel=0, 
    ClipsDescendants=false, 
    ZIndex=3,
}, SG)
rnd(14, Win)

local WinStroke = mk("UIStroke", {
    Color=C.LINE, 
    Thickness=1, 
    Transparency=0.4
}, Win)

-- Titlebar
local TBar = mk("Frame", {
    Size=UDim2.new(1,0,0,TH),
    BackgroundColor3=C.TBAR,
    BackgroundTransparency=0.1,
    BorderSizePixel=0, 
    ZIndex=6, 
    ClipsDescendants=false, 
    Active=true,
}, Win)
mk("UICorner", {CornerRadius=UDim.new(0,14)}, TBar)

mk("Frame", {
    Size=UDim2.new(1,0,0,14), 
    Position=UDim2.new(0,0,1,-14),
    BackgroundColor3=C.TBAR,
    BackgroundTransparency=0.1,
    BorderSizePixel=0, 
    ZIndex=5, 
    Active=false,
}, TBar)

local rdot = mk("Frame", {
    Size=UDim2.new(0,10,0,10), 
    Position=UDim2.new(0,14,0.5,-5),
    BackgroundColor3=C.RED, 
    BorderSizePixel=0, 
    ZIndex=8
}, TBar)
rnd(5, rdot)

-- Títulos
local function tlbl(txt, font, sz, col, x, w)
    return mk("TextLabel", {
        Text=txt, 
        Font=font, 
        TextSize=sz, 
        TextColor3=col,
        BackgroundTransparency=1,
        Size=UDim2.new(0,w,0,TH), 
        Position=UDim2.new(0,x,0,0),
        TextXAlignment=Enum.TextXAlignment.Left, 
        ZIndex=8
    }, TBar)
end

local title1 = tlbl("serios.gg", Enum.Font.GothamBold, 13, C.WHITE, 30, 100)
local title2 = tlbl("|", Enum.Font.GothamBold, 16, C.RED, 133, 14)

-- Botones de control
local MinB = mk("TextButton", {
    Text="─", 
    Font=Enum.Font.GothamBold, 
    TextSize=16,
    TextColor3=C.GRAY, 
    BackgroundTransparency=1, 
    BorderSizePixel=0,
    Size=UDim2.new(0,36,0,TH), 
    Position=UDim2.new(0,WW-72,0,0),
    ZIndex=8, 
    AutoButtonColor=false
}, TBar)

local ClsB = mk("TextButton", {
    Text="×", 
    Font=Enum.Font.GothamBold, 
    TextSize=22,
    TextColor3=C.GRAY, 
    BackgroundTransparency=1, 
    BorderSizePixel=0,
    Size=UDim2.new(0,36,0,TH), 
    Position=UDim2.new(0,WW-36,0,0),
    ZIndex=8, 
    AutoButtonColor=false
}, TBar)

ClsB.MouseEnter:Connect(function() tw(ClsB,.1,{TextColor3=C.RED}) end)
ClsB.MouseLeave:Connect(function() tw(ClsB,.1,{TextColor3=C.GRAY}) end)
MinB.MouseEnter:Connect(function() tw(MinB,.1,{TextColor3=C.WHITE}) end)
MinB.MouseLeave:Connect(function() tw(MinB,.1,{TextColor3=C.GRAY}) end)

-- Body
local Body = mk("Frame", {
    Size=UDim2.new(1,-40,1,-TH-60), 
    Position=UDim2.new(0,20,0,TH+20),
    BackgroundTransparency=1, 
    BorderSizePixel=0, 
    ZIndex=4,
}, Win)

-- Input creator
local function CreateInput(parent, labelText, yPos, isPassword)
    local container = mk("Frame", {
        Size=UDim2.new(1,0,0,56),
        Position=UDim2.new(0,0,0,yPos),
        BackgroundTransparency=1, 
        BorderSizePixel=0, 
        ZIndex=5
    }, parent)
    
    mk("TextLabel", {
        Text=labelText, 
        Font=Enum.Font.GothamSemibold, 
        TextSize=10,
        TextColor3=C.WHITE, 
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,16),
        TextXAlignment=Enum.TextXAlignment.Left, 
        ZIndex=6
    }, container)
    
    local inputBg = mk("Frame", {
        Size=UDim2.new(1,0,0,34), 
        Position=UDim2.new(0,0,0,20),
        BackgroundColor3=C.INPUT,
        BackgroundTransparency=0.2,
        BorderSizePixel=0, 
        ZIndex=6
    }, container)
    rnd(6, inputBg)
    mk("UIStroke", {Color=C.LINE, Thickness=1, Transparency=0.6}, inputBg)
    
    local input = mk("TextBox", {
        Text="", 
        Font=Enum.Font.Gotham, 
        TextSize=11,
        TextColor3=C.WHITE, 
        PlaceholderText=labelText,
        PlaceholderColor3=C.MUTED,
        BackgroundTransparency=1,
        Size=UDim2.new(1,-16,1,0), 
        Position=UDim2.new(0,8,0,0),
        TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false, 
        ZIndex=7
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
        tw(inputBg,.15,{BackgroundColor3=Color3.fromRGB(22,22,22), BackgroundTransparency=0.1})
        tw(inputBg:FindFirstChildOfClass("UIStroke"),.15,{Color=C.RED, Transparency=0.4})
    end)
    
    input.FocusLost:Connect(function()
        tw(inputBg,.15,{BackgroundColor3=C.INPUT, BackgroundTransparency=0.2})
        tw(inputBg:FindFirstChildOfClass("UIStroke"),.15,{Color=C.LINE, Transparency=0.6})
    end)
    
    local function getRealText()
        if isPassword then
            return realText
        else
            return input.Text
        end
    end
    
    return input, container, getRealText
end

-- Inputs
local usernameInput, userContainer, getUsernameText = CreateInput(Body, "Username", 0, false)
local keyInput, keyContainer, getKeyText = CreateInput(Body, "Key", 66, true)

-- Botón verify
local verifyBtn = mk("TextButton", {
    Text="Verify", 
    Font=Enum.Font.GothamBold, 
    TextSize=11,
    TextColor3=C.WHITE, 
    BackgroundColor3=C.RED,
    BackgroundTransparency=0.1,
    BorderSizePixel=0, 
    ZIndex=6,
    Size=UDim2.new(0.5,-5,0,34), 
    Position=UDim2.new(0.25,0,0,145),
    AutoButtonColor=false
}, Body)
rnd(6, verifyBtn)
mk("UIStroke", {Color=Color3.fromRGB(255,50,50), Thickness=1, Transparency=0.4}, verifyBtn)

-- Status circles
local statusContainer = mk("Frame", {
    Size=UDim2.new(0,46,0,10),
    Position=UDim2.new(0,149,0.5,-5),
    BackgroundTransparency=1, 
    BorderSizePixel=0, 
    ZIndex=8
}, TBar)

local circles = {}
for i = 1, 3 do
    local circle = mk("Frame", {
        Size=UDim2.new(0,10,0,10),
        Position=UDim2.new(0,(i-1)*18,0,0),
        BackgroundColor3=C.WHITE,
        BackgroundTransparency=0.3,
        BorderSizePixel=0, 
        ZIndex=9
    }, statusContainer)
    rnd(5, circle)
    circles[i] = circle
end

local function resetCircles()
    for i, circle in ipairs(circles) do
        tw(circle, 0.2, {BackgroundColor3=C.WHITE, BackgroundTransparency=0.3})
    end
end

local function animateCircles(color)
    for i, circle in ipairs(circles) do
        task.delay((i-1)*0.08, function()
            tw(circle, 0.3, {BackgroundColor3=color, BackgroundTransparency=0})
        end)
    end
    task.delay(1, resetCircles)
end

-- Verify logic
verifyBtn.MouseButton1Click:Connect(function()
    local username = getUsernameText()
    local key = getKeyText()
    
    tw(verifyBtn,.08,{Size=UDim2.new(0.5,-9,0,30)})
    task.delay(.08, function()
        tw(verifyBtn,.12,{Size=UDim2.new(0.5,-5,0,34)})
    end)
    
    verifyBtn.Active = false
    verifyBtn.Text = "Verifying..."
    
    KeyAuth.Verify(username, key, function(success, message)
        verifyBtn.Active = true
        verifyBtn.Text = "Verify"
        
        if username == "" or key == "" then
            animateCircles(C.RED)
        elseif success then
            animateCircles(C.GREEN)
            task.delay(2, function()
                SG:Destroy()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/denzells/serios.gg/main/main.lua"))()
            end)
        else
            animateCircles(C.YELLOW)
        end
    end)
end)

-- Drag system
do
    local dragging=false
    local mStart=Vector2.new()
    local wStart=Vector2.new()
    
    local DragHit=mk("TextButton", {
        Text="", 
        BackgroundTransparency=1, 
        BorderSizePixel=0,
        Size=UDim2.new(1,-72,1,0), 
        Position=UDim2.new(0,0,0,0),
        ZIndex=50, 
        AutoButtonColor=false,
    }, TBar)
    
    DragHit.MouseButton1Down:Connect(function()
        local mp=UIS:GetMouseLocation()
        dragging=true
        mStart=mp
        wStart=Vector2.new(Win.Position.X.Offset,Win.Position.Y.Offset)
    end)
    
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then 
            dragging=false 
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local mp=UIS:GetMouseLocation()
        local d=mp-mStart
        local tx=wStart.X+d.X
        local ty=wStart.Y+d.Y
        local cx=Win.Position.X.Offset
        local cy=Win.Position.Y.Offset
        local nx=cx+(tx-cx)*0.5
        local ny=cy+(ty-cy)*0.5
        if math.abs(nx-tx)<0.3 then nx=tx end
        if math.abs(ny-ty)<0.3 then ny=ty end
        Win.Position = UDim2.new(0.5, nx, 0.5, ny)
    end)
end

-- Body animation
local function animateBodyElements(show)
    local targetTransparency = show and 0 or 1
    
    for _, child in ipairs(userContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            tw(child,.2,{TextTransparency=targetTransparency})
        end
    end
    
    for _, child in ipairs(keyContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            tw(child,.2,{TextTransparency=targetTransparency})
        end
    end
    
    local function animateInputBg(container)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") then
                local targetBgTransparency = show and 0.2 or 1
                tw(child,.2,{BackgroundTransparency=targetBgTransparency})
                local stroke = child:FindFirstChildOfClass("UIStroke")
                if stroke then
                    local targetStrokeTransparency = show and 0.6 or 1
                    tw(stroke,.2,{Transparency=targetStrokeTransparency})
                end
                local textbox = child:FindFirstChildOfClass("TextBox")
                if textbox then
                    tw(textbox,.2,{
                        TextTransparency=targetTransparency,
                        PlaceholderColor3 = show and C.MUTED or Color3.fromRGB(0,0,0)
                    })
                end
            end
        end
    end
    
    animateInputBg(userContainer)
    animateInputBg(keyContainer)
    
    local btnTargetTransparency = show and 0.1 or 1
    tw(verifyBtn,.2,{
        BackgroundTransparency=btnTargetTransparency,
        TextTransparency=targetTransparency,
        Size = show and UDim2.new(0.5,-5,0,34) or UDim2.new(0.5,-5,0,0)
    })
    
    local btnStroke = verifyBtn:FindFirstChildOfClass("UIStroke")
    if btnStroke then
        local strokeTargetTransparency = show and 0.4 or 1
        tw(btnStroke,.2,{Transparency=strokeTargetTransparency})
    end
end

-- Minimize/Close
local minimized=false
local animating=false

MinB.MouseButton1Click:Connect(function()
    if animating then return end
    animating=true
    minimized=not minimized
    
    if minimized then
        animateBodyElements(false)
        tw(Body,.3,{Size=UDim2.new(1,-40,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        tw(Win,.3,{Size=UDim2.new(0,WW,0,TH), BackgroundTransparency=0.15},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        tw(WinStroke,.25,{Transparency=0.5})
        tw(title1,.2,{TextTransparency=0.5})
        task.delay(.35,function() animating=false end)
    else
        tw(Win,.35,{Size=UDim2.new(0,WW,0,WH), BackgroundTransparency=0.15},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        tw(Body,.35,{Size=UDim2.new(1,-40,1,-TH-60)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        tw(WinStroke,.3,{Transparency=0.4})
        tw(title1,.25,{TextTransparency=0})
        task.delay(.15, function() animateBodyElements(true) end)
        task.delay(.5,function() animating=false end)
    end
    MinB.Text=minimized and "□" or "─"
end)

local function doClose()
    if animating then return end
    animating=true
    Win.Active=false
    
    animateBodyElements(false)
    tw(Body,.3,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0,TH)},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
    tw(rdot,.2,{BackgroundTransparency=1})
    tw(title1,.2,{TextTransparency=1})
    tw(title2,.2,{TextTransparency=1})
    tw(MinB,.2,{TextTransparency=1})
    tw(ClsB,.2,{TextTransparency=1})
    
    for _, circle in ipairs(circles) do
        tw(circle,.2,{BackgroundTransparency=1})
    end
    
    task.delay(.4,function()
        tw(Win,.35,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
        tw(WinStroke,.3,{Transparency=1})
    end)
    task.delay(.8,function() SG:Destroy() end)
end

ClsB.MouseButton1Click:Connect(doClose)

-- Hotkeys
local hidden=false
UIS.InputBegan:Connect(function(i,gp)
    if gp or animating then return end
    
    if i.KeyCode == Enum.KeyCode.RightShift then
        hidden = not hidden
        if hidden then
            tw(Win,.2,{BackgroundTransparency=1},Enum.EasingStyle.Sine)
            tw(WinStroke,.2,{Transparency=1})
            animateBodyElements(false)
            for _, circle in ipairs(circles) do
                tw(circle,.2,{BackgroundTransparency=1})
            end
            task.delay(.2,function() Win.Visible=false end)
        else
            Win.Visible=true
            Win.BackgroundTransparency=1
            WinStroke.Transparency=1
            tw(Win,.25,{BackgroundTransparency=0.15},Enum.EasingStyle.Sine)
            tw(WinStroke,.25,{Transparency=0.4})
            for _, circle in ipairs(circles) do
                tw(circle,.25,{BackgroundTransparency=0.3})
            end
            task.delay(.15, function() animateBodyElements(true) end)
        end
    end
    
    if i.KeyCode == Enum.KeyCode.End then
        doClose()
    end
end)

-- Open animation
Win.Size=UDim2.new(0,WW/3,0,TH)
Win.BackgroundTransparency=1
WinStroke.Transparency=1
Body.Size=UDim2.new(1,-40,0,0)
Body.Position=UDim2.new(0,20,0,TH+20)
rdot.BackgroundTransparency=1
title1.TextTransparency=1
title2.TextTransparency=1
MinB.TextTransparency=1
ClsB.TextTransparency=1

for _, circle in ipairs(circles) do
    circle.BackgroundTransparency=1
end

animateBodyElements(false)

tw(Win,.4,{Size=UDim2.new(0,WW,0,TH),BackgroundTransparency=0.15},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
tw(WinStroke,.35,{Transparency=0.4})

task.delay(.1,function()
    tw(rdot,.3,{BackgroundTransparency=0},Enum.EasingStyle.Sine)
    task.delay(.05,function() tw(title1,.3,{TextTransparency=0},Enum.EasingStyle.Sine) end)
    task.delay(.08,function() tw(title2,.3,{TextTransparency=0},Enum.EasingStyle.Sine) end)
    task.delay(.11,function()
        for i, circle in ipairs(circles) do
            task.delay((i-1)*0.05, function()
                tw(circle,.25,{BackgroundTransparency=0.3},Enum.EasingStyle.Sine)
            end)
        end
    end)
    task.delay(.2,function() 
        tw(MinB,.25,{TextTransparency=0},Enum.EasingStyle.Sine)
        tw(ClsB,.25,{TextTransparency=0},Enum.EasingStyle.Sine)
    end)
end)

task.delay(.25,function()
    tw(Win,.45,{Size=UDim2.new(0,WW,0,WH),BackgroundTransparency=0.15},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
    tw(Body,.45,{Size=UDim2.new(1,-40,1,-TH-60)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
    task.delay(.3, function() animateBodyElements(true) end)
end)