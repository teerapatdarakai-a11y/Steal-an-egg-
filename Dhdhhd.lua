-- [[ STEAL AN EGG: TESTING MODULE (COMMON CHICKEN EGG TEST) ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
local StatusLabel = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")

-- ดีไซน์หน้าต่าง UI
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "EggTesterHub"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 160)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "EGG TESTER V2"
Title.TextColor3 = Color3.fromRGB(0, 255, 150) -- สีเขียวสำหรับตัวเทส
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Parent = TopBar
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(0.85, 0, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 35, 1, 0)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.TextSize = 20

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0, 45)
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "สถานะ: รอการทดสอบ..."
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 14

ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "START TEST"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16

ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleBtn

-- ปุ่มย่อหน้าต่าง
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = !isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 260, 0, 35), "Out", "Quad", 0.3, true)
        ToggleBtn.Visible = false
        StatusLabel.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 260, 0, 160), "Out", "Quad", 0.3, true)
        task.wait(0.1)
        ToggleBtn.Visible = true
        StatusLabel.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

-- =======================================================
-- SYSTEM LOGIC & INFINITE JUMP
-- =======================================================

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

_G.AutoStealTest = false

-- เปิดใช้งานระบบ Infinite Jump ทันทีที่รันสคริปต์
UserInputService.JumpRequest:Connect(function()
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function getMyBase()
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Bases") or workspace:FindFirstChild("Tycoons")
    if plots then
        for _, plot in pairs(plots:GetChildren()) do
            if plot:GetAttribute("Owner") == player.Name or (plot:FindFirstChild("Owner") and (plot.Owner.Value == player or plot.Owner.Value == player.Name)) then
                return plot:FindFirstChild("EggDrop") or plot:FindFirstChild("Main") or plot:FindFirstChild("DropZone") or plot
            end
        end
    end
    return nil
end

-- ฟังก์ชันค้นหาไข่เป้าหมายตัวอย่าง (Common Chicken Egg)
local function getTestTargetEgg()
    -- สแกนหาจากตำแหน่งยอดนิยมในไฟล์เกม
    local foldersToSearch = {
        workspace:FindFirstChild("Eggs"),
        workspace:FindFirstChild("EggSpawns"),
        workspace:FindFirstChild("DroppedEggs"),
        workspace -- เผื่อกรณีไข่วางอยู่กระจายใน Workspace
    }
    
    for _, eggFolder in pairs(foldersToSearch) do
        if eggFolder then
            for _, egg in pairs(eggFolder:GetChildren()) do
                if egg:IsA("Model") or egg:IsA("BasePart") then
                    local nameLower = string.lower(egg.Name)
                    -- ตรวจสอบคำดักจับ (รองรับทั้งพิมพ์ผิด คล้ายคลึง หรือชื่อตรง)
                    if string.find(nameLower, "common") and string.find(nameLower, "chick") then
                        return egg
                    end
                end
            end
        end
    end
    return nil
end

local function flyTo(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    -- บินสูงขึ้น 45 หน่วยเพื่อความปลอดภัยจากผู้พุมด่าน
    local flyHeight = Vector3.new(0, 45, 0)
    local startFlyPos = hrp.Position + flyHeight
    local endFlyPos = targetCFrame.Position + flyHeight

    hrp.CFrame = CFrame.new(startFlyPos)
    task.wait(0.1)

    local distance = (startFlyPos - endFlyPos).Magnitude
    local duration = distance / 500 -- ค่อยๆ เร่งความเร็วจำกัดที่ 500

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(endFlyPos)})
    tween:Play()
    tween.Completed:Wait()

    hrp.CFrame = targetCFrame
    task.wait(0.1)
end

-- ลูปทำงานหลักสำหรับตัวทดสอบ
task.spawn(function()
    while true do
        if _G.AutoStealTest then
            StatusLabel.Text = "สถานะ: กำลังค้นหา Common Chicken..."
            StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
            
            local targetEgg = getTestTargetEgg()
            if targetEgg and _G.AutoStealTest then
                StatusLabel.Text = "พบไข่ทดสอบ: บินไปหา " .. targetEgg.Name
                StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                
                local eggCFrame = targetEgg:IsA("Model") and (targetEgg.PrimaryPart and targetEgg.PrimaryPart.CFrame or targetEgg:GetModelCFrame()) or targetEgg.CFrame
                flyTo(eggCFrame)
                
                if _G.AutoStealTest then
                    StatusLabel.Text = "กำลังกดขโมยไข่ (Hold E)..."
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(2.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
                
                if _G.AutoStealTest then
                    StatusLabel.Text = "บินกลับฐานหลัก..."
                    local myBase = getMyBase()
                    if myBase then 
                        local baseCFrame = myBase:IsA("Model") and (myBase.PrimaryPart and myBase.PrimaryPart.CFrame or myBase:GetModelCFrame()) or myBase.CFrame
                        flyTo(baseCFrame) 
                    end
                    task.wait(0.5)
                end
            end
        else
            StatusLabel.Text = "สถานะ: ปิดการทำงาน"
            StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        task.wait(1)
    end
end)

-- ควบคุมปุ่มเปิด-ปิดระบบสคริปต์
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoStealTest = not _G.AutoStealTest
    if _G.AutoStealTest then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        ToggleBtn.Text = "STOP TEST"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        ToggleBtn.Text = "START TEST"
    end
end)

print("สคริปต์ทดสอบสแกน Common_Chicken_Egg พร้อมใช้งาน!")
