local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Thanathip x Dev",
    SubTitle = "บริการรับเขียนสคริปต์คุณภาพสูง ราคาถูก",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,

    -- macOS-style colored window buttons
    CloseColor = Color3.fromRGB(255, 95, 86),   -- Red
    MinimizeColor = Color3.fromRGB(255, 189, 46), -- Yellow
    MaximizeColor = Color3.fromRGB(39, 201, 63),  -- Green
})

-- หมวดหมู่ 1 : HOME
local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "house" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    -- แถบแสดงข้อมูลใน Home tab
    Tabs.Home:AddParagraph({
        Title = "กำลังมองหาค่ายเขียนสคริปต์รึป่าว?",
        Content = "ติดต่อไปที่นี่สิ่\nFacebook : Thanathip Lamlert"
    })
end

-- Addons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Thanathip x Dev",
    Content = "โหลดสคริปต์เรียบร้อยแล้ว!",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
