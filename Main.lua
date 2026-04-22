--[[
    LOBOCATJ HUB V7.8 - ULTIMATE & FIXED
    - Nome: LOBOCATJ HUB
    - Correção: Minha Hitbox Pequena (Não trava mais ao andar)
    - Correção: Hitbox de Inimigos (Ignora o LocalPlayer)
    - Funções: Hitbox, Movimento, Serviços, Scanner de Conta e Modo Caos
]]

if game.CoreGui:FindFirstChild("LobocatjHub_Final") then 
    game.CoreGui:FindFirstChild("LobocatjHub_Final"):Destroy() 
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Mouse = LocalPlayer:GetMouse()

-- --- CONFIGS ---
_G.HitboxSize = 15
_G.HitboxEnabled = false
_G.InfJump = false
_G.Noclip = false
_G.SmallHitbox = false
_G.ScannerTarget = LocalPlayer

-- --- UI PRINCIPAL ---
local SG = Instance.new("ScreenGui", game.CoreGui); SG.Name = "LobocatjHub_Final"
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 480, 0, 360)
Main.Position = UDim2.new(0.5, -240, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 100)

-- Barra Lateral
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Instance.new("UICorner", Sidebar)

-- Título
local HubTitle = Instance.new("TextLabel", Sidebar)
HubTitle.Size = UDim2.new(1, 0, 0, 45)
HubTitle.Text = "LOBOCATJ HUB"
HubTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
HubTitle.Font = "Orbitron"
HubTitle.TextSize = 14
HubTitle.BackgroundTransparency = 1

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -140, 1, -50); Content.Position = UDim2.new(0, 135, 0, 45)
Content.BackgroundTransparency = 1

local Tabs = {}
local function createTabFrame(name)
    local f = Instance.new("ScrollingFrame", Content)
    f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1
    f.Visible = false; f.ScrollBarThickness = 2
    f.CanvasSize = UDim2.new(0, 0, 2, 0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 8)
    Tabs[name] = f
    return f
end

local function addTabBtn(name, index)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0.9, 0, 0, 32); b.Position = UDim2.new(0.05, 0, 0, 55 + (index * 38))
    b.Text = name; b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.TextColor3 = Color3.new(1, 1, 1); b.Font = "GothamBold"; b.TextSize = 10
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        for _, frame in pairs(Tabs) do frame.Visible = false end
        Tabs[name].Visible = true
    end)
end

-- Criando Abas
local combatT = createTabFrame("Combate")
local moveT = createTabFrame("Movimento")
local scanT = createTabFrame("Scanner")
local servT = createTabFrame("Serviços")
local chaosT = createTabFrame("CAOS")

addTabBtn("Combate", 0); addTabBtn("Movimento", 1); addTabBtn("Scanner", 2); addTabBtn("Serviços", 3); addTabBtn("CAOS", 4)
Tabs["Combate"].Visible = true

-- Botão Fechar
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 25, 0, 25); Close.Position = UDim2.new(1, -30, 0, 5)
Close.Text = "X"; Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0); Close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Close); Close.MouseButton1Click:Connect(function() SG:Destroy() end)

-- --- FUNÇÕES AUXILIARES ---
local function btn(parent, text, color, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = text; b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 11
    Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb)
end

-- --- CONTEÚDO ABAS ---

-- ABA COMBATE
btn(combatT, "HITBOX INIMIGOS: ON/OFF", Color3.fromRGB(0, 150, 80), function() _G.HitboxEnabled = not _G.HitboxEnabled end)

btn(combatT, "MINHA HITBOX: PEQUENA", Color3.fromRGB(0, 80, 150), function()
    _G.SmallHitbox = not _G.SmallHitbox
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if root and hum then
        if _G.SmallHitbox then
            root.Size = Vector3.new(0.5, 0.5, 0.5)
            hum.HipHeight = 1.8 -- Ajuste para não travar no chão
        else
            root.Size = Vector3.new(2, 2, 1)
            hum.HipHeight = 0
        end
    end
end)

-- ABA MOVIMENTO
btn(moveT, "PULO INFINITO", Color3.fromRGB(80, 0, 150), function() _G.InfJump = not _G.InfJump end)
btn(moveT, "NOCLIP (PAREDES)", Color3.fromRGB(150, 100, 0), function() _G.Noclip = not _G.Noclip end)

-- ABA SERVIÇOS
btn(servT, "SCANNER DE ITENS SEGURO", Color3.fromRGB(50, 50, 60), function()
    local found = 0
    local targets = {game.Lighting, game.ReplicatedStorage, workspace}
    for _, container in pairs(targets) do
        for _, item in pairs(container:GetDescendants()) do
            if item:IsA("Tool") then
                pcall(function() item:Clone().Parent = LocalPlayer.Backpack end)
                found = found + 1
            end
        end
    end
    print("Lobocatj: Encontrados " .. found .. " itens.")
end)

-- ABA CAOS
btn(chaosT, "GRAVIDADE ZERO (RISCO!)", Color3.fromRGB(200, 0, 0), function() workspace.Gravity = (workspace.Gravity == 0 and 196.2 or 0) end)

-- --- LOOP DE FUNCIONAMENTO (SISTEMA CENTRAL) ---
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Hitbox nos Inimigos (Ignora Você)
            if _G.HitboxEnabled then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local r = p.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            r.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                            r.Transparency = 0.7; r.Material = "Neon"; r.CanCollide = false
                        end
                    end
                end
            end
            
            -- Noclip Seu
            if _G.Noclip and LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end
end)

-- Pulo Infinito e Teleporte
UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end
end)

Mouse.Button1Down:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and Mouse.Target then
        LocalPlayer.Character:MoveTo(Mouse.Hit.p)
    end
end)
