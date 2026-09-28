-- ========================================================
-- 🌶️ CHILLI HUB V2 - SECRET / ETERNAL / DIVINE EDITION
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👑 Chilli Hub V2 - Divine & Secret Edition",
   LoadingTitle = "กำลังโหลดลิสต์ไข่ Secret, Eternal, Divine...",
   LoadingSubtitle = "by Script Collaborator",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ====================
-- GLOBAL CONFIG & DATABASE
-- ====================
getgenv().Config = {
    AutoSteal = false,
    StealDelay = 2,
    InstantPrompt = true,
    TargetEggOnly = true, -- เปิดกรองระดับสูงไว้เป็นค่าเริ่มต้น
    SelectedEgg = "All High Tiers",
    
    TweenSpeed = 35,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false
}

-- รายชื่อเฉพาะกลุ่ม Secret, Eternal, Divine และตัวระดับเทพสูงสุดในเกม
local HighTierEggList = {
    "All High Tiers", -- ตัวเลือกขโมยทุกตัวในลิสต์นี้พร้อมกัน
    "Eternal Lunar Dragon",
    "Steal an Egg Arch Angel",
    "ArchAngel",
    "Steal an Egg World Burner",
    "World Burner",
    "Ascended Vermilion Phoenix",
    "Abyss Overlord",
    "Godzilla",
    "King Kong",
    "BrainrotEgg",
    "Secret",
    "Eternal",
    "Divine"
}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ====================
-- HELPER FUNCTIONS
-- ====================

local function TweenToCFrame(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = distance / getgenv().Config.TweenSpeed
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        return tween
    end
end

-- ระบบสแกนและขโมยเจาะจงเฉพาะ Secret / Eternal / Divine
local function ProcessAutoSteal()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, prompt in pairs(workspace:GetDescendants()) do
        if not getgenv().Config.AutoSteal then break end
        
        if prompt:IsA("ProximityPrompt") then
            local eggModel = prompt.Parent
            
            if getgenv().Config.InstantPrompt then
                prompt.HoldDuration = 0
            end

            local canSteal = false
            local eggName = eggModel and string.lower(eggModel.Name) or ""

            if getgenv().Config.SelectedEgg == "All High Tiers" then
                -- สแกนหาคำว่า secret, eternal, divine หรือชื่อมหาเทพทั้งหมดในลิสต์
                for _, name in ipairs(HighTierEggList) do
                    if name ~= "All High Tiers" and string.find(eggName, string.lower(name)) then
                        canSteal = true
                        break
                    end
                end
            else
                -- ขโมยเฉพาะตัวที่เลือกใน Dropdown
                if string.find(eggName, string.lower(getgenv().Config.SelectedEgg)) then
                    canSteal = true
                end
            end

            if canSteal then
                fireproximityprompt(prompt)
            end
        end
    end
end

-- ====================
-- TABS CREATION
-- ====================
local TabFarm = Window:CreateTab("🔥 Auto Steal", 4483362458)
local TabTarget = Window:CreateTab("👑 High Tier Filter", 4483362458)
local TabTeleport = Window:CreateTab("🚀 Tween / Teleport", 4483362458)
local TabPlayer = Window:CreateTab("⚡ Player Mods", 4483362458)

-- ====================
-- 1. AUTO FARM TAB
-- ====================
TabFarm:CreateSection("ระบบขโมยไข่อัตโนมัติ (Secret / Eternal / Divine)")

TabFarm:CreateToggle({
   Name = "🔥 เปิด Auto Steal (สแกนเฉพาะ Secret / Eternal / Divine)",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
      getgenv().Config.AutoSteal = Value
      if Value then
         task.spawn(function()
            while getgenv().Config.AutoSteal do
               pcall(ProcessAutoSteal)
               task.wait(getgenv().Config.StealDelay)
            end
         end)
      end
   end,
})

TabFarm:CreateSlider({
   Name = "⏱️ Steal Delay (วินาที)",
   Range = {0.1, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 2,
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
-- 2. HIGH TIER FILTER TAB
-- ====================
TabTarget:CreateSection("ตั้งค่าเป้าหมายการขโมย")

TabTarget:CreateDropdown({
   Name = "👑 เลือกไข่ระดับสูงสุดที่ต้องการขโมย:",
   Options = HighTierEggList,
   CurrentOption = "All High Tiers",
   Flag = "SelectedEggDropdown",
   Callback = function(Option)
      getgenv().Config.SelectedEgg = Option[1] or Option
   end,
})

-- ====================
-- 3. TELEPORT TAB
-- ====================
TabTeleport:CreateSection("ระบบบินวาร์ปไปหาไข่ระดับสูง")

TabTeleport:CreateSlider({
   Name = "🏎️ ความเร็วการบิน Tween Speed",
   Range = {10, 100},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 35,
   Flag = "TweenSpeedSlider",
   Callback = function(Value)
      getgenv().Config.TweenSpeed = Value
   end,
})

TabTeleport:CreateButton({
   Name = "👑 บินไปหาไข่ Secret / Eternal / Divine ที่เจอในแมพ",
   Callback = function()
      pcall(function()
         local targetPart = nil
         for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
               local parent = prompt.Parent
               if parent then
                  local pName = string.lower(parent.Name)
                  if string.find(pName, "secret") or string.find(pName, "eternal") or string.find(pName, "divine") or string.find(pName, "arch angel") or string.find(pName, "world burner") then
                     targetPart = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
                     if targetPart then break end
                  end
               end
            end
         end
         
         if targetPart then
            TweenToCFrame(targetPart.CFrame * CFrame.new(0, 3, 0))
            Rayfield:Notify({
               Title = "พบบริเวณเป้าหมาย!",
               Content = "กำลังบินไปหาไข่ระดับสูง...",
               Duration = 3,
               Image = 4483362458,
            })
         else
            Rayfield:Notify({
               Title = "ไม่พบไข่ระดับสูง!",
               Content = "ขณะนี้ยังไม่มีไข่ Secret, Eternal หรือ Divine เกิดบนแมพ",
               Duration = 3,
               Image = 4483362458,
            })
         end
      end)
   end,
})

-- ====================
-- 4. PLAYER MODS TAB
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
   Name = "🕊️ Infinite Jump (กระโดดกลางอากาศไม่จำกัด)",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      getgenv().Config.InfiniteJump = Value
   end,
})

Rayfield:Notify({
   Title = "Divine & Secret Mode Ready!",
   Content = "ตั้งค่าสแกนเฉพาะระดับ Secret / Eternal / Divine เรียบร้อยแล้ว",
   Duration = 5,
   Image = 4483362458,
})
