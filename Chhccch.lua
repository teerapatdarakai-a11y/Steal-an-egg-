-- ========================================================
-- 🌶️ CHILLI HUB V5.1 - CHICKEN EGG TEST EDITION
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌶️ Chilli Hub V5.1 - Chicken Egg Test",
   LoadingTitle = "กำลังโหลดระบบเทสขโมยไข่...",
   LoadingSubtitle = "by Script Collaborator",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ====================
-- GLOBAL CONFIG
-- ====================
getgenv().Config = {
    AutoSteal = false,
    StealDelay = 0.2,
    TweenSpeed = 80,
    
    CFrameSpeed = 16, -- ปรับความเร็ววิ่งพุ่งได้สูงสุด 1000
    EnableSpeedHack = false,
    
    JumpPower = 50,
    InfiniteJump = true,
}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- รายชื่อเป้าหมายเฉพาะสำหรับการทดสอบ
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
AirPlatform.Size = Vector3.new(8, 1, 8)
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
-- CFRAME SPEED ENGINE (SPEED 1000+)
-- ====================
RunService.PreRender:Connect(function(deltaTime)
    if getgenv().Config.EnableSpeedHack then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            if hum.MoveDirection.Magnitude > 0 then
                local moveSpeed = getgenv().Config.CFrameSpeed
                local velocity = hum.MoveDirection * (moveSpeed - hum.WalkSpeed) * deltaTime
                hrp.CFrame = hrp.CFrame + velocity
            end
        end
    end
end)

-- ====================
-- SPECIFIC EGG CHECKER
-- ====================
local function IsChickenEgg(prompt)
    local parent = prompt.Parent
    if not parent then return false end
    
    -- รวมข้อความจากชื่อโมเดล, ข้อความปุ่มกด เพื่อสแกนหาคำ
    local fullText = string.lower(parent.Name .. " " .. prompt.ObjectText .. " " .. prompt.ActionText)
    
    for _, name in ipairs(TargetEggs) do
        if string.find(fullText, name) then
            return true
        end
    end
    
    return false
end

local function SafeTweenToCFrame(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        
        if distance < 5 then
            hrp.CFrame = targetCFrame
            return
        end

        local duration = distance / getgenv().Config.TweenSpeed
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait()
    end
end

-- ====================
-- AUTO STEAL PROCESSOR
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
                    
                    if targetPart then
                        foundTarget = true
                        
                        -- บายพาสปุ่มกด
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = 9999
                        
                        -- บินวาร์ปไปหาไข่
                        SafeTweenToCFrame(targetPart.CFrame * CFrame.new(0, 3, 2))
                        task.wait(0.05)
                        
                        -- สั่งขโมยแบบ Dual Bypass
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                        
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end)
                        
                        Rayfield:Notify({
                           Title = "ขโมยไข่ไก่สำเร็จ!",
                           Content = "ขโมย: " .. prompt.Parent.Name,
                           Duration = 2,
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
local TabPlayer = Window:CreateTab("⚡ Speed & Jump", 4483362458)
local TabFarm = Window:CreateTab("🐔 Test Chicken Egg", 4483362458)

-- ====================
-- 1. PLAYER MODS
-- ====================
TabPlayer:CreateSection("ระบบความเร็ว (Bypass สปีด 1000+)")

TabPlayer:CreateToggle({
   Name = "🔴 เปิดใช้งาน Speed Hack (CFrame)",
   CurrentValue = false,
   Flag = "SpeedHackToggle",
   Callback = function(Value)
      getgenv().Config.EnableSpeedHack = Value
   end,
})

TabPlayer:CreateSlider({
   Name = "🏎️ ปรับความเร็ววิ่ง (16 - 1000)",
   Range = {16, 1000},
   Increment = 10,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "CFrameSpeedSlider",
   Callback = function(Value)
      getgenv().Config.CFrameSpeed = Value
   end,
})

TabPlayer:CreateSection("ระบบกระโดด")

TabPlayer:CreateToggle({
   Name = "🔴 Safe Infinite Jump (โดดไม่ร่วง/ไม่ตาย)",
   CurrentValue = true,
   Flag = "SafeInfJumpToggle",
   Callback = function(Value)
      getgenv().Config.InfiniteJump = Value
   end,
})

-- ====================
-- 2. AUTO FARM TAB (TEST EGG)
-- ====================
TabFarm:CreateSection("ทดสอบระบบขโมยไข่เฉพาะ (Chicken_Egg)")

TabFarm:CreateToggle({
   Name = "🐔 ออโต้ขโมย Chicken_Egg เท่านั้น",
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
   Name = "🏎️ ความเร็วการบินวาร์ป",
   Range = {30, 250},
   Increment = 10,
   Suffix = " Speed",
   CurrentValue = 80,
   Flag = "TweenSpeedSlider",
   Callback = function(Value)
      getgenv().Config.TweenSpeed = Value
   end,
})

Rayfield:Notify({
   Title = "Chilli Hub V5.1 Loaded!",
   Content = "ตั้งค่าล็อกเป้าหมายเฉพาะ Chicken_Egg เรียบร้อยแล้ว",
   Duration = 4,
   Image = 4483362458,
})
