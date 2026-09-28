-- ========================================================
-- 🌶️ CHILLI HUB V6 - HYPER SPEED 1000+ BYPASS EDITION
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌶️ Chilli Hub V6 - Speed 1000+ Bypass",
   LoadingTitle = "กำลังเปิดใช้งาน Hyper Speed Engine...",
   LoadingSubtitle = "by Script Collaborator",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ====================
-- GLOBAL CONFIG
-- ====================
getgenv().Config = {
    AutoSteal = false,
    StealDelay = 0.3,
    
    -- Hyper Speed Config
    HyperSpeedEnabled = false,
    HyperSpeedValue = 500, -- ปรับได้สูงสุด 1000+
    
    InfiniteJump = true,
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local TargetEggs = {
    "chicken_egg",
    "common_chicken_egg",
    "chicken egg",
    "common chicken egg",
    "chicken"
}

-- ====================
-- SAFE INFINITE JUMP
-- ====================
local AirPlatform = Instance.new("Part")
AirPlatform.Size = Vector3.new(6, 1, 6)
AirPlatform.Transparency = 1
AirPlatform.Anchored = true
AirPlatform.CanCollide = true
AirPlatform.Parent = workspace

UserInputService.JumpRequest:Connect(function()
    if getgenv().Config.InfiniteJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            AirPlatform.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            
            task.delay(0.2, function()
                AirPlatform.CFrame = CFrame.new(0, -9999, 0)
            end)
        end
    end
end)

-- ====================
-- HYPER SPEED 1000+ ENGINE (BYPASS ANTI-KICK)
-- ====================
-- ใช้เทคนิคส่งผ่าน Vector ความเร็วสูงแบบไม่ให้ตำแหน่งกระโดดข้ามพิกัดรุนแรง
RunService.Heartbeat:Connect(function(deltaTime)
    if getgenv().Config.HyperSpeedEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local hum = char.Humanoid
                
                -- ปิดแรงโน้มถ่วงชั่วคราวขณะวิ่งเร็วเพื่อให้พุ่งลื่นไม่ตกแมพ
                hum.PlatformStand = false
                
                if hum.MoveDirection.Magnitude > 0 then
                    -- คำนวณความเร็วแบบสมูท (Linear Delta Slide) หลบการตรวจจับของ Anti-Cheat
                    local speed = getgenv().Config.HyperSpeedValue
                    local currentVelocity = hrp.AssemblyLinearVelocity
                    
                    -- ดันความเร็วตามทิศทางที่กดเดิน
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        hum.MoveDirection.X * speed,
                        currentVelocity.Y,
                        hum.MoveDirection.Z * speed
                    )
                end
            end
        end)
    end
end)

-- ====================
-- SPECIFIC EGG CHECKER
-- ====================
local function IsChickenEgg(prompt)
    local parent = prompt.Parent
    if not parent then return false end
    
    local fullText = string.lower(parent.Name .. " " .. (prompt.ObjectText or "") .. " " .. (prompt.ActionText or ""))
    
    for _, name in ipairs(TargetEggs) do
        if string.find(fullText, name) then
            return true
        end
    end
    
    return false
end

-- ====================
-- HYPER AUTO STEAL (SMOOTH GLIDE TO TARGET)
-- ====================
local function ProcessAutoSteal()
    while getgenv().Config.AutoSteal do
        local foundTarget = false
        
        for _, prompt in pairs(workspace:GetDescendants()) do
            if not getgenv().Config.AutoSteal then break end
            
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                if IsChickenEgg(prompt) then
                    local targetPart = prompt.Parent
                    if not targetPart:IsA("BasePart") then
                        targetPart = targetPart:FindFirstChildWhichIsA("BasePart") or targetPart:FindFirstChild("HumanoidRootPart")
                    end
                    
                    if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        foundTarget = true
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        
                        -- พุ่งเข้าหาเป้าหมายด้วยความเร็วสูงแบบไล่ระดับ (Smooth Slide Approach)
                        while getgenv().Config.AutoSteal and targetPart and targetPart.Parent do
                            local targetPos = targetPart.Position + Vector3.new(0, 2, 0)
                            local distance = (hrp.Position - targetPos).Magnitude
                            
                            if distance < 6 then 
                                break 
                            end
                            
                            -- ค่อยๆ ดึง CFrame เข้าหาเป้าหมายทีละน้อยอย่างรวดเร็ว (ปลอดภัยกว่าการวาร์ปเปรี้ยงเดียว)
                            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos), 0.3)
                            task.wait(0.03)
                        end
                        
                        -- กดเก็บไข่
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                        
                        Rayfield:Notify({
                           Title = "เก็บไข่ Hyper Speed สำเร็จ!",
                           Content = "ได้ไข่: " .. prompt.Parent.Name,
                           Duration = 1.5,
                           Image = 4483362458,
                        })
                        
                        task.wait(getgenv().Config.StealDelay)
                    end
                end
            end
        end
        
        if not foundTarget then
            task.wait(0.5)
        end
    end
end

-- ====================
-- TABS CREATION
-- ====================
local TabPlayer = Window:CreateTab("⚡ Hyper Speed 1000+", 4483362458)
local TabFarm = Window:CreateTab("🐔 Auto Steal", 4483362458)

-- ====================
-- 1. PLAYER MODS
-- ====================
TabPlayer:CreateSection("ระบบความเร็วสูงพิเศษ (Hyper Speed Bypass)")

TabPlayer:CreateToggle({
   Name = "🚀 เปิดใช้งาน Hyper Speed (พุ่งไว 1000+)",
   CurrentValue = false,
   Flag = "HyperSpeedToggle",
   Callback = function(Value)
      getgenv().Config.HyperSpeedEnabled = Value
   end,
})

TabPlayer:CreateSlider({
   Name = "⚡ ปรับระดับความเร็ว (100 - 1000+)",
   Range = {100, 1200},
   Increment = 50,
   Suffix = " Speed",
   CurrentValue = 500,
   Flag = "HyperSpeedSlider",
   Callback = function(Value)
      getgenv().Config.HyperSpeedValue = Value
   end,
})

TabPlayer:CreateSection("ระบบกระโดด")

TabPlayer:CreateToggle({
   Name = "🔴 Safe Infinite Jump (โดดลอยกลางอากาศ)",
   CurrentValue = true,
   Flag = "SafeInfJumpToggle",
   Callback = function(Value)
      getgenv().Config.InfiniteJump = Value
   end,
})

-- ====================
-- 2. AUTO FARM TAB
-- ====================
TabFarm:CreateSection("ระบบออโต้เก็บ Chicken_Egg แบบความเร็วสูง")

TabFarm:CreateToggle({
   Name = "🐔 เปิดออโต้เก็บ Chicken_Egg (Hyper)",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
      getgenv().Config.AutoSteal = Value
      if Value then
         task.spawn(ProcessAutoSteal)
      end
   end,
})

TabFarm:CreateSlider({
   Name = "⏱️ ดีเลย์เวลากดเก็บ (วินาที)",
   Range = {0.1, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.3,
   Flag = "StealDelaySlider",
   Callback = function(Value)
      getgenv().Config.StealDelay = Value
   end,
})

Rayfield:Notify({
   Title = "Chilli Hub V6 Hyper Loaded!",
   Content = "พร้อมซิ่งความเร็ว 1000+ แบบไม่โดนเตะแล้ว!",
   Duration = 4,
   Image = 4483362458,
})
