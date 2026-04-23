-- [[ SYS_HUB DEFINITIVE EDITION v6.2 - XENO PATCH + FINAL ANTI-KICK ENGINE ]]

local uiName = "Sys_" .. math.random(100, 999)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

-- Limpeza de versões anteriores
for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name:find("Sys_") then v:Destroy() end
end

-- [[ ESTADO GLOBAL ]]
local S = {
    Aimbot=false, FOV=150, Smooth=5,
    Hitbox=false, HitboxSize=15,
    MyHitboxSize=2,
    Speed=16, Jump=50, InfJump=false,
    Fly=false, FlySpeed=50,
    Noclip=false, FullBright=false,
    Waypoints={}
}

-- [[ UI SYSTEM v6.2 DESIGN ]]
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
    l.Text = text
    l.TextColor3 = Color3.new(1,1,1)
    l.BackgroundTransparency = 1
    l.TextXAlignment = 0

    local box = Instance.new("TextBox", f)
    box.Size = UDim2.fromOffset(70, 25)
    box.Position = UDim2.new(1, -75, 0.5, -12)
    box.BackgroundColor3 = Color3.fromRGB(40,40,45)
    box.Text = tostring(S[key])
    box.TextColor3 = Color3.new(0,1,0)
    Instance.new("UICorner", box)

    box.FocusLost:Connect(function()
        S[key] = tonumber(box.Text:match("%d+%.?%d*")) or S[key]
    end)
end

function AddToggle(tab, text, key)
    local b = Instance.new("TextButton", tab)
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)

    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        b.BackgroundColor3 = S[key] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(30, 30, 35)
    end)
end

-- Configuração das Abas
local combat = AddTab("Combate")
local player = AddTab("Jogador")
local way = AddTab("Waypoints")

AddToggle(combat, "Aimbot Assist", "Aimbot")
AddNumeric(combat, "Raio FOV", "FOV")
AddToggle(combat, "Hitbox Inimiga", "Hitbox")
AddNumeric(combat, "Tamanho Inimigo", "HitboxSize")

AddNumeric(player, "Velocidade", "Speed")
AddNumeric(player, "Pulo", "Jump")
AddToggle(player, "Voo (Fly)", "Fly")
AddNumeric(player, "Velocidade Voo", "FlySpeed")
AddToggle(player, "Atravessar (Noclip)", "Noclip")
AddNumeric(player, "Minha Hitbox", "MyHitboxSize")

-- [[ WAYPOINTS ]]
local wpInput = Instance.new("TextBox", way)
wpInput.Size = UDim2.new(1, 0, 0, 30)
wpInput.PlaceholderText = "Nome do local..."
wpInput.BackgroundColor3 = Color3.fromRGB(40,40,45)
wpInput.TextColor3 = Color3.new(1,1,1)

local addWp = Instance.new("TextButton", way)
addWp.Size = UDim2.new(1, 0, 0, 30)
addWp.Text = "Salvar Posição Atual"
addWp.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
addWp.TextColor3 = Color3.new(1,1,1)

local wpList = Instance.new("ScrollingFrame", way)
wpList.Size = UDim2.new(1, 0, 0, 200)
wpList.BackgroundTransparency = 1
Instance.new("UIListLayout", wpList).Padding = UDim.new(0, 5)

local function RefreshWaypoints()
    for _, v in ipairs(wpList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for i, w in ipairs(S.Waypoints) do
        local f = Instance.new("Frame", wpList)
        f.Size = UDim2.new(1, 0, 0, 35)
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(0.4, 0, 1, 0)
        t.Text = " " .. w.Name
        t.TextColor3 = Color3.new(1,1,1)
        t.BackgroundTransparency = 1
        t.TextXAlignment = 0

        local go = Instance.new("TextButton", f)
        go.Size = UDim2.new(0.25, 0, 0.8, 0)
        go.Position = UDim2.new(0.45, 0, 0.1, 0)
        go.Text = "IR"
        go.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        Instance.new("UICorner", go)

        local del = Instance.new("TextButton", f)
        del.Size = UDim2.new(0.25, 0, 0.8, 0)
        del.Position = UDim2.new(0.72, 0, 0.1, 0)
        del.Text = "DEL"
        del.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        Instance.new("UICorner", del)

        go.MouseButton1Click:Connect(function()
            if LP.Character then LP.Character:MoveTo(w.Pos) end
        end)

        del.MouseButton1Click:Connect(function()
            table.remove(S.Waypoints, i)
            RefreshWaypoints()
        end)
    end
end

addWp.MouseButton1Click:Connect(function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        table.insert(S.Waypoints, { Name = wpInput.Text ~= "" and wpInput.Text or "Local "..#S.Waypoints+1, Pos = hrp.Position })
        wpInput.Text = ""
        RefreshWaypoints()
    end
end)

-- [[ LOOP DE FÍSICA E MINHA HITBOX ]]
RunService.Stepped:Connect(function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hrp and hum then
        -- Speed & Noclip
        if S.Speed > 16 and not S.Fly then
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                hrp.Velocity = Vector3.new(dir.X * S.Speed, hrp.Velocity.Y, dir.Z * S.Speed)
            end
        end
        if S.Noclip then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end

        -- CORREÇÃO MINHA HITBOX
        if S.MyHitboxSize ~= 2 then
            hrp.Size = Vector3.new(S.MyHitboxSize, S.MyHitboxSize, S.MyHitboxSize)
            hum.HipHeight = S.MyHitboxSize / 2
        else
            -- Reset real para o padrão se for 2
            if hrp.Size ~= Vector3.new(2, 2, 1) then
                hrp.Size = Vector3.new(2, 2, 1)
                hum.HipHeight = 0
            end
        end
    end
end)

-- [[ HITBOX INIMIGA - FIX DE DESATIVAÇÃO ]]
local playerCache = {}
local function updateCache()
    table.clear(playerCache)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(playerCache, p) end
    end
end
Players.PlayerAdded:Connect(updateCache)
Players.PlayerRemoving:Connect(updateCache)
updateCache()

task.spawn(function()
    while task.wait(0.3) do
        for _, p in ipairs(playerCache) do
            local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if S.Hitbox then
                    root.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                    root.Transparency = 0.8
                    root.CanCollide = false
                else
                    -- FORÇA A VOLTA PARA O PADRÃO QUANDO DESATIVADO
                    if root.Size ~= Vector3.new(2, 2, 1) then
                        root.Size = Vector3.new(2, 2, 1)
                        root.Transparency = 0
                        root.CanCollide = true
                    end
                end
            end
        end
    end
end)

-- Jump, Fly e Atalho
UIS.JumpRequest:Connect(function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp and S.Jump > 50 then hrp.Velocity = Vector3.new(hrp.Velocity.X, S.Jump, hrp.Velocity.Z) end
end)

RunService.Heartbeat:Connect(function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if S.Fly and hrp then
        local bv = hrp:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyVel"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        bv.Velocity = dir * S.FlySpeed; hrp.Velocity = Vector3.zero
    elseif hrp and hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightShift then SG.Enabled = not SG.Enabled end
end)

Tabs["Combate"].P.Visible = true
Tabs["Combate"].B.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
