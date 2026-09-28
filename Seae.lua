-- ========================================================
-- 🌶️ CHILLI HUB V3 - AUTO FLY & STEAL (FIXED)
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 Chilli Hub V3 - Fixed Auto Fly & Steal",
   LoadingTitle = "กำลังแก้ไขระบบบินวาร์ปขโมยไข่...",
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
    TweenSpeed = 45,
    InstantPrompt = true,
    
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false
}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- คีย์เวิร์ดไข่ระดับสูงที่ต้องบินไปเก็บทันที
local HighTierKeywords = {
    "secret", "eternal", "divine", "arch angel", "world burner", 
    "godzilla", "king kong", "phoenix", "brainrot", "dragon"
}

-- ====================
-- HELPER FUNCTIONS
-- ====================

-- เช็คว่าวัตถุนี้คือไข่ Secret / Eternal / Divine หรือไม่
local function IsHighTierEgg(model)
    if not model then return false end
    
    local name = string.lower(model.Name)
    
    -- 1. เช็คจากชื่อ Model
    for _, kw in ipairs(HighTierKeywords) do
        if string.find(name, kw) then
            return true
        end
    end
    
    -- 2. เช็คจากข้อความป้ายชื่อบนหัวไข่ (BillboardGui)
    for _, child in pairs(model:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("SurfaceGui") then
            local text = string.lower(child.Text or "")
            for _, kw in ipairs(HighTierKeywords) do
                if string.find(text, kw) then
                    return true
                end
            end
        end
    end
    
    return false
end

-- สั่งบินไปหาตำแหน่ง
local function TweenToCFrame(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        
        -- ถ้าระยะใกล้มาก ให้กดวาร์ปเลย ไม่ต้อง Tween ให้เสียเวลา
        if distance < 10 then
            hrp.CFrame = targetCFrame
            return
        end

        local duration = distance / getgenv().Config.TweenSpeed
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Wait() -- รอจนกว่าจะบินไปถึงจุดหมาย
    end
end

-- Loop หลัก: บินไปหา + ขโมย
local function AutoFlyAndSteal()
    while getgenv().Config.AutoSteal do
        local foundTarget = false
        
        for _, prompt in pairs(workspace:GetDescendants()) do
            if not getgenv().Config.AutoSteal then break end
            
            if prompt:IsA("ProximityPrompt") then
                local eggModel = prompt.Parent
                
                if IsHighTierEgg(eggModel) then
                    foundTarget = true
                    
                    -- หาตำแหน่ง CFrame ของไข่
                    local targetPart = eggModel:IsA("BasePart") and eggModel or eggModel:FindFirstChildWhichIsA("BasePart")
                    if targetPart then
                        -- 1. บินไปจ่อเหนือไข่ 3 บล็อก
                        TweenToCFrame(targetPart.CFrame * CFrame.new(0, 3, 0))
                        
                        task.wait(0.1)
                        
                        -- 2. ปรับระยะเวลากดเป็น 0
                        if getgenv().Config.InstantPrompt then
                            prompt.HoldDuration = 0
                        end
                        
                        -- 3. สั่งกดขโมย
                        fireproximityprompt(prompt)
                        
                        Rayfield:Notify({
                           Title = "ขโมยไข่สำเร็จ!",
                           Content = "ขโมยไข่: " .. eggModel.Name,
                           Duration = 2,
                           Image = 4483362458,
                        })
                        
                        task.wait(getgenv().Config.StealDelay)
                    end
                end
            end
        end
        
        -- ถ้าสแกนรอบแมพแล้วไม่เจอไข่ไฮเทียร์ ให้พัก 1 วินาทีก่อนวนสแกนใหม่
        if not foundTarget then
            task.wait(1)
        end
    end
end

-- ====================
-- TABS CREATION
-- ====================
local TabFarm = Window:CreateTab("🔥 Auto Fly & Steal", 4483362458)
local TabPlayer = Window:CreateTab("⚡ Player Mods", 4483362458)

-- ====================
-- 1. AUTO FARM TAB
-- ====================
TabFarm:CreateSection("ระบบบินไปขโมยอัตโนมัติ (แก้ไขล็อกเป้า + บินถึงที่)")

TabFarm:CreateToggle({
   Name = "🚀 เปิด Auto Fly & Steal (บินไปขโมย Secret/Eternal/Divine ทันที)",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
      getgenv().Config.AutoSteal = Value
      if Value then
         task.spawn(AutoFlyAndSteal)
      end
   end,
})

TabFarm:CreateSlider({
   Name = "🏎️ ความเร็วการบิน (Tween Speed)",
   Range = {20, 150},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 45,
   Flag = "TweenSpeedSlider",
   Callback = function(Value)
      getgenv().Config.TweenSpeed = Value
   end,
})

TabFarm:CreateSlider({
   Name = "⏱️ หน่วงเวลาหลังขโมยเสร็จ (Steal Delay)",
   Range = {0.1, 3},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "StealDelaySlider",
   Callback = function(Value)
      getgenv().Config.StealDelay = Value
   end,
})

TabFarm:CreateToggle({
   Name = "⚡ Instant Prompt (กดขโมยทันที 0 วินาที)",
   CurrentValue = true,
   Flag = "InstantPromptToggle",
   Callback = function(Value)
      getgenv().Config.InstantPrompt = Value
   end,
})

-- ====================
-- 2. PLAYER MODS TAB
-- ====================
TabPlayer:CreateSection("การปรับแต่งตัวละคร")

TabPlayer:CreateSlider({
   Name = "👟 WalkSpeed (ความเร็วเดิน)",
   Range = {16, 250},
   Increment = 2,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      getgenv().Config.WalkSpeed = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

TabPlayer:CreateSlider({
   Name = "🦘 JumpPower (แรงกระโดด)",
   Range = {50, 300},
   Increment = 5,
   Suffix = " Power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      getgenv().Config.JumpPower = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if getgenv().Config.InfiniteJump then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end
end)

TabPlayer:CreateToggle({
   Name = "🕊️ Infinite Jump (กระโดดกลางอากาศ)",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      getgenv().Config.InfiniteJump = Value
   end,
})

Rayfield:Notify({
   Title = "Chilli Hub V3 Ready!",
   Content = "แก้ระบบบินวาร์ปไปขโมยเรียบร้อยแล้ว!",
   Duration = 4,
   Image = 4483362458,
})
