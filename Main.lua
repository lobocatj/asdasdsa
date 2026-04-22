--[[
    LOBOCATJ HUB V9.0 - STEALTH EDITION
    - Antidetect: Camuflagem de UI e Renomeação de Instância
    - Aimbot: Silent Aim integrado (Foca no jogador mais próximo do mouse)
]]

-- Proteção inicial: Deleta se já existir
local uiName = "RobloxSystemControl_" .. math.random(100, 999)
if game:GetService("CoreGui"):FindFirstChildOfClass("ScreenGui") and game:GetService("CoreGui"):FindFirstChildOfClass("ScreenGui").Name:find("RobloxSystem") then
    game:GetService("CoreGui"):FindFirstChildOfClass("ScreenGui"):Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- --- CONFIGS ---
_G.AimbotEnabled = false
_G.HitboxEnabled = false
_G.HitboxSize = 15
_G.InfJump = false

-- --- FUNÇÃO AIMBOT (SEGURO) ---
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < shortestDist and dist < 400 then
                    closest = p.Character.HumanoidRootPart
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

-- --- UI CAMUFLADA ---
local SG = Instance.new("ScreenGui", game:GetService("CoreGui"))
SG.Name = uiName
SG.IgnoreGuiInset = true

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 480, 0, 360); Main.Position = UDim2.new(0.5, -240, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 100)

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Instance.new("UICorner", Sidebar)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -140, 1, -50); Content.Position = UDim2.new(0, 135, 0, 45); Content.BackgroundTransparency = 1

local Tabs = {}
local function createTab(name)
    local f = Instance.new("ScrollingFrame", Content)
    f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.Visible = false
    f.ScrollBarThickness = 0; f.CanvasSize = UDim2.new(0, 0, 2, 0)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 8)
    Tabs[name] = f
    return f
end

local function addTabBtn(name, index)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(0.9, 0, 0, 32); b.Position = UDim2.new(0.05, 0, 0, 50 + (index * 38))
    b.Text = name; b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = "GothamBold"; b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        Tabs[name].Visible = true
    end)
end

local combatT = createTab("Combate"); addTabBtn("Combate", 0)
local moveT = createTab("Movimento"); addTabBtn("Movimento", 1)
local servT = createTab("Serviços"); addTabBtn("Serviços", 2)
Tabs["Combate"].Visible = true

-- Botão Fechar
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 25, 0, 25); Close.Position = UDim2.new(1, -30, 0, 5)
Close.Text = "X"; Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0); Close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Close); Close.MouseButton1Click:Connect(function() SG:Destroy() end)

-- --- FUNÇÕES ---
local function btn(parent, text, color, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = text; b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
end

-- ABA COMBATE
btn(combatT, "AIMBOT (SEGURAR BOTÃO DIR.)", Color3.fromRGB(0, 100, 200), function() _G.AimbotEnabled = not _G.AimbotEnabled end)
btn(combatT, "HITBOX INIMIGOS", Color3.fromRGB(0, 150, 80), function() _G.HitboxEnabled = not _G.HitboxEnabled end)

-- ABA MOVIMENTO
btn(moveT, "PULO INFINITO", Color3.fromRGB(80, 0, 150), function() _G.InfJump = not _G.InfJump end)

-- --- LOOPS DE EXECUÇÃO ---

-- Loop do Aimbot (Suave)
RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
end)

-- Loop de Hitbox e Otimização
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if _G.HitboxEnabled then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local r = p.Character:FindFirstChild("HumanoidRootPart")
                        if r then 
                            r.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                            r.Transparency = 0.8; r.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
end)

UserInputService.JumpRequest:Connect(function() if _G.InfJump then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)

print("Lobocatj Hub Loaded Stealthily!")
