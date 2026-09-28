-- ========================================================
-- EGG DATABASE DUMPER & AUTO CLIPBOARD COPY (FOR MOBILE / DELTA)
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "📱 Mobile Egg Dumper & Copy",
   LoadingTitle = "กำลังดึงข้อมูลชื่อไข่ทั้งหมด...",
   LoadingSubtitle = "by Script Collaborator",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("📋 คัดลอกชื่อไข่", 4483362458)

local AllEggNames = {}

-- ฟังก์ชันเจาะค้นหาชื่อไข่ทั้งหมดในระบบผู้พัฒนา
local function DeepScanDevEggs()
    AllEggNames = {}
    
    -- 1. เจาะค้นใน ReplicatedStorage
    local repStorage = game:GetService("ReplicatedStorage")
    for _, obj in pairs(repStorage:GetDescendants()) do
        if string.find(string.lower(obj.Name), "egg") or (obj.Parent and string.find(string.lower(obj.Parent.Name), "egg")) then
            if not table.find(AllEggNames, obj.Name) and obj.Name ~= "Eggs" and obj.Name ~= "Egg" then
                table.insert(AllEggNames, obj.Name)
            end
        end
    end
    
    -- 2. เจาะค้นใน Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Folder") or obj:IsA("Model") then
            if string.find(string.lower(obj.Name), "egg") then
                for _, child in pairs(obj:GetChildren()) do
                    if not table.find(AllEggNames, child.Name) then
                        table.insert(AllEggNames, child.Name)
                    end
                end
            end
        end
    end

    -- รวมรายชื่อเป็นข้อความยาวสำหรับ Copy
    local textForCopy = "=== รายชื่อไข่ทั้งหมดในเกม (#" .. #AllEggNames .. " รายการ) ===\n\n"
    for index, name in ipairs(AllEggNames) do
        textForCopy = textForCopy .. name .. "\n"
    end
    
    return textForCopy
end

-- สแกนข้อมูล
local textResult = DeepScanDevEggs()

MainTab:CreateSection("พบชื่อไข่ทั้งหมด: " .. #AllEggNames .. " รายการ")

-- ปุ่มกดคัดลอกลง Clipboard มือถือทันที
MainTab:CreateButton({
   Name = "📋 กดตรงนี้เพื่อคัดลอกชื่อไข่ทั้งหมด (Copy to Clipboard)",
   Callback = function()
      pcall(function()
         -- คำสั่งส่งข้อความเข้า Clipboard ของมือถือ
         setclipboard(textResult)
         
         Rayfield:Notify({
            Title = "คัดลอกสำเร็จ! ✅",
            Content = "ก๊อปปี้ชื่อไข่ทั้งหมดลงมือถือแล้ว นำไปวาง (Paste) ได้เลย",
            Duration = 5,
            Image = 4483362458,
         })
      end)
   end,
})

MainTab:CreateSection("ดูรายชื่อคร่าวๆ ในนี้:")

-- แสดงตัวอย่างข้อความใน UI
local SampleInput = MainTab:CreateInput({
   Name = "รายการที่พบ:",
   PlaceholderText = "กำลังดึงข้อมูล...",
   RemoveTextOnFocus = false,
   Callback = function() end,
})

SampleInput:Set(textResult)
