-- [[ SYS_HUB DEFINITIVE EDITION v6.2 - XENO OPTIMIZED ]]

-- Limpeza e Segurança Inicial
local CoreGui = game:GetService("CoreGui")
for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name:find("Sys_") then v:Destroy() end
end

-- AMBIENTE SEGURO PARA XENO (Prevenir index nil)
local RunService, Players, UIS, HttpService
local function GetServices()
    local success = pcall(function()
        RunService = game:GetService("RunService")
        Players = game:GetService("Players")
        UIS = game:GetService("UserInputService")
        HttpService = game:GetService("HttpService")
    end)
    return success and RunService and Players
end

-- Tenta obter os serviços até conseguir (Máximo 5 segundos)
local retry = 0
while not GetServices() and retry < 50 do
    task.wait(0.1)
    retry = retry + 1
end

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera
local uiName = "Sys_" .. math.random(100, 999)

-- [[ ESTADO GLOBAL ]]
local S = {
    Aimbot=false, FOV=150, Smooth=5,
    Hitbox=false, HitboxSize=15,
    HeadHitbox=false, HeadSize=5,
    TriggerBot=false,
    AutoLeave=false,
    MyHitboxSize=2,
    Speed=16, Jump=50, InfJump=false,
    Fly=false, FlySpeed=50,
    Noclip=false, FullBright=false,
    Waypoints={}
}

-- [[ AUTO-SAVE ]]
local fileName = "SysHub_Xeno.json"
local function SaveConfig()
    if writefile then pcall(function() writefile(fileName, HttpService:JSONEncode(S)) end) end
end
local function LoadConfig()
    if isfile and isfile(fileName) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(fileName))
            for k, v in pairs(data) do S[k] = v end
        end)
    end
end
LoadConfig()

-- [[ DESIGN DA UI ]]
local SG = Instance.new("ScreenGui", CoreGui)
SG.Name = uiName
SG.ResetOnSpawn = false

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.fromOffset(550, 420)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Active = true
Main.Draggable = true 
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Instance.new("UICorner", Main)

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.fromOffset(30, 25)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() SG.Enabled = false end)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", Sidebar)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -170, 1, -20)
Container.Position = UDim2.new(0, 160, 0, 10)
Container.BackgroundTransparency = 1

local Tabs = {}
function AddTab(name)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, #Sidebar:GetChildren() * 40 - 35)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)

    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.fromScale(1, 1)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 0
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)

    b.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do
            v.P.Visible = false
            v.B.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        end
        p.Visible = true
        b.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    end)
    Tabs[name] = {P = p, B = b}
    return p
end

function AddNumeric(tab, text, key)
    local f = Instance.new("Frame", tab)
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.6, 0, 1, 0)
    l.Text = text; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = 0
    local box = Instance.new("TextBox", f)
    box.Size = UDim2.fromOffset(70, 25); box.Position = UDim2.new(1, -75, 0.5, -12); box.BackgroundColor3 = Color3.fromRGB(40,40,45)
    box.Text = tostring(S[key]); box.TextColor3 = Color3.new(0,1,0); Instance.new("UICorner", box)
    box.FocusLost:Connect(function() S[key] = tonumber(box.Text:match("%d+%.?%d*")) or S[key]; SaveConfig() end)
end

function AddToggle(tab, text, key)
    local b = Instance.new("TextButton", tab)
    b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = S[key] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(30, 30, 35)
    b.Text = text; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() S[key] = not S[key]; b.BackgroundColor3 = S[key] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(30, 30, 35); SaveConfig() end)
end

local combat = AddTab("Combate")
local player = AddTab("Jogador")
local way = AddTab("Waypoints")
local config = AddTab("Sistema")

AddToggle(combat, "Aimbot Assist", "Aimbot")
AddNumeric(combat, "Raio FOV", "FOV")
AddToggle(combat, "Trigger Bot", "TriggerBot")
AddToggle(combat, "Hitbox (Corpo)", "Hitbox")
AddNumeric(combat, "Tam. Corpo", "HitboxSize")
AddToggle(combat, "Hitbox (Cabeça)", "HeadHitbox")
AddNumeric(combat, "Tam. Cabeça", "HeadSize")

AddNumeric(player, "Velocidade", "Speed")
AddNumeric(player, "Pulo", "Jump")
AddToggle(player, "Voo (Fly)", "Fly")
AddNumeric(player, "Minha Hitbox", "MyHitboxSize")
AddToggle(config, "Auto-Leave (Admins)", "AutoLeave")

-- [[ LÓGICA TRIGGER BOT (SAFE CONNECTION) ]]
task.spawn(function()
    while not RunService do task.wait(0.1) end
    RunService.RenderStepped:Connect(function()
        if S.TriggerBot and Mouse.Target then
            local model = Mouse.Target:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChild("Humanoid") then
                local tp = Players:GetPlayerFromCharacter(model)
                if tp and tp ~= LP and model.Humanoid.Health > 0 then
                    if tp.Team ~= LP.Team or tostring(tp.Team) == "Neutral" then
                        if mouse1click then mouse1click() else game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0)) end
                    end
                end
            end
        end
    end)
end)

-- [[ LOOP DE HITBOX ]]
task.spawn(function()
    while task.wait(0.5) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                local head = p.Character:FindFirstChild("Head")
                if p.Team ~= LP.Team or tostring(p.Team) == "Neutral" then
                    if root and S.Hitbox then
                        root.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                        root.Transparency = 0.8; root.CanCollide = false; root.CanQuery = true; root.Massless = true
                    elseif root then root.Size = Vector3.new(2, 2, 1) end
                    if head and S.HeadHitbox then
                        head.Size = Vector3.new(S.HeadSize, S.HeadSize, S.HeadSize)
                        head.Transparency = 0.5; head.CanCollide = false; head.CanQuery = true; head.Massless = true
                    elseif head then head.Size = Vector3.new(1, 1, 1) end
                end
            end
        end
    end
end)

-- [[ FÍSICA ]]
RunService.Stepped:Connect(function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        if S.Speed > 16 and not S.Fly then
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then hrp.Velocity = Vector3.new(dir.X * S.Speed, hrp.Velocity.Y, dir.Z * S.Speed) end
        end
        if S.MyHitboxSize ~= 2 then
            hrp.Size = Vector3.new(S.MyHitboxSize, S.MyHitboxSize, S.MyHitboxSize); hum.HipHeight = S.MyHitboxSize / 2
        else
            if hrp.Size ~= Vector3.new(2, 2, 1) then hrp.Size = Vector3.new(2, 2, 1); hum.HipHeight = 0 end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightShift then SG.Enabled = not SG.Enabled end end)
Tabs["Combate"].P.Visible = true; Tabs["Combate"].B.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
