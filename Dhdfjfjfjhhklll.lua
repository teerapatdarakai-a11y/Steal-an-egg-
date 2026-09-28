-- ========================================================
-- 🌶️ CHILLI HUB V4 - STEALTH & ANTI-DEATH EDITION
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌶️ Chilli Hub V4 - Anti-Death Stealth",
   LoadingTitle = "กำลังโหลดระบบหลบ Anti-Cheat...",
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
    TweenSpeed = 40,
    
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    BypassAntiCheat = true
}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local HighTierKeywords = {
    "secret", "eternal", "divine", "arch angel", "world burner", 
    "godzilla", "king kong", "phoenix", "brainrot", "dragon"
}

-- ====================
-- SAFE INFINITE JUMP (AIR WALK BYPASS)
-- ====================
-- สร้างแผ่นล่องหนใต้เท้าชั่วคราว เพื่อไม่ให้เกมจับได้ว่าเราลอยกลางอากาศแล้วสั่งตาย
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
            
            -- ป้องกันการสั่งตายโดยไม่ใช้ State Jumping ตรงๆ
            AirPlatform.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            
            task.delay(0.2, function()
                AirPlatform.CFrame = CFrame.new(0, -9999, 0)
            end)
        end
    end
end)

-- ====================
-- HELPER FUNCTIONS
-- ====================

local function IsHighTierEgg(model)
    if not model then return false end
    local name = string.lower(model.Name)
    
    for _, kw in ipairs(HighTierKeywords) do
        if string.find(name, kw) then return true end
    end
    
    for _, child in pairs(model:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("SurfaceGui") then
            local text = string.lower(child.Text or "")
            for _, kw in ipairs(HighTierKeywords) do
                if string.find(text, kw) then return true end
            end
        end
    end
    
    return false
end

local function SafeTweenToCFrame(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        
        if distance < 8 then
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

local function ProcessAutoSteal()
    while getgenv().Config.AutoSteal do
        local foundTarget = false
        
        for _, prompt in pairs(workspace:GetDescendants()) do
            if not getgenv().Config.AutoSteal then break end
            
            if prompt:IsA("ProximityPrompt") then
                local eggModel = prompt.Parent
                
                if IsHighTierEgg(eggModel) then
                    foundTarget = true
                    local targetPart = eggModel:IsA("BasePart") and eggModel or eggModel:FindFirstChildWhichIsA("BasePart")
                    
                    if targetPart then
                        SafeTweenToCFrame(targetPart.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.1)
                        
                        prompt.HoldDuration = 0
                        fireproximityprompt(prompt)
                        
                        Rayfield:Notify({
                           Title = "ขโมยไข่สำเร็จ!",
                           Content = "ได้ไข่: " .. eggModel.Name,
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
local TabPlayer = Window:CreateTab("⚡ Player Mods (Safe)", 4483362458)
local TabFarm = Window:CreateTab("🚀 Auto Fly & Steal", 4483362458)

-- ====================
-- 1. PLAYER MODS (SAFE)
-- ====================
TabPlayer:CreateSection("ระบบปรับตัวละคร (เซฟความปลอดภัยไม่ให้โดนฆ่าตาย)")

TabPlayer:CreateSlider({
   Name = "🔴 วิ่งเร็ว (WalkSpeed)",
   Range = {16, 120},
   Increment = 2,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      getgenv().Config.WalkSpeed = Value
      pcall(function()
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end)
   end,
})

TabPlayer:CreateSlider({
   Name = "🔴 กระโดดสูง (JumpPower)",
   Range = {50, 200},
   Increment = 5,
   Suffix = " Power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      getgenv().Config.JumpPower = Value
      pcall(function()
         LocalPlayer.Character.Humanoid.UseJumpPower = true
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end)
   end,
})

TabPlayer:CreateToggle({
   Name = "🔴 อินฟินิตี้โดดปลอดภัย (Safe Air-Walk / พกนอกเซฟโซนไม่ตาย)",
   CurrentValue = false,
   Flag = "SafeInfJumpToggle",
   Callback = function(Value)
      getgenv().Config.InfiniteJump = Value
   end,
})

-- ====================
-- 2. AUTO FARM TAB
-- ====================
TabFarm:CreateSection("ระบบออโต้ขโมยไข่ ( Secret / Eternal / Divine )")

TabFarm:CreateToggle({
   Name = "🔴 ออโต้ขโมยไข่ + บินไปหาอัตโนมัติ",
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
   Range = {20, 100},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 40,
   Flag = "TweenSpeedSlider",
   Callback = function(Value)
      getgenv().Config.TweenSpeed = Value
   end,
})

-- ลูปคอยรักษาสภาพความเร็วตัวละครไม่ให้โดนเกมรีเซ็ต
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if getgenv().Config.WalkSpeed > 16 then
                    LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Config.WalkSpeed
                end
                if getgenv().Config.JumpPower > 50 then
                    LocalPlayer.Character.Humanoid.UseJumpPower = true
                    LocalPlayer.Character.Humanoid.JumpPower = getgenv().Config.JumpPower
                end
            end
        end)
    end
end)

Rayfield:Notify({
   Title = "Chilli Hub V4 Stealth Loaded!",
   Content = "แก้ระบบกระโดดไม่ให้โดนฆ่าตายเรียบร้อยแล้ว!",
   Duration = 4,
   Image = 4483362458,
})
