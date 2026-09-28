-- ============================================================================
-- 👑 STEAL AN EGG: IRONCLAD SAFE EDITION (v6.18)
-- ============================================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)

if playerGui and playerGui:FindFirstChild("StealAnEggBypass_UI") then
    playerGui.StealAnEggBypass_UI:Destroy()
end

local isAutoActive = true
local currentWorker = nil
local activeConns = {}
local isFlyingBack = false
local flyConnection = nil

-- ============================================================================
-- ⚙️ CONFIGURATION & EXACT TIERED TARGET EGGS LIST
-- ============================================================================
local TARGET_EGGS = {
    -- ระดับ Secret
    ["Secret RazorFang Egg"] = true,
    ["Secret Pure Jellyfish Egg"] = true,
    ["Secret Gargoyle Egg"] = true,
    ["Secret Centaur Egg"] = true,
    ["Secret Mutant Shark Egg"] = true,
    ["Secret Stang Egg"] = true,
    ["Secret Cosmic Skeleton Boss Egg"] = true,
    ["Secret Cosmic Dragon Egg"] = true,
    ["Secret TRex Egg"] = true,
    ["Secret Tralaledon Egg"] = true,
    ["Secret Kraken Egg"] = true,
    ["Secret Cerberus Egg"] = true,

    -- ระดับ Eternal
    ["Eternal Skeleton Horse Egg"] = true,
    ["Eternal Pegasus Egg"] = true,
    ["Eternal Gorilla King Egg"] = true,
    ["Eternal Oni Tiger Egg"] = true,
    ["Eternal Lunar Dragon Egg"] = true,
    ["Eternal Mosasaurus Egg"] = true,
    ["Eternal Ice Dragon Egg"] = true,

    -- ระดับ Divine
    ["Divine World Burner Egg"] = true,
    ["Divine Kitsune Egg"] = true
}

local BLACKLIST_KEYS = { "sell", "shop", "combine", "craft", "fuse", "hatch", "upgrade", "place", "base", "plot" }

-- ============================================================================
-- 🦅 SAFE FLOPPY / FLY-ASSIST SYSTEM (HEIGHT +30)
-- ============================================================================
local function StopFlying()
    isFlyingBack = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local bodyVel = hrp and hrp:FindFirstChild("EggFlyVelocity")
    local bodyGyro = hrp and hrp:FindFirstChild("EggFlyGyro")
    if bodyVel then bodyVel:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

local function StartFlyingToTarget(targetPos)
    StopFlying()
    isFlyingBack = true
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    humanoid.PlatformStand = false

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.Name = "EggFlyVelocity"
    bodyVel.MaxForce = Vector3.new(40000, 40000, 40000)
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.Parent = hrp

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "EggFlyGyro"
    bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        if not isAutoActive or not isFlyingBack or not hrp.Parent then
            StopFlying()
            return
        end

        local currentPos = hrp.Position
        local elevatedTarget = Vector3.new(targetPos.X, targetPos.Y + 30, targetPos.Z)
        local direction = (elevatedTarget - currentPos)
        local distance = direction.Magnitude

        if distance > 4 then
            local speed = math.clamp(humanoid.WalkSpeed * 1.5, 16, 50)
            bodyVel.Velocity = direction.Unit * speed
            bodyGyro.CFrame = CFrame.new(currentPos, elevatedTarget)
        else
            bodyVel.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- ============================================================================
-- 🧹 CLEANUP & WORKER MANAGEMENT
-- ============================================================================
local function StopWorker()
    StopFlying()
    if currentWorker then
        task.cancel(currentWorker)
        currentWorker = nil
    end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if humanoid and hrp then
        humanoid:MoveTo(hrp.Position)
    end
end

local function HardCleanup()
    isAutoActive = false
    StopWorker()
    for _, conn in ipairs(activeConns) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(activeConns)
end

table.insert(activeConns, player.CharacterAdded:Connect(StopWorker))
table.insert(activeConns, player.CharacterRemoving:Connect(StopWorker))

-- ============================================================================
-- 🎨 COMPACT USER INTERFACE (250x150) & 🚀 RESTORE BUTTON
-- ============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggBypass_UI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
if playerGui then screenGui.Parent = playerGui end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 20, 26)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 220, 130)
stroke.Thickness = 2

local restoreBtn = Instance.new("TextButton")
restoreBtn.Name = "RestoreButton"
restoreBtn.Size = UDim2.new(0, 45, 0, 45)
restoreBtn.Position = UDim2.new(0.85, -50, 0.15, 0)
restoreBtn.BackgroundColor3 = Color3.fromRGB(24, 30, 38)
restoreBtn.Text = "🚀"
restoreBtn.TextSize = 22
restoreBtn.Visible = false
restoreBtn.Active = true
restoreBtn.Draggable = true
restoreBtn.Parent = screenGui

Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(1, 0)
local restoreStroke = Instance.new("UIStroke", restoreBtn)
restoreStroke.Color = Color3.fromRGB(0, 220, 130)
restoreStroke.Thickness = 2

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 32)
titleLabel.BackgroundColor3 = Color3.fromRGB(24, 30, 38)
titleLabel.Text = "   🛡️ STEAL EGG v6.18"
titleLabel.TextColor3 = Color3.fromRGB(0, 220, 130)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 8)

local minimizeBtn = Instance.new("TextButton", titleLabel)
minimizeBtn.Size = UDim2.new(0, 22, 0, 22)
minimizeBtn.Position = UDim2.new(1, -50, 0.5, -11)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 11
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)

local destroyBtn = Instance.new("TextButton", titleLabel)
destroyBtn.Size = UDim2.new(0, 22, 0, 22)
destroyBtn.Position = UDim2.new(1, -25, 0.5, -11)
destroyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
destroyBtn.Text = "✕"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.Font = Enum.Font.GothamBold
destroyBtn.TextSize = 11
Instance.new("UICorner", destroyBtn).CornerRadius = UDim.new(0, 4)

local monitor = Instance.new("TextLabel", mainFrame)
monitor.Size = UDim2.new(1, -16, 0, 30)
monitor.Position = UDim2.new(0, 8, 0, 38)
monitor.BackgroundColor3 = Color3.fromRGB(26, 34, 44)
monitor.Text = "STATUS: SCANNING..."
monitor.TextColor3 = Color3.fromRGB(180, 190, 200)
monitor.Font = Enum.Font.GothamSemibold
monitor.TextSize = 9
Instance.new("UICorner", monitor).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, -16, 0, 66)
toggleBtn.Position = UDim2.new(0, 8, 0, 74)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
toggleBtn.Text = "AUTO DETECT: ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    restoreBtn.Visible = false
end)

destroyBtn.MouseButton1Click:Connect(function()
    HardCleanup()
    screenGui:Destroy()
end)

toggleBtn.MouseButton1Click:Connect(function()
    isAutoActive = not isAutoActive
    if isAutoActive then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        toggleBtn.Text = "AUTO DETECT: ON"
        monitor.Text = "STATUS: SCANNING..."
    else
        StopWorker()
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 62)
        toggleBtn.Text = "AUTO DETECT: OFF"
        monitor.Text = "STATUS: PAUSED"
    end
end)

-- ============================================================================
-- 🔍 HELPER FUNCTIONS & TARGET SEARCH ENGINE
-- ============================================================================
local function HasEgg()
    local char = player.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Model") or item:IsA("Tool") then
            local name = string.lower(item.Name)
            if string.find(name, "egg") or string.find(name, "carrying") or string.find(name, "stolen") then
                return true
            end
        end
    end
    return false
end

local function FindBasePos()
    for _, fName in ipairs({"Bases", "Plots", "Islands", "Tycoons"}) do
        local folder = Workspace:FindFirstChild(fName)
        if folder then
            for _, base in ipairs(folder:GetChildren()) do
                local owner = base:GetAttribute("Owner") or ""
                if string.find(string.lower(base.Name), string.lower(player.Name)) or tostring(owner) == tostring(player.UserId) then
                    if base:FindFirstChild("Core") then return base.Core.Position end
                    if base.PrimaryPart then return base.PrimaryPart.Position end
                    return base:GetPivot().Position
                end
            end
        end
    end
    local spawnLoc = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    return spawnLoc and spawnLoc.Position or Vector3.new(0, 5, 0)
end

local function SearchTarget()
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local parent = prompt.Parent
            if parent then
                local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart") or parent.PrimaryPart
                if not part and parent.Parent then
                    part = parent.Parent:FindFirstChildWhichIsA("BasePart") or parent.Parent.PrimaryPart
                end

                if part then
                    local pName = string.lower(tostring(parent.Name))
                    local ppName = parent.Parent and string.lower(tostring(parent.Parent.Name)) or ""
                    local pppName = (parent.Parent and parent.Parent.Parent) and string.lower(tostring(parent.Parent.Parent.Name)) or ""
                    local actTxt = string.lower(tostring(prompt.ActionText or ""))
                    local objTxt = string.lower(tostring(prompt.ObjectText or ""))
                    
                    local fullStr = pName .. " " .. ppName .. " " .. pppName .. " " .. actTxt .. " " .. objTxt

                    local skip = false
                    for _, bKey in ipairs(BLACKLIST_KEYS) do
                        if string.find(fullStr, bKey) then skip = true break end
                    end

                    if not skip then
                        for keyName, _ in pairs(TARGET_EGGS) do
                            if string.find(fullStr, string.lower(keyName)) then
                                return part, prompt, keyName
                            end
                        end
                    end
                end
            end
        end
    end

    return nil, nil, nil
end

local function MoveToTarget(targetPos)
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return false end

    if (hrp.Position - targetPos).Magnitude < 18 then
        humanoid:MoveTo(targetPos)
        local t = tick()
        while isAutoActive and (hrp.Position - targetPos).Magnitude > 5 do
            task.wait(0.1)
            if tick() - t > 2.5 then break end
        end
        return (hrp.Position - targetPos).Magnitude <= 7
    end

    local path = PathfindingService:CreatePath({ AgentRadius = 2.0, AgentHeight = 5.0, AgentCanJump = true })
    pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)

    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            if not isAutoActive then break end
            if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            
            humanoid:MoveTo(waypoint.Position)
            local lastPos = hrp.Position
            local t = tick()
            
            while isAutoActive and (hrp.Position - waypoint.Position).Magnitude > 4 do
                task.wait(0.05)
                if tick() - t > 0.6 and (hrp.Position - lastPos).Magnitude < 0.5 then
                    humanoid.Jump = true
                    break
                end
                if tick() - t > 1.2 then break end
            end
        end
    else
        humanoid:MoveTo(targetPos)
        task.wait(0.8)
    end
    return (hrp.Position - targetPos).Magnitude <= 8
end

local function SafeTrigger(prompt)
    if not prompt or not prompt.Parent then return end
    task.wait(0.1)
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, prompt.HoldDuration or 0)
        elseif prompt.InputHoldBegin then
            prompt:InputHoldBegin()
            task.wait((prompt.HoldDuration or 0) + 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

-- ============================================================================
-- 🎯 IRONCLAD SAFE CONTROLLER LOOP (WITH PCALL THREAD PROTECTION)
-- ============================================================================
task.spawn(function()
    while screenGui and screenGui.Parent do
        task.wait(0.5)
        
        if isAutoActive and not currentWorker then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                currentWorker = task.spawn(function()
                    local success, err = pcall(function()
                        local part, prompt, foundKey = SearchTarget()
                        
                        if part and prompt then
                            monitor.Text = "STATUS: 🏃 GOING TO [" .. string.upper(foundKey or "TARGET") .. "]"
                            monitor.TextColor3 = Color3.fromRGB(255, 200, 80)

                            local reached = MoveToTarget(part.Position)
                            if reached and isAutoActive then
                                monitor.Text = "STATUS: 🥚 STEALING EGG..."
                                monitor.TextColor3 = Color3.fromRGB(255, 140, 0)
                                
                                local waitPromptTime = tick()
                                while isAutoActive and not prompt.Enabled and (tick() - waitPromptTime < 2) do
                                    task.wait(0.1)
                                end

                                SafeTrigger(prompt)
                                task.wait(0.6)

                                if HasEgg() then
                                    monitor.Text = "STATUS: 🦅 FLYING BACK TO BASE (+30)"
                                    monitor.TextColor3 = Color3.fromRGB(100, 200, 255)
                                    
                                    local basePos = FindBasePos()
                                    StartFlyingToTarget(basePos)
                                    
                                    local flyTimeout = tick()
                                    while isAutoActive and HasEgg() and (hrp.Position - basePos).Magnitude > 10 and (tick() - flyTimeout < 15) do
                                        task.wait(0.2)
                                    end
                                    
                                    StopFlying()
                                    task.wait(1)
                                end
                            end
                        else
                            monitor.Text = "STATUS: 🔍 SCANNING MAP..."
                            monitor.TextColor3 = Color3.fromRGB(180, 190, 200)
                        end
                    end)
                    
                    if not success then
                        StopFlying()
                    end
                    
                    currentWorker = nil
                end)
            end
        end
    end
end)
