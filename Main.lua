-- [[ SYS_HUB DEFINITIVE EDITION v6.2 - XENO PATCH + FINAL ANTI-KICK ENGINE ]]
-- MODIFICADO: Fix Hitbox (Dano), Team Check e TriggerBot Universal

-- ... (Mantenha todo o início do seu código igual até a parte das lógicas) ...

-- [[ LÓGICA TRIGGER BOT (ATUALIZADA COM TEAM CHECK) ]]
RunService.RenderStepped:Connect(function()
    if S.TriggerBot and Mouse.Target then
        local model = Mouse.Target:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") then
            local targetPlayer = Players:GetPlayerFromCharacter(model)
            
            -- Verifica se o alvo existe, não é você, está vivo e NÃO é do seu time
            if targetPlayer and targetPlayer ~= LP and model.Humanoid.Health > 0 then
                if targetPlayer.Team ~= LP.Team or tostring(targetPlayer.Team) == "Neutral" then
                    if mouse1click then
                        mouse1click()
                    else
                        -- Fallback para executores que não tem mouse1click
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                    end
                end
            end
        end
    end
end)

-- [[ LOOP DE HITBOX (ATUALIZADO COM TEAM CHECK E FIX DE DANO) ]]
task.spawn(function()
    while task.wait(0.5) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                -- TEAM CHECK: Só aplica a hitbox se for inimigo ou neutro
                if p.Team ~= LP.Team or tostring(p.Team) == "Neutral" then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    local head = p.Character:FindFirstChild("Head")
                    
                    -- Hitbox Corpo
                    if root then
                        if S.Hitbox then
                            root.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                            root.Transparency = 0.8
                            root.CanCollide = false
                            root.CanQuery = true -- PERMITE QUE A BALA DETECTE O HIT
                        else
                            root.Size = Vector3.new(2, 2, 1)
                            root.Transparency = 1
                        end
                    end

                    -- Hitbox Cabeça (Separada)
                    if head then
                        if S.HeadHitbox then
                            head.Size = Vector3.new(S.HeadSize, S.HeadSize, S.HeadSize)
                            head.Transparency = 0.5
                            head.CanCollide = false
                            head.CanQuery = true -- ESSENCIAL PARA HEADSHOTS
                        else
                            head.Size = Vector3.new(1, 1, 1)
                            head.Transparency = 0
                        end
                    end
                else
                    -- Se for do mesmo time, reseta para o padrão (Anti-Friendly Fire)
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    local head = p.Character:FindFirstChild("Head")
                    if root then root.Size = Vector3.new(2, 2, 1) end
                    if head then head.Size = Vector3.new(1, 1, 1) end
                end
            end
        end
    end
end)

-- ... (O resto do seu código de Voo, Waypoints e Movimentação continua abaixo) ...
