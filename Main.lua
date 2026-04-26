-- [[ LOBOCATJ HUB - CUSTOM NATIVE ENGINE ]]
-- Foco: Alta Performance, UI Minimalista e Execução Paralela.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- [[ ESTADO GLOBAL E CONEXÕES ]]
local Settings = {
    Running = true,
    Hitbox = { HeadOn = false, HeadSize = 2, HeadVis = true, BodyOn = false, BodySize = 2, BodyVis = true, SmallSelf = false },
    Trigger = { On = false, Team = true, Delay = 0 },
    Aim = { On = false, Part = "Head", Smooth = 0.1, Fov = 200, Team = true },
    Move = { SpeedOn = false, Speed = 16, JumpOn = false, Jump = 50, Fly = false, FlySpeed = 50, Noclip = false },
    God = { On = false },
    Render = { Fullbright = false, BlackScreen = nil },
    Sec = { Watch = false, Dist = 60, AntiStaff = false },
    Farm = { Click = false, Delay = 0.01 },
    Waypoints = {}
}

local Connections = {}
local function AddCon(sig, func)
    local c = sig:Connect(func)
    table.insert(Connections, c)
    return c
end

-- [[ SISTEMA DE UI NATIVA (DARK/MINIMALISTA) ]]
local HubUI = Instance.new("ScreenGui")
HubUI.Name = "LoboCatJ_Native"
HubUI.ResetOnSpawn = false
pcall(function() HubUI.Parent = (gethui and gethui()) or CoreGui end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = HubUI
MainFrame.ClipsDescendants = true

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LOBOCATJ HUB | NATIVE ENGINE"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = TopBar

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(0, 130, 1, -30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabContainer.BorderSizePixel = 0
TabContainer.ScrollBarThickness = 2
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -130, 1, -30)
ContentContainer.Position = UDim2.new(0, 130, 0, 30)
ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local UIListLayout_Tabs = Instance.new("UIListLayout")
UIListLayout_Tabs.Parent = TabContainer
UIListLayout_Tabs.SortOrder = Enum.SortOrder.LayoutOrder

-- Drag Logic
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    ContentContainer.Visible = not ContentContainer.Visible
    TabContainer.Visible = not TabContainer.Visible
    MainFrame.Size = ContentContainer.Visible and UDim2.new(0, 550, 0, 350) or UDim2.new(0, 550, 0, 30)
end)

local Tabs = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.Code
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabContainer

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ScrollBarThickness = 3
    ContentFrame.Visible = false
    ContentFrame.Parent = ContentContainer

    local UIListLayout_Content = Instance.new("UIListLayout")
    UIListLayout_Content.Parent = ContentFrame
    UIListLayout_Content.Padding = UDim.new(0, 5)

    local UIPadding = Instance.new("UIPadding")
    UIPadding.Parent = ContentFrame
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingRight = UDim.new(0, 5)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do v.Frame.Visible = false v.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
        ContentFrame.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    table.insert(Tabs, {Btn = TabBtn, Frame = ContentFrame})
    if #Tabs == 1 then ContentFrame.Visible = true TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end

    local Elements = {}
    
    function Elements:CreateToggle(text, callback)
        local frame = Instance.new("Frame", ContentFrame)
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BorderSizePixel = 0
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -40, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 20, 0, 20)
        btn.Position = UDim2.new(1, -30, 0, 5)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = ""
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(50, 50, 50)
            callback(state)
        end)
    end

    function Elements:CreateSlider(text, min, max, default, callback)
        local frame = Instance.new("Frame", ContentFrame)
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BorderSizePixel = 0
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text .. " (" .. tostring(default) .. ")"
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local sliderBG = Instance.new("TextButton", frame)
        sliderBG.Size = UDim2.new(1, -20, 0, 10)
        sliderBG.Position = UDim2.new(0, 10, 0, 25)
        sliderBG.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        sliderBG.Text = ""
        local sliderFill = Instance.new("Frame", sliderBG)
        sliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        local function Update(input)
            local pct = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(pct, 0, 1, 0)
            local val = math.floor(min + (max - min) * pct)
            lbl.Text = text .. " (" .. tostring(val) .. ")"
            callback(val)
        end
        sliderBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Update(input)
                local m = UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
                local u; u = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then m:Disconnect() u:Disconnect() end end)
            end
        end)
    end

    function Elements:CreateButton(text, callback)
        local btn = Instance.new("TextButton", ContentFrame)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Code
        btn.MouseButton1Click:Connect(callback)
    end

    function Elements:CreateInput(text, callback)
        local frame = Instance.new("Frame", ContentFrame)
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BorderSizePixel = 0
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(0.4, 0, 0, 20)
        box.Position = UDim2.new(0.6, -10, 0, 5)
        box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Text = ""
        box.Font = Enum.Font.Code
        box.FocusLost:Connect(function() callback(box.Text) end)
    end

    return Elements
end

-- [[ LÓGICA CORE (ENGINES) ]]

-- 1. Hitbox
task.spawn(function()
    while Settings.Running do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                pcall(function()
                    local head = p.Character:FindFirstChild("Head")
                    if head and Settings.Hitbox.HeadOn then
    head.Size = Vector3.new(Settings.Hitbox.HeadSize, Settings.Hitbox.HeadSize, Settings.Hitbox.HeadSize)
    head.Transparency = Settings.Hitbox.HeadVis and 0.5 or 1
    head.CanCollide = false
end

                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and Settings.Hitbox.BodyOn then
    hrp.Size = Vector3.new(Settings.Hitbox.BodySize, Settings.Hitbox.BodySize, Settings.Hitbox.BodySize)
    hrp.Transparency = Settings.Hitbox.BodyVis and 0.5 or 1
    hrp.CanCollide = false
end
                end)
            end
        end

        local char = Player.Character
        local char = Player.Character
if char then
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        
        if Settings.Hitbox.SmallSelf then
            hrp.Size = Vector3.new(1.5, 1.5, 1.5)
            hrp.Transparency = 1
        else
            hrp.Massless = false
            hrp.Size = Vector3.new(2, 2, 1)
            hrp.Transparency = 0
            hrp.CanCollide = true
        end

    end
end

        task.wait(0.5)
    end
end)

local function ResetHitbox()
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function()
            local h = p.Character and p.Character:FindFirstChild("Head")
            if h then
                h.Size = Vector3.new(2,1,1)
                h.Transparency = 0
            end

            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
    hrp.Size = Vector3.new(2,2,1)
    hrp.Transparency = 1
    hrp.CanCollide = true
end
        end)
    end
end
-- 2. Trigger Bot
task.spawn(function()
    while Settings.Running do
        if Settings.Trigger.On then
            local t = Mouse.Target
            if t and t.Parent then
                local char = t.Parent:IsA("Model") and t.Parent or t.Parent.Parent
                local tp = Players:GetPlayerFromCharacter(char)
                if tp and tp ~= Player and tp.Character and tp.Character:FindFirstChild("Humanoid") and tp.Character.Humanoid.Health > 0 then
                    local canShoot = true
                    if Settings.Trigger.Team and tp.Team == Player.Team then canShoot = false end
                    if canShoot then
                        if Settings.Trigger.Delay > 0 then task.wait(Settings.Trigger.Delay) end
                        if mouse1click then mouse1click() elseif mouse1press then mouse1press() task.wait() mouse1release() end
                    end
                end
            end
        end
        task.wait(0.01)
    end
end)

-- 3. Aimbot (Distance/FOV)
local function GetClosest()
    local t, d = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild(Settings.Aim.Part) then
            if Settings.Aim.Team and p.Team == Player.Team then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (p.Character[Settings.Aim.Part].Position - Player.Character.PrimaryPart.Position).Magnitude
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character[Settings.Aim.Part].Position)
                local mPos = Vector2.new(Mouse.X, Mouse.Y)
                local sDist = (Vector2.new(pos.X, pos.Y) - mPos).Magnitude
                if onScreen and sDist <= Settings.Aim.Fov and dist < d then
                    d = dist t = p
                end
            end
        end
    end
    return t
end

AddCon(RunService.RenderStepped, function()
    if Settings.Aim.On then
        local t = GetClosest()
        if t then
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, t.Character[Settings.Aim.Part].Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, Settings.Aim.Smooth)
        end
    end
end)

-- -- 4. Movimento, Noclip & God Mode
AddCon(RunService.Stepped, function()
    pcall(function()
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hum then
            if Settings.Move.SpeedOn then
                hum.WalkSpeed = Settings.Move.Speed
            else
                hum.WalkSpeed = 16
            end

            if not hum:GetAttribute("DefaultJump") then
                hum:SetAttribute("DefaultJump", hum.JumpPower)
            end

            if Settings.Move.JumpOn then
                hum.UseJumpPower = true
                hum.JumpPower = Settings.Move.Jump
            else
                hum.UseJumpPower = true
                local default = hum:GetAttribute("DefaultJump")
                if default then
                    hum.JumpPower = default
                end
            end

            if Settings.God.On then
                if hum.Health ~= hum.MaxHealth and hum.MaxHealth > 0 then
                    hum.Health = hum.MaxHealth
                end
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end

        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = not Settings.Move.Noclip
                end
            end
        end
    end)
end)

-- Fly Logic
if FlyBG then FlyBG:Destroy() end
if FlyBV then FlyBV:Destroy() end
local FlyBG, FlyBV
local function UpdateFly()
    if Settings.Move.Fly and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        if not FlyBG then
            FlyBG = Instance.new("BodyGyro", Player.Character.HumanoidRootPart)
            FlyBG.P = 9e4 FlyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            FlyBV = Instance.new("BodyVelocity", Player.Character.HumanoidRootPart)
            FlyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)
        end
        Player.Character.Humanoid.PlatformStand = true
        FlyBG.CFrame = Camera.CFrame
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        FlyBV.Velocity = dir * Settings.Move.FlySpeed
    else
        if FlyBG then FlyBG:Destroy() FlyBG = nil end
        if FlyBV then FlyBV:Destroy() FlyBV = nil end
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character.Humanoid.PlatformStand = false
        end
    end
end
AddCon(RunService.RenderStepped, UpdateFly)

-- 5. Auto Farm / Clicker
task.spawn(function()
    while Settings.Running do
        if Settings.Farm.Click then
            pcall(function()
                local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
                if mouse1click then mouse1click() elseif mouse1press then mouse1press() task.wait() mouse1release() end
            end)
        end
        task.wait(Settings.Farm.Delay)
    end
end)

-- 6. Render & Segurança
task.spawn(function()
    while Settings.Running do
        if Settings.Render.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        end
        if Settings.Sec.Watch then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (Player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < Settings.Sec.Dist then
                        -- Simples print/alerta interno (Notificações complexas omitidas para leveza)
                        warn("ALERTA: " .. p.Name .. " a " .. math.floor(d) .. " studs!")
                    end
                end
            end
        end
        task.wait(1)
    end
end)

AddCon(Players.PlayerAdded, function(p)
    if Settings.Sec.AntiStaff then
        local n = p.Name:lower()
        if n:find("admin") or n:find("mod") or n:find("staff") or n:find("owner") then Player:Kick("Staff detectada: " .. p.Name) end
    end
end)

-- [[ CONSTRUÇÃO DAS ABAS (UI) ]]

local tHitbox = CreateTab("Hitbox")

tHitbox:CreateToggle("Hitbox Cabeça", function(v)
    Settings.Hitbox.HeadOn = v
    if not v then ResetHitbox() end
end)

tHitbox:CreateToggle("Hitbox Corpo", function(v)
    Settings.Hitbox.BodyOn = v
    if not v then ResetHitbox() end
end)

tHitbox:CreateToggle("Diminuir Minha Hitbox", function(v)
    Settings.Hitbox.SmallSelf = v
end)

tHitbox:CreateInput("Tamanho Cabeça", function(txt)
    local v = tonumber(txt)
    if v then
        Settings.Hitbox.HeadSize = v
    end
end)

tHitbox:CreateInput("Tamanho Corpo", function(txt)
    local v = tonumber(txt)
    if v then
        Settings.Hitbox.BodySize = v
    end
end)
local tCombat = CreateTab("Combate")
tCombat:CreateToggle("Aimbot Distance", function(v) Settings.Aim.On = v end)
tCombat:CreateSlider("Aimbot Smooth", 0.01, 1, 0.1, function(v) Settings.Aim.Smooth = v end)
tCombat:CreateSlider("Aimbot FOV", 50, 800, 200, function(v) Settings.Aim.Fov = v end)
tCombat:CreateToggle("Trigger Bot", function(v) Settings.Trigger.On = v end)
tCombat:CreateToggle("God Mode", function(v) Settings.God.On = v if not v then pcall(function() Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end) end end)

local tMove = CreateTab("Movimento")
tMove:CreateToggle("Ativar Speed", function(v) Settings.Move.SpeedOn = v end)
tMove:CreateSlider("Velocidade", 16, 300, 16, function(v) Settings.Move.Speed = v end)
tMove:CreateToggle("Ativar Fly", function(v) Settings.Move.Fly = v end)
tMove:CreateSlider("Velocidade Fly", 10, 300, 50, function(v) Settings.Move.FlySpeed = v end)
tMove:CreateToggle("Noclip", function(v) Settings.Move.Noclip = v end)
tMove:CreateToggle("Ativar Pulo", function(v) 
    Settings.Move.JumpOn = v 
end)

tMove:CreateSlider("Força do Pulo", 10, 200, 50, function(v) 
    Settings.Move.Jump = v 
end)

local tFarm = CreateTab("Farm/Auto")
tFarm:CreateToggle("Auto-Clicker Hardware", function(v) Settings.Farm.Click = v end)
tFarm:CreateSlider("Click Delay (s * 100)", 1, 100, 1, function(v) Settings.Farm.Delay = v / 100 end)

local tVisual = CreateTab("Otimização")
tVisual:CreateToggle("Fullbright", function(v) Settings.Render.Fullbright = v if not v then Lighting.Brightness = 1 Lighting.GlobalShadows = true end end)
tVisual:CreateToggle("Black Screen Saver", function(v)
    if v then
        local sg = Instance.new("ScreenGui", CoreGui)
        sg.Name = "LoboCat_BS"
        local f = Instance.new("Frame", sg) f.Size = UDim2.new(1,0,1,0) f.BackgroundColor3 = Color3.new(0,0,0)
        Settings.Render.BlackScreen = sg
        RunService:Set3dRenderingEnabled(false)
    else
        if Settings.Render.BlackScreen then Settings.Render.BlackScreen:Destroy() end
        RunService:Set3dRenderingEnabled(true)
    end
end)
tVisual:CreateButton("Potato Graphics", function()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end)
end)
tVisual:CreateSlider("Travar FPS", 5, 240, 60, function(v) if setfpscap then setfpscap(v) end end)

local tWorld = CreateTab("World/Segurança")
tWorld:CreateButton("Server Hop", function()
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in pairs(Servers.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player) break end end
end)
tWorld:CreateButton("Rejoin", function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
tWorld:CreateButton("Ativar Anti-AFK", function() Player.Idled:Connect(function() VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame) end) end)
tWorld:CreateToggle("Auto-Leave Staff", function(v) Settings.Sec.AntiStaff = v end)

local tWay = CreateTab("Waypoints")
local WpContainer = tWay.Frame -- Acessando o frame diretamente
local WaypointButtons = {}

local function RefreshWaypoints()
    for _, btn in pairs(WaypointButtons) do btn:Destroy() end
    WaypointButtons = {}
    for name, cf in pairs(Settings.Waypoints) do
        local btn = Instance.new("TextButton", WpContainer)
        btn.Size = UDim2.new(1, 0, 0, 30) btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215) btn.BorderSizePixel = 0
        btn.Text = "TP: " .. name btn.TextColor3 = Color3.new(1,1,1) btn.Font = Enum.Font.Code
        btn.MouseButton1Click:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.Velocity = Vector3.zero
                Player.Character.HumanoidRootPart.CFrame = cf + Vector3.new(0,3,0)
            end
        end)
        table.insert(WaypointButtons, btn)
    end
end

tWay:CreateInput("Nome do Local", function(txt)
    if txt ~= "" and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Settings.Waypoints[txt] = Player.Character.HumanoidRootPart.CFrame
        RefreshWaypoints()
    end
end)

-- [[ SISTEMA DE KILL SWITCH (X BUTTON) ]]
CloseBtn.MouseButton1Click:Connect(function()
    Settings.Running = false
    for _, c in pairs(Connections) do c:Disconnect() end
    ResetHitbox()
    if Settings.Render.BlackScreen then Settings.Render.BlackScreen:Destroy() end
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    HubUI:Destroy()
end)
