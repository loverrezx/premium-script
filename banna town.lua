local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local GlobalEnv = (getgenv and getgenv()) or _G
if GlobalEnv.LoverrWindow and GlobalEnv.LoverrWindow.Root then
    GlobalEnv.LoverrWindow.Root:Destroy()
end

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TAB_WIDTH = 160

local Window = Fluent:CreateWindow({
    Title = "JOPAGEN " .. Fluent.Version,
    SubTitle = "Banna Town | Premium Script",
    TabWidth = TAB_WIDTH,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

GlobalEnv.LoverrWindow = Window

local ControlBar = Instance.new("Frame")
ControlBar.Name = "ControlBar"
ControlBar.Size = UDim2.fromOffset(80, 18)
ControlBar.AnchorPoint = Vector2.new(1, 0)
ControlBar.Position = UDim2.new(1, -6, 0, 12)
ControlBar.BackgroundTransparency = 1
ControlBar.BorderSizePixel = 0
ControlBar.Active = true
ControlBar.ZIndex = 100
ControlBar.Parent = Window.Root

local function removeOldWindowButtons()
    task.spawn(function()
        task.wait(0.1)

        local root = Window.Root
        if not root then
            return
        end

        local function shouldRemove(obj)
            if not obj:IsA("GuiObject") then
                return false
            end

            if obj == ControlBar or obj:IsDescendantOf(ControlBar) then
                return false
            end

            local n = obj.Name
            if n == "Close" or n == "Minimize" or n == "Maximize" or n == "Exit" then
                return true
            end

            local p = obj.AbsolutePosition
            local rootPos = root.AbsolutePosition
            local rootSize = root.AbsoluteSize

            local inTopRight =
                p.Y >= rootPos.Y and p.Y < rootPos.Y + 50 and
                p.X > rootPos.X + rootSize.X - 140

            return inTopRight
        end

        for _, obj in ipairs(root:GetDescendants()) do
            if shouldRemove(obj) then
                obj:Destroy()
            end
        end
    end)
end

removeOldWindowButtons()

Window.Root.DescendantAdded:Connect(function(obj)
    task.defer(function()
        local root = Window.Root
        if not root then
            return
        end

        if not obj:IsA("GuiObject") or obj == ControlBar or obj:IsDescendantOf(ControlBar) then
            return
        end

        local n = obj.Name
        if n == "Close" or n == "Minimize" or n == "Maximize" or n == "Exit" then
            obj:Destroy()
            return
        end

        local p = obj.AbsolutePosition
        local rootPos = root.AbsolutePosition
        local rootSize = root.AbsoluteSize

        local inTopRight =
            p.Y >= rootPos.Y and p.Y < rootPos.Y + 50 and
            p.X > rootPos.X + rootSize.X - 140

        if inTopRight then
            obj:Destroy()
        end
    end)
end)

local DOT_COUNT = 3

local function createDot(color, index, callback)
    local Dot = Instance.new("TextButton")
    Dot.Name = "Dot" .. index
    Dot.Size = UDim2.fromOffset(16, 16)
    Dot.AnchorPoint = Vector2.new(1, 0.5)
    Dot.Position = UDim2.new(1, -((DOT_COUNT - index) * 20 + 4), 0.5, 0)
    Dot.BackgroundColor3 = color
    Dot.BorderSizePixel = 0
    Dot.AutoButtonColor = true
    Dot.Text = ""
    Dot.ZIndex = 101
    Dot.Parent = ControlBar

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Dot

    Dot.MouseButton1Click:Connect(callback)

    return Dot
end
local DragBar = Instance.new("Frame")
DragBar.Name = "DragBar"
DragBar.AnchorPoint = Vector2.new(0.5, 0)
DragBar.Size = UDim2.new(0.5, 0, 0, 10)
DragBar.Position = UDim2.new(0.5, 0, 1, 6)
DragBar.BackgroundTransparency = 1
DragBar.BorderSizePixel = 0
DragBar.ZIndex = 100
DragBar.Parent = Window.Root

local DragBarLine = Instance.new("Frame")
DragBarLine.Name = "DragBarLine"
DragBarLine.AnchorPoint = Vector2.new(0.5, 0.5)
DragBarLine.Position = UDim2.new(0.5, 0, 0.5, 0)
DragBarLine.Size = UDim2.new(1, -8, 0, 4)
DragBarLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DragBarLine.BorderSizePixel = 0
DragBarLine.ZIndex = 101
DragBarLine.Parent = DragBar

local DragBarCorner = Instance.new("UICorner")
DragBarCorner.CornerRadius = UDim.new(1, 0)
DragBarCorner.Parent = DragBarLine

local PlayerInfo = Instance.new("Frame")
PlayerInfo.Name = "PlayerInfo"
PlayerInfo.AnchorPoint = Vector2.new(0, 1)
PlayerInfo.Position = UDim2.new(0, 12, 1, -12)
PlayerInfo.Size = UDim2.new(0, TAB_WIDTH - 24, 0, 52)
PlayerInfo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PlayerInfo.BackgroundTransparency = 1
PlayerInfo.BorderSizePixel = 0
PlayerInfo.ZIndex = 100
PlayerInfo.Parent = Window.Root

local PlayerInfoCorner = Instance.new("UICorner")
PlayerInfoCorner.CornerRadius = UDim.new(0, 8)
PlayerInfoCorner.Parent = PlayerInfo

local Avatar = Instance.new("ImageLabel")
Avatar.Name = "Avatar"
Avatar.AnchorPoint = Vector2.new(0, 0.5)
Avatar.Position = UDim2.new(0, 8, 0.5, 0)
Avatar.Size = UDim2.fromOffset(36, 36)
Avatar.BackgroundTransparency = 1
Avatar.BorderSizePixel = 0
Avatar.ZIndex = 101
Avatar.Parent = PlayerInfo

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = Avatar

local username = "Player"
local displayName = "Player"

if LocalPlayer then
    username = LocalPlayer.Name
    displayName = LocalPlayer.DisplayName or LocalPlayer.Name

    local success, result = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)

    if success then
        Avatar.Image = result
    end
end

local NameLabel = Instance.new("TextLabel")
NameLabel.Name = "NameLabel"
NameLabel.BackgroundTransparency = 1
NameLabel.BorderSizePixel = 0
NameLabel.AnchorPoint = Vector2.new(0, 0)
NameLabel.Position = UDim2.new(0, 56, 0, 6)
NameLabel.Size = UDim2.new(1, -64, 0, 20)
NameLabel.Font = Enum.Font.Gotham
NameLabel.Text = username
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.TextYAlignment = Enum.TextYAlignment.Top
NameLabel.TextScaled = false
NameLabel.TextSize = 14
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.ZIndex = 101
NameLabel.Parent = PlayerInfo

local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Name = "DisplayNameLabel"
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.BorderSizePixel = 0
DisplayNameLabel.AnchorPoint = Vector2.new(0, 0)
DisplayNameLabel.Position = UDim2.new(0, 56, 0, 26)
DisplayNameLabel.Size = UDim2.new(1, -64, 0, 18)
DisplayNameLabel.Font = Enum.Font.Gotham
DisplayNameLabel.Text = displayName
DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
DisplayNameLabel.TextYAlignment = Enum.TextYAlignment.Top
DisplayNameLabel.TextScaled = false
DisplayNameLabel.TextSize = 13
DisplayNameLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
DisplayNameLabel.ZIndex = 101
DisplayNameLabel.Parent = PlayerInfo

local dragActive = false
local dragStart
local startPos
local lastStablePos = Window.Root.Position
local updatingPosition = false

local ResizeHandle = Instance.new("Frame")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.AnchorPoint = Vector2.new(1, 1)
ResizeHandle.Size = UDim2.fromOffset(28, 28)
ResizeHandle.Position = UDim2.new(1, 0, 1, 0)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 100
ResizeHandle.Parent = Window.Root

local ResizeBottom = Instance.new("Frame")
ResizeBottom.Name = "ResizeBottom"
ResizeBottom.AnchorPoint = Vector2.new(1, 0.5)
ResizeBottom.Position = UDim2.new(1, 8, 1, 6)
ResizeBottom.Size = UDim2.new(0, 24, 0, 4)
ResizeBottom.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ResizeBottom.BorderSizePixel = 0
ResizeBottom.ZIndex = 101
ResizeBottom.Parent = ResizeHandle

local ResizeBottomCorner = Instance.new("UICorner")
ResizeBottomCorner.CornerRadius = UDim.new(1, 0)
ResizeBottomCorner.Parent = ResizeBottom

local ResizeSide = Instance.new("Frame")
ResizeSide.Name = "ResizeSide"
ResizeSide.AnchorPoint = Vector2.new(0.5, 1)
ResizeSide.Position = UDim2.new(1, 6, 1, 8)
ResizeSide.Size = UDim2.new(0, 4, 0, 24)
ResizeSide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ResizeSide.BorderSizePixel = 0
ResizeSide.ZIndex = 101
ResizeSide.Parent = ResizeHandle

local ResizeSideCorner = Instance.new("UICorner")
ResizeSideCorner.CornerRadius = UDim.new(1, 0)
ResizeSideCorner.Parent = ResizeSide

local resizeActive = false
local resizeStart
local startSize

local function beginDrag(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    dragActive = true
    dragStart = input.Position
    startPos = Window.Root.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragActive = false
        end
    end)
end

DragBar.InputBegan:Connect(beginDrag)

local function beginResize(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    resizeActive = true
    resizeStart = input.Position
    startSize = Window.Root.Size

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            resizeActive = false
        end
    end)
end

ResizeHandle.InputBegan:Connect(beginResize)
ResizeBottom.InputBegan:Connect(beginResize)
ResizeSide.InputBegan:Connect(beginResize)

UserInputService.InputChanged:Connect(function(input)
    if not dragActive and not resizeActive then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    if dragActive then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        updatingPosition = true
        Window.Root.Position = newPos
        updatingPosition = false
    elseif resizeActive then
        local delta = input.Position - resizeStart
        local minWidth = 380
        local minHeight = 260

        local newWidth = startSize.X.Offset + delta.X
        local newHeight = startSize.Y.Offset + delta.Y

        if newWidth < minWidth then
            newWidth = minWidth
        end

        if newHeight < minHeight then
            newHeight = minHeight
        end

        Window.Root.Size = UDim2.new(
            startSize.X.Scale,
            newWidth,
            startSize.Y.Scale,
            newHeight
        )
    end
end)

Window.Root:GetPropertyChangedSignal("Position"):Connect(function()
    if updatingPosition then
        lastStablePos = Window.Root.Position
        return
    end

    if dragActive then
        lastStablePos = Window.Root.Position
    else
        updatingPosition = true
        Window.Root.Position = lastStablePos
        updatingPosition = false
    end
end)

local originalSize = Window.Root.Size
local expandedSize = UDim2.new(
    originalSize.X.Scale,
    originalSize.X.Offset + 220,
    originalSize.Y.Scale,
    originalSize.Y.Offset + 140
)
local isExpanded = false

createDot(Color3.fromRGB(255, 95, 86), 1, function()
    if Fluent.Window then
        Fluent.Unloaded = true
        if Fluent.UseAcrylic and Fluent.Window.AcrylicPaint and Fluent.Window.AcrylicPaint.Model then
            Fluent.Window.AcrylicPaint.Model:Destroy()
        end
        if Fluent.GUI then
            Fluent.GUI:Destroy()
        end
    end
end)

createDot(Color3.fromRGB(255, 189, 46), 2, function()
    if Window.Minimize then
        Window:Minimize()
    else
        Window.Minimized = not Window.Minimized
        Window.Root.Visible = not Window.Minimized
    end
end)

createDot(Color3.fromRGB(39, 201, 63), 3, function()
    if isExpanded then
        Window.Root.Size = originalSize
    else
        Window.Root.Size = expandedSize
    end
    isExpanded = not isExpanded
end)

local Tabs = {
    Welcome = Window:AddTab({ Title = "Welcome", Icon = "home" }),
    BlackJob = Window:AddTab({ Title = "Black Job", Icon = "briefcase" }),
    PoliceJob = Window:AddTab({ Title = "Police Job", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    local Welcome = Tabs.Welcome

    Welcome:AddParagraph({
        Title = "ยินดีต้อนรับ | WELCOME",
        Content = "บริการสคริปต์ Premium คุณภาพสูง"
    })

    Welcome:AddButton({
        Title = "เข้าร่วมเซิฟเวอรืดิสคอร์ด | Join Discord",
        Description = "คลิกเพื่อคัดลอกลิงก์ดิสคอร์ด",
        Callback = function()
            setclipboard("https://discord.gg/bcpNCvMryT")
            Fluent:Notify({
                Title = "Discord",
                Content = "คัดลอกลิงก์ดิสคอร์ดลงในคลิปบอร์ดแล้ว!",
                Duration = 5
            })
        end
    })
end

do
    local BlackJob = Tabs.BlackJob

    local JobDropdown = BlackJob:AddDropdown("BlackJobJob", {
        Title = "เลือกงาน Black Job",
        Values = {"จกปูน", "จกสายไฟ", "ปล้นเพชร"},
        Multi = false,
        Default = 1
    })

    local StartToggle = BlackJob:AddToggle("BlackJobStart", {
        Title = "เริ่มต้นทำงาน",
        Default = false
    })
end

do
    local PoliceJob = Tabs.PoliceJob

    PoliceJob:AddSection("Location Player")

    local WantedESP = PoliceJob:AddToggle("WantedESP", {
        Title = "แสดงตำแหน่งผู้เล่นที่ติดคดี",
        Default = false
    })

    local PoliceESP = PoliceJob:AddToggle("PoliceESP", {
        Title = "แสดงตำแหน่งตำรวจ",
        Default = false
    })

    local espFolder = Instance.new("Folder")
    espFolder.Name = "WantedESP_Folder"
    espFolder.Parent = workspace

    local function createESP(player, type)
        local char = player.Character
        if not char then return end

        local espName = type == "Wanted" and "WantedHighlight" or "PoliceHighlight"
        local billboardName = type == "Wanted" and "WantedBillboard" or "PoliceBillboard"
        local labelName = type == "Wanted" and "WantedLabel" or "PoliceLabel"
        local color = type == "Wanted" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 170, 255)
        local tagText = type == "Wanted" and "[WANTED]" or "[POLICE]"

        local highlight = char:FindFirstChild(espName) or Instance.new("Highlight")
        highlight.Name = espName
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = char

        local head = char:FindFirstChild("Head")
        if head then
            local billboard = head:FindFirstChild(billboardName) or Instance.new("BillboardGui")
            billboard.Name = billboardName
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.AlwaysOnTop = true
            billboard.ExtentsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = head

            local label = billboard:FindFirstChild(labelName) or Instance.new("TextLabel")
            label.Name = labelName
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = color
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.Parent = billboard

            local function updateInfo()
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    label.Text = string.format("%s\n%s\n%d M", player.DisplayName, tagText, math.floor(dist))
                else
                    label.Text = player.DisplayName .. "\n" .. tagText
                end
            end
            
            updateInfo()
        end
    end

    local function removeESP(player, type)
        local char = player.Character
        if char then
            local espName = type == "Wanted" and "WantedHighlight" or "PoliceHighlight"
            local billboardName = type == "Wanted" and "WantedBillboard" or "PoliceBillboard"
            
            local highlight = char:FindFirstChild(espName)
            if highlight then highlight:Destroy() end
            
            local head = char:FindFirstChild("Head")
            if head then
                local billboard = head:FindFirstChild(billboardName)
                if billboard then billboard:Destroy() end
            end
        end
    end

    task.spawn(function()
        print("ESP Loop Started")
        while task.wait(0.5) do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    -- Wanted ESP Logic
                    if WantedESP.Value then
                        local isWanted = false
                        pcall(function()
                            local targetPlayerGui = player:FindFirstChild("PlayerGui")
                            local targetMenu = targetPlayerGui and targetPlayerGui:FindFirstChild("Menu")
                            local targetWantedFrame = targetMenu and targetMenu:FindFirstChild("WANTED_Frame")
                            if targetWantedFrame and targetWantedFrame.Visible then
                                isWanted = true
                            end
                        end)
                        
                        if not isWanted then
                            pcall(function()
                                local myWantedFrame = LocalPlayer.PlayerGui.Menu:FindFirstChild("WANTED_Frame")
                                if myWantedFrame then
                                    local playerItem = myWantedFrame:FindFirstChild(player.Name) or myWantedFrame:FindFirstChild(player.DisplayName)
                                    if playerItem and playerItem.Visible then
                                        isWanted = true
                                    end
                                    if not isWanted then
                                        for _, child in ipairs(myWantedFrame:GetDescendants()) do
                                            if child:IsA("TextLabel") and child.Visible and (child.Text:find(player.Name) or child.Text:find(player.DisplayName)) then
                                                isWanted = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end)
                        end

                        if isWanted then
                            createESP(player, "Wanted")
                            pcall(function()
                                local label = player.Character.Head.WantedBillboard.WantedLabel
                                local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                label.Text = string.format("%s\n[WANTED]\n%d M", player.DisplayName, math.floor(dist))
                            end)
                        else
                            removeESP(player, "Wanted")
                        end
                    else
                        removeESP(player, "Wanted")
                    end

                    -- Police ESP Logic
                    if PoliceESP.Value then
                        local isPolice = false
                        pcall(function()
                            local playerGui = player:FindFirstChild("PlayerGui")
                            local statFrame = playerGui and playerGui:FindFirstChild("Menu") and playerGui.Menu:FindFirstChild("StatFrame")
                            local jobText = statFrame and statFrame:FindFirstChild("JobText")
                            
                            if jobText and (jobText.Text:find("Police") or jobText.Text:find("ตำรวจ")) then
                                isPolice = true
                            end
                        end)

                        if isPolice then
                            createESP(player, "Police")
                            pcall(function()
                                local label = player.Character.Head.PoliceBillboard.PoliceLabel
                                local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                label.Text = string.format("%s\n[POLICE]\n%d M", player.DisplayName, math.floor(dist))
                            end)
                        else
                            removeESP(player, "Police")
                        end
                    else
                        removeESP(player, "Police")
                    end
                end
            end
        end
    end)
end

do
    Fluent:Notify({
        Title = "Notification",
        Content = "This is a notification",
        SubContent = "SubContent",
        Duration = 5
    })
end

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
    Title = "JOPAGEN Premium Script.",
    Content = "โหลดสคริปต์สำเร็จ | The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
