-- ========================================================
-- DEV EGG DATABASE DUMPER (เจาะค้นชื่อไข่ทั้งหมดของผู้พัฒนา)
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔓 Dev Egg Database Dumper",
   LoadingTitle = "กำลังเจาะค้นหา Database ไข่ของผู้พัฒนา...",
   LoadingSubtitle = "by Script Collaborator",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("📜 รายชื่อไข่ทั้งหมดในเกม", 4483362458)

local AllEggNames = {}

-- ฟังก์ชันสแกนหา Folder หรือ Module ใน ReplicatedStorage
local function DeepScanDevEggs()
    AllEggNames = {}
    local scannedCount = 0
    
    -- 1. ค้นหาใน ReplicatedStorage (ที่เก็บไอเท็มหลักที่ Server ส่งให้ Client)
    local repStorage = game:GetService("ReplicatedStorage")
    
    for _, obj in pairs(repStorage:GetDescendants()) do
        -- หาวัตถุที่อยู่ใน Folder เกี่ยวกับ Egg, Pets, Items หรือมีคำว่า Egg
        if string.find(string.lower(obj.Name), "egg") or (obj.Parent and string.find(string.lower(obj.Parent.Name), "egg")) then
            if not table.find(AllEggNames, obj.Name) and obj.Name ~= "Eggs" and obj.Name ~= "Egg" then
                table.insert(AllEggNames, obj.Name)
            end
        end
    end
    
    -- 2. ค้นหาใน Workspace เผื่อผู้พัฒนาสร้าง Folder รวม Egg Models ไว้
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
    
    -- แปลงเป็นข้อความต่อกัน
    local resultText = ""
    for index, name in ipairs(AllEggNames) do
        resultText = resultText .. "[" .. index .. "] " .. name .. "\n"
    end
    
    if #AllEggNames == 0 then
        return "❌ ไม่พบ Folder Database ไข่ของผู้พัฒนา (อาจจะโดนซ่อนไว้ใน ServerScriptService)"
    end
    
    return resultText
end

-- สแกนทันทีที่กดรัน
local devEggsResult = DeepScanDevEggs()

MainTab:CreateSection("รายชื่อไข่ทั้งหมดที่ผู้พัฒนาสร้างไว้ในเกม (#" .. #AllEggNames .. " รายการ)")

-- ช่องแสดงข้อความ
local ResultInput = MainTab:CreateInput({
   Name = "ชื่อไข่ทั้งหมดในระบบผู้พัฒนา:",
   PlaceholderText = "กำลังดึงข้อมูล...",
   RemoveTextOnFocus = false,
   Callback = function() end,
})

ResultInput:Set(devEggsResult)

MainTab:CreateSection("ตัวเลือกการดึงข้อมูล")

-- ปุ่มส่งชื่อทั้งหมดไปที่ Console (F9) เพื่อก๊อปปี้ง่ายๆ
MainTab:CreateButton({
   Name = "📋 ส่งรายชื่อทั้งหมดเข้า Console (กด F9 เพื่อ Copy)",
   Callback = function()
      print("\n================ [ DEV EGG DATABASE DUMP ] ================")
      for i, name in ipairs(AllEggNames) do
          print(i .. ". " .. name)
      end
      print("============================================================\n")
      
      Rayfield:Notify({
         Title = "ส่งข้อมูลสำเร็จ!",
         Content = "เปิด Console (F9) ในเกมเพื่อก๊อปปี้รายชื่อไข่ทั้งหมดได้เลย",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})
