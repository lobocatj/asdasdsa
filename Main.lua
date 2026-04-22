-- OTIMIZAÇÃO AVANÇADA (sem gargalos + mais eficiente + mesmas funções)

local uiName="Sys_"..math.random(100,999)
local CoreGui,Players,RunService,UIS,Lighting=game:GetService("CoreGui"),game:GetService("Players"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("Lighting")
local LP=Players.LocalPlayer
local Mouse=LP:GetMouse()
local Camera=workspace.CurrentCamera

-- CLEAN
pcall(function()
    for _,v in ipairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and (v.Name:find("Sys_") or v.Name=="LobocatjHub_Final") then v:Destroy() end
    end
end)

-- STATE
local S={
Aimbot=false,Hitbox=false,InfJump=false,Noclip=false,
HitboxSize=15,FOV=200,Smooth=0.15,Speed=16,Jump=50,
FullBright=false,NoFog=false,ESP=false
}

-- CACHE PLAYERS
local playerCache={}
local function updatePlayers()
    playerCache={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then playerCache[#playerCache+1]=p end
    end
end
updatePlayers()
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

-- AIMBOT (menos alocação)
local function getClosest()
    local cx,cy=Mouse.X,Mouse.Y
    local closest,dist=nil,S.FOV

    for i=1,#playerCache do
        local ch=playerCache[i].Character
        local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos,vis=Camera:WorldToViewportPoint(hrp.Position)
            if vis then
                local dx,dy=pos.X-cx,pos.Y-cy
                local mag=(dx*dx+dy*dy)^0.5
                if mag<dist then dist,closest=mag,hrp end
            end
        end
    end
    return closest
end

-- UI
local SG=Instance.new("ScreenGui",CoreGui);SG.Name=uiName
local Main=Instance.new("Frame",SG)
Main.Size=UDim2.fromOffset(430,320)
Main.Position=UDim2.fromScale(0.5,0.5)-UDim2.fromOffset(215,160)
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
Side.Size=UDim2.new(0,115,1,-28)
Side.Position=UDim2.new(0,0,0,28)
Side.BackgroundColor3=Color3.fromRGB(22,22,26)
Instance.new("UIListLayout",Side).Padding=UDim.new(0,4)

local Content=Instance.new("Frame",Main)
Content.Size=UDim2.new(1,-115,1,-28)
Content.Position=UDim2.new(0,115,0,28)
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
    f.ScrollBarThickness=3
    f.CanvasSize=UDim2.new(0,0,0,0)
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

local combat,move,world,extra=tab("Combat"),tab("Move"),tab("World"),tab("Extra")
combat.Visible=true

-- COMPONENTES
local function toggle(p,t,key)
    local s=false
    local b=Instance.new("TextButton",p)
    b.Size=UDim2.new(1,-8,0,30)
    b.Text=t.." [OFF]"
    b.BackgroundColor3=Color3.fromRGB(45,45,50)
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.Gotham

    b.MouseButton1Click:Connect(function()
        s=not s; S[key]=s
        b.Text=t..(s and " [ON]" or " [OFF]")
        b.BackgroundColor3=s and Color3.fromRGB(0,140,90) or Color3.fromRGB(45,45,50)
    end)
end

local function slider(p,t,min,max,key)
    local v=S[key]
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,-8,0,40)
    f.BackgroundColor3=Color3.fromRGB(40,40,45)

    local txt=Instance.new("TextLabel",f)
    txt.Size=UDim2.new(1,0,0,18)
    txt.Text=t..": "..v
    txt.BackgroundTransparency=1
    txt.TextColor3=Color3.new(1,1,1)

    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(1,-8,0,6)
    bar.Position=UDim2.new(0,4,1,-10)
    bar.BackgroundColor3=Color3.fromRGB(70,70,75)

    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new(v/max,0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,150,100)

    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local c
            c=UIS.InputChanged:Connect(function(m)
                if m.UserInputType==Enum.UserInputType.MouseMovement then
                    local pct=(m.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                    pct=math.clamp(pct,0,1)
                    v=math.floor(min+(max-min)*pct)
                    S[key]=v
                    fill.Size=UDim2.new(pct,0,1,0)
                    txt.Text=t..": "..v
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
toggle(combat,"Aimbot","Aimbot")
toggle(combat,"Hitbox","Hitbox")
slider(combat,"FOV",50,500,"FOV")
slider(combat,"Smooth",1,100,"Smooth")

toggle(move,"Inf Jump","InfJump")
toggle(move,"Noclip","Noclip")
slider(move,"Speed",16,100,"Speed")
slider(move,"Jump",50,150,"Jump")

toggle(world,"FullBright","FullBright")
toggle(world,"No Fog","NoFog")

toggle(extra,"ESP","ESP")
button(extra,"Gravity 0",function() workspace.Gravity=workspace.Gravity==0 and 196.2 or 0 end)

-- FOV CIRCLE (lazy render)
local circle=Drawing.new("Circle")
circle.Thickness=1
circle.NumSides=40
circle.Filled=false

-- LOOPS
RunService.RenderStepped:Connect(function()
    local mx,my=Mouse.X,Mouse.Y+36

    if S.Aimbot then
        circle.Visible=true
        circle.Position=Vector2.new(mx,my)
        circle.Radius=S.FOV
    else
        circle.Visible=false
    end

    if S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=getClosest()
        if t then
            Camera.CFrame=Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position,t.Position),
                S.Smooth/100
            )
        end
    end

    local char=LP.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed=S.Speed
        hum.JumpPower=S.Jump
    end
end)

RunService.Stepped:Connect(function()
    if S.Noclip then
        local char=LP.Character
        if char then
            for _,v in ipairs(char:GetChildren()) do -- otimizado (não usa GetDescendants)
                if v:IsA("BasePart") then v.CanCollide=false end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.8) do -- reduzido carga
        if S.Hitbox then
            for i=1,#playerCache do
                local ch=playerCache[i].Character
                local r=ch and ch:FindFirstChild("HumanoidRootPart")
                if r then
                    r.Size=Vector3.new(S.HitboxSize,S.HitboxSize,S.HitboxSize)
                    r.Transparency=0.7
                    r.CanCollide=false
                end
            end
        end

        if S.FullBright or S.NoFog then
            Lighting.FogEnd=100000
            if S.FullBright then
                Lighting.Brightness=2
                Lighting.ClockTime=14
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

UIS.InputBegan:Connect(function(i,g)
    if not g and i.KeyCode==Enum.KeyCode.RightShift then
        SG.Enabled=not SG.Enabled
    end
end)

-- CLOSE
Close.MouseButton1Click:Connect(function()
    circle:Remove()
    SG:Destroy()
end)

print("Sys otimizado MAX")
