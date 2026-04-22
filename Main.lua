-- COMPACT + OTIMIZADO (mesmas funções, menos overhead, mais estável)

local uiName = "Sys_" .. math.random(100,999)
local CoreGui,Players,RunService,UIS = game:GetService("CoreGui"),game:GetService("Players"),game:GetService("RunService"),game:GetService("UserInputService")
local LP,Mouse,Camera = Players.LocalPlayer,Players.LocalPlayer:GetMouse(),workspace.CurrentCamera

pcall(function()
    for _,v in ipairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name:find("Sys_") or v.Name=="LobocatjHub_Final") then v:Destroy() end
    end
end)

-- STATES
local S = {
    Aimbot=false,Hitbox=false,InfJump=false,Noclip=false,HitboxSize=15
}

-- AIMBOT (mais leve)
local function getClosest()
    local c,d = nil,350
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local ch=p.Character
            local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos,vis=Camera:WorldToViewportPoint(hrp.Position)
                if vis then
                    local mag=(Vector2.new(pos.X,pos.Y)-Vector2.new(Mouse.X,Mouse.Y)).Magnitude
                    if mag<d then d,c=mag,hrp end
                end
            end
        end
    end
    return c
end

-- UI
local SG=Instance.new("ScreenGui",CoreGui);SG.Name=uiName
local Main=Instance.new("Frame",SG)
Main.Size=UDim2.fromOffset(410,310)
Main.Position=UDim2.fromScale(0.5,0.5)-UDim2.fromOffset(205,155)
Main.BackgroundColor3=Color3.fromRGB(18,18,22)
Main.Active,Main.Draggable=true,true
Instance.new("UICorner",Main)

local Top=Instance.new("Frame",Main)
Top.Size=UDim2.new(1,0,0,28)
Top.BackgroundColor3=Color3.fromRGB(25,25,30)

local Close=Instance.new("TextButton",Top)
Close.Size=UDim2.fromOffset(25,18)
Close.Position=UDim2.new(1,-28,0.5,-9)
Close.Text="X"
Close.BackgroundColor3=Color3.fromRGB(140,0,0)
Close.TextColor3=Color3.new(1,1,1)
Close.Font=Enum.Font.GothamBold
Instance.new("UICorner",Close)

local Side=Instance.new("Frame",Main)
Side.Size=UDim2.new(0,110,1,-28)
Side.Position=UDim2.new(0,0,0,28)
Side.BackgroundColor3=Color3.fromRGB(22,22,26)
Instance.new("UIListLayout",Side).Padding=UDim.new(0,4)

local Content=Instance.new("Frame",Main)
Content.Size=UDim2.new(1,-110,1,-28)
Content.Position=UDim2.new(0,110,0,28)
Content.BackgroundTransparency=1

local Tabs={}
local function tab(n)
    local b=Instance.new("TextButton",Side)
    b.Size=UDim2.new(1,0,0,32)
    b.Text=n
    b.BackgroundColor3=Color3.fromRGB(35,35,40)
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamBold

    local f=Instance.new("ScrollingFrame",Content)
    f.Size=UDim2.new(1,0,1,0)
    f.CanvasSize=UDim2.new(0,0,0,0)
    f.ScrollBarThickness=3
    f.Visible=false
    f.BackgroundTransparency=1

    local l=Instance.new("UIListLayout",f)
    l.Padding=UDim.new(0,5)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        f.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+5)
    end)

    b.MouseButton1Click:Connect(function()
        for _,v in pairs(Tabs) do v.Visible=false end
        f.Visible=true
    end)

    Tabs[n]=f
    return f
end

local combat,move,extra=tab("Combat"),tab("Movement"),tab("Extra")
combat.Visible=true

-- COMPONENTES
local function toggle(p,t,ref)
    local s=false
    local b=Instance.new("TextButton",p)
    b.Size=UDim2.new(1,-8,0,30)
    b.Text=t.." [OFF]"
    b.BackgroundColor3=Color3.fromRGB(45,45,50)
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.Gotham

    b.MouseButton1Click:Connect(function()
        s=not s; S[ref]=s
        b.Text=t..(s and " [ON]" or " [OFF]")
        b.BackgroundColor3=s and Color3.fromRGB(0,140,90) or Color3.fromRGB(45,45,50)
    end)
end

local function slider(p)
    local v=S.HitboxSize
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,-8,0,40)
    f.BackgroundColor3=Color3.fromRGB(40,40,45)

    local txt=Instance.new("TextLabel",f)
    txt.Size=UDim2.new(1,0,0,18)
    txt.Text="Hitbox: "..v
    txt.BackgroundTransparency=1
    txt.TextColor3=Color3.new(1,1,1)

    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(1,-8,0,6)
    bar.Position=UDim2.new(0,4,1,-10)
    bar.BackgroundColor3=Color3.fromRGB(70,70,75)

    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new(v/50,0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,150,100)

    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local c
            c=UIS.InputChanged:Connect(function(m)
                if m.UserInputType==Enum.UserInputType.MouseMovement then
                    local pct=math.clamp((m.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    v=math.floor(1+(50-1)*pct)
                    S.HitboxSize=v
                    fill.Size=UDim2.new(pct,0,1,0)
                    txt.Text="Hitbox: "..v
                end
            end)
            UIS.InputEnded:Once(function() c:Disconnect() end)
        end
    end)
end

local function button(p,t,cb)
    local b=Instance.new("TextButton",p)
    b.Size=UDim2.new(1,-8,0,30)
    b.Text=t
    b.BackgroundColor3=Color3.fromRGB(60,60,65)
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.Gotham
    b.MouseButton1Click:Connect(cb)
end

-- UI ELEMENTS
toggle(combat,"Aimbot (M2)","Aimbot")
toggle(combat,"Hitbox","Hitbox")
slider(combat)

toggle(move,"Inf Jump","InfJump")
toggle(move,"Noclip","Noclip")

button(extra,"Gravity 0",function()
    workspace.Gravity = workspace.Gravity==0 and 196.2 or 0
end)

-- LOOPS
RunService.RenderStepped:Connect(function()
    if S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=getClosest()
        if t then
            Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,t.Position),0.15)
        end
    end
end)

RunService.Stepped:Connect(function()
    if S.Noclip and LP.Character then
        for _,v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end
end)

task.spawn(function()
    while task.wait(0.6) do
        if S.Hitbox then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then
                    local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if r then
                        r.Size=Vector3.new(S.HitboxSize,S.HitboxSize,S.HitboxSize)
                        r.Transparency=0.7
                        r.CanCollide=false
                    end
                end
            end
        end
    end
end)

-- INPUTS
UIS.JumpRequest:Connect(function()
    if S.InfJump then
        local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Mouse.Button1Down:Connect(function()
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) and Mouse.Target then
        local c=LP.Character
        if c then c:MoveTo(Mouse.Hit.p) end
    end
end)

Close.MouseButton1Click:Connect(function() SG:Destroy() end)

print("Sys compacto carregado")
