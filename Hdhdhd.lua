-- โหลด Library หน้าต่าง UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- สร้างหน้าต่าง UI
local Window = Fluent:CreateWindow({
    Title = "Steal an Egg - Auto Farm",
    SubTitle = "by Custom Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "egg" })
}

-- ตัวแปรสถานะ
local AutoFarmEnabled = false
local TARGET_RARITIES = {
    ["SECRET"] = true,
    ["ETERNAL"] = true,
    ["DIVINE"] = true
}

-- สวิตช์ เปิด/ปิด บนหน้าต่าง UI
local Toggle = Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "เปิด/ปิด สคริปต์เก็บไข่อัตโนมัติ",
    Default = false
})

Toggle:OnChanged(function(Value)
    AutoFarmEnabled = Value
    if Value then
        Fluent:Notify({
            Title = "Auto Farm",
            Content = "เริ่มระบบเก็บไข่ (Secret+) บินสปีด 500 แล้ว!",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Auto Farm",
            Content = "หยุดระบบเก็บไข่เรียบร้อยแล้ว",
            Duration = 3
        })
    end
end)

-- ==========================================
-- ระบบบินสมูท (0 -> 500)
-- ==========================================
local function smoothFlyTo(targetPosition)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    humanoid.PlatformStand = true

    local currentSpeed = 0
    local maxSpeed = 500
    local acceleration = 25 
    local reached = false

    local connection
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not AutoFarmEnabled or not hrp or not hrp.Parent then 
            if connection then connection:Disconnect() end
            return 
        end

        local direction = targetPosition - hrp.Position
        local distance = direction.Magnitude

        if distance < 5 then
            reached = true
            connection:Disconnect()
            return
        end

        if currentSpeed < maxSpeed then
            currentSpeed = math.min(maxSpeed, currentSpeed + acceleration)
        end

        local moveStep = currentSpeed * deltaTime
        if moveStep > distance then moveStep = distance end

        hrp.CFrame = hrp.CFrame + (direction.Unit * moveStep)
    end)

    while not reached and AutoFarmEnabled and player.Character == char do
        task.wait(0.1)
    end

    if connection then connection:Disconnect() end
    if bv then bv:Destroy() end
    if humanoid then humanoid.PlatformStand = false end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = true end
    end
end

-- ==========================================
-- สแกนหาไข่ใน workspace.Eggs.PlacedEggRenders
-- ==========================================
local function findTargetEgg()
    local eggsFolder = workspace:FindFirstChild("Eggs")
    if not eggsFolder then return nil end
    local placedFolder = eggsFolder:FindFirstChild("PlacedEggRenders") or eggsFolder
    
    for _, eggModel in pairs(placedFolder:GetChildren()) do
        local eggNameText = ""
        local eggNameObj = eggModel:FindFirstChild("EggName", true)
        
        if eggNameObj and (eggNameObj:IsA("TextLabel") or eggNameObj:IsA("StringValue")) then
            eggNameText = eggNameObj:IsA("TextLabel") and eggNameObj.Text or eggNameObj.Value
        else
            eggNameText = eggModel.Name
        end

        local upperText = string.upper(eggNameText)
        for target, _ in pairs(TARGET_RARITIES) do
            if string.find(upperText, target) then
                return eggModel
            end
        end
    end
    return nil
end

-- ==========================================
-- ลูปทำงานหลัก
-- ==========================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoFarmEnabled then
            -- จำพิกัดฐานตอนเปิดทำงาน
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local basePos = char.HumanoidRootPart.Position
                
                -- รอสแกนคำว่า ALL EGG RESET!
                local isReset = false
                for _, gui in pairs(PlayerGui:GetDescendants()) do
                    if gui:IsA("TextLabel") or gui:IsA("TextBox") then
                        if string.find(string.upper(gui.Text), "ALL EGG RESET!") then
                            isReset = true
                            break
                        end
                    end
                end

                if isReset then
                    task.wait(2) -- รอไข่โหลด
                    local targetEgg = findTargetEgg()
                    if targetEgg and AutoFarmEnabled then
                        local eggPos = targetEgg:IsA("Model") and (targetEgg.PrimaryPart and targetEgg.PrimaryPart.Position or targetEgg:FindFirstChildOfClass("BasePart").Position) or targetEgg.Position
                        if eggPos then
                            smoothFlyTo(eggPos)
                            
                            local prompt = targetEgg:FindFirstChildOfClass("ProximityPrompt", true)
                            if prompt then fireproximityprompt(prompt) end
                            
                            task.wait(1)
                            smoothFlyTo(basePos)
                        end
                    end
                end
            end
        end
    end
end)
