local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Thanathip x Dev " .. Fluent.Version,
    SubTitle = "By ThanathhipxDev",
    TabWidth = 190,
    Size = UDim2.fromOffset(685, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local LogoImage = "https://img2.pic.in.th/Thanathip-x-dev.png"
local LogoAsset = LogoImage
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

pcall(function()
    if writefile and isfile and getcustomasset then
        local fileName = "ThanathipLogo.png"

        if not isfile(fileName) then
            writefile(fileName, game:HttpGet(LogoImage))
        end

        LogoAsset = getcustomasset(fileName)
    end
end)

local GuiParent = (gethui and gethui()) or CoreGui

if _G.ThanathipUiRuntime then
    if _G.ThanathipUiRuntime.Connections then
        for _, connection in ipairs(_G.ThanathipUiRuntime.Connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
    end

    if _G.ThanathipUiRuntime.Gui then
        pcall(function()
            _G.ThanathipUiRuntime.Gui:Destroy()
        end)
    end

    if _G.ThanathipUiRuntime.MacControls then
        pcall(function()
            _G.ThanathipUiRuntime.MacControls:Destroy()
        end)
    end

    if _G.ThanathipUiRuntime.TitleOverlay then
        pcall(function()
            _G.ThanathipUiRuntime.TitleOverlay:Destroy()
        end)
    end

    if _G.ThanathipUiRuntime.UserProfilePanel then
        pcall(function()
            _G.ThanathipUiRuntime.UserProfilePanel:Destroy()
        end)
    end

end

local function clearOldRuntimeObjects(container)
    for _, object in ipairs(container:GetDescendants()) do
        if object.Name == "ThanathipLogoToggle" or object.Name == "WindowDragHandle" or object.Name == "MacControlButtons" or object.Name == "CustomTitleBarLabels" then
            pcall(function()
                object:Destroy()
            end)
        end
    end

    while container:FindFirstChild("ThanathipLogoToggle") do
        container:FindFirstChild("ThanathipLogoToggle"):Destroy()
    end

    while container:FindFirstChild("UserProfilePanel") do
        container:FindFirstChild("UserProfilePanel"):Destroy()
    end
end

for _, container in ipairs({GuiParent, CoreGui, Players.LocalPlayer:WaitForChild("PlayerGui")}) do
    clearOldRuntimeObjects(container)
end

_G.ThanathipUiRuntime = {
    Connections = {}
}

local LogoGui = Instance.new("ScreenGui")
LogoGui.Name = "ThanathipLogoToggle"
LogoGui.ResetOnSpawn = false
LogoGui.IgnoreGuiInset = true
LogoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LogoGui.Parent = GuiParent
_G.ThanathipUiRuntime.Gui = LogoGui

local LogoButton = Instance.new("ImageButton")
LogoButton.Name = "LogoButton"
LogoButton.Image = LogoAsset
LogoButton.BackgroundTransparency = 1
LogoButton.Size = UDim2.fromOffset(64, 64)
LogoButton.Position = UDim2.new(0, 18, 0.5, -32)
LogoButton.Visible = false
LogoButton.Active = true
LogoButton.Draggable = true
LogoButton.Parent = LogoGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoButton

local RuntimeConnections = _G.ThanathipUiRuntime.Connections

local CachedWindowGui
local CachedWindowRoot

local function findWindowGui()
    if CachedWindowGui and CachedWindowGui.Parent then
        return CachedWindowGui
    end

    for _, container in ipairs({GuiParent, CoreGui, Players.LocalPlayer:WaitForChild("PlayerGui")}) do
        for _, gui in ipairs(container:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= LogoGui then
                local foundTitle = false
                for _, item in ipairs(gui:GetDescendants()) do
                    if item:IsA("TextLabel") and tostring(item.Text):find("Thanathip x Dev") then
                        foundTitle = true
                        break
                    end
                end

                if foundTitle then
                    CachedWindowGui = gui
                    return gui
                end
            end
        end
    end
end

local function findWindowRoot()
    if CachedWindowRoot and CachedWindowRoot.Parent then
        return CachedWindowRoot
    end

    local windowGui = findWindowGui()

    if not windowGui then
        return
    end

    for _, item in ipairs(windowGui:GetDescendants()) do
        if item:IsA("TextLabel") and tostring(item.Text):find("Thanathip x Dev") then
            local root = item

            while root.Parent and not root.Parent:IsA("ScreenGui") do
                root = root.Parent
            end

            if root:IsA("GuiObject") then
                CachedWindowRoot = root
                return root
            end
        end
    end

    for _, property in ipairs({"Root", "Frame", "Window"}) do
        local success, object = pcall(function()
            return Window[property]
        end)

        if success and typeof(object) == "Instance" and object:IsA("GuiObject") then
            CachedWindowRoot = object
            return object
        end
    end
end

local function setWindowVisible(visible)
    local windowGui = findWindowGui()

    if windowGui then
        windowGui.Enabled = visible
    end

    for _, property in ipairs({"Root", "Frame", "Window"}) do
        local success, object = pcall(function()
            return Window[property]
        end)

        if success and typeof(object) == "Instance" and object:IsA("GuiObject") then
            object.Visible = visible
        end
    end
end

local function isWindowVisible()
    local minimized = false

    pcall(function()
        minimized = Window.Minimized == true
    end)

    if minimized then
        return false
    end

    local windowGui = findWindowGui()

    if windowGui and not windowGui.Enabled then
        return false
    end

    for _, property in ipairs({"Root", "Frame", "Window"}) do
        local success, object = pcall(function()
            return Window[property]
        end)

        if success and typeof(object) == "Instance" and object:IsA("GuiObject") and not object.Visible then
            return false
        end
    end

    return true
end

local DragHandle = Instance.new("Frame")
DragHandle.Name = "WindowDragHandle"
DragHandle.AnchorPoint = Vector2.new(0.5, 0)
DragHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DragHandle.BackgroundTransparency = 0.5
DragHandle.BorderSizePixel = 0
DragHandle.Size = UDim2.fromOffset(200, 4)
DragHandle.Visible = false
DragHandle.Active = true
DragHandle.Parent = LogoGui

local DragHandleCorner = Instance.new("UICorner")
DragHandleCorner.CornerRadius = UDim.new(1, 0)
DragHandleCorner.Parent = DragHandle

local draggingWindow = false
local dragStartPosition
local dragStartInputPosition
local styledMacButtons = false
local MacControlsFrame
local MacControlButtons
local TitleOverlay
local UserProfilePanel
local LastLocalizationTime = 0

local ThaiText = {
    ["Interface"] = "หน้าตา UI",
    ["Interface Manager"] = "จัดการหน้าตา UI",
    ["Configuration"] = "การตั้งค่า",
    ["Configuration Manager"] = "จัดการการตั้งค่า",
    ["Configs"] = "รายการตั้งค่า",
    ["Config"] = "การตั้งค่า",
    ["Settings"] = "Settings",
    ["Home"] = "Home",
    ["Save"] = "บันทึก",
    ["Load"] = "โหลด",
    ["Delete"] = "ลบ",
    ["Refresh"] = "รีเฟรช",
    ["Create"] = "สร้าง",
    ["Update"] = "อัปเดต",
    ["Reset"] = "รีเซ็ต",
    ["Cancel"] = "ยกเลิก",
    ["Confirm"] = "ยืนยัน",
    ["Yes"] = "ใช่",
    ["No"] = "ไม่",
    ["Close"] = "ปิด",
    ["Minimize"] = "ย่อ",
    ["Restore"] = "เปิดกลับ",
    ["Resize"] = "ปรับขนาด",
    ["Search"] = "ค้นหา",
    ["Select"] = "เลือก",
    ["Theme"] = "ธีม",
    ["Acrylic"] = "เอฟเฟกต์เบลอ",
    ["Transparency"] = "ความโปร่งใส",
    ["Save config"] = "บันทึกการตั้งค่า",
    ["Load config"] = "โหลดการตั้งค่า",
    ["Delete config"] = "ลบการตั้งค่า",
    ["Refresh list"] = "รีเฟรชรายการ",
    ["Auto Load"] = "โหลดอัตโนมัติ",
    ["Autoload"] = "โหลดอัตโนมัติ",
    ["Set as autoload"] = "ตั้งให้โหลดอัตโนมัติ",
    ["Ignore Theme Settings"] = "ไม่บันทึกค่าธีม",
    ["The script has been loaded."] = "โหลดสคริปต์เรียบร้อยแล้ว",
    ["Notification"] = "แจ้งเตือน"
}

local function translateText(text)
    if ThaiText[text] then
        return ThaiText[text]
    end

    local translated = text
    translated = translated:gsub("Save", "บันทึก")
    translated = translated:gsub("Load", "โหลด")
    translated = translated:gsub("Delete", "ลบ")
    translated = translated:gsub("Refresh", "รีเฟรช")
    translated = translated:gsub("Config", "การตั้งค่า")
    translated = translated:gsub("Interface", "หน้าตา UI")
    translated = translated:gsub("Theme", "ธีม")
    translated = translated:gsub("Autoload", "โหลดอัตโนมัติ")
    translated = translated:gsub("Auto Load", "โหลดอัตโนมัติ")

    return translated
end

local function localizeUiText()
    if os.clock() - LastLocalizationTime < 0.25 then
        return
    end

    LastLocalizationTime = os.clock()

    local windowRoot = findWindowRoot()

    if not windowRoot then
        return
    end

    for _, item in ipairs(windowRoot:GetDescendants()) do
        if item:IsA("TextLabel") or item:IsA("TextButton") then
            local text = tostring(item.Text)

            if text ~= "" and text ~= "Home" and text ~= "Settings" and item.Name ~= "CenteredTitle" and item.Name ~= "RightSubtitle" and not item:FindFirstAncestor("UserProfilePanel") then
                item.Text = translateText(text)
            end
        elseif item:IsA("TextBox") then
            local text = tostring(item.Text)
            local placeholder = tostring(item.PlaceholderText)

            if text ~= "" and text ~= "Home" and text ~= "Settings" then
                item.Text = translateText(text)
            end

            if placeholder ~= "" and placeholder ~= "Home" and placeholder ~= "Settings" then
                item.PlaceholderText = translateText(placeholder)
            end
        end
    end
end

local function updateUserProfilePanel()
    local windowRoot = findWindowRoot()

    if not windowRoot then
        return
    end

    local player = Players.LocalPlayer

    if not UserProfilePanel or not UserProfilePanel.Parent then
        UserProfilePanel = Instance.new("Frame")
        UserProfilePanel.Name = "UserProfilePanel"
        UserProfilePanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        UserProfilePanel.BackgroundTransparency = 0.93
        UserProfilePanel.BorderSizePixel = 0
        UserProfilePanel.Size = UDim2.fromOffset(170, 58)
        UserProfilePanel.ZIndex = 850
        UserProfilePanel.Parent = windowRoot
        _G.ThanathipUiRuntime.UserProfilePanel = UserProfilePanel

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = UserProfilePanel

        local avatar = Instance.new("ImageLabel")
        avatar.Name = "Avatar"
        avatar.BackgroundTransparency = 1
        avatar.Position = UDim2.fromOffset(8, 9)
        avatar.Size = UDim2.fromOffset(40, 40)
        avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=150&h=150"
        avatar.ZIndex = 851
        avatar.Parent = UserProfilePanel

        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatar

        local displayName = Instance.new("TextLabel")
        displayName.Name = "DisplayName"
        displayName.BackgroundTransparency = 1
        displayName.Position = UDim2.fromOffset(54, 8)
        displayName.Size = UDim2.fromOffset(108, 16)
        displayName.Font = Enum.Font.GothamSemibold
        displayName.TextColor3 = Color3.fromRGB(235, 235, 235)
        displayName.TextSize = 11
        displayName.TextXAlignment = Enum.TextXAlignment.Left
        displayName.TextTruncate = Enum.TextTruncate.AtEnd
        displayName.ZIndex = 851
        displayName.Parent = UserProfilePanel

        local username = Instance.new("TextLabel")
        username.Name = "Username"
        username.BackgroundTransparency = 1
        username.Position = UDim2.fromOffset(54, 24)
        username.Size = UDim2.fromOffset(108, 14)
        username.Font = Enum.Font.Gotham
        username.TextColor3 = Color3.fromRGB(185, 185, 185)
        username.TextSize = 10
        username.TextXAlignment = Enum.TextXAlignment.Left
        username.TextTruncate = Enum.TextTruncate.AtEnd
        username.ZIndex = 851
        username.Parent = UserProfilePanel

        local userId = Instance.new("TextLabel")
        userId.Name = "UserId"
        userId.BackgroundTransparency = 1
        userId.Position = UDim2.fromOffset(54, 38)
        userId.Size = UDim2.fromOffset(108, 12)
        userId.Font = Enum.Font.Gotham
        userId.TextColor3 = Color3.fromRGB(150, 150, 150)
        userId.TextSize = 9
        userId.TextXAlignment = Enum.TextXAlignment.Left
        userId.TextTruncate = Enum.TextTruncate.AtEnd
        userId.ZIndex = 851
        userId.Parent = UserProfilePanel
    end

    UserProfilePanel.Position = UDim2.fromOffset(10, math.max(windowRoot.AbsoluteSize.Y - 70, 60))
    UserProfilePanel.DisplayName.Text = player.DisplayName
    UserProfilePanel.Username.Text = "@" .. player.Name
    UserProfilePanel.UserId.Text = "ID: " .. tostring(player.UserId)
end

local function alignTitleLabels()
    local windowRoot = findWindowRoot()

    if not windowRoot then
        return
    end

    if not TitleOverlay or not TitleOverlay.Parent then
        TitleOverlay = Instance.new("Frame")
        TitleOverlay.Name = "CustomTitleBarLabels"
        TitleOverlay.BackgroundTransparency = 1
        TitleOverlay.Size = UDim2.new(1, 0, 0, 48)
        TitleOverlay.Position = UDim2.fromOffset(0, 0)
        TitleOverlay.ZIndex = 900
        TitleOverlay.Parent = windowRoot

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "CenteredTitle"
        titleLabel.BackgroundTransparency = 1
        titleLabel.AnchorPoint = Vector2.new(0.5, 0)
        titleLabel.Position = UDim2.new(0.5, 0, 0, 12)
        titleLabel.Size = UDim2.fromOffset(320, 18)
        titleLabel.Font = Enum.Font.Gotham
        titleLabel.Text = "Thanathip x Dev " .. tostring(Fluent.Version)
        titleLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
        titleLabel.TextSize = 12
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.ZIndex = 901
        titleLabel.Parent = TitleOverlay

        local subtitleLabel = Instance.new("TextLabel")
        subtitleLabel.Name = "RightSubtitle"
        subtitleLabel.BackgroundTransparency = 1
        subtitleLabel.AnchorPoint = Vector2.new(1, 0)
        subtitleLabel.Position = UDim2.new(1, -18, 0, 12)
        subtitleLabel.Size = UDim2.fromOffset(240, 18)
        subtitleLabel.Font = Enum.Font.Gotham
        subtitleLabel.Text = "By ThanathhipxDev"
        subtitleLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        subtitleLabel.TextSize = 12
        subtitleLabel.TextXAlignment = Enum.TextXAlignment.Right
        subtitleLabel.ZIndex = 901
        subtitleLabel.Parent = TitleOverlay

        _G.ThanathipUiRuntime.TitleOverlay = TitleOverlay
    end

    for _, item in ipairs(windowRoot:GetDescendants()) do
        if item:IsA("TextLabel") then
            local text = tostring(item.Text)
            local relativeY = item.AbsolutePosition.Y - windowRoot.AbsolutePosition.Y

            if text:find("Thanathip x Dev") and relativeY >= 0 and relativeY <= 54 then
                if item.Name ~= "CenteredTitle" then
                    item.TextTransparency = 1
                end
            elseif text:find("By ThanathhipxDev") and relativeY >= 0 and relativeY <= 54 then
                if item.Name ~= "RightSubtitle" then
                    item.TextTransparency = 1
                end
            end
        end
    end
end

local function styleMacControlButtons()
    local windowRoot = findWindowRoot()

    if not windowRoot then
        return
    end

    if not styledMacButtons then
        local controls = {}

        for _, item in ipairs(windowRoot:GetDescendants()) do
            if (item:IsA("ImageButton") or item:IsA("TextButton")) and item.AbsoluteSize.X <= 42 and item.AbsoluteSize.Y <= 42 then
                local relativeX = item.AbsolutePosition.X - windowRoot.AbsolutePosition.X
                local relativeY = item.AbsolutePosition.Y - windowRoot.AbsolutePosition.Y

                if relativeY >= 0 and relativeY <= 54 and relativeX >= windowRoot.AbsoluteSize.X - 170 then
                    table.insert(controls, item)
                end
            end
        end

        if #controls < 3 then
            return
        end

        table.sort(controls, function(a, b)
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)

        MacControlsFrame = Instance.new("Frame")
        MacControlsFrame.Name = "MacControlButtons"
        MacControlsFrame.BackgroundTransparency = 1
        MacControlsFrame.Size = UDim2.fromOffset(86, 28)
        MacControlsFrame.Position = UDim2.fromOffset(14, 12)
        MacControlsFrame.ZIndex = 999
        MacControlsFrame.Parent = windowRoot
        _G.ThanathipUiRuntime.MacControls = MacControlsFrame

        MacControlButtons = {
            controls[3],
            controls[1],
            controls[2]
        }

        for index = 1, 3 do
            local button = MacControlButtons[index]

            button.Parent = MacControlsFrame
            button.AnchorPoint = Vector2.new(0, 0.5)
            button.Position = UDim2.fromOffset((index - 1) * 28, 14)
            button.Size = UDim2.fromOffset(18, 18)
            button.ClipsDescendants = true
            button.ZIndex = 1000
            button.AutoButtonColor = false
        end

        styledMacButtons = true
    end

    if not MacControlsFrame or not MacControlsFrame.Parent or not MacControlButtons then
        styledMacButtons = false
        return
    end

    local colors = {
        Color3.fromRGB(255, 95, 87),
        Color3.fromRGB(255, 189, 46),
        Color3.fromRGB(40, 200, 64)
    }

    for index = 1, 3 do
        local button = MacControlButtons[index]

        if not button or not button.Parent then
            styledMacButtons = false
            return
        end

        button.BackgroundColor3 = colors[index]
        button.BackgroundTransparency = 0
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Size = UDim2.fromOffset(18, 18)
        button.ClipsDescendants = true
        button.Position = UDim2.fromOffset((index - 1) * 28, 14)

        if button:IsA("TextButton") then
            button.TextTransparency = 1
            button.Text = ""
        end

        pcall(function()
            button.ImageTransparency = 1
        end)

        for _, child in ipairs(button:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                pcall(function()
                    child.Text = ""
                    child.TextTransparency = 1
                    child.BackgroundTransparency = 1
                end)
            elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                pcall(function()
                    child.ImageTransparency = 1
                    child.BackgroundTransparency = 1
                end)
            end
        end

        if not button:FindFirstChild("MacControlCorner") then
            local corner = Instance.new("UICorner")
            corner.Name = "MacControlCorner"
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = button
        end

        if not button:FindFirstChild("MacControlStroke") then
            local stroke = Instance.new("UIStroke")
            stroke.Name = "MacControlStroke"
            stroke.Color = Color3.fromRGB(0, 0, 0)
            stroke.Transparency = 0.82
            stroke.Thickness = 1
            stroke.Parent = button
        end
    end

    styledMacButtons = true
end

table.insert(RuntimeConnections, DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local windowRoot = findWindowRoot()

        if not windowRoot then
            return
        end

        draggingWindow = true
        dragStartPosition = windowRoot.AbsolutePosition
        dragStartInputPosition = input.Position
    end
end))

table.insert(RuntimeConnections, UserInputService.InputChanged:Connect(function(input)
    if not draggingWindow then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local windowRoot = findWindowRoot()

    if not windowRoot then
        return
    end

    local delta = input.Position - dragStartInputPosition
    windowRoot.Position = UDim2.fromOffset(dragStartPosition.X + delta.X, dragStartPosition.Y + delta.Y)
end))

table.insert(RuntimeConnections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = false
    end
end))

table.insert(RuntimeConnections, LogoButton.MouseButton1Click:Connect(function()
    pcall(function()
        if Window.Minimized and Window.Minimize then
            Window:Minimize()
        end
    end)

    setWindowVisible(true)
    LogoButton.Visible = false
end))

table.insert(RuntimeConnections, RunService.RenderStepped:Connect(function()
    local windowVisible = isWindowVisible()
    local windowRoot = findWindowRoot()

    styleMacControlButtons()
    alignTitleLabels()
    localizeUiText()
    updateUserProfilePanel()

    LogoButton.Visible = not windowVisible
    DragHandle.Visible = windowVisible and windowRoot ~= nil

    if windowRoot then
        local width = math.max(windowRoot.AbsoluteSize.X * 0.35, 70)
        DragHandle.Size = UDim2.fromOffset(width, 4)
        DragHandle.Position = UDim2.fromOffset(
            windowRoot.AbsolutePosition.X + (windowRoot.AbsoluteSize.X / 2),
            windowRoot.AbsolutePosition.Y + windowRoot.AbsoluteSize.Y + 70
        )
    end
end))

table.insert(RuntimeConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        task.wait()
        LogoButton.Visible = not isWindowVisible()
    end
end))

local Tabs = {
    Main = Window:AddTab({ Title = "Home", Icon = "home" }),
    AutoNormal = Window:AddTab({ Title = "Auto Normal", Icon = "bot" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Tabs.Main:AddParagraph({
    Title = "ค่ายผู้ให้บริการสคริปต์",
    Content = "Thanathip x Dev"
})

Tabs.Main:AddButton({
    Title = "คลิก สำหรับก็อปปี้ Discord",
    Description = "Click For copy link discord.",
    Callback = function()
        local discordLink = "https://discord.gg/yCFVxTJ2pN"

        if setclipboard then
            setclipboard(discordLink)
        elseif toclipboard then
            toclipboard(discordLink)
        end

        Fluent:Notify({
            Title = "แจ้งเตือน",
            Content = "ก็อปปี้ลิงก์ Discord เรียบร้อยแล้ว",
            Duration = 5
        })
    end
})

local AnimalOptions = {
    { Name = "Frog", Price = 10000, Rank = "Common" },
    { Name = "Bunny", Price = 20000, Rank = "Common" },
    { Name = "Owl", Price = 25000, Rank = "Uncommon" },
    { Name = "Deer", Price = 50000, Rare = "Rare" },
    { Name = "Turtle", Price = 70000, Rank = "Rare" },
    { Name = "Robin", Price = 75000, Rank = "Legendary" },
    { Name = "Bee", Price = 1000000, Rank = "Legendary" },
    { Name = "Monkey", Price = 3000000, Rank = "Mythic" },
    { Name = "Golden Dragonfly", Price = 9000000, Rank = "Mythic" },
    { Name = "Unicorn", Price = 12000000, Rank = "Mythic" },
    { Name = "Bear", Price = 5000000, Rank = "Mythic" },
    { Name = "Raccoon", Price = 15000000, Rank = "Super" }
}
local AnimalOptionLabels = {}
local AnimalOptionsByLabel = {}
local SelectedAnimals = {}
local AutoAnimalsToggle

local function formatNumber(value)
    local text = tostring(math.floor(tonumber(value) or 0))
    local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()

    if formatted:sub(1, 1) == "," then
        formatted = formatted:sub(2)
    end

    return formatted
end

local function getPlayerMoney()
    local player = Players.LocalPlayer
    local leaderstats = player and player:FindFirstChild("leaderstats")
    local sheckles = leaderstats and leaderstats:FindFirstChild("Sheckles")

    return tonumber(sheckles and sheckles.Value) or 0
end

local function canAffordAnimal(animal)
    return animal and getPlayerMoney() >= animal.Price
end

-- ========== ANIMALS AUTOMATION SYSTEM ==========

local AutoAnimalsActive = false
local AutoAnimalsThread = nil
local VirtualInputManager = nil
local HttpService = game:GetService("HttpService")

pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local function getCharacterParts()
    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    return char, hrp, hum
end

local function warpToSpawn()
    pcall(function()
        local spawnPoint = workspace:FindFirstChild("Gardens")
            and workspace.Gardens:FindFirstChild("Plot1")
            and workspace.Gardens.Plot1:FindFirstChild("SpawnPoint")

        if spawnPoint then
            local _, hrp, _ = getCharacterParts()
            if hrp then
                hrp.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end

local function findTargetAnimal(animalName)
    local found = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name
            local extractedName = name:match("^WildPet_([^_]+)_")
            if extractedName and extractedName:lower() == animalName:lower() then
                if obj:IsA("Model") then
                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        table.insert(found, { model = obj, part = part })
                    end
                else
                    table.insert(found, { model = obj.Parent, part = obj })
                end
            end
        end
    end

    return found
end

local function smoothMoveTo(targetPart)
    local _, hrp, _ = getCharacterParts()
    if not hrp or not targetPart then return end

    local maxSteps = 80
    local step = 0

    while step < maxSteps and AutoAnimalsActive do
        if not targetPart or not targetPart.Parent then break end
        if not hrp or not hrp.Parent then break end

        local targetPos = targetPart.CFrame.Position + Vector3.new(0, 3, 0)
        local currentPos = hrp.Position
        local dist = (targetPos - currentPos).Magnitude

        if dist < 5 then break end

        local alpha = math.min(0.35, dist / 20)
        local newPos = currentPos:Lerp(targetPos, alpha)
        hrp.CFrame = CFrame.new(newPos, targetPos)

        step += 1
        task.wait(0.03)
    end
end

local function getObjectPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        return p and p.Position
    end
    return nil
end

local function findNearbyInteractable()
    local _, hrp, _ = getCharacterParts()
    if not hrp then return nil, nil end

    local bestObj = nil
    local bestType = nil
    local bestDist = 25

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parent = obj.Parent
            local pos = getObjectPosition(parent)
            if pos then
                local dist = (pos - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestObj = obj
                    bestType = "ProximityPrompt"
                end
            end
        elseif obj:IsA("ClickDetector") then
            local parent = obj.Parent
            local pos = getObjectPosition(parent)
            if pos then
                local dist = (pos - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestObj = obj
                    bestType = "ClickDetector"
                end
            end
        end
    end

    if not bestObj then
        for _, gui in ipairs(workspace:GetDescendants()) do
            if (gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) then
                local adornee = gui.Adornee or gui.Parent
                local pos = adornee and getObjectPosition(adornee)
                if pos then
                    local dist = (pos - hrp.Position).Magnitude
                    if dist < bestDist then
                        for _, child in ipairs(gui:GetDescendants()) do
                            if (child:IsA("TextButton") or child:IsA("ImageButton")) and child.Visible then
                                bestDist = dist
                                bestObj = child
                                bestType = "GuiButton"
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    if not bestObj then
        local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in ipairs(playerGui:GetDescendants()) do
                if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                    local text = tostring(gui.Text):upper()
                    if text == "E" or text == "" or text:find("HOLD") or text:find("PRESS") or text:find("COLLECT") or text:find("CATCH") then
                        bestObj = gui
                        bestType = "ScreenButton"
                        break
                    end
                end
            end
        end
    end

    return bestObj, bestType
end

local function holdInteractableUntilGone(obj, objType)
    if not obj then return end

    local holdStart = os.clock()
    local maxHold = 10

    if objType == "ProximityPrompt" then
        local holdDuration = (obj.HoldDuration or 0)
        local usedFire = false
        pcall(function()
            if fireproximityprompt then
                if holdDuration > 0 then
                    local fireStart = os.clock()
                    while AutoAnimalsActive and obj and obj.Parent do
                        fireproximityprompt(obj)
                        if os.clock() - fireStart >= holdDuration + 0.3 then break end
                        task.wait(0.05)
                    end
                else
                    fireproximityprompt(obj)
                end
                usedFire = true
            end
        end)

        if not usedFire then
            pcall(function()
                if VirtualInputManager then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    local waitTime = math.max(holdDuration + 0.3, 0.5)
                    task.wait(waitTime)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end)
        end

        if not usedFire then
            pcall(function()
                local inputObject = {
                    KeyCode = Enum.KeyCode.E,
                    UserInputType = Enum.UserInputType.Keyboard,
                    UserInputState = Enum.UserInputState.Begin
                }
                UserInputService.InputBegan:Fire(inputObject, false)
                task.wait(math.max(holdDuration + 0.3, 0.5))
                inputObject.UserInputState = Enum.UserInputState.End
                UserInputService.InputEnded:Fire(inputObject, false)
            end)
        end

        local waited = 0
        while obj and obj.Parent and waited < 80 and AutoAnimalsActive do
            task.wait(0.1)
            waited += 1
        end

    elseif objType == "ClickDetector" then
        local fired = false
        pcall(function()
            if fireclickdetector then
                fireclickdetector(obj)
                fired = true
            end
        end)
        if not fired then
            pcall(function()
                obj.MouseClick:Fire(Players.LocalPlayer)
            end)
        end

        local waited = 0
        while obj and obj.Parent and waited < 80 and AutoAnimalsActive do
            task.wait(0.1)
            waited += 1
        end

    elseif objType == "GuiButton" or objType == "ScreenButton" then
        local function clickButton()
            pcall(function()
                obj.MouseButton1Click:Fire()
            end)
            pcall(function()
                obj.MouseButton1Down:Fire(0, 0)
                task.wait(0.05)
                obj.MouseButton1Up:Fire(0, 0)
            end)
        end

        while obj and obj.Parent and obj.Visible and AutoAnimalsActive do
            if os.clock() - holdStart >= maxHold then break end
            clickButton()
            task.wait(0.15)
        end
    end
end

local function runAutoAnimalsLoop()
    while AutoAnimalsActive do
        if #SelectedAnimals == 0 then
            AutoAnimalsActive = false
            if AutoAnimalsToggle and AutoAnimalsToggle.SetValue then
                pcall(function() AutoAnimalsToggle:SetValue(false) end)
            end
            Fluent:Notify({ Title = "Animals", Content = "ไม่มีตัวเลือกที่เลือก ปิดอัตโนมัติ", Duration = 4 })
            break
        end

        local foundAnyTarget = false

        for _, animal in ipairs(SelectedAnimals) do
            if not AutoAnimalsActive then break end

            if canAffordAnimal(animal) then
                local targets = findTargetAnimal(animal.Name)

                if #targets > 0 then
                    foundAnyTarget = true
                    local target = targets[1]
                    local targetPart = target.part

                    if targetPart and targetPart.Parent then
                        smoothMoveTo(targetPart)

                        if AutoAnimalsActive then
                            local interactable, interactType = findNearbyInteractable()
                            if interactable then
                                holdInteractableUntilGone(interactable, interactType)
                            else
                                task.wait(0.5)
                                interactable, interactType = findNearbyInteractable()
                                if interactable then
                                    holdInteractableUntilGone(interactable, interactType)
                                end
                            end
                        end

                        if AutoAnimalsActive then
                            warpToSpawn()
                            task.wait(1)
                        end
                        
                        break
                    end
                end
            end
        end

        if not foundAnyTarget and AutoAnimalsActive then
            task.wait(1)
        end

        task.wait(0.1)
    end
end

local function setAutoAnimalsEnabled(enabled)
    if not enabled then
        AutoAnimalsActive = false
        return
    end

    if #SelectedAnimals == 0 then
        Fluent:Notify({
            Title = "Animals",
            Content = "กรุณาเลือก Name Animals อย่างน้อย 1 ตัว",
            Duration = 4
        })
        if AutoAnimalsToggle and AutoAnimalsToggle.SetValue then
            pcall(function() AutoAnimalsToggle:SetValue(false) end)
        end
        return
    end

    local canAffordAny = false
    for _, animal in ipairs(SelectedAnimals) do
        if canAffordAnimal(animal) then
            canAffordAny = true
            break
        end
    end

    if not canAffordAny then
        Fluent:Notify({
            Title = "Animals",
            Content = "เงินของคุณไม่พอสำหรับสัตว์ประเภทใดๆ ที่คุณเลือกไว้เลย",
            Duration = 5
        })
        if AutoAnimalsToggle and AutoAnimalsToggle.SetValue then
            pcall(function() AutoAnimalsToggle:SetValue(false) end)
        end
        return
    end

    AutoAnimalsActive = true

    Fluent:Notify({
        Title = "Animals",
        Content = "เริ่มทำงาน Auto Animals แบบหลายตัวเลือกเรียบร้อย",
        Duration = 4
    })

    if AutoAnimalsThread then
        task.cancel(AutoAnimalsThread)
    end
    AutoAnimalsThread = task.spawn(runAutoAnimalsLoop)
end

-- ========== GARDEN PROTECTION SYSTEM ==========

local ProtectionActive = false
local ProtectionThread = nil
local LocalWalls = {}

local function removeLocalWalls()
    for _, wall in ipairs(LocalWalls) do
        pcall(function() wall:Destroy() end)
    end
    LocalWalls = {}
end

local function createLocalWalls()
    removeLocalWalls()
    pcall(function()
        local myPlot = workspace:FindFirstChild("Gardens") and workspace.Gardens:FindFirstChild("Plot1")
        if myPlot then
            local plotPos = myPlot:FindFirstChild("SpawnPoint") and myPlot.SpawnPoint.Position
            if not plotPos then
                local anyPart = myPlot:FindFirstChildWhichIsA("BasePart", true)
                if anyPart then plotPos = anyPart.Position end
            end
            
            if plotPos then
                local size = 150
                local height = 100
                local wallThickness = 2
                
                local wallPositions = {
                    {CFrame = CFrame.new(plotPos + Vector3.new(size/2, height/2, 0)), Size = Vector3.new(wallThickness, height, size)},
                    {CFrame = CFrame.new(plotPos + Vector3.new(-size/2, height/2, 0)), Size = Vector3.new(wallThickness, height, size)},
                    {CFrame = CFrame.new(plotPos + Vector3.new(0, height/2, size/2)), Size = Vector3.new(size, height, wallThickness)},
                    {CFrame = CFrame.new(plotPos + Vector3.new(0, height/2, -size/2)), Size = Vector3.new(size, height, wallThickness)},
                }
                
                for _, wallData in ipairs(wallPositions) do
                    local wall = Instance.new("Part")
                    wall.Size = wallData.Size
                    wall.CFrame = wallData.CFrame
                    wall.Anchored = true
                    wall.Transparency = 1 
                    wall.Color = Color3.fromRGB(255, 30, 30)
                    wall.Material = Enum.Material.SmoothPlastic
                    wall.CanCollide = false
                    wall.Name = "ProtectionWall"
                    wall.Parent = workspace
                    table.insert(LocalWalls, wall)
                end
            end
        end
    end)
end

local function runProtectionLoop()
    while ProtectionActive do
        pcall(function()
            local player = Players.LocalPlayer
            local myPlot = workspace:FindFirstChild("Gardens") and workspace.Gardens:FindFirstChild("Plot1")
            
            if myPlot then
                local plotPos = myPlot:FindFirstChild("SpawnPoint") and myPlot.SpawnPoint.Position
                if not plotPos then
                    local anyPart = myPlot:FindFirstChildWhichIsA("BasePart", true)
                    if anyPart then plotPos = anyPart.Position end
                end
                
                if plotPos then
                    for _, v in ipairs(Players:GetPlayers()) do
                        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                            local targetHrp = v.Character.HumanoidRootPart
                            local distance = (targetHrp.Position - plotPos).Magnitude
                            
                            if distance < 85 then
                                if v.Character.Humanoid.Health > 0 then
                                    v.Character.Humanoid.Health = 0
                                    v.Character:BreakJoints()
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end

local function setProtectionEnabled(enabled)
    ProtectionActive = enabled
    if enabled then
        createLocalWalls()
        if ProtectionThread then task.cancel(ProtectionThread) end
        ProtectionThread = task.spawn(runProtectionLoop)
        Fluent:Notify({
            Title = "Garden Protection",
            Content = "เปิดใช้งานระบบป้องกันสวนแบบล่องหนเรียบร้อยแล้ว",
            Duration = 4
        })
    else
        removeLocalWalls()
        if ProtectionThread then 
            task.cancel(ProtectionThread) 
            ProtectionThread = nil
        end
        Fluent:Notify({
            Title = "Garden Protection",
            Content = "ปิดใช้งานระบบป้องกันสวนแล้ว",
            Duration = 4
        })
    end
end

-- ===============================================

for _, animal in ipairs(AnimalOptions) do
    local label = animal.Name .. " / " .. formatNumber(animal.Price) .. " / " .. animal.Rank

    table.insert(AnimalOptionLabels, label)
    AnimalOptionsByLabel[label] = animal
end

-- ========== [จุดแก้ไขโครงสร้างเมนู หน้า Auto Normal] ==========
-- สร้างตัวแปรมารับค่า Section และส่งค่าเป็น String ข้อความตรงๆ เพื่อให้ระบบเอาไปเจนเนอเรทปุ่มลูกได้ถูกต้อง
local ProtectionSection = Tabs.AutoNormal:AddSection("Garden Protection")

-- เอาปุ่ม Toggle ไปผูกไว้กับตัวแปร Section ที่เราเพิ่งสร้าง
ProtectionSection:AddToggle("CreateProtection", {
    Title = "Create Protection",
    Description = "สร้างการป้องกันสวน จากการขโมยผลไม้",
    Default = false,
    Callback = function(value)
        setProtectionEnabled(value)
    end
})

local AnimalsSection = Tabs.AutoNormal:AddSection("Animals")

local NameAnimalsDropdown = AnimalsSection:AddDropdown("NameAnimals", {
    Title = "Name Animals",
    Values = AnimalOptionLabels,
    Multi = true,
    Default = {}
})

NameAnimalsDropdown:OnChanged(function(value)
    SelectedAnimals = {}
    for label, selected in pairs(value) do
        if selected then
            local animal = AnimalOptionsByLabel[label]
            if animal then
                table.insert(SelectedAnimals, animal)
            end
        end
    end
end)

AutoAnimalsToggle = AnimalsSection:AddToggle("AutoAnimals", {
    Title = "Auto Animals",
    Description = "ต้องเลือก Name Animals และมีเงินเพียงพอ",
    Default = false,
    Callback = function(value)
        setAutoAnimalsEnabled(value)
    end
})

-- =============================================================

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
    Title = "แจ้งเตือน",
    Content = "โหลดสคริปต์เรียบร้อยแล้ว",
    Duration = 8
})
