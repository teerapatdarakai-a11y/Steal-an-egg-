-- ========================================================
-- 🌶️ CHILLI HUB V7 - ULTIMATE SAFE & WORKING EDITION
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌶️ Chilli Hub V7 - Safe Working Mode",
   LoadingTitle = "กำลังโหลดระบบปลอดภัย (Anti-Crash)...",
   LoadingSubtitle = "by Script Collaborator",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ====================
-- GLOBAL CONFIG
-- ====================
getgenv().Config = {
    AutoSteal = false,
    StealDelay = 0.8, -- เพิ่มดีเลย์เพื่อให้ปลอดภัย ไม่ส่งคำสั่งถี่เกินไป
    InfiniteJump = true,
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local TargetEggs = {
    "Chicken egg",
    "Chickenegg",
    "Chicken",
    "chicken egg",
    "chickenegg",
    "chicken"
    "Common Egg"
}

-- ====================
-- SAFE INFINITE JUMP (ระบบที่ใช้งานได้จริง 100%)
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
-- TARGET EGG CHECKER
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
-- SAFE WORKING AUTO STEAL (เดินไปเก็บแบบเนียน ไม่ตาย ไม่ดีด)
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
                    
                    if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        foundTarget = true
                        local humanoid = LocalPlayer.Character.Humanoid
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        
                        -- ค่อยๆ เดินเข้าหาเป้าหมายตามระบบปกติของเกม ไม่วาร์ป ไม่บิน
                        while getgenv().Config.AutoSteal and targetPart and targetPart.Parent do
                            local distance = (hrp.Position - targetPart.Position).Magnitude
                            if distance < 4 then 
                                break 
                            end
                            humanoid:MoveTo(targetPart.Position)
                            task.wait(0.3)
                        end
                        
                        -- หยุดเดินชั่วขณะเมื่อถึงเป้า
                        humanoid:MoveTo(hrp.Position)
                        task.wait(0.2)
                        
                        -- สั่งยิง ProximityPrompt เก็บไข่
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                        
                        Rayfield:Notify({
                           Title = "เก็บไข่ไก่สำเร็จ!",
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
            task.wait(1)
        end
    end
end

-- ====================
-- TABS CREATION
-- ====================
local TabPlayer = Window:CreateTab("⚡ Safe Features", 4483362458)
local TabFarm = Window:CreateTab("🐔 Working Auto Steal", 4483362458)

-- ====================
-- 1. PLAYER MODS
-- ====================
TabPlayer:CreateSection("ระบบปลอดภัยที่ใช้งานได้จริง")

TabPlayer:CreateToggle({
   Name = "🔴 Safe Infinite Jump (กระโดดลอยกลางอากาศ ไม่ร่วง)",
   CurrentValue = true,
   Flag = "SafeInfJumpToggle",
   Callback = function(Value)
      getgenv().Config.InfiniteJump = Value
   end,
})

-- ====================
-- 2. AUTO FARM TAB
-- ====================
TabFarm:CreateSection("ระบบออโต้เก็บ Chicken_Egg (โหมดปลอดภัย 100%)")

TabFarm:CreateToggle({
   Name = "🐔 เปิดออโต้เดินเก็บ Chicken_Egg",
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
   Name = "⏱️ ดีเลย์เวลากดเก็บ (วินาที - ป้องกันโดนเตะ)",
   Range = {0.5, 3},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.8,
   Flag = "StealDelaySlider",
   Callback = function(Value)
      getgenv().Config.StealDelay = Value
   end,
})

Rayfield:Notify({
   Title = "Chilli Hub V7 Loaded!",
   Content = "ตัดระบบสปีดที่ทำให้ตายออกแล้ว คงเหลือระบบเดินเก็บและโดดที่ปลอดภัยที่สุด!",
   Duration = 4,
   Image = 4483362458,
})
