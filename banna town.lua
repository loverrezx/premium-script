--!nocheck
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local GlobalEnv = (getgenv and getgenv()) or _G
if GlobalEnv.LoverrWindow and GlobalEnv.LoverrWindow.Root then
    GlobalEnv.LoverrWindow.Root:Destroy()
end

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
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

    local cementSpawnCFrame = CFrame.new(363.979919, 1.92225266, 212.50528, 0, 0, 1, 0, 1, 0, -1, 0, 0)
    local cementEscapeCFrame = CFrame.new(123.261833, 47.95289898, 1687.30115, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    local escapeMaxHeight = cementEscapeCFrame.Position.Y + 10000
    local diamondTargetCFrames = {
        CFrame.new(-174.351608, 8.92668629, 1025.00928, -1, 0, 0, 0, 1, 0, 0, 0, -1),
        CFrame.new(-184.099991, 8.02774906, 1005.47998, -1, 0, 0, 0, 1, 0, 0, 0, -1),
        CFrame.new(-162.550003, 8.02774906, 1024.95996, -1, 0, 0, 0, 1, 0, 0, 0, -1),
        CFrame.new(-189.149994, 8.92668629, 1025.01001, -1, 0, 0, 0, 1, 0, 0, 0, -1),
        CFrame.new(-200.419998, 8.02774906, 1024.84998, -1, 0, 0, 0, 1, 0, 0, 0, -1)
    }
    local cementVehicleName = "Rord F100"
    local cementRandom = Random.new()
    local wireRandom = Random.new()
    local diamondRandom = Random.new()
    local blackJobSession = 0
    local requiresInitialCementSpawn = true
    local cementVehicleSpawned = false
    local activeCementCar
    local requiresInitialWireSpawn = true
    local wireVehicleSpawned = false
    local activeWireCar
    local requiresInitialDiamondSpawn = true
    local diamondVehicleSpawned = false
    local activeDiamondCar
    local lastShownPrompt
    local isCementTargetVisible = function(_)
        return true
    end
    local flyCarUp = function()
        return false
    end

    local function getCharacter()
        return LocalPlayer.Character
    end

    local function getHumanoid()
        local char = getCharacter()
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function getHRP()
        local char = getCharacter()
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function isDisplayed(instance)
        if not instance then
            return false
        end

        local ok, value = pcall(function()
            return instance.Visible
        end)
        if ok and type(value) == "boolean" then
            return value
        end

        ok, value = pcall(function()
            return instance.Enabled
        end)
        if ok and type(value) == "boolean" then
            return value
        end

        return true
    end

    local function isCementJobSelected()
        return Options.BlackJobJob and Options.BlackJobJob.Value == "จกปูน"
    end

    local function isCementJobEnabled()
        return Options.BlackJobStart and Options.BlackJobStart.Value and isCementJobSelected()
    end

    local function isWireJobSelected()
        return Options.BlackJobJob and Options.BlackJobJob.Value == "จกสายไฟ"
    end

    local function isWireJobEnabled()
        return Options.BlackJobStart and Options.BlackJobStart.Value and isWireJobSelected()
    end

    local function isDiamondJobSelected()
        return Options.BlackJobJob and Options.BlackJobJob.Value == "ปล้นเพชร"
    end

    local function isDiamondJobEnabled()
        return Options.BlackJobStart and Options.BlackJobStart.Value and isDiamondJobSelected()
    end

    local function holdKey(keyCode, holdSeconds)
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(holdSeconds or 0.2)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end

    local function getInstanceCFrame(instance)
        if not instance then
            return nil
        end

        if instance:IsA("Model") then
            return instance:GetPivot()
        end

        if instance:IsA("BasePart") then
            return instance.CFrame
        end

        for _, descendant in ipairs(instance:GetDescendants()) do
            if descendant:IsA("BasePart") then
                return descendant.CFrame
            end
        end

        return nil
    end

    local function getInstancePosition(instance)
        local cframe = getInstanceCFrame(instance)
        return cframe and cframe.Position or nil
    end

    local function moveCharacterTo(position, stopDistance, timeoutSeconds, session)
        local startTime = tick()

        while tick() - startTime < (timeoutSeconds or 10) do
            if session ~= blackJobSession or not isCementJobEnabled() then
                return false
            end

            local humanoid = getHumanoid()
            local hrp = getHRP()
            if not humanoid or not hrp then
                return false
            end

            if (hrp.Position - position).Magnitude <= (stopDistance or 5) then
                return true
            end

            humanoid:MoveTo(position)
            task.wait(0.2)
        end

        local hrp = getHRP()
        return hrp and (hrp.Position - position).Magnitude <= (stopDistance or 5) or false
    end

    local function teleportCharacter(cframe)
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = cframe
            return true
        end
        return false
    end

    local function getCementFolder()
        local greyJobs = workspace:FindFirstChild("Grey_Jobs")
        return greyJobs and greyJobs:FindFirstChild("CementsFolder") or nil
    end

    local function getCementTargets()
        local folder = getCementFolder()
        local targets = {}

        if not folder then
            return targets
        end

        local children = folder:GetChildren()

        local function pushTarget(target)
            if target and isCementTargetVisible(target) and not table.find(targets, target) then
                table.insert(targets, target)
            end
        end

        pushTarget(children[6])
        pushTarget(children[3])
        pushTarget(folder:FindFirstChild("Cement"))
        pushTarget(children[4])
        pushTarget(children[5])

        if #targets == 0 then
            for _, child in ipairs(children) do
                pushTarget(child)
            end
        end

        return targets
    end

    local function getOwnedCar()
        local carFolder = workspace:FindFirstChild("CarFolder")
        if not carFolder then
            return nil
        end

        local exactName = ("%s's Car"):format(LocalPlayer.Name)
        local exactCar = carFolder:FindFirstChild(exactName)
        if exactCar and exactCar:IsA("Model") then
            return exactCar
        end

        for _, car in ipairs(carFolder:GetChildren()) do
            if car:IsA("Model") and car.Name:find(LocalPlayer.Name, 1, true) and car.Name:find("'s Car", 1, true) then
                return car
            end
        end

        return nil
    end

    local function getDriverSeat(car)
        if not car then
            return nil
        end

        local seat = car:FindFirstChild("DriverSeat", true)
        if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
            return seat
        end

        for _, descendant in ipairs(car:GetDescendants()) do
            if descendant:IsA("VehicleSeat") or descendant:IsA("Seat") then
                return descendant
            end
        end

        return nil
    end

    local function getCarRootPart(car)
        if not car then
            return nil
        end

        if car.PrimaryPart and car.PrimaryPart:IsA("BasePart") then
            return car.PrimaryPart
        end

        local driverSeat = getDriverSeat(car)
        if driverSeat and driverSeat:IsA("BasePart") then
            return driverSeat
        end

        for _, descendant in ipairs(car:GetDescendants()) do
            if descendant:IsA("BasePart") then
                return descendant
            end
        end

        return nil
    end

    local function stopCarMotion(car)
        local rootPart = getCarRootPart(car)
        if rootPart then
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end

    local function spawnCementVehicle(session)
        local events = ReplicatedStorage:FindFirstChild("Events")
        local vehicleEvent = events and events:FindFirstChild("VehicleEvent")
        if not vehicleEvent then
            activeCementCar = getOwnedCar()
            return activeCementCar
        end

        vehicleEvent:FireServer("Spawn", cementVehicleName)

        local deadline = tick() + 8
        while tick() < deadline do
            if session ~= blackJobSession or not isCementJobEnabled() then
                return nil
            end

            local car = getOwnedCar()
            if car then
                activeCementCar = car
                cementVehicleSpawned = true
                return car
            end

            task.wait(0.2)
        end

        activeCementCar = getOwnedCar()
        cementVehicleSpawned = activeCementCar ~= nil
        return activeCementCar
    end

    local function getCurrentCementCar()
        if activeCementCar and activeCementCar.Parent then
            return activeCementCar
        end

        activeCementCar = nil
        return nil
    end

    local function ensureInitialCementVehicle(session)
        if requiresInitialCementSpawn then
            requiresInitialCementSpawn = false
            cementVehicleSpawned = false
            activeCementCar = nil
            teleportCharacter(cementSpawnCFrame)
            task.wait(0.35)
            return spawnCementVehicle(session)
        end

        local currentCar = getCurrentCementCar()
        if currentCar then
            return currentCar
        end

        if cementVehicleSpawned then
            return nil
        end

        return nil
    end

    local function enterDriverSeat(car, session, walkToSeat)
        local seat = getDriverSeat(car)
        local humanoid = getHumanoid()
        local hrp = getHRP()
        if not seat or not humanoid or not hrp then
            return false
        end

        if seat.Occupant and seat.Occupant ~= humanoid then
            return false
        end

        if seat.Occupant == humanoid or humanoid.SeatPart == seat then
            return true
        end

        local seatPosition = seat.Position
        local shouldWalkToSeat = walkToSeat == true

        local function quickSit()
            hrp.CFrame = seat.CFrame + seat.CFrame.UpVector * 2
            task.wait(0.15)
            pcall(function()
                seat:Sit(humanoid)
            end)
            task.wait(0.35)
            return seat.Occupant == humanoid or humanoid.SeatPart == seat
        end

        if not shouldWalkToSeat then
            if quickSit() then
                return true
            end
            shouldWalkToSeat = true
        end

        local approachPosition = seatPosition + Vector3.new(0, 2, 0)

        if not moveCharacterTo(seatPosition, 8, 6, session) then
            return false
        end

        hrp = getHRP()
        if not hrp then
            return false
        end

        hrp.CFrame = CFrame.new(approachPosition, seatPosition + seat.CFrame.LookVector * 6)
        task.wait(0.2)
        holdKey(Enum.KeyCode.E, 0.4)
        pcall(function()
            seat:Sit(humanoid)
        end)
        task.wait(0.8)

        if seat.Occupant == humanoid or humanoid.SeatPart == seat then
            return true
        end

        return quickSit()
    end

    local function leaveVehicle()
        local humanoid = getHumanoid()
        if not humanoid then
            return false
        end

        humanoid.Sit = false
        humanoid.Jump = true
        task.wait(0.3)
        return humanoid.SeatPart == nil
    end

    local function getNameTagFlagVisible(flagName)
        local char = getCharacter()
        local head = char and char:FindFirstChild("Head")
        local nameTag = head and head:FindFirstChild("NameTag")
        local flag = nameTag and nameTag:FindFirstChild(flagName)
        return isDisplayed(flag)
    end

    local function getWantedVisible()
        return getNameTagFlagVisible("WANTED")
    end

    local function getProtectWantedVisible()
        return getNameTagFlagVisible("PROTECT WANTED")
    end

    local function hasActiveWantedStatus()
        return getWantedVisible() or getProtectWantedVisible()
    end

    isCementTargetVisible = function(target)
        if not target or not target.Parent then
            return false
        end

        if target:IsA("BasePart") then
            return target.Transparency < 0.99
        end

        local ok, visibleValue = pcall(function()
            return target.Visible
        end)
        if ok and type(visibleValue) == "boolean" then
            return visibleValue
        end

        ok, visibleValue = pcall(function()
            return target.Enabled
        end)
        if ok and type(visibleValue) == "boolean" then
            return visibleValue
        end

        local foundVisiblePart = false
        for _, descendant in ipairs(target:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Transparency < 0.99 then
                foundVisiblePart = true
                break
            end

            if (descendant:IsA("GuiObject") or descendant:IsA("ProximityPrompt")) and isDisplayed(descendant) then
                foundVisiblePart = true
                break
            end
        end

        return foundVisiblePart
    end

    local function findCementPrompt(target)
        if lastShownPrompt and lastShownPrompt.Parent and isDisplayed(lastShownPrompt) then
            local keyboardKey = Enum.KeyCode.Unknown
            pcall(function()
                keyboardKey = lastShownPrompt.KeyboardKeyCode
            end)

            if keyboardKey == Enum.KeyCode.F or keyboardKey == Enum.KeyCode.Unknown then
                return lastShownPrompt
            end
        end

        local folder = getCementFolder() or target
        local targetPosition = getInstancePosition(target)
        if not folder or not targetPosition then
            return nil
        end

        for _, descendant in ipairs(folder:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local promptPosition = getInstancePosition(descendant.Parent)
                if promptPosition and (promptPosition - targetPosition).Magnitude <= 20 and isDisplayed(descendant) then
                    local keyboardKey = Enum.KeyCode.Unknown
                    local ok = pcall(function()
                        keyboardKey = descendant.KeyboardKeyCode
                    end)

                    if ok and (keyboardKey == Enum.KeyCode.F or keyboardKey == Enum.KeyCode.Unknown) then
                        return descendant
                    end
                end
            end
        end

        return nil
    end

    local function escapeWithCar(car, session)
        if not hasActiveWantedStatus() then
            return false
        end

        local escapeCar = car or getOwnedCar()
        if not escapeCar then
            return false
        end

        if not enterDriverSeat(escapeCar, session, true) then
            return false
        end

        flyCarUp(escapeCar, session)

        return true
    end

    local function triggerPrompt(prompt, session)
        if not prompt then
            return false
        end

        local holdDuration = 2
        pcall(function()
            holdDuration = math.max(prompt.HoldDuration + 0.5, 2)
        end)

        pcall(function()
            prompt:InputHoldBegin()
        end)

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)

        local releaseAt = tick() + holdDuration
        while tick() < releaseAt do
            if session ~= blackJobSession or not isCementJobEnabled() then
                break
            end

            if hasActiveWantedStatus() then
                break
            end

            if not prompt.Parent or not isDisplayed(prompt) then
                break
            end

            task.wait(0.1)
        end

        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)

        pcall(function()
            prompt:InputHoldEnd()
        end)

        return true
    end

    local function getSafeCementApproachCFrame(target)
        local targetPosition = getInstancePosition(target)
        if not targetPosition then
            return nil
        end

        local hrp = getHRP()
        local horizontalDirection = hrp and (hrp.Position - targetPosition) or Vector3.new(1, 0, 0)
        horizontalDirection = Vector3.new(horizontalDirection.X, 0, horizontalDirection.Z)

        if horizontalDirection.Magnitude <= 0.01 then
            horizontalDirection = Vector3.new(1, 0, 0)
        else
            horizontalDirection = horizontalDirection.Unit
        end

        local safePosition = targetPosition + horizontalDirection * 6 + Vector3.new(0, 4.5, 0)
        return CFrame.new(safePosition, targetPosition)
    end

    local function getSafeCarApproachCFrame(target, car)
        local targetPosition = getInstancePosition(target)
        if not targetPosition then
            return nil, nil
        end

        local carPivot = car and car:GetPivot() or nil
        local horizontalDirection = carPivot and (carPivot.Position - targetPosition) or Vector3.new(1, 0, 0)
        horizontalDirection = Vector3.new(horizontalDirection.X, 0, horizontalDirection.Z)

        if horizontalDirection.Magnitude <= 0.01 then
            local hrp = getHRP()
            horizontalDirection = hrp and (hrp.Position - targetPosition) or Vector3.new(1, 0, 0)
            horizontalDirection = Vector3.new(horizontalDirection.X, 0, horizontalDirection.Z)
        end

        if horizontalDirection.Magnitude <= 0.01 then
            horizontalDirection = Vector3.new(1, 0, 0)
        else
            horizontalDirection = horizontalDirection.Unit
        end

        local highPosition = targetPosition + horizontalDirection * 16 + Vector3.new(0, 40, 0)
        local settlePosition = targetPosition + horizontalDirection * 16 + Vector3.new(0, 25, 0)
        return CFrame.new(highPosition, targetPosition), CFrame.new(settlePosition, targetPosition)
    end

    local function moveCarToCementTarget(car, target, session)
        if not car then
            return false
        end

        local highCFrame, settleCFrame = getSafeCarApproachCFrame(target, car)
        if not highCFrame or not settleCFrame then
            return false
        end

        car:PivotTo(highCFrame)
        task.wait(0.2)

        if session ~= blackJobSession or not isCementJobEnabled() then
            return false
        end

        car:PivotTo(settleCFrame)
        task.wait(0.35)
        return true
    end

    local function attemptStealCement(target, session)
        local targetPosition = getInstancePosition(target)
        if not targetPosition then
            return false
        end

        if not isCementTargetVisible(target) then
            task.wait(2)
            return false
        end

        local safeApproachCFrame = getSafeCementApproachCFrame(target)
        if safeApproachCFrame then
            teleportCharacter(safeApproachCFrame)
        end
        task.wait(0.3)

        local deadline = tick() + 20
        while tick() < deadline do
            if session ~= blackJobSession or not isCementJobEnabled() then
                return false
            end

            if hasActiveWantedStatus() then
                return true
            end

            if not isCementTargetVisible(target) then
                task.wait(2)
                return false
            end

            local prompt = findCementPrompt(target)
            if prompt then
                local promptPosition = getInstancePosition(prompt.Parent) or targetPosition
                moveCharacterTo(promptPosition, 6, 3, session)
                triggerPrompt(prompt, session)
                task.wait(0.2)
            else
                local hrp = getHRP()
                local awayDirection = hrp and hrp.CFrame.RightVector or Vector3.new(1, 0, 0)
                awayDirection = Vector3.new(awayDirection.X, 0, awayDirection.Z)
                if awayDirection.Magnitude <= 0.01 then
                    awayDirection = Vector3.new(1, 0, 0)
                else
                    awayDirection = awayDirection.Unit
                end

                local awayPosition = targetPosition + awayDirection * 12
                moveCharacterTo(awayPosition, 4, 3.2, session)
                task.wait(3)
                moveCharacterTo(targetPosition, 6, 4, session)
                local retryPrompt = findCementPrompt(target)
                if retryPrompt then
                    triggerPrompt(retryPrompt, session)
                    task.wait(0.2)
                end
            end
        end

        return getProtectWantedVisible()
    end

    flyCarUp = function(car, session)
        if not enterDriverSeat(car, session) then
            return false
        end

        car:PivotTo(cementEscapeCFrame)
        task.wait(0.15)

        local escapeStartedAt = tick()
        local lastTick = tick()
        local currentPosition = cementEscapeCFrame.Position
        while true do
            if not car.Parent then
                stopCarMotion(car)
                return false
            end

            if session ~= blackJobSession or not isCementJobEnabled() then
                stopCarMotion(car)
                return false
            end

            if tick() - escapeStartedAt > 3 and not hasActiveWantedStatus() then
                stopCarMotion(car)
                return true
            end

            local now = tick()
            local delta = now - lastTick
            lastTick = now

            currentPosition = currentPosition + Vector3.new(0, 120 * delta, 0)
            if currentPosition.Y >= escapeMaxHeight then
                currentPosition = Vector3.new(currentPosition.X, escapeMaxHeight, currentPosition.Z)
                local holdCFrame = CFrame.new(
                    currentPosition.X,
                    currentPosition.Y,
                    currentPosition.Z,
                    0, 0, -1,
                    0, 1, 0,
                    1, 0, 0
                )
                car:PivotTo(holdCFrame)
                while true do
                    if not car.Parent then
                        stopCarMotion(car)
                        return false
                    end

                    if session ~= blackJobSession or not isCementJobEnabled() then
                        stopCarMotion(car)
                        return false
                    end

                    stopCarMotion(car)
                    car:PivotTo(holdCFrame)

                    if not hasActiveWantedStatus() then
                        return true
                    end

                    task.wait(0.2)
                end
            end

            local nextCFrame = CFrame.new(
                currentPosition.X,
                currentPosition.Y,
                currentPosition.Z,
                0, 0, -1,
                0, 1, 0,
                1, 0, 0
            )

            car:PivotTo(nextCFrame)

            local rootPart = getCarRootPart(car)
            if rootPart then
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 120, 0)
                rootPart.AssemblyAngularVelocity = Vector3.zero
            end

            task.wait()
        end

        return true
    end

    local function runCementCycle(session)
        local targets = getCementTargets()
        if #targets == 0 then
            task.wait(2)
            return
        end

        local car = ensureInitialCementVehicle(session)
        if not car then
            task.wait(1)
            return
        end

        if escapeWithCar(car, session) then
            return
        end

        if not enterDriverSeat(car, session, false) then
            task.wait(0.5)
            return
        end

        if escapeWithCar(car, session) then
            return
        end

        local target = targets[cementRandom:NextInteger(1, #targets)]
        local targetCFrame = getInstanceCFrame(target)
        if not targetCFrame or not isCementTargetVisible(target) then
            task.wait(2)
            return
        end

        if not moveCarToCementTarget(car, target, session) then
            task.wait(0.5)
            return
        end

        if escapeWithCar(car, session) then
            return
        end

        leaveVehicle()

        if escapeWithCar(car, session) then
            return
        end

        if attemptStealCement(target, session) and hasActiveWantedStatus() then
            escapeWithCar(car, session)
        end
    end

    local function getWireFolder()
        local greyJobs = workspace:FindFirstChild("Grey_Jobs")
        return greyJobs and greyJobs:FindFirstChild("Wires") or nil
    end

    local function getWireTargets()
        local folder = getWireFolder()
        local targets = {}

        if not folder then
            return targets
        end

        local children = folder:GetChildren()

        local function pushTarget(target)
            if target and isCementTargetVisible(target) and not table.find(targets, target) then
                table.insert(targets, target)
            end
        end

        pushTarget(children[9])
        pushTarget(children[3])
        pushTarget(children[4])
        pushTarget(children[8])
        pushTarget(children[6])
        pushTarget(children[7])
        pushTarget(folder:FindFirstChild("MeshWire"))
        pushTarget(children[5])

        if #targets == 0 then
            for _, child in ipairs(children) do
                pushTarget(child)
            end
        end

        return targets
    end

    local function moveCharacterToWire(position, stopDistance, timeoutSeconds, session)
        local startTime = tick()

        while tick() - startTime < (timeoutSeconds or 10) do
            if session ~= blackJobSession or not isWireJobEnabled() then
                return false
            end

            local humanoid = getHumanoid()
            local hrp = getHRP()
            if not humanoid or not hrp then
                return false
            end

            if (hrp.Position - position).Magnitude <= (stopDistance or 5) then
                return true
            end

            humanoid:MoveTo(position)
            task.wait(0.2)
        end

        local hrp = getHRP()
        return hrp and (hrp.Position - position).Magnitude <= (stopDistance or 5) or false
    end

    local function spawnWireVehicle(session)
        local events = ReplicatedStorage:FindFirstChild("Events")
        local vehicleEvent = events and events:FindFirstChild("VehicleEvent")
        if not vehicleEvent then
            activeWireCar = getOwnedCar()
            return activeWireCar
        end

        vehicleEvent:FireServer("Spawn", cementVehicleName)

        local deadline = tick() + 8
        while tick() < deadline do
            if session ~= blackJobSession or not isWireJobEnabled() then
                return nil
            end

            local car = getOwnedCar()
            if car then
                activeWireCar = car
                wireVehicleSpawned = true
                return car
            end

            task.wait(0.2)
        end

        activeWireCar = getOwnedCar()
        wireVehicleSpawned = activeWireCar ~= nil
        return activeWireCar
    end

    local function getCurrentWireCar()
        if activeWireCar and activeWireCar.Parent then
            return activeWireCar
        end

        activeWireCar = nil
        return nil
    end

    local function ensureInitialWireVehicle(session)
        if requiresInitialWireSpawn then
            requiresInitialWireSpawn = false
            wireVehicleSpawned = false
            activeWireCar = nil
            teleportCharacter(cementSpawnCFrame)
            task.wait(0.35)
            return spawnWireVehicle(session)
        end

        local currentCar = getCurrentWireCar()
        if currentCar then
            return currentCar
        end

        if wireVehicleSpawned then
            return nil
        end

        return nil
    end

    local function enterWireDriverSeat(car, session, walkToSeat)
        local seat = getDriverSeat(car)
        local humanoid = getHumanoid()
        local hrp = getHRP()
        if not seat or not humanoid or not hrp then
            return false
        end

        if seat.Occupant and seat.Occupant ~= humanoid then
            return false
        end

        if seat.Occupant == humanoid or humanoid.SeatPart == seat then
            return true
        end

        local seatPosition = seat.Position
        local shouldWalkToSeat = walkToSeat == true

        local function quickSit()
            hrp.CFrame = seat.CFrame + seat.CFrame.UpVector * 2
            task.wait(0.15)
            pcall(function()
                seat:Sit(humanoid)
            end)
            task.wait(0.35)
            return seat.Occupant == humanoid or humanoid.SeatPart == seat
        end

        if not shouldWalkToSeat then
            if quickSit() then
                return true
            end
            shouldWalkToSeat = true
        end

        local approachPosition = seatPosition + Vector3.new(0, 2, 0)

        if not moveCharacterToWire(seatPosition, 8, 6, session) then
            return false
        end

        hrp = getHRP()
        if not hrp then
            return false
        end

        hrp.CFrame = CFrame.new(approachPosition, seatPosition + seat.CFrame.LookVector * 6)
        task.wait(0.2)
        holdKey(Enum.KeyCode.E, 0.4)
        pcall(function()
            seat:Sit(humanoid)
        end)
        task.wait(0.8)

        if seat.Occupant == humanoid or humanoid.SeatPart == seat then
            return true
        end

        return quickSit()
    end

    local function findWirePrompt(target)
        if lastShownPrompt and lastShownPrompt.Parent and isDisplayed(lastShownPrompt) then
            local keyboardKey = Enum.KeyCode.Unknown
            pcall(function()
                keyboardKey = lastShownPrompt.KeyboardKeyCode
            end)

            if keyboardKey == Enum.KeyCode.F or keyboardKey == Enum.KeyCode.Unknown then
                return lastShownPrompt
            end
        end

        local folder = getWireFolder() or target
        local targetPosition = getInstancePosition(target)
        if not folder or not targetPosition then
            return nil
        end

        for _, descendant in ipairs(folder:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local promptPosition = getInstancePosition(descendant.Parent)
                if promptPosition and (promptPosition - targetPosition).Magnitude <= 20 and isDisplayed(descendant) then
                    local keyboardKey = Enum.KeyCode.Unknown
                    local ok = pcall(function()
                        keyboardKey = descendant.KeyboardKeyCode
                    end)

                    if ok and (keyboardKey == Enum.KeyCode.F or keyboardKey == Enum.KeyCode.Unknown) then
                        return descendant
                    end
                end
            end
        end

        return nil
    end

    local function triggerWirePrompt(prompt, session)
        if not prompt then
            return false
        end

        local holdDuration = 2
        pcall(function()
            holdDuration = math.max(prompt.HoldDuration + 0.5, 2)
        end)

        pcall(function()
            prompt:InputHoldBegin()
        end)

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)

        local releaseAt = tick() + holdDuration
        while tick() < releaseAt do
            if session ~= blackJobSession or not isWireJobEnabled() then
                break
            end

            if hasActiveWantedStatus() then
                break
            end

            if not prompt.Parent or not isDisplayed(prompt) then
                break
            end

            task.wait(0.1)
        end

        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)

        pcall(function()
            prompt:InputHoldEnd()
        end)

        return true
    end

    local function moveCarToWireTarget(car, target, session)
        if not car then
            return false
        end

        local highCFrame, settleCFrame = getSafeCarApproachCFrame(target, car)
        if not highCFrame or not settleCFrame then
            return false
        end

        car:PivotTo(highCFrame)
        task.wait(0.2)

        if session ~= blackJobSession or not isWireJobEnabled() then
            return false
        end

        car:PivotTo(settleCFrame)
        task.wait(0.35)
        return true
    end

    local function attemptStealWire(target, session)
        local targetPosition = getInstancePosition(target)
        if not targetPosition then
            return false
        end

        if not isCementTargetVisible(target) then
            task.wait(2)
            return false
        end

        local safeApproachCFrame = getSafeCementApproachCFrame(target)
        if safeApproachCFrame then
            teleportCharacter(safeApproachCFrame)
        end
        task.wait(0.3)

        local deadline = tick() + 20
        while tick() < deadline do
            if session ~= blackJobSession or not isWireJobEnabled() then
                return false
            end

            if hasActiveWantedStatus() then
                return true
            end

            if not isCementTargetVisible(target) then
                task.wait(2)
                return false
            end

            local prompt = findWirePrompt(target)
            if prompt then
                local promptPosition = getInstancePosition(prompt.Parent) or targetPosition
                moveCharacterToWire(promptPosition, 6, 3, session)
                triggerWirePrompt(prompt, session)
                task.wait(0.2)
            else
                local hrp = getHRP()
                local awayDirection = hrp and hrp.CFrame.RightVector or Vector3.new(1, 0, 0)
                awayDirection = Vector3.new(awayDirection.X, 0, awayDirection.Z)
                if awayDirection.Magnitude <= 0.01 then
                    awayDirection = Vector3.new(1, 0, 0)
                else
                    awayDirection = awayDirection.Unit
                end

                local awayPosition = targetPosition + awayDirection * 12
                moveCharacterToWire(awayPosition, 4, 3.2, session)
                task.wait(3)
                moveCharacterToWire(targetPosition, 6, 4, session)
                local retryPrompt = findWirePrompt(target)
                if retryPrompt then
                    triggerWirePrompt(retryPrompt, session)
                    task.wait(0.2)
                end
            end
        end

        return getProtectWantedVisible()
    end

    local function flyWireCarUp(car, session)
        if not enterWireDriverSeat(car, session) then
            return false
        end

        car:PivotTo(cementEscapeCFrame)
        task.wait(0.15)

        local escapeStartedAt = tick()
        local lastTick = tick()
        local currentPosition = cementEscapeCFrame.Position
        while true do
            if not car.Parent then
                stopCarMotion(car)
                return false
            end

            if session ~= blackJobSession or not isWireJobEnabled() then
                stopCarMotion(car)
                return false
            end

            if tick() - escapeStartedAt > 3 and not hasActiveWantedStatus() then
                stopCarMotion(car)
                return true
            end

            local now = tick()
            local delta = now - lastTick
            lastTick = now

            currentPosition = currentPosition + Vector3.new(0, 120 * delta, 0)
            if currentPosition.Y >= escapeMaxHeight then
                currentPosition = Vector3.new(currentPosition.X, escapeMaxHeight, currentPosition.Z)
                local holdCFrame = CFrame.new(
                    currentPosition.X,
                    currentPosition.Y,
                    currentPosition.Z,
                    0, 0, -1,
                    0, 1, 0,
                    1, 0, 0
                )
                car:PivotTo(holdCFrame)
                while true do
                    if not car.Parent then
                        stopCarMotion(car)
                        return false
                    end

                    if session ~= blackJobSession or not isWireJobEnabled() then
                        stopCarMotion(car)
                        return false
                    end

                    stopCarMotion(car)
                    car:PivotTo(holdCFrame)

                    if not hasActiveWantedStatus() then
                        return true
                    end

                    task.wait(0.2)
                end
            end

            local nextCFrame = CFrame.new(
                currentPosition.X,
                currentPosition.Y,
                currentPosition.Z,
                0, 0, -1,
                0, 1, 0,
                1, 0, 0
            )

            car:PivotTo(nextCFrame)

            local rootPart = getCarRootPart(car)
            if rootPart then
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 120, 0)
                rootPart.AssemblyAngularVelocity = Vector3.zero
            end

            task.wait()
        end
    end

    local function escapeWithWireCar(car, session)
        if not hasActiveWantedStatus() then
            return false
        end

        local escapeCar = car or getOwnedCar()
        if not escapeCar then
            return false
        end

        if not enterWireDriverSeat(escapeCar, session, true) then
            return false
        end

        flyWireCarUp(escapeCar, session)

        return true
    end

    local function runWireCycle(session)
        local targets = getWireTargets()
        if #targets == 0 then
            task.wait(2)
            return
        end

        local car = ensureInitialWireVehicle(session)
        if not car then
            task.wait(1)
            return
        end

        if escapeWithWireCar(car, session) then
            return
        end

        if not enterWireDriverSeat(car, session, false) then
            task.wait(0.5)
            return
        end

        if escapeWithWireCar(car, session) then
            return
        end

        local target = targets[wireRandom:NextInteger(1, #targets)]
        local targetCFrame = getInstanceCFrame(target)
        if not targetCFrame or not isCementTargetVisible(target) then
            task.wait(2)
            return
        end

        if not moveCarToWireTarget(car, target, session) then
            task.wait(0.5)
            return
        end

        if escapeWithWireCar(car, session) then
            return
        end

        leaveVehicle()

        if escapeWithWireCar(car, session) then
            return
        end

        if attemptStealWire(target, session) and hasActiveWantedStatus() then
            escapeWithWireCar(car, session)
        end
    end

    local function getDiamondFolder()
        local greyJobs = workspace:FindFirstChild("Grey_Jobs")
        return greyJobs and greyJobs:FindFirstChild("Diamond") or nil
    end

    local function getDiamondTargets()
        local folder = getDiamondFolder()
        local targets = {}

        if not folder then
            return targets
        end

        local children = folder:GetChildren()
        local cframeIndex = 0

        local function pushTarget(target)
            if target and isCementTargetVisible(target) and not table.find(targets, target) then
                cframeIndex = cframeIndex + 1
                table.insert(targets, {
                    target = target,
                    targetCFrame = diamondTargetCFrames[cframeIndex] or getInstanceCFrame(target)
                })
            end
        end

        pushTarget(children[6])
        pushTarget(children[3])
        pushTarget(folder:FindFirstChild("Box"))
        pushTarget(children[4])
        pushTarget(children[5])

        if #targets == 0 then
            for _, child in ipairs(children) do
                pushTarget(child)
            end
        end

        return targets
    end

    local function moveCharacterToDiamond(position, stopDistance, timeoutSeconds, session)
        local startTime = tick()

        while tick() - startTime < (timeoutSeconds or 10) do
            if session ~= blackJobSession or not isDiamondJobEnabled() then
                return false
            end

            local humanoid = getHumanoid()
            local hrp = getHRP()
            if not humanoid or not hrp then
                return false
            end

            if (hrp.Position - position).Magnitude <= (stopDistance or 5) then
                return true
            end

            humanoid:MoveTo(position)
            task.wait(0.2)
        end

        local hrp = getHRP()
        return hrp and (hrp.Position - position).Magnitude <= (stopDistance or 5) or false
    end

    local function spawnDiamondVehicle(session)
        local events = ReplicatedStorage:FindFirstChild("Events")
        local vehicleEvent = events and events:FindFirstChild("VehicleEvent")
        if not vehicleEvent then
            activeDiamondCar = getOwnedCar()
            return activeDiamondCar
        end

        vehicleEvent:FireServer("Spawn", cementVehicleName)

        local deadline = tick() + 8
        while tick() < deadline do
            if session ~= blackJobSession or not isDiamondJobEnabled() then
                return nil
            end

            local car = getOwnedCar()
            if car then
                activeDiamondCar = car
                diamondVehicleSpawned = true
                return car
            end

            task.wait(0.2)
        end

        activeDiamondCar = getOwnedCar()
        diamondVehicleSpawned = activeDiamondCar ~= nil
        return activeDiamondCar
    end

    local function getCurrentDiamondCar()
        if activeDiamondCar and activeDiamondCar.Parent then
            return activeDiamondCar
        end

        activeDiamondCar = nil
        return nil
    end

    local function ensureInitialDiamondVehicle(session)
        if requiresInitialDiamondSpawn then
            requiresInitialDiamondSpawn = false
            diamondVehicleSpawned = false
            activeDiamondCar = nil
            teleportCharacter(cementSpawnCFrame)
            task.wait(0.35)
            return spawnDiamondVehicle(session)
        end

        local currentCar = getCurrentDiamondCar()
        if currentCar then
            return currentCar
        end

        if diamondVehicleSpawned then
            return nil
        end

        return nil
    end

    local function enterDiamondDriverSeat(car, session, walkToSeat)
        local seat = getDriverSeat(car)
        local humanoid = getHumanoid()
        local hrp = getHRP()
        if not seat or not humanoid or not hrp then
            return false
        end

        if seat.Occupant and seat.Occupant ~= humanoid then
            return false
        end

        if seat.Occupant == humanoid or humanoid.SeatPart == seat then
            return true
        end

        local seatPosition = seat.Position
        local shouldWalkToSeat = walkToSeat == true

        local function quickSit()
            hrp.CFrame = seat.CFrame + seat.CFrame.UpVector * 2
            task.wait(0.15)
            pcall(function()
                seat:Sit(humanoid)
            end)
            task.wait(0.35)
            return seat.Occupant == humanoid or humanoid.SeatPart == seat
        end

        if not shouldWalkToSeat then
            if quickSit() then
                return true
            end
            shouldWalkToSeat = true
        end

        local approachPosition = seatPosition + Vector3.new(0, 2, 0)

        if not moveCharacterToDiamond(seatPosition, 8, 6, session) then
            return false
        end

        hrp = getHRP()
        if not hrp then
            return false
        end

        hrp.CFrame = CFrame.new(approachPosition, seatPosition + seat.CFrame.LookVector * 6)
        task.wait(0.2)
        holdKey(Enum.KeyCode.E, 0.4)
        pcall(function()
            seat:Sit(humanoid)
        end)
        task.wait(0.8)

        if seat.Occupant == humanoid or humanoid.SeatPart == seat then
            return true
        end

        return quickSit()
    end

    local function findDiamondPrompt(target)
        if lastShownPrompt and lastShownPrompt.Parent and isDisplayed(lastShownPrompt) then
            local keyboardKey = Enum.KeyCode.Unknown
            pcall(function()
                keyboardKey = lastShownPrompt.KeyboardKeyCode
            end)

            if keyboardKey == Enum.KeyCode.F or keyboardKey == Enum.KeyCode.Unknown then
                return lastShownPrompt
            end
        end

        local folder = getDiamondFolder() or target
        local targetPosition = getInstancePosition(target)
        if not folder or not targetPosition then
            return nil
        end

        for _, descendant in ipairs(folder:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local promptPosition = getInstancePosition(descendant.Parent)
                if promptPosition and (promptPosition - targetPosition).Magnitude <= 20 and isDisplayed(descendant) then
                    local keyboardKey = Enum.KeyCode.Unknown
                    local ok = pcall(function()
                        keyboardKey = descendant.KeyboardKeyCode
                    end)

                    if ok and (keyboardKey == Enum.KeyCode.F or keyboardKey == Enum.KeyCode.Unknown) then
                        return descendant
                    end
                end
            end
        end

        return nil
    end

    local function triggerDiamondPrompt(prompt, session)
        if not prompt then
            return false
        end

        local holdDuration = 2
        pcall(function()
            holdDuration = math.max(prompt.HoldDuration + 0.5, 2)
        end)

        pcall(function()
            prompt:InputHoldBegin()
        end)

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)

        local releaseAt = tick() + holdDuration
        while tick() < releaseAt do
            if session ~= blackJobSession or not isDiamondJobEnabled() then
                break
            end

            if hasActiveWantedStatus() then
                break
            end

            if not prompt.Parent or not isDisplayed(prompt) then
                break
            end

            task.wait(0.1)
        end

        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)

        pcall(function()
            prompt:InputHoldEnd()
        end)

        return true
    end

    local function moveCarToDiamondTarget(car, target, session, targetCFrameOverride)
        if not car then
            return false
        end

        local proxyTarget = target
        if targetCFrameOverride then
            proxyTarget = {
                IsA = function()
                    return false
                end,
                GetDescendants = function()
                    return {}
                end
            }
        end

        local highCFrame, settleCFrame
        if targetCFrameOverride then
            local targetPosition = targetCFrameOverride.Position
            local carPivot = car and car:GetPivot() or nil
            local horizontalDirection = carPivot and (carPivot.Position - targetPosition) or Vector3.new(1, 0, 0)
            horizontalDirection = Vector3.new(horizontalDirection.X, 0, horizontalDirection.Z)

            if horizontalDirection.Magnitude <= 0.01 then
                local hrp = getHRP()
                horizontalDirection = hrp and (hrp.Position - targetPosition) or Vector3.new(1, 0, 0)
                horizontalDirection = Vector3.new(horizontalDirection.X, 0, horizontalDirection.Z)
            end

            if horizontalDirection.Magnitude <= 0.01 then
                horizontalDirection = Vector3.new(1, 0, 0)
            else
                horizontalDirection = horizontalDirection.Unit
            end

            highCFrame = CFrame.new(targetPosition + horizontalDirection * 16 + Vector3.new(0, 40, 0), targetPosition)
            settleCFrame = CFrame.new(targetPosition + horizontalDirection * 16 + Vector3.new(0, 25, 0), targetPosition)
        else
            highCFrame, settleCFrame = getSafeCarApproachCFrame(proxyTarget, car)
        end
        if not highCFrame or not settleCFrame then
            return false
        end

        car:PivotTo(highCFrame)
        task.wait(0.2)

        if session ~= blackJobSession or not isDiamondJobEnabled() then
            return false
        end

        car:PivotTo(settleCFrame)
        task.wait(0.35)
        return true
    end

    local function attemptStealDiamond(target, session, targetCFrameOverride)
        local targetPosition = targetCFrameOverride and targetCFrameOverride.Position or getInstancePosition(target)
        if not targetPosition then
            return false
        end

        if not isCementTargetVisible(target) then
            task.wait(2)
            return false
        end

        local safeApproachCFrame = targetCFrameOverride and CFrame.new(targetPosition + Vector3.new(6, 4.5, 0), targetPosition) or getSafeCementApproachCFrame(target)
        if safeApproachCFrame then
            teleportCharacter(safeApproachCFrame)
        end
        task.wait(0.3)

        local deadline = tick() + 20
        while tick() < deadline do
            if session ~= blackJobSession or not isDiamondJobEnabled() then
                return false
            end

            if hasActiveWantedStatus() then
                return true
            end

            if not isCementTargetVisible(target) then
                task.wait(2)
                return false
            end

            local prompt = findDiamondPrompt(target)
            if prompt then
                local promptPosition = getInstancePosition(prompt.Parent) or targetPosition
                moveCharacterToDiamond(promptPosition, 6, 3, session)
                triggerDiamondPrompt(prompt, session)
                task.wait(0.2)
            else
                local hrp = getHRP()
                local awayDirection = hrp and hrp.CFrame.RightVector or Vector3.new(1, 0, 0)
                awayDirection = Vector3.new(awayDirection.X, 0, awayDirection.Z)
                if awayDirection.Magnitude <= 0.01 then
                    awayDirection = Vector3.new(1, 0, 0)
                else
                    awayDirection = awayDirection.Unit
                end

                local awayPosition = targetPosition + awayDirection * 12
                moveCharacterToDiamond(awayPosition, 4, 3.2, session)
                task.wait(3)
                moveCharacterToDiamond(targetPosition, 6, 4, session)
                local retryPrompt = findDiamondPrompt(target)
                if retryPrompt then
                    triggerDiamondPrompt(retryPrompt, session)
                    task.wait(0.2)
                end
            end
        end

        return getProtectWantedVisible()
    end

    local function flyDiamondCarUp(car, session)
        if not enterDiamondDriverSeat(car, session) then
            return false
        end

        car:PivotTo(cementEscapeCFrame)
        task.wait(0.15)

        local escapeStartedAt = tick()
        local lastTick = tick()
        local currentPosition = cementEscapeCFrame.Position
        while true do
            if not car.Parent then
                stopCarMotion(car)
                return false
            end

            if session ~= blackJobSession or not isDiamondJobEnabled() then
                stopCarMotion(car)
                return false
            end

            if tick() - escapeStartedAt > 3 and not hasActiveWantedStatus() then
                stopCarMotion(car)
                return true
            end

            local now = tick()
            local delta = now - lastTick
            lastTick = now

            currentPosition = currentPosition + Vector3.new(0, 120 * delta, 0)
            if currentPosition.Y >= escapeMaxHeight then
                currentPosition = Vector3.new(currentPosition.X, escapeMaxHeight, currentPosition.Z)
                local holdCFrame = CFrame.new(
                    currentPosition.X,
                    currentPosition.Y,
                    currentPosition.Z,
                    0, 0, -1,
                    0, 1, 0,
                    1, 0, 0
                )
                car:PivotTo(holdCFrame)
                while true do
                    if not car.Parent then
                        stopCarMotion(car)
                        return false
                    end

                    if session ~= blackJobSession or not isDiamondJobEnabled() then
                        stopCarMotion(car)
                        return false
                    end

                    stopCarMotion(car)
                    car:PivotTo(holdCFrame)

                    if not hasActiveWantedStatus() then
                        return true
                    end

                    task.wait(0.2)
                end
            end

            local nextCFrame = CFrame.new(
                currentPosition.X,
                currentPosition.Y,
                currentPosition.Z,
                0, 0, -1,
                0, 1, 0,
                1, 0, 0
            )

            car:PivotTo(nextCFrame)

            local rootPart = getCarRootPart(car)
            if rootPart then
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 120, 0)
                rootPart.AssemblyAngularVelocity = Vector3.zero
            end

            task.wait()
        end
    end

    local function escapeWithDiamondCar(car, session)
        if not hasActiveWantedStatus() then
            return false
        end

        local escapeCar = car or getOwnedCar()
        if not escapeCar then
            return false
        end

        if not enterDiamondDriverSeat(escapeCar, session, true) then
            return false
        end

        flyDiamondCarUp(escapeCar, session)

        return true
    end

    local function runDiamondCycle(session)
        local targets = getDiamondTargets()
        if #targets == 0 then
            task.wait(2)
            return
        end

        local car = ensureInitialDiamondVehicle(session)
        if not car then
            task.wait(1)
            return
        end

        if escapeWithDiamondCar(car, session) then
            return
        end

        if not enterDiamondDriverSeat(car, session, false) then
            task.wait(0.5)
            return
        end

        if escapeWithDiamondCar(car, session) then
            return
        end

        local targetEntry = targets[diamondRandom:NextInteger(1, #targets)]
        local target = targetEntry and targetEntry.target or nil
        local targetCFrame = targetEntry and targetEntry.targetCFrame or nil
        if not target or not targetCFrame or not isCementTargetVisible(target) then
            task.wait(2)
            return
        end

        if not moveCarToDiamondTarget(car, target, session, targetCFrame) then
            task.wait(0.5)
            return
        end

        if escapeWithDiamondCar(car, session) then
            return
        end

        leaveVehicle()

        if escapeWithDiamondCar(car, session) then
            return
        end

        if attemptStealDiamond(target, session, targetCFrame) and hasActiveWantedStatus() then
            escapeWithDiamondCar(car, session)
        end
    end

    StartToggle:OnChanged(function()
        blackJobSession = blackJobSession + 1
        requiresInitialCementSpawn = true
        cementVehicleSpawned = false
        activeCementCar = nil
        requiresInitialWireSpawn = true
        wireVehicleSpawned = false
        activeWireCar = nil
        requiresInitialDiamondSpawn = true
        diamondVehicleSpawned = false
        activeDiamondCar = nil
    end)

    JobDropdown:OnChanged(function()
        blackJobSession = blackJobSession + 1
        requiresInitialCementSpawn = true
        cementVehicleSpawned = false
        activeCementCar = nil
        requiresInitialWireSpawn = true
        wireVehicleSpawned = false
        activeWireCar = nil
        requiresInitialDiamondSpawn = true
        diamondVehicleSpawned = false
        activeDiamondCar = nil
    end)

    task.spawn(function()
        while task.wait(0.25) do
            if not isCementJobEnabled() then
                continue
            end

            local session = blackJobSession
            runCementCycle(session)
        end
    end)

    task.spawn(function()
        while task.wait(0.25) do
            if not isWireJobEnabled() then
                continue
            end

            local session = blackJobSession
            runWireCycle(session)
        end
    end)

    task.spawn(function()
        while task.wait(0.25) do
            if not isDiamondJobEnabled() then
                continue
            end

            local session = blackJobSession
            runDiamondCycle(session)
        end
    end)

    ProximityPromptService.PromptShown:Connect(function(prompt)
        local keyboardKey = Enum.KeyCode.Unknown
        pcall(function()
            keyboardKey = prompt.KeyboardKeyCode
        end)

        if keyboardKey == Enum.KeyCode.F or keyboardKey == Enum.KeyCode.Unknown then
            lastShownPrompt = prompt
        end
    end)

    ProximityPromptService.PromptHidden:Connect(function(prompt)
        if lastShownPrompt == prompt then
            lastShownPrompt = nil
        end
    end)
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

    PoliceJob:AddSection("Auto arrest | ออโต้จับผู้เล่น")

    local AutoArrest = PoliceJob:AddToggle("AutoArrest", {
        Title = "เริ่มต้นจับผู้เล่น",
        Default = false
    })

    local espFolder = Instance.new("Folder")
    espFolder.Name = "WantedESP_Folder"
    espFolder.Parent = workspace

    local playerState = {}

    local function getState(player)
        local id = player.UserId
        local state = playerState[id]
        if not state then
            state = {
                wantedFalse = 0,
                policeFalse = 0
            }
            playerState[id] = state
        end
        return state
    end

    local function createESP(player, type)
        local char = player.Character
        if not char then return end

        local espName = type == "Wanted" and "WantedHighlight" or "PoliceHighlight"
        local billboardName = type == "Wanted" and "WantedBillboard" or "PoliceBillboard"
        local labelName = type == "Wanted" and "WantedLabel" or "PoliceLabel"
        local color = type == "Wanted" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 170, 255)
        local tagText = type == "Wanted" and "[WANTED]" or "[POLICE]"

        -- จัดการ Highlight
        local highlight = char:FindFirstChild(espName)
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = espName
            highlight.Parent = char
        end
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0

        -- จัดการ BillboardGui
        local head = char:FindFirstChild("Head")
        if head then
            local billboard = head:FindFirstChild(billboardName)
            if not billboard then
                billboard = Instance.new("BillboardGui")
                billboard.Name = billboardName
                billboard.Size = UDim2.new(0, 200, 0, 60)
                billboard.AlwaysOnTop = true
                billboard.ExtentsOffset = Vector3.new(0, 3, 0)
                billboard.Parent = head
            end

            local label = billboard:FindFirstChild(labelName)
            if not label then
                label = Instance.new("TextLabel")
                label.Name = labelName
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = color
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.Parent = billboard
            end

            -- อัปเดตข้อความ
            local dist = 0
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                dist = math.floor((char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            end
            label.Text = string.format("%s\n%s\n%d M", player.DisplayName, tagText, dist)
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

    local function isWantedFromNameTag(player)
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local nameTag = head and head:FindFirstChild("NameTag")
        local wanted = nameTag and nameTag:FindFirstChild("WANTED")
        if not wanted then
            return false
        end

        local ok, v = pcall(function()
            return wanted.Visible
        end)
        if ok and type(v) == "boolean" then
            return v
        end

        ok, v = pcall(function()
            return wanted.Enabled
        end)
        if ok and type(v) == "boolean" then
            return v
        end

        return true
    end

    local function isPoliceTeam(player)
        return player.Team and player.Team.Name and (player.Team.Name:lower():find("police") or player.Team.Name:find("ตำรวจ")) ~= nil
    end

    local function getHRP(player)
        local char = player.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getHumanoid(player)
        local char = player.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function moveNear(position, stopDistance, timeoutSeconds)
        local start = tick()
        local humanoid = getHumanoid(LocalPlayer)
        local hrp = getHRP(LocalPlayer)
        if not humanoid or not hrp then
            return false
        end

        while tick() - start < (timeoutSeconds or 15) do
            if not (Options.AutoArrest and Options.AutoArrest.Value) then
                return false
            end
            hrp = getHRP(LocalPlayer)
            if not hrp then
                return false
            end
            if (hrp.Position - position).Magnitude <= (stopDistance or 5) then
                return true
            end
            humanoid:MoveTo(position)
            task.wait(0.2)
        end

        hrp = getHRP(LocalPlayer)
        return hrp and (hrp.Position - position).Magnitude <= (stopDistance or 5) or false
    end

    local function holdKey(keyCode, holdSeconds)
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, keyCode, false, game)
        task.wait(holdSeconds)
        vim:SendKeyEvent(false, keyCode, false, game)
    end

    local function equipHandcuffs()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return false
        end

        local tool = (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Handcuffs")) or (char and char:FindFirstChild("Handcuffs"))
        if tool and tool:IsA("Tool") then
            humanoid:EquipTool(tool)
            return true
        end
        return false
    end

    local function ensurePolice()
        local enabled = Options.AutoArrest and Options.AutoArrest.Value
        if not enabled then
            return false
        end
        if isPoliceTeam(LocalPlayer) then
            return true
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then
            return false
        end

        local joinPos = Vector3.new(770.383179, 10.6919441, -19.1743813)
        moveNear(joinPos, 6, 25)
        holdKey(Enum.KeyCode.E, 0.7)
        task.wait(0.35)
        return isPoliceTeam(LocalPlayer)
    end

    local function findNearestWanted()
        local myHrp = getHRP(LocalPlayer)
        if not myHrp then
            return nil
        end

        local bestPlayer = nil
        local bestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isWantedFromNameTag(p) then
                local hrp = getHRP(p)
                if hrp then
                    local d = (hrp.Position - myHrp.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestPlayer = p
                    end
                end
            end
        end
        return bestPlayer
    end

    task.spawn(function()
        while task.wait(0.25) do
            if not (Options.AutoArrest and Options.AutoArrest.Value) then
                continue
            end

            while (Options.AutoArrest and Options.AutoArrest.Value) and not isPoliceTeam(LocalPlayer) do
                if ensurePolice() then
                    break
                end
                task.wait(0.35)
            end

            if not (Options.AutoArrest and Options.AutoArrest.Value) then
                continue
            end

            local target = findNearestWanted()
            if not target then
                task.wait(0.5)
                continue
            end

            while (Options.AutoArrest and Options.AutoArrest.Value) and isPoliceTeam(LocalPlayer) and target and target.Parent and isWantedFromNameTag(target) do
                local myHrp = getHRP(LocalPlayer)
                local tHrp = getHRP(target)
                local myHumanoid = getHumanoid(LocalPlayer)
                if not myHrp or not tHrp then
                    break
                end

                if myHumanoid then
                    local desiredPos = (tHrp.CFrame * CFrame.new(0, 0, -2)).Position
                    myHumanoid:MoveTo(desiredPos)
                end

                if (myHrp.Position - tHrp.Position).Magnitude <= 7 then
                    equipHandcuffs()
                    holdKey(Enum.KeyCode.F, 1.25)
                end
                task.wait(0.15)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.5) do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        local state = getState(player)
                        local wantedEnabled = Options.WantedESP and Options.WantedESP.Value or false
                        local policeEnabled = Options.PoliceESP and Options.PoliceESP.Value or false

                        -- เช็คสถานะ Wanted (ต้องเป็น UI ที่ Visible ตามที่ระบุ)
                        local isWanted = false
                        if wantedEnabled then
                            isWanted = isWantedFromNameTag(player)
                        end

                        -- เช็คสถานะ Police (เช็คจากทีม Police โดยตรง)
                        local isPolice = false
                        if policeEnabled then
                            isPolice = isPoliceTeam(player)
                        end

                        -- จัดการการแสดงผล Wanted (กันกระพริบด้วยตัวนับ)
                        if not wantedEnabled then
                            state.wantedFalse = 0
                            removeESP(player, "Wanted")
                        elseif isWanted then
                            state.wantedFalse = 0
                            createESP(player, "Wanted")
                        else
                            state.wantedFalse = state.wantedFalse + 1
                            if state.wantedFalse >= 3 then
                                removeESP(player, "Wanted")
                            end
                        end

                        -- จัดการการแสดงผล Police (กันกระพริบด้วยตัวนับ)
                        if not policeEnabled then
                            state.policeFalse = 0
                            removeESP(player, "Police")
                        elseif isPolice then
                            state.policeFalse = 0
                            createESP(player, "Police")
                        else
                            state.policeFalse = state.policeFalse + 1
                            if state.policeFalse >= 3 then
                                removeESP(player, "Police")
                            end
                        end
                    end)
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
