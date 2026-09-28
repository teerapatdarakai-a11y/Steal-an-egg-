local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local Window = Fluent:CreateWindow({
    Title = "Steal an Egg - Safe Farm",
    SubTitle = "Anti-Kick Version",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Main Farm", Icon = "egg" }) }
local AutoFarmEnabled = false

local Toggle = Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "เปิด/ปิด สคริปต์เก็บไข่อัตโนมัติ (Safe Speed)",
    Default = false
})

Toggle:OnChanged(function(Value)
    AutoFarmEnabled = Value
end)

-- ระบบบินปลอดภัย (จำกัดความเร็วไว้ที่ 120 เพื่อหลบ Anti-Cheat BAC)
local function safeFlyTo(targetPosition)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    local currentSpeed = 0
    local maxSpeed = 120 -- ความเร็วปลอดภัย ไม่โดนระบบเตะ
    local acceleration = 5 
    local reached = false

    local connection
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not AutoFarmEnabled or not hrp or not hrp.Parent then 
            if connection then connection:Disconnect() end
            return 
        end

        local direction = targetPosition - hrp.Position
        local distance = direction.Magnitude

        if distance < 6 then
            reached = true
            connection:Disconnect()
            return
        end

        if currentSpeed < maxSpeed then
            currentSpeed = math.min(maxSpeed, currentSpeed + acceleration)
        end

        bv.Velocity = direction.Unit * currentSpeed
    end)

    while not reached and AutoFarmEnabled and player.Character == char do
        task.wait(0.1)
    end

    if connection then connection:Disconnect() end
    if bv then bv:Destroy() end
end

local function findTargetEgg()
    local eggsFolder = workspace:FindFirstChild("Eggs")
    if not eggsFolder then return nil end
    local placedFolder = eggsFolder:FindFirstChild("PlacedEggRenders") or eggsFolder
    
    local TARGETS = { ["SECRET"] = true, ["ETERNAL"] = true, ["DIVINE"] = true }

    for _, eggModel in pairs(placedFolder:GetChildren()) do
        local eggNameText = ""
        local eggNameObj = eggModel:FindFirstChild("EggName", true)
        
        if eggNameObj and (eggNameObj:IsA("TextLabel") or eggNameObj:IsA("StringValue")) then
            eggNameText = eggNameObj:IsA("TextLabel") and eggNameObj.Text or eggNameObj.Value
        else
            eggNameText = eggModel.Name
        end

        local upperText = string.upper(eggNameText)
        for target, _ in pairs(TARGETS) do
            if string.find(upperText, target) then
                return eggModel
            end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoFarmEnabled then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local basePos = char.HumanoidRootPart.Position
                
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
                    task.wait(2)
                    local targetEgg = findTargetEgg()
                    if targetEgg and AutoFarmEnabled then
                        local eggPos = targetEgg:IsA("Model") and (targetEgg.PrimaryPart and targetEgg.PrimaryPart.Position or targetEgg:FindFirstChildOfClass("BasePart").Position) or targetEgg.Position
                        if eggPos then
                            safeFlyTo(eggPos)
                            
                            local prompt = targetEgg:FindFirstChildOfClass("ProximityPrompt", true)
                            if prompt then fireproximityprompt(prompt) end
                            
                            task.wait(1)
                            safeFlyTo(basePos)
                        end
                    end
                end
            end
        end
    end
end)
