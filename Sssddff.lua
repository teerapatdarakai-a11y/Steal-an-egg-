-- ========================================================
-- 🌶️ CHILLI HUB V5.2 - ANTI-KICK & CHICKEN EGG TEST
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌶️ Chilli Hub V5.2 - Anti-Kick Edition",
   LoadingTitle = "กำลังโหลดระบบหลบ Anti-Cheat (BAC)...",
   LoadingSubtitle = "by Script Collaborator",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ====================
-- GLOBAL CONFIG
-- ====================
getgenv().Config = {
    AutoSteal = false,
    StealDelay = 0.5,
    MoveSpeed = 35, -- ลดความเร็วลงเพื่อไม่ให้ Anti-Cheat (BAC) ตรวจจับการวาร์ป
    
    WalkSpeed = 16,
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
-- SAFE SPEED ENGINE (PREVENT BAC DETECT)
-- ====================
RunService.Stepped:Connect(function()
    if getgenv().Config.EnableSpeedHack then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = getgenv().Config.WalkSpeed
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

-- ระบบเคลื่อนที่แบบ Stealth นุ่มนวลเพื่อหลบ BAC-3514
local function SafeMoveToCFrame(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        
        if distance < 4 then
            return
        end

        local duration = distance / getgenv().Config.MoveSpeed
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait()
    end
end

-- ====================
-- STEALTH AUTO STEAL PROCESSOR
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
                        
                        -- ค่อยๆ เดิน/บินไปใกล้ๆ เป้าหมาย
                        SafeMoveToCFrame(targetPart.CFrame * CFrame.new(0, 2, 2))
                        task.wait(0.1)
                        
                        -- กดปุ่ม ProximityPrompt แบบเนียนๆ ไม่ดัดแปลง Property
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                        
                        Rayfield:Notify({
                           Title = "ขโมยสำเร็จ!",
                           Content = "ได้ไข่: " .. prompt.Parent.Name,
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
local TabPlayer = Window:CreateTab("⚡ Safe Player Mods", 4483362458)
local TabFarm = Window:CreateTab("🐔 Chicken Egg Steal", 4483362458)

-- ====================
-- 1. PLAYER MODS
-- ====================
TabPlayer:CreateSection("ปรับความเร็ววิ่ง (ตั้งค่าเซฟปลอดภัยจาก BAC)")

TabPlayer:CreateToggle({
   Name = "🔴 เปิดใช้งานระบบ Speed",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      getgenv().Config.EnableSpeedHack = Value
      if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.WalkSpeed = 16
      end
   end,
})

TabPlayer:CreateSlider({
   Name = "🏎️ ความเร็ววิ่ง (แนะนำไม่เกิน 60-80)",
   Range = {16, 120},
   Increment = 2,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      getgenv().Config.WalkSpeed = Value
   end,
})

TabPlayer:CreateSection("ระบบกระโดด")

TabPlayer:CreateToggle({
   Name = "🔴 Safe Infinite Jump (กระโดดลอยกลางอากาศ)",
   CurrentValue = true,
   Flag = "SafeInfJumpToggle",
   Callback = function(Value)
      getgenv().Config.InfiniteJump = Value
   end,
})

-- ====================
-- 2. AUTO FARM TAB
-- ====================
TabFarm:CreateSection("ขโมยเฉพาะ Chicken_Egg (Stealth Mode)")

TabFarm:CreateToggle({
   Name = "🐔 เปิดออโต้ขโมย Chicken_Egg",
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
   Name = "🏎️ ความเร็วในการเข้าหาเป้าหมาย (แนะนำ 30-50)",
   Range = {20, 80},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 35,
   Flag = "MoveSpeedSlider",
   Callback = function(Value)
      getgenv().Config.MoveSpeed = Value
   end,
})

TabFarm:CreateSlider({
   Name = "⏱️ ระยะเวลาหน่วงหลังเก็บไข่ (วินาที)",
   Range = {0.2, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "StealDelaySlider",
   Callback = function(Value)
      getgenv().Config.StealDelay = Value
   end,
})

Rayfield:Notify({
   Title = "Chilli Hub V5.2 Anti-Kick Loaded!",
   Content = "ปรับระบบให้หลบ BAC-3514 เรียบร้อยแล้ว",
   Duration = 4,
   Image = 4483362458,
})
