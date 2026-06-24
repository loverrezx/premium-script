local MacLib = { 
	Options = {}, 
	Folder = "Maclib", 
	GetService = function(service)
		return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
	end
}

--// Services
local TweenService = MacLib.GetService("TweenService")
local RunService = MacLib.GetService("RunService")
local HttpService = MacLib.GetService("HttpService")
local ContentProvider = MacLib.GetService("ContentProvider")
local UserInputService = MacLib.GetService("UserInputService")
local Lighting = MacLib.GetService("Lighting")
local Players = MacLib.GetService("Players")

--// Variables
local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer

local windowState
local acrylicBlur
local hasGlobalSetting

local unloaded = false

-- Category & Tab tracking
local categories = {}         -- { [categoryFrame] = { name, tabs = { [tabSwitcher] = tabInfo } } }
local allTabs = {}            -- { [tabSwitcher] = tabInfo }
local currentTabInstance = nil

local assets = {
	interFont = "rbxassetid://12187365364",
	userInfoBlurred = "rbxassetid://18824089198",
	toggleBackground = "rbxassetid://18772190202",
	togglerHead = "rbxassetid://18772309008",
	buttonImage = "rbxassetid://10709791437",
	searchIcon = "rbxassetid://86737463322606",
	colorWheel = "rbxassetid://2849458409",
	colorTarget = "rbxassetid://73265255323268",
	grid = "rbxassetid://121484455191370",
	globe = "rbxassetid://108952102602834",
	transform = "rbxassetid://90336395745819",
	dropdown = "rbxassetid://18865373378",
	sliderbar = "rbxassetid://18772615246",
	sliderhead = "rbxassetid://18772834246",
}

--// Functions
local function GetGui()
	local newGui = Instance.new("ScreenGui")
	newGui.ScreenInsets = Enum.ScreenInsets.None
	newGui.ResetOnSpawn = false
	newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	newGui.DisplayOrder = 2147483647

	local parent = RunService:IsStudio() 
		and LocalPlayer:FindFirstChild("PlayerGui")
		or (gethui and gethui())
		or (cloneref and cloneref(MacLib.GetService("CoreGui")) or MacLib.GetService("CoreGui"))

	newGui.Parent = parent
	return newGui
end

local function Tween(instance, tweeninfo, propertytable)
	return TweenService:Create(instance, tweeninfo, propertytable)
end

--// Library Functions
function MacLib:Window(Settings)
	local WindowFunctions = {Settings = Settings}
	if Settings.AcrylicBlur ~= nil then
		acrylicBlur = Settings.AcrylicBlur
	else
		acrylicBlur = true
	end

	local macLib = GetGui()

	-- Notifications
	local notifications = Instance.new("Frame")
	notifications.Name = "Notifications"
	notifications.BackgroundTransparency = 1
	notifications.BorderSizePixel = 0
	notifications.Size = UDim2.fromScale(1, 1)
	notifications.Parent = macLib
	notifications.ZIndex = 2

	local notificationsUIListLayout = Instance.new("UIListLayout")
	notificationsUIListLayout.Padding = UDim.new(0, 10)
	notificationsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notificationsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notificationsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notificationsUIListLayout.Parent = notifications

	local notificationsUIPadding = Instance.new("UIPadding")
	notificationsUIPadding.PaddingBottom = UDim.new(0, 10)
	notificationsUIPadding.PaddingLeft = UDim.new(0, 10)
	notificationsUIPadding.PaddingRight = UDim.new(0, 10)
	notificationsUIPadding.PaddingTop = UDim.new(0, 10)
	notificationsUIPadding.Parent = notifications

	-- Base Window
	local base = Instance.new("Frame")
	base.Name = "Base"
	base.AnchorPoint = Vector2.new(0.5, 0.5)
	base.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	base.BackgroundTransparency = Settings.AcrylicBlur and 0.05 or 0
	base.BorderSizePixel = 0
	base.Position = UDim2.fromScale(0.5, 0.5)
	base.Size = Settings.Size or UDim2.fromOffset(868, 650)

	local baseUIScale = Instance.new("UIScale")
	baseUIScale.Parent = base

	local baseUICorner = Instance.new("UICorner")
	baseUICorner.CornerRadius = UDim.new(0, 10)
	baseUICorner.Parent = base

	local baseUIStroke = Instance.new("UIStroke")
	baseUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	baseUIStroke.Color = Color3.fromRGB(255, 255, 255)
	baseUIStroke.Transparency = 0.9
	baseUIStroke.Parent = base

	-- Sidebar
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundTransparency = 1
	sidebar.BorderSizePixel = 0
	sidebar.Size = UDim2.fromScale(0.325, 1)
	sidebar.Parent = base

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.AnchorPoint = Vector2.new(1, 0)
	divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider.BackgroundTransparency = 0.9
	divider.BorderSizePixel = 0
	divider.Position = UDim2.fromScale(1, 0)
	divider.Size = UDim2.new(0, 1, 1, 0)
	divider.Parent = sidebar

	local dividerInteract = Instance.new("TextButton")
	dividerInteract.Name = "DividerInteract"
	dividerInteract.AnchorPoint = Vector2.new(0.5, 0)
	dividerInteract.BackgroundTransparency = 1
	dividerInteract.BorderSizePixel = 0
	dividerInteract.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	dividerInteract.Position = UDim2.fromScale(0.5, 0)
	dividerInteract.Size = UDim2.new(1, 6, 1, 0)
	dividerInteract.Text = ""
	dividerInteract.TextColor3 = Color3.fromRGB(0, 0, 0)
	dividerInteract.TextSize = 14
	dividerInteract.Parent = divider

	-- =============================================
	-- Window Controls (macOS colored dots)
	-- =============================================
	local windowControls = Instance.new("Frame")
	windowControls.Name = "WindowControls"
	windowControls.BackgroundTransparency = 1
	windowControls.BorderSizePixel = 0
	windowControls.Size = UDim2.new(1, 0, 0, 31)
	windowControls.Parent = sidebar

	local controls = Instance.new("Frame")
	controls.Name = "Controls"
	controls.BackgroundTransparency = 1
	controls.BorderSizePixel = 0
	controls.Size = UDim2.fromScale(1, 1)
	controls.Parent = windowControls

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Padding = UDim.new(0, 8)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = controls

	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0, 13)
	uIPadding.Parent = controls

	-- Helper: สร้าง macOS dot button
	local function CreateMacDot(color, hoverColor, order)
		local dot = Instance.new("TextButton")
		dot.Name = "Dot"
		dot.Size = UDim2.fromOffset(12, 12)
		dot.BackgroundColor3 = color
		dot.BorderSizePixel = 0
		dot.Text = ""
		dot.AutoButtonColor = false
		dot.LayoutOrder = order

		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = dot

		-- Hover: symbol เล็กๆ ตรงกลาง
		local symbol = Instance.new("TextLabel")
		symbol.Name = "Symbol"
		symbol.AnchorPoint = Vector2.new(0.5, 0.5)
		symbol.Position = UDim2.fromScale(0.5, 0.5)
		symbol.Size = UDim2.fromScale(1, 1)
		symbol.BackgroundTransparency = 1
		symbol.TextTransparency = 1
		symbol.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		symbol.TextScaled = true
		symbol.TextColor3 = Color3.fromRGB(80, 30, 0)
		symbol.ZIndex = 2
		symbol.Parent = dot

		dot.MouseEnter:Connect(function()
			dot.BackgroundColor3 = hoverColor
			Tween(symbol, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { TextTransparency = 0.1 }):Play()
		end)
		dot.MouseLeave:Connect(function()
			dot.BackgroundColor3 = color
			Tween(symbol, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { TextTransparency = 1 }):Play()
		end)

		dot.Parent = controls
		return dot, symbol
	end

	-- ปุ่มแดง (Close)
	local exitDot, exitSymbol = CreateMacDot(
		Color3.fromRGB(255, 95, 87),
		Color3.fromRGB(220, 60, 55),
		0
	)
	exitSymbol.Text = "✕"
	exitSymbol.TextColor3 = Color3.fromRGB(100, 20, 15)

	-- ปุ่มเหลือง (Minimize)
	local minimizeDot, minimizeSymbol = CreateMacDot(
		Color3.fromRGB(255, 189, 46),
		Color3.fromRGB(220, 155, 20),
		1
	)
	minimizeSymbol.Text = "–"
	minimizeSymbol.TextColor3 = Color3.fromRGB(100, 70, 0)

	-- ปุ่มเขียว (Maximize — disabled ในที่นี้)
	local maximizeDot, maximizeSymbol = CreateMacDot(
		Color3.fromRGB(40, 200, 64),
		Color3.fromRGB(20, 160, 40),
		2
	)
	maximizeSymbol.Text = "+"
	maximizeSymbol.TextColor3 = Color3.fromRGB(0, 60, 20)
	maximizeDot.Active = false
	maximizeDot.Interactable = false
	maximizeDot.BackgroundColor3 = Color3.fromRGB(87, 87, 87)

	local divider1 = Instance.new("Frame")
	divider1.AnchorPoint = Vector2.new(0, 1)
	divider1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider1.BackgroundTransparency = 0.9
	divider1.BorderSizePixel = 0
	divider1.Position = UDim2.fromScale(0, 1)
	divider1.Size = UDim2.new(1, 0, 0, 1)
	divider1.Parent = windowControls

	-- Information (Title / Subtitle)
	local information = Instance.new("Frame")
	information.Name = "Information"
	information.BackgroundTransparency = 1
	information.BorderSizePixel = 0
	information.Position = UDim2.fromOffset(0, 31)
	information.Size = UDim2.new(1, 0, 0, 60)
	information.Parent = sidebar

	local divider2 = Instance.new("Frame")
	divider2.AnchorPoint = Vector2.new(0, 1)
	divider2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider2.BackgroundTransparency = 0.9
	divider2.BorderSizePixel = 0
	divider2.Position = UDim2.fromScale(0, 1)
	divider2.Size = UDim2.new(1, 0, 0, 1)
	divider2.Parent = information

	local informationHolder = Instance.new("Frame")
	informationHolder.BackgroundTransparency = 1
	informationHolder.BorderSizePixel = 0
	informationHolder.Size = UDim2.fromScale(1, 1)
	informationHolder.Parent = information

	local informationHolderUIPadding = Instance.new("UIPadding")
	informationHolderUIPadding.PaddingBottom = UDim.new(0, 10)
	informationHolderUIPadding.PaddingLeft = UDim.new(0, 23)
	informationHolderUIPadding.PaddingRight = UDim.new(0, 22)
	informationHolderUIPadding.PaddingTop = UDim.new(0, 10)
	informationHolderUIPadding.Parent = informationHolder

	local globalSettingsButton = Instance.new("ImageButton")
	globalSettingsButton.Image = assets.globe
	globalSettingsButton.ImageTransparency = 0.5
	globalSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
	globalSettingsButton.BackgroundTransparency = 1
	globalSettingsButton.BorderSizePixel = 0
	globalSettingsButton.Position = UDim2.fromScale(1, 0.5)
	globalSettingsButton.Size = UDim2.fromOffset(16, 16)
	globalSettingsButton.Parent = informationHolder

	globalSettingsButton.MouseEnter:Connect(function()
		Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.3 }):Play()
	end)
	globalSettingsButton.MouseLeave:Connect(function()
		Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.5 }):Play()
	end)

	local titleFrame = Instance.new("Frame")
	titleFrame.BackgroundTransparency = 1
	titleFrame.BorderSizePixel = 0
	titleFrame.Size = UDim2.fromScale(1, 1)
	titleFrame.Parent = informationHolder

	local title = Instance.new("TextLabel")
	title.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold)
	title.Text = Settings.Title
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.RichText = true
	title.TextSize = 18
	title.TextTransparency = 0.1
	title.TextTruncate = Enum.TextTruncate.SplitWord
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Top
	title.AutomaticSize = Enum.AutomaticSize.Y
	title.BackgroundTransparency = 1
	title.BorderSizePixel = 0
	title.Size = UDim2.new(1, -20, 0, 0)
	title.Parent = titleFrame

	local subtitle = Instance.new("TextLabel")
	subtitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
	subtitle.Text = Settings.Subtitle
	subtitle.RichText = true
	subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	subtitle.TextSize = 12
	subtitle.TextTransparency = 0.7
	subtitle.TextTruncate = Enum.TextTruncate.SplitWord
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextYAlignment = Enum.TextYAlignment.Top
	subtitle.AutomaticSize = Enum.AutomaticSize.Y
	subtitle.BackgroundTransparency = 1
	subtitle.BorderSizePixel = 0
	subtitle.LayoutOrder = 1
	subtitle.Size = UDim2.new(1, -20, 0, 0)
	subtitle.Parent = titleFrame

	local titleFrameUIListLayout = Instance.new("UIListLayout")
	titleFrameUIListLayout.Padding = UDim.new(0, 3)
	titleFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	titleFrameUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	titleFrameUIListLayout.Parent = titleFrame

	-- =============================================
	-- Sidebar Group (Category + Tab system)
	-- =============================================
	local sidebarGroup = Instance.new("Frame")
	sidebarGroup.Name = "SidebarGroup"
	sidebarGroup.BackgroundTransparency = 1
	sidebarGroup.BorderSizePixel = 0
	sidebarGroup.Position = UDim2.fromOffset(0, 91)
	sidebarGroup.Size = UDim2.new(1, 0, 1, -91)
	sidebarGroup.Parent = sidebar

	-- User Info (bottom)
	local userInfo = Instance.new("Frame")
	userInfo.AnchorPoint = Vector2.new(0, 1)
	userInfo.BackgroundTransparency = 1
	userInfo.BorderSizePixel = 0
	userInfo.Position = UDim2.fromScale(0, 1)
	userInfo.Size = UDim2.new(1, 0, 0, 107)
	userInfo.Parent = sidebarGroup

	local informationGroup = Instance.new("Frame")
	informationGroup.BackgroundTransparency = 1
	informationGroup.BorderSizePixel = 0
	informationGroup.Size = UDim2.fromScale(1, 1)
	informationGroup.Parent = userInfo

	local informationGroupUIPadding = Instance.new("UIPadding")
	informationGroupUIPadding.PaddingBottom = UDim.new(0, 17)
	informationGroupUIPadding.PaddingLeft = UDim.new(0, 25)
	informationGroupUIPadding.Parent = informationGroup

	local informationGroupUIListLayout = Instance.new("UIListLayout")
	informationGroupUIListLayout.FillDirection = Enum.FillDirection.Horizontal
	informationGroupUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	informationGroupUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	informationGroupUIListLayout.Parent = informationGroup

	local userId = LocalPlayer.UserId
	local thumbType = Enum.ThumbnailType.AvatarBust
	local thumbSize = Enum.ThumbnailSize.Size48x48
	local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

	local headshot = Instance.new("ImageLabel")
	headshot.BackgroundTransparency = 1
	headshot.BorderSizePixel = 0
	headshot.Size = UDim2.fromOffset(32, 32)
	headshot.Image = (isReady and headshotImage) or "rbxassetid://0"

	local uICorner3 = Instance.new("UICorner")
	uICorner3.CornerRadius = UDim.new(1, 0)
	uICorner3.Parent = headshot

	local baseUIStroke2 = Instance.new("UIStroke")
	baseUIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	baseUIStroke2.Color = Color3.fromRGB(255, 255, 255)
	baseUIStroke2.Transparency = 0.9
	baseUIStroke2.Parent = headshot
	headshot.Parent = informationGroup

	local userAndDisplayFrame = Instance.new("Frame")
	userAndDisplayFrame.BackgroundTransparency = 1
	userAndDisplayFrame.BorderSizePixel = 0
	userAndDisplayFrame.LayoutOrder = 1
	userAndDisplayFrame.Size = UDim2.new(1, -42, 0, 32)
	userAndDisplayFrame.Parent = informationGroup

	local displayName = Instance.new("TextLabel")
	displayName.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold)
	displayName.Text = LocalPlayer.DisplayName
	displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
	displayName.TextSize = 13
	displayName.TextTransparency = 0.1
	displayName.TextTruncate = Enum.TextTruncate.SplitWord
	displayName.TextXAlignment = Enum.TextXAlignment.Left
	displayName.TextYAlignment = Enum.TextYAlignment.Top
	displayName.AutomaticSize = Enum.AutomaticSize.XY
	displayName.BackgroundTransparency = 1
	displayName.BorderSizePixel = 0
	displayName.Size = UDim2.fromScale(1, 0)
	displayName.Parent = userAndDisplayFrame

	local userAndDisplayFrameUIPadding = Instance.new("UIPadding")
	userAndDisplayFrameUIPadding.PaddingLeft = UDim.new(0, 8)
	userAndDisplayFrameUIPadding.PaddingTop = UDim.new(0, 3)
	userAndDisplayFrameUIPadding.Parent = userAndDisplayFrame

	local userAndDisplayFrameUIListLayout = Instance.new("UIListLayout")
	userAndDisplayFrameUIListLayout.Padding = UDim.new(0, 1)
	userAndDisplayFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	userAndDisplayFrameUIListLayout.Parent = userAndDisplayFrame

	local username = Instance.new("TextLabel")
	username.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold)
	username.Text = "@" .. LocalPlayer.Name
	username.TextColor3 = Color3.fromRGB(255, 255, 255)
	username.TextSize = 12
	username.TextTransparency = 0.7
	username.TextTruncate = Enum.TextTruncate.SplitWord
	username.TextXAlignment = Enum.TextXAlignment.Left
	username.TextYAlignment = Enum.TextYAlignment.Top
	username.AutomaticSize = Enum.AutomaticSize.XY
	username.BackgroundTransparency = 1
	username.BorderSizePixel = 0
	username.LayoutOrder = 1
	username.Size = UDim2.fromScale(1, 0)
	username.Parent = userAndDisplayFrame

	local userInfoUIPadding = Instance.new("UIPadding")
	userInfoUIPadding.PaddingLeft = UDim.new(0, 10)
	userInfoUIPadding.PaddingRight = UDim.new(0, 10)
	userInfoUIPadding.Parent = userInfo

	-- Scrolling frame สำหรับ category + tab switchers
	local tabSwitchers = Instance.new("Frame")
	tabSwitchers.BackgroundTransparency = 1
	tabSwitchers.BorderSizePixel = 0
	tabSwitchers.Size = UDim2.new(1, 0, 1, -107)
	tabSwitchers.Parent = sidebarGroup

	local tabSwitchersScrollingFrame = Instance.new("ScrollingFrame")
	tabSwitchersScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabSwitchersScrollingFrame.BottomImage = ""
	tabSwitchersScrollingFrame.CanvasSize = UDim2.new()
	tabSwitchersScrollingFrame.ScrollBarImageTransparency = 0.8
	tabSwitchersScrollingFrame.ScrollBarThickness = 1
	tabSwitchersScrollingFrame.TopImage = ""
	tabSwitchersScrollingFrame.BackgroundTransparency = 1
	tabSwitchersScrollingFrame.BorderSizePixel = 0
	tabSwitchersScrollingFrame.Size = UDim2.fromScale(1, 1)
	tabSwitchersScrollingFrame.Parent = tabSwitchers

	local tabSwitchersScrollingFrameUIListLayout = Instance.new("UIListLayout")
	tabSwitchersScrollingFrameUIListLayout.Padding = UDim.new(0, 4)
	tabSwitchersScrollingFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabSwitchersScrollingFrameUIListLayout.Parent = tabSwitchersScrollingFrame

	local tabSwitchersScrollingFrameUIPadding = Instance.new("UIPadding")
	tabSwitchersScrollingFrameUIPadding.PaddingTop = UDim.new(0, 8)
	tabSwitchersScrollingFrameUIPadding.PaddingLeft = UDim.new(0, 10)
	tabSwitchersScrollingFrameUIPadding.PaddingRight = UDim.new(0, 10)
	tabSwitchersScrollingFrameUIPadding.Parent = tabSwitchersScrollingFrame

	sidebar.Parent = base

	-- Content Area
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.AnchorPoint = Vector2.new(1, 0)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.Position = UDim2.fromScale(1, 0)
	content.Size = UDim2.new(0, (base.AbsoluteSize.X - sidebar.AbsoluteSize.X), 1, 0)
	content.Parent = base

	-- Sidebar resize
	local resizingContent = false
	local defaultSidebarWidth = sidebar.AbsoluteSize.X
	local initialMouseX, initialSidebarWidth
	local snapRange = 20
	local minSidebarWidth = 107
	local maxSidebarWidth = base.AbsoluteSize.X - minSidebarWidth

	dividerInteract.MouseEnter:Connect(function()
		Tween(divider, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.85 }):Play()
	end)
	dividerInteract.MouseLeave:Connect(function()
		Tween(divider, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.9 }):Play()
	end)
	dividerInteract.MouseButton1Down:Connect(function()
		resizingContent = true
		initialMouseX = UserInputService:GetMouseLocation().X
		initialSidebarWidth = sidebar.AbsoluteSize.X
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizingContent = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if resizingContent and input.UserInputType == Enum.UserInputType.MouseMovement then
			local deltaX = UserInputService:GetMouseLocation().X - initialMouseX
			local newSidebarWidth = initialSidebarWidth + deltaX
			if math.abs(newSidebarWidth - defaultSidebarWidth) < snapRange then
				newSidebarWidth = defaultSidebarWidth
			else
				newSidebarWidth = math.clamp(newSidebarWidth, minSidebarWidth, maxSidebarWidth)
			end
			sidebar.Size = UDim2.new(0, newSidebarWidth, 1, 0)
			content.Size = UDim2.new(0, base.AbsoluteSize.X - newSidebarWidth, 1, 0)
		end
	end)

	-- Topbar (content area)
	local topbar = Instance.new("Frame")
	topbar.BackgroundTransparency = 1
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(1, 0, 0, 63)
	topbar.Parent = content

	local divider4 = Instance.new("Frame")
	divider4.AnchorPoint = Vector2.new(0, 1)
	divider4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider4.BackgroundTransparency = 0.9
	divider4.BorderSizePixel = 0
	divider4.Position = UDim2.fromScale(0, 1)
	divider4.Size = UDim2.new(1, 0, 0, 1)
	divider4.Parent = topbar

	local topbarElements = Instance.new("Frame")
	topbarElements.BackgroundTransparency = 1
	topbarElements.BorderSizePixel = 0
	topbarElements.Size = UDim2.fromScale(1, 1)
	topbarElements.Parent = topbar

	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.PaddingLeft = UDim.new(0, 20)
	uIPadding2.PaddingRight = UDim.new(0, 20)
	uIPadding2.Parent = topbarElements

	local moveIcon = Instance.new("ImageButton")
	moveIcon.Image = assets.transform
	moveIcon.ImageTransparency = 0.7
	moveIcon.AnchorPoint = Vector2.new(1, 0.5)
	moveIcon.BackgroundTransparency = 1
	moveIcon.BorderSizePixel = 0
	moveIcon.Position = UDim2.fromScale(1, 0.5)
	moveIcon.Size = UDim2.fromOffset(15, 15)
	moveIcon.Parent = topbarElements
	moveIcon.Visible = not Settings.DragStyle or Settings.DragStyle == 1

	local moveInteract = Instance.new("TextButton")
	moveInteract.Text = ""
	moveInteract.BackgroundTransparency = 1
	moveInteract.BorderSizePixel = 0
	moveInteract.AnchorPoint = Vector2.new(0.5, 0.5)
	moveInteract.Position = UDim2.fromScale(0.5, 0.5)
	moveInteract.Size = UDim2.fromOffset(40, 40)
	moveInteract.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	moveInteract.TextColor3 = Color3.fromRGB(0,0,0)
	moveInteract.TextSize = 14
	moveInteract.Parent = moveIcon

	moveInteract.MouseEnter:Connect(function()
		Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.4 }):Play()
	end)
	moveInteract.MouseLeave:Connect(function()
		Tween(moveIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.7 }):Play()
	end)

	local currentTabLabel = Instance.new("TextLabel")
	currentTabLabel.FontFace = Font.new(assets.interFont)
	currentTabLabel.RichText = true
	currentTabLabel.Text = ""
	currentTabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	currentTabLabel.TextSize = 15
	currentTabLabel.TextTransparency = 0.5
	currentTabLabel.TextTruncate = Enum.TextTruncate.SplitWord
	currentTabLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentTabLabel.TextYAlignment = Enum.TextYAlignment.Top
	currentTabLabel.AnchorPoint = Vector2.new(0, 0.5)
	currentTabLabel.AutomaticSize = Enum.AutomaticSize.Y
	currentTabLabel.BackgroundTransparency = 1
	currentTabLabel.BorderSizePixel = 0
	currentTabLabel.Position = UDim2.fromScale(0, 0.5)
	currentTabLabel.Size = UDim2.fromScale(0.9, 0)
	currentTabLabel.Parent = topbarElements

	-- Drag
	local dragging_ = false
	local dragInput, dragStart, startPos

	local function updateDrag(input)
		local delta = input.Position - dragStart
		base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	local function onDragStart(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging_ = true
			dragStart = input.Position
			startPos = base.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging_ = false end
			end)
		end
	end
	if not Settings.DragStyle or Settings.DragStyle == 1 then
		moveInteract.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				onDragStart(input)
			end
		end)
		moveInteract.InputChanged:Connect(function(input)
			if dragging_ then dragInput = input end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging_ then updateDrag(input) end
		end)
	elseif Settings.DragStyle == 2 then
		base.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				onDragStart(input)
			end
		end)
		base.InputChanged:Connect(function(input)
			if dragging_ then dragInput = input end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging_ then updateDrag(input) end
		end)
	end

	-- GlobalSettings panel
	local globalSettings = Instance.new("Frame")
	globalSettings.AutomaticSize = Enum.AutomaticSize.XY
	globalSettings.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	globalSettings.BorderSizePixel = 0
	globalSettings.Position = UDim2.fromScale(0.298, 0.104)

	local globalSettingsUIStroke = Instance.new("UIStroke")
	globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	globalSettingsUIStroke.Color = Color3.fromRGB(255, 255, 255)
	globalSettingsUIStroke.Transparency = 0.9
	globalSettingsUIStroke.Parent = globalSettings

	local globalSettingsUICorner = Instance.new("UICorner")
	globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
	globalSettingsUICorner.Parent = globalSettings

	local globalSettingsUIPadding = Instance.new("UIPadding")
	globalSettingsUIPadding.PaddingBottom = UDim.new(0, 10)
	globalSettingsUIPadding.PaddingTop = UDim.new(0, 10)
	globalSettingsUIPadding.Parent = globalSettings

	local globalSettingsUIListLayout = Instance.new("UIListLayout")
	globalSettingsUIListLayout.Padding = UDim.new(0, 5)
	globalSettingsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	globalSettingsUIListLayout.Parent = globalSettings

	local globalSettingsUIScale = Instance.new("UIScale")
	globalSettingsUIScale.Scale = 1e-07
	globalSettingsUIScale.Parent = globalSettings
	globalSettings.Parent = base
	base.Parent = macLib

	-- Acrylic Blur
	local HS = HttpService
	local camera = workspace.CurrentCamera
	local MTREL = "Glass"
	local binds = {}
	local wedgeguid = HS:GenerateGUID(true)
	local DepthOfField

	for _, v in pairs(Lighting:GetChildren()) do
		if not v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
			DepthOfField = Instance.new("DepthOfFieldEffect")
			DepthOfField.FarIntensity = 0; DepthOfField.FocusDistance = 51.6
			DepthOfField.InFocusRadius = 50; DepthOfField.NearIntensity = 1
			DepthOfField.Name = HS:GenerateGUID(true); DepthOfField:AddTag(".")
		elseif v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
			DepthOfField = v
		end
	end
	if not DepthOfField then
		DepthOfField = Instance.new("DepthOfFieldEffect")
		DepthOfField.FarIntensity = 0; DepthOfField.FocusDistance = 51.6
		DepthOfField.InFocusRadius = 50; DepthOfField.NearIntensity = 1
		DepthOfField.Name = HS:GenerateGUID(true); DepthOfField:AddTag(".")
	end

	local blurFrame = Instance.new("Frame")
	blurFrame.Parent = base
	blurFrame.Size = UDim2.new(0.97, 0, 0.97, 0)
	blurFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	blurFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	blurFrame.BackgroundTransparency = 1
	blurFrame.Name = HS:GenerateGUID(true)

	do
		local function IsNotNaN(x) return x == x end
		local continue = IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x)
		while not continue do
			RunService.RenderStepped:Wait()
			continue = IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x)
		end
	end

	local DrawQuad; do
		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
		local sz = 0.2
		local function DrawTriangle(v1, v2, v3, p0, p1)
			local s1=(v1-v2).magnitude; local s2=(v2-v3).magnitude; local s3=(v3-v1).magnitude
			local smax=max(s1,s2,s3); local A,B,C
			if s1==smax then A,B,C=v1,v2,v3 elseif s2==smax then A,B,C=v2,v3,v1 else A,B,C=v3,v1,v2 end
			local para=((B-A).x*(C-A).x+(B-A).y*(C-A).y+(B-A).z*(C-A).z)/(A-B).magnitude
			local perp=sqrt((C-A).magnitude^2-para*para)
			local dif_para=(A-B).magnitude-para
			local st=CFrame.new(B,A); local za=CFrame.Angles(pi/2,0,0); local cf0=st
			local Top_Look=(cf0*za).lookVector
			local Mid_Point=A+CFrame.new(A,B).lookVector*para
			local Needed_Look=CFrame.new(Mid_Point,C).lookVector
			local dot=Top_Look.x*Needed_Look.x+Top_Look.y*Needed_Look.y+Top_Look.z*Needed_Look.z
			local ac=CFrame.Angles(0,0,acos(dot)); cf0=cf0*ac
			if((cf0*za).lookVector-Needed_Look).magnitude>0.01 then cf0=cf0*CFrame.Angles(0,0,-2*acos(dot)) end
			cf0=cf0*CFrame.new(0,perp/2,-(dif_para+para/2))
			local cf1=st*ac*CFrame.Angles(0,pi,0)
			if((cf1*za).lookVector-Needed_Look).magnitude>0.01 then cf1=cf1*CFrame.Angles(0,0,2*acos(dot)) end
			cf1=cf1*CFrame.new(0,perp/2,dif_para/2)
			if not p0 then
				p0=Instance.new("Part"); p0.FormFactor="Custom"; p0.TopSurface=0; p0.BottomSurface=0
				p0.Anchored=true; p0.CanCollide=false; p0.CastShadow=false; p0.Material=MTREL
				p0.Size=Vector3.new(sz,sz,sz); p0.Name=HS:GenerateGUID(true)
				local mesh=Instance.new("SpecialMesh",p0); mesh.MeshType=2; mesh.Name=wedgeguid
			end
			p0[wedgeguid].Scale=Vector3.new(0,perp/sz,para/sz); p0.CFrame=cf0
			if not p1 then p1=p0:clone() end
			p1[wedgeguid].Scale=Vector3.new(0,perp/sz,dif_para/sz); p1.CFrame=cf1
			return p0,p1
		end
		function DrawQuad(v1,v2,v3,v4,parts)
			parts[1],parts[2]=DrawTriangle(v1,v2,v3,parts[1],parts[2])
			parts[3],parts[4]=DrawTriangle(v3,v2,v4,parts[3],parts[4])
		end
	end

	local blurParts = {}
	local blurParents = {}
	do
		local function add(child)
			if child:IsA("GuiObject") then blurParents[#blurParents+1]=child; add(child.Parent) end
		end
		add(blurFrame)
	end

	local function IsVisible(instance)
		while instance do
			if instance:IsA("GuiObject") then if not instance.Visible then return false end
			elseif instance:IsA("ScreenGui") then if not instance.Enabled then return false end; break end
			instance = instance.Parent
		end
		return true
	end

	local function UpdateOrientation(fetchProps)
		if not IsVisible(blurFrame) or not acrylicBlur or unloaded then
			for _, pt in pairs(blurParts) do pt.Parent = nil; DepthOfField.Enabled = false; DepthOfField.Parent = nil end
			return
		end
		if not DepthOfField.Parent then DepthOfField.Parent = Lighting end
		DepthOfField.Enabled = true
		local properties = { Transparency = 0.98; BrickColor = BrickColor.new("Institutional white") }
		local zIndex = 1 - 0.05 * blurFrame.ZIndex
		local tl, br = blurFrame.AbsolutePosition, blurFrame.AbsolutePosition + blurFrame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		do
			local rot = 0
			for _, v in ipairs(blurParents) do rot = rot + v.Rotation end
			if rot ~= 0 and rot % 180 ~= 0 then
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				tl=Vector2.new(c*(tl.x-mid.x)-s*(tl.y-mid.y),s*(tl.x-mid.x)+c*(tl.y-mid.y))+mid
				tr=Vector2.new(c*(tr.x-mid.x)-s*(tr.y-mid.y),s*(tr.x-mid.x)+c*(tr.y-mid.y))+mid
				bl=Vector2.new(c*(bl.x-mid.x)-s*(bl.y-mid.y),s*(bl.x-mid.x)+c*(bl.y-mid.y))+mid
				br=Vector2.new(c*(br.x-mid.x)-s*(br.y-mid.y),s*(br.x-mid.x)+c*(br.y-mid.y))+mid
			end
		end
		DrawQuad(
			camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
			camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
			camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
			camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
			blurParts
		)
		if fetchProps then
			for _, pt in pairs(blurParts) do pt.Parent = camera end
			for propName, propValue in pairs(properties) do
				for _, pt in pairs(blurParts) do pt[propName] = propValue end
			end
		end
	end
	UpdateOrientation(true)
	RunService.RenderStepped:Connect(UpdateOrientation)

	-- =============================================
	-- WindowFunctions
	-- =============================================
	function WindowFunctions:UpdateTitle(NewTitle)    title.Text = NewTitle end
	function WindowFunctions:UpdateSubtitle(NewSub)   subtitle.Text = NewSub end

	-- GlobalSetting
	local hovering
	local gsToggled = globalSettingsUIScale.Scale == 1 and true or false
	local function toggleGS()
		if not gsToggled then
			local t = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = 1 })
			t:Play(); t.Completed:Wait(); gsToggled = true
		else
			local t = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = 0 })
			t:Play(); t.Completed:Wait(); gsToggled = false
		end
	end
	globalSettingsButton.MouseButton1Click:Connect(function()
		if not hasGlobalSetting then return end
		toggleGS()
	end)
	globalSettings.MouseEnter:Connect(function() hovering = true end)
	globalSettings.MouseLeave:Connect(function() hovering = false end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and gsToggled and not hovering then
			toggleGS()
		end
	end)

	function WindowFunctions:GlobalSetting(Settings)
		hasGlobalSetting = true
		local GSF = {}
		local gs = Instance.new("TextButton")
		gs.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		gs.Text = ""; gs.TextColor3 = Color3.fromRGB(0,0,0); gs.TextSize = 14
		gs.BackgroundTransparency = 1; gs.BorderSizePixel = 0
		gs.Size = UDim2.fromOffset(200, 30); gs.Parent = globalSettings

		local gsPad = Instance.new("UIPadding")
		gsPad.PaddingLeft = UDim.new(0, 15); gsPad.Parent = gs

		local gsName = Instance.new("TextLabel")
		gsName.FontFace = Font.new(assets.interFont)
		gsName.Text = Settings.Name; gsName.RichText = true
		gsName.TextColor3 = Color3.fromRGB(255,255,255); gsName.TextSize = 13
		gsName.TextTransparency = 0.5; gsName.TextTruncate = Enum.TextTruncate.SplitWord
		gsName.TextXAlignment = Enum.TextXAlignment.Left; gsName.TextYAlignment = Enum.TextYAlignment.Top
		gsName.AnchorPoint = Vector2.new(0,0.5); gsName.AutomaticSize = Enum.AutomaticSize.Y
		gsName.BackgroundTransparency = 1; gsName.BorderSizePixel = 0
		gsName.Position = UDim2.fromScale(0,0.5); gsName.Size = UDim2.new(1,-40,0,0)
		gsName.Parent = gs

		local gsLayout = Instance.new("UIListLayout")
		gsLayout.Padding = UDim.new(0,10); gsLayout.FillDirection = Enum.FillDirection.Horizontal
		gsLayout.SortOrder = Enum.SortOrder.LayoutOrder; gsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		gsLayout.Parent = gs

		local gsCheck = Instance.new("TextLabel")
		gsCheck.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
		gsCheck.Text = "✓"; gsCheck.TextColor3 = Color3.fromRGB(255,255,255)
		gsCheck.TextSize = 13; gsCheck.TextTransparency = 1
		gsCheck.TextXAlignment = Enum.TextXAlignment.Left; gsCheck.TextYAlignment = Enum.TextYAlignment.Top
		gsCheck.AnchorPoint = Vector2.new(0,0.5); gsCheck.AutomaticSize = Enum.AutomaticSize.Y
		gsCheck.BackgroundTransparency = 1; gsCheck.BorderSizePixel = 0
		gsCheck.LayoutOrder = -1; gsCheck.Position = UDim2.fromScale(0,0.5)
		gsCheck.Size = UDim2.fromOffset(-10,0); gsCheck.Parent = gs

		local tw = {
			dur = 0.2; sty = Enum.EasingStyle.Quint
		}
		local function Toggle(State)
			if State then
				Tween(gsCheck, TweenInfo.new(tw.dur,tw.sty), { Size = UDim2.new(0,0,12,0,0) }):Play()
				Tween(gsName, TweenInfo.new(tw.dur,tw.sty), { TextTransparency = 0.2 }):Play()
				gsCheck.TextTransparency = 0
			else
				Tween(gsCheck, TweenInfo.new(tw.dur,tw.sty), { Size = UDim2.fromOffset(-10,0) }):Play()
				Tween(gsName, TweenInfo.new(tw.dur,tw.sty), { TextTransparency = 0.5 }):Play()
				gsCheck.TextTransparency = 1
			end
		end
		local tog = Settings.Default; Toggle(tog)
		gs.MouseButton1Click:Connect(function()
			tog = not tog; Toggle(tog)
			task.spawn(function() if Settings.Callback then Settings.Callback(tog) end end)
		end)
		function GSF:UpdateName(n) gsName.Text = n end
		function GSF:UpdateState(s) Toggle(s); tog = s end
		return GSF
	end

	-- =============================================
	-- ระบบ Category ใหม่
	-- =============================================

	-- ฟังก์ชันเลือก tab
	local function SelectTab(tabSwitcher)
		local easetime = 0.15

		if currentTabInstance then
			currentTabInstance.Parent = nil
		end

		for ts, tabInfo in pairs(allTabs) do
			local isSelected = (ts == tabSwitcher)
			Tween(ts, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
				BackgroundTransparency = isSelected and 0.92 or 1
			}):Play()
			if tabInfo.tabStroke then
				Tween(tabInfo.tabStroke, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
					Transparency = isSelected and 0.88 or 1
				}):Play()
			end
			if tabInfo.switcherImage then
				Tween(tabInfo.switcherImage, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
					ImageTransparency = isSelected and 0.05 or 0.5
				}):Play()
			end
			if tabInfo.switcherName then
				Tween(tabInfo.switcherName, TweenInfo.new(easetime, Enum.EasingStyle.Sine), {
					TextTransparency = isSelected and 0.05 or 0.5
				}):Play()
			end
		end

		allTabs[tabSwitcher].tabContent.Parent = content
		currentTabInstance = allTabs[tabSwitcher].tabContent
		currentTabLabel.Text = allTabs[tabSwitcher].tabName or ""
	end

	-- สร้าง Category
	function WindowFunctions:Category(categorySettings)
		local CategoryFunctions = {}
		local catName = categorySettings.Name or ""
		local catOrder = categorySettings.Order or 99

		-- Header ชื่อหมวดหมู่
		local catFrame = Instance.new("Frame")
		catFrame.Name = "Category_" .. catName
		catFrame.BackgroundTransparency = 1
		catFrame.BorderSizePixel = 0
		catFrame.AutomaticSize = Enum.AutomaticSize.Y
		catFrame.Size = UDim2.fromScale(1, 0)
		catFrame.LayoutOrder = catOrder
		catFrame.Parent = tabSwitchersScrollingFrame

		local catLayout = Instance.new("UIListLayout")
		catLayout.Padding = UDim.new(0, 2)
		catLayout.SortOrder = Enum.SortOrder.LayoutOrder
		catLayout.Parent = catFrame

		-- Label ชื่อ Category
		local catLabel = Instance.new("TextLabel")
		catLabel.Name = "CategoryLabel"
		catLabel.FontFace = Font.new(assets.interFont, Enum.FontWeight.Bold)
		catLabel.Text = string.upper(catName)
		catLabel.RichText = true
		catLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		catLabel.TextSize = 10
		catLabel.TextTransparency = 0.55
		catLabel.TextXAlignment = Enum.TextXAlignment.Left
		catLabel.BackgroundTransparency = 1
		catLabel.BorderSizePixel = 0
		catLabel.Size = UDim2.new(1, 0, 0, 18)
		catLabel.LayoutOrder = 0

		local catLabelPad = Instance.new("UIPadding")
		catLabelPad.PaddingLeft = UDim.new(0, 6)
		catLabelPad.Parent = catLabel
		catLabel.Parent = catFrame

		-- ตัวนับ tab ใน category นี้
		local tabIndexInCat = 0

		-- สร้าง Tab ใน Category
		function CategoryFunctions:Tab(tabSettings)
			local TabFunctions = { Settings = tabSettings }
			tabIndexInCat += 1

			-- Tab switcher button
			local tabSwitcher = Instance.new("TextButton")
			tabSwitcher.Name = "TabSwitcher"
			tabSwitcher.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
			tabSwitcher.Text = ""
			tabSwitcher.TextColor3 = Color3.fromRGB(0, 0, 0)
			tabSwitcher.TextSize = 14
			tabSwitcher.AutoButtonColor = false
			tabSwitcher.AnchorPoint = Vector2.new(0.5, 0)
			tabSwitcher.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			tabSwitcher.BackgroundTransparency = 1
			tabSwitcher.BorderSizePixel = 0
			tabSwitcher.Position = UDim2.fromScale(0.5, 0)
			tabSwitcher.Size = UDim2.new(1, 0, 0, 36)
			tabSwitcher.LayoutOrder = tabIndexInCat
			tabSwitcher.Parent = catFrame

			local tabSwitcherUICorner = Instance.new("UICorner")
			tabSwitcherUICorner.CornerRadius = UDim.new(0, 7)
			tabSwitcherUICorner.Parent = tabSwitcher

			local tabSwitcherUIStroke = Instance.new("UIStroke")
			tabSwitcherUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			tabSwitcherUIStroke.Color = Color3.fromRGB(255, 255, 255)
			tabSwitcherUIStroke.Transparency = 1
			tabSwitcherUIStroke.Parent = tabSwitcher

			local tabSwitcherUIListLayout = Instance.new("UIListLayout")
			tabSwitcherUIListLayout.Padding = UDim.new(0, 9)
			tabSwitcherUIListLayout.FillDirection = Enum.FillDirection.Horizontal
			tabSwitcherUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			tabSwitcherUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			tabSwitcherUIListLayout.Parent = tabSwitcher

			local tabSwitcherUIPadding = Instance.new("UIPadding")
			tabSwitcherUIPadding.PaddingLeft = UDim.new(0, 10)
			tabSwitcherUIPadding.PaddingRight = UDim.new(0, 10)
			tabSwitcherUIPadding.Parent = tabSwitcher

			local tabImage
			if tabSettings.Image then
				tabImage = Instance.new("ImageLabel")
				tabImage.Image = tabSettings.Image
				tabImage.ImageTransparency = 0.5
				tabImage.BackgroundTransparency = 1
				tabImage.BorderSizePixel = 0
				tabImage.Size = UDim2.fromOffset(16, 16)
				tabImage.Parent = tabSwitcher
			end

			local tabSwitcherName = Instance.new("TextLabel")
			tabSwitcherName.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
			tabSwitcherName.Text = tabSettings.Name
			tabSwitcherName.RichText = true
			tabSwitcherName.TextColor3 = Color3.fromRGB(255, 255, 255)
			tabSwitcherName.TextSize = 14
			tabSwitcherName.TextTransparency = 0.5
			tabSwitcherName.TextTruncate = Enum.TextTruncate.SplitWord
			tabSwitcherName.TextXAlignment = Enum.TextXAlignment.Left
			tabSwitcherName.TextYAlignment = Enum.TextYAlignment.Top
			tabSwitcherName.AutomaticSize = Enum.AutomaticSize.Y
			tabSwitcherName.BackgroundTransparency = 1
			tabSwitcherName.BorderSizePixel = 0
			tabSwitcherName.Size = UDim2.fromScale(1, 0)
			tabSwitcherName.LayoutOrder = 1
			tabSwitcherName.Parent = tabSwitcher

			-- Content frame สำหรับ tab นี้
			local elements = Instance.new("Frame")
			elements.Name = "Elements_" .. tabSettings.Name
			elements.BackgroundTransparency = 1
			elements.BorderSizePixel = 0
			elements.Position = UDim2.fromOffset(0, 63)
			elements.Size = UDim2.new(1, 0, 1, -63)
			elements.ClipsDescendants = true

			local elementsUIPadding = Instance.new("UIPadding")
			elementsUIPadding.PaddingRight = UDim.new(0, 5)
			elementsUIPadding.PaddingTop = UDim.new(0, 10)
			elementsUIPadding.PaddingBottom = UDim.new(0, 10)
			elementsUIPadding.Parent = elements

			local elementsScrolling = Instance.new("ScrollingFrame")
			elementsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
			elementsScrolling.BottomImage = ""; elementsScrolling.TopImage = ""
			elementsScrolling.CanvasSize = UDim2.new()
			elementsScrolling.ScrollBarImageTransparency = 0.5
			elementsScrolling.ScrollBarThickness = 1
			elementsScrolling.BackgroundTransparency = 1
			elementsScrolling.BorderSizePixel = 0
			elementsScrolling.Size = UDim2.fromScale(1, 1)
			elementsScrolling.ClipsDescendants = false

			local elementsScrollingUIPadding = Instance.new("UIPadding")
			elementsScrollingUIPadding.PaddingBottom = UDim.new(0, 5)
			elementsScrollingUIPadding.PaddingLeft = UDim.new(0, 11)
			elementsScrollingUIPadding.PaddingRight = UDim.new(0, 3)
			elementsScrollingUIPadding.PaddingTop = UDim.new(0, 5)
			elementsScrollingUIPadding.Parent = elementsScrolling

			local elementsScrollingUIListLayout = Instance.new("UIListLayout")
			elementsScrollingUIListLayout.Padding = UDim.new(0, 15)
			elementsScrollingUIListLayout.FillDirection = Enum.FillDirection.Horizontal
			elementsScrollingUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			elementsScrollingUIListLayout.Parent = elementsScrolling

			local left = Instance.new("Frame")
			left.Name = "Left"
			left.AutomaticSize = Enum.AutomaticSize.Y
			left.BackgroundTransparency = 1
			left.BorderSizePixel = 0
			left.Size = UDim2.new(0.5, -10, 0, 0)

			local leftUIListLayout = Instance.new("UIListLayout")
			leftUIListLayout.Padding = UDim.new(0, 15)
			leftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			leftUIListLayout.Parent = left
			left.Parent = elementsScrolling

			local right = Instance.new("Frame")
			right.Name = "Right"
			right.AutomaticSize = Enum.AutomaticSize.Y
			right.BackgroundTransparency = 1
			right.BorderSizePixel = 0
			right.LayoutOrder = 1
			right.Size = UDim2.new(0.5, -10, 0, 0)

			local rightUIListLayout = Instance.new("UIListLayout")
			rightUIListLayout.Padding = UDim.new(0, 15)
			rightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rightUIListLayout.Parent = right
			right.Parent = elementsScrolling

			elementsScrolling.Parent = elements

			-- ลงทะเบียน tab
			allTabs[tabSwitcher] = {
				tabContent = elements,
				tabStroke = tabSwitcherUIStroke,
				switcherImage = tabImage,
				switcherName = tabSwitcherName,
				tabName = tabSettings.Name,
			}

			tabSwitcher.MouseButton1Click:Connect(function()
				SelectTab(tabSwitcher)
			end)

			function TabFunctions:Select()
				SelectTab(tabSwitcher)
			end

			-- Section creator (เหมือนเดิม)
			function TabFunctions:Section(sectionSettings)
				local SectionFunctions = {}

				local section = Instance.new("Frame")
				section.Name = "Section"
				section.AutomaticSize = Enum.AutomaticSize.Y
				section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				section.BackgroundTransparency = 0.98
				section.BorderSizePixel = 0
				section.Size = UDim2.fromScale(1, 0)
				section.ClipsDescendants = true
				section.Parent = sectionSettings.Side == "Left" and left or right

				local sectionUICorner = Instance.new("UICorner")
				sectionUICorner.Parent = section

				local sectionUIStroke = Instance.new("UIStroke")
				sectionUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				sectionUIStroke.Color = Color3.fromRGB(255, 255, 255)
				sectionUIStroke.Transparency = 0.95
				sectionUIStroke.Parent = section

				local sectionUIListLayout = Instance.new("UIListLayout")
				sectionUIListLayout.Padding = UDim.new(0, 10)
				sectionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				sectionUIListLayout.Parent = section

				local sectionUIPadding = Instance.new("UIPadding")
				sectionUIPadding.PaddingBottom = UDim.new(0, 20)
				sectionUIPadding.PaddingLeft = UDim.new(0, 20)
				sectionUIPadding.PaddingRight = UDim.new(0, 18)
				sectionUIPadding.PaddingTop = UDim.new(0, 22)
				sectionUIPadding.Parent = section

				-- ==================
				-- InfoCard (แถบแสดงข้อมูล)
				-- ==================
				function SectionFunctions:InfoCard(cardSettings)
					local card = Instance.new("Frame")
					card.Name = "InfoCard"
					card.AutomaticSize = Enum.AutomaticSize.Y
					card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					card.BackgroundTransparency = 0.94
					card.BorderSizePixel = 0
					card.Size = UDim2.fromScale(1, 0)
					card.Parent = section

					local cardCorner = Instance.new("UICorner")
					cardCorner.CornerRadius = UDim.new(0, 8)
					cardCorner.Parent = card

					local cardStroke = Instance.new("UIStroke")
					cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					cardStroke.Color = Color3.fromRGB(255, 255, 255)
					cardStroke.Transparency = 0.88
					cardStroke.Parent = card

					local cardLayout = Instance.new("UIListLayout")
					cardLayout.Padding = UDim.new(0, 4)
					cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
					cardLayout.Parent = card

					local cardPad = Instance.new("UIPadding")
					cardPad.PaddingLeft = UDim.new(0, 14)
					cardPad.PaddingRight = UDim.new(0, 14)
					cardPad.PaddingTop = UDim.new(0, 12)
					cardPad.PaddingBottom = UDim.new(0, 12)
					cardPad.Parent = card

					-- Main text
					if cardSettings.MainText then
						local mainTxt = Instance.new("TextLabel")
						mainTxt.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold)
						mainTxt.Text = cardSettings.MainText
						mainTxt.RichText = true
						mainTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
						mainTxt.TextSize = 14
						mainTxt.TextTransparency = 0.1
						mainTxt.TextWrapped = true
						mainTxt.TextXAlignment = Enum.TextXAlignment.Left
						mainTxt.AutomaticSize = Enum.AutomaticSize.Y
						mainTxt.BackgroundTransparency = 1
						mainTxt.BorderSizePixel = 0
						mainTxt.Size = UDim2.fromScale(1, 0)
						mainTxt.LayoutOrder = 0
						mainTxt.Parent = card
					end

					-- Sub text
					if cardSettings.SubText then
						local subTxt = Instance.new("TextLabel")
						subTxt.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
						subTxt.Text = cardSettings.SubText
						subTxt.RichText = true
						subTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
						subTxt.TextSize = 11
						subTxt.TextTransparency = 0.5
						subTxt.TextWrapped = true
						subTxt.TextXAlignment = Enum.TextXAlignment.Left
						subTxt.AutomaticSize = Enum.AutomaticSize.Y
						subTxt.BackgroundTransparency = 1
						subTxt.BorderSizePixel = 0
						subTxt.Size = UDim2.fromScale(1, 0)
						subTxt.LayoutOrder = 1
						subTxt.Parent = card
					end

					local InfoCardFunctions = {}
					function InfoCardFunctions:SetVisibility(State) card.Visible = State end
					return InfoCardFunctions
				end

				-- Button
				function SectionFunctions:Button(Settings, Flag)
					local BF = { Settings = Settings }
					local button = Instance.new("Frame")
					button.AutomaticSize = Enum.AutomaticSize.Y
					button.BackgroundTransparency = 1
					button.BorderSizePixel = 0
					button.Size = UDim2.new(1, 0, 0, 38)
					button.Parent = section

					local bi = Instance.new("TextButton")
					bi.FontFace = Font.new(assets.interFont)
					bi.RichText = true
					bi.TextColor3 = Color3.fromRGB(255, 255, 255)
					bi.TextSize = 13; bi.TextTransparency = 0.5
					bi.TextTruncate = Enum.TextTruncate.AtEnd
					bi.TextXAlignment = Enum.TextXAlignment.Left
					bi.BackgroundTransparency = 1; bi.BorderSizePixel = 0
					bi.Size = UDim2.fromScale(1, 1)
					bi.Parent = button; bi.Text = Settings.Name

					local bimg = Instance.new("ImageLabel")
					bimg.Image = assets.buttonImage; bimg.ImageTransparency = 0.5
					bimg.AnchorPoint = Vector2.new(1, 0.5); bimg.BackgroundTransparency = 1
					bimg.BorderSizePixel = 0; bimg.Position = UDim2.fromScale(1, 0.5)
					bimg.Size = UDim2.fromOffset(15, 15); bimg.Parent = button

					bi.MouseEnter:Connect(function()
						Tween(bi, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { TextTransparency = 0.3 }):Play()
						Tween(bimg, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.3 }):Play()
					end)
					bi.MouseLeave:Connect(function()
						Tween(bi, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { TextTransparency = 0.5 }):Play()
						Tween(bimg, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { ImageTransparency = 0.5 }):Play()
					end)
					bi.MouseButton1Click:Connect(function()
						if Settings.Callback then Settings.Callback() end
					end)
					function BF:UpdateName(n) bi.Text = n end
					function BF:SetVisibility(s) button.Visible = s end
					if Flag then MacLib.Options[Flag] = BF end
					return BF
				end

				-- Toggle
				function SectionFunctions:Toggle(Settings, Flag)
					local TF = { Settings = Settings, IgnoreConfig = false, Class = "Toggle" }
					local toggle = Instance.new("Frame")
					toggle.AutomaticSize = Enum.AutomaticSize.Y
					toggle.BackgroundTransparency = 1; toggle.BorderSizePixel = 0
					toggle.Size = UDim2.new(1, 0, 0, 38); toggle.Parent = section

					local tName = Instance.new("TextLabel")
					tName.FontFace = Font.new(assets.interFont)
					tName.Text = Settings.Name; tName.RichText = true
					tName.TextColor3 = Color3.fromRGB(255,255,255); tName.TextSize = 13
					tName.TextTransparency = 0.5; tName.TextTruncate = Enum.TextTruncate.AtEnd
					tName.TextXAlignment = Enum.TextXAlignment.Left; tName.TextYAlignment = Enum.TextYAlignment.Top
					tName.AnchorPoint = Vector2.new(0,0.5); tName.AutomaticSize = Enum.AutomaticSize.Y
					tName.BackgroundTransparency = 1; tName.BorderSizePixel = 0
					tName.Position = UDim2.fromScale(0,0.5); tName.Size = UDim2.new(1,-50,0,0)
					tName.Parent = toggle

					local tog1 = Instance.new("ImageButton")
					tog1.Image = assets.toggleBackground; tog1.ImageColor3 = Color3.fromRGB(87,86,86)
					tog1.AutoButtonColor = false; tog1.AnchorPoint = Vector2.new(1,0.5)
					tog1.BackgroundTransparency = 1; tog1.BorderSizePixel = 0
					tog1.Position = UDim2.fromScale(1,0.5); tog1.Size = UDim2.fromOffset(41,21)
					tog1.ImageTransparency = 0.5; tog1.Parent = toggle

					local togHead = Instance.new("ImageLabel")
					togHead.Image = assets.togglerHead; togHead.ImageColor3 = Color3.fromRGB(255,255,255)
					togHead.AnchorPoint = Vector2.new(1,0.5); togHead.BackgroundTransparency = 1
					togHead.BorderSizePixel = 0; togHead.Position = UDim2.fromScale(0.5,0.5)
					togHead.Size = UDim2.fromOffset(15,15); togHead.ZIndex = 2
					togHead.Parent = tog1; togHead.ImageTransparency = 0.8

					local tInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
					local togglebool = Settings.Default

					local function NewState(State, callback)
						local t1 = State and 0 or 0.5
						local t2 = State and 0 or 0.85
						local pos = State and UDim2.new(1,0,0.5,0) or UDim2.new(0.5,0,0.5,0)
						Tween(tog1, tInfo, { ImageTransparency = t1 }):Play()
						Tween(togHead, tInfo, { ImageTransparency = t2 }):Play()
						Tween(togHead, tInfo, { Position = pos }):Play()
						TF.State = State
						if callback then callback(togglebool) end
					end
					NewState(togglebool)

					local function Toggle()
						togglebool = not togglebool
						NewState(togglebool, Settings.Callback)
					end
					tog1.MouseButton1Click:Connect(Toggle)
					function TF:Toggle() Toggle() end
					function TF:UpdateState(s) togglebool = s; NewState(s, Settings.Callback) end
					function TF:GetState() return togglebool end
					function TF:UpdateName(n) tName.Text = n end
					function TF:SetVisibility(s) toggle.Visible = s end
					if Flag then MacLib.Options[Flag] = TF end
					return TF
				end

				-- Slider
				function SectionFunctions:Slider(Settings, Flag)
					local SF = { Settings = Settings, IgnoreConfig = false, Class = "Slider" }
					local slider = Instance.new("Frame")
					slider.AutomaticSize = Enum.AutomaticSize.Y
					slider.BackgroundTransparency = 1; slider.BorderSizePixel = 0
					slider.Size = UDim2.new(1, 0, 0, 38); slider.Parent = section

					local sName = Instance.new("TextLabel")
					sName.FontFace = Font.new(assets.interFont)
					sName.Text = Settings.Name; sName.RichText = true
					sName.TextColor3 = Color3.fromRGB(255,255,255); sName.TextSize = 13
					sName.TextTransparency = 0.5; sName.TextTruncate = Enum.TextTruncate.AtEnd
					sName.TextXAlignment = Enum.TextXAlignment.Left; sName.TextYAlignment = Enum.TextYAlignment.Top
					sName.AnchorPoint = Vector2.new(0,0.5); sName.AutomaticSize = Enum.AutomaticSize.XY
					sName.BackgroundTransparency = 1; sName.BorderSizePixel = 0
					sName.Position = UDim2.fromScale(0,0.5); sName.Parent = slider

					local sElems = Instance.new("Frame")
					sElems.AnchorPoint = Vector2.new(1,0); sElems.BackgroundTransparency = 1
					sElems.BorderSizePixel = 0; sElems.Position = UDim2.fromScale(1,0)
					sElems.Size = UDim2.fromScale(1,1); sElems.Parent = slider

					local sVal = Instance.new("TextBox")
					sVal.FontFace = Font.new(assets.interFont)
					sVal.TextColor3 = Color3.fromRGB(255,255,255); sVal.TextSize = 12
					sVal.TextTransparency = 0.1; sVal.BackgroundTransparency = 0.95
					sVal.BorderSizePixel = 0; sVal.LayoutOrder = 1
					sVal.Position = UDim2.fromScale(-0.0789,0.171)
					sVal.Size = UDim2.fromOffset(41,21); sVal.ClipsDescendants = true
					local sValC = Instance.new("UICorner"); sValC.CornerRadius = UDim.new(0,4); sValC.Parent = sVal
					local sValS = Instance.new("UIStroke"); sValS.Color = Color3.fromRGB(255,255,255)
					sValS.Transparency = 0.9; sValS.Parent = sVal
					sVal.Parent = sElems

					local sElemsLayout = Instance.new("UIListLayout")
					sElemsLayout.Padding = UDim.new(0,20); sElemsLayout.FillDirection = Enum.FillDirection.Horizontal
					sElemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
					sElemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
					sElemsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					sElemsLayout.Parent = sElems

					local sBar = Instance.new("ImageLabel")
					sBar.Image = assets.sliderbar; sBar.ImageColor3 = Color3.fromRGB(87,86,86)
					sBar.BackgroundTransparency = 1; sBar.BorderSizePixel = 0
					sBar.Size = UDim2.fromOffset(123,3); sBar.Parent = sElems

					local sHead = Instance.new("ImageButton")
					sHead.Image = assets.sliderhead; sHead.AnchorPoint = Vector2.new(0.5,0.5)
					sHead.BackgroundTransparency = 1; sHead.BorderSizePixel = 0
					sHead.Position = UDim2.fromScale(1,0.5); sHead.Size = UDim2.fromOffset(12,12)
					sHead.Parent = sBar

					local dragging = false
					local finalValue

					local DisplayMethods = {
						Round = function(v, p) return p and string.format("%."..p.."f", v) or tostring(math.round(v)) end,
						Percent = function(v, p)
							local pct = (v - Settings.Minimum) / (Settings.Maximum - Settings.Minimum) * 100
							return (p and string.format("%."..p.."f", pct) or tostring(math.round(pct))) .. "%"
						end,
						Value = function(v, p) return p and string.format("%."..p.."f", v) or tostring(v) end
					}
					local VDM = DisplayMethods[Settings.DisplayMethod] or DisplayMethods.Value

					local function SetValue(val, ignorecb)
						local posXScale
						if typeof(val) == "Instance" then
							posXScale = math.clamp((val.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
						else
							posXScale = (val - Settings.Minimum) / (Settings.Maximum - Settings.Minimum)
						end
						sHead.Position = UDim2.new(posXScale,0,0.5,0)
						finalValue = posXScale * (Settings.Maximum - Settings.Minimum) + Settings.Minimum
						sVal.Text = (Settings.Prefix or "") .. VDM(finalValue, Settings.Precision) .. (Settings.Suffix or "")
						if not ignorecb then
							task.spawn(function() if Settings.Callback then Settings.Callback(finalValue) end end)
						end
						SF.Value = finalValue
					end
					SetValue(Settings.Default, true)
					sHead.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							dragging = true; SetValue(i)
						end
					end)
					sHead.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							dragging = false
							if Settings.onInputComplete then Settings.onInputComplete(finalValue) end
						end
					end)
					UserInputService.InputChanged:Connect(function(i)
						if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
							SetValue(i)
						end
					end)
					function SF:UpdateValue(v) SetValue(tonumber(v), true) end
					function SF:GetValue() return finalValue end
					function SF:SetVisibility(s) slider.Visible = s end
					if Flag then MacLib.Options[Flag] = SF end
					return SF
				end

				-- Label
				function SectionFunctions:Label(Settings, Flag)
					local LF = { Settings = Settings }
					local label = Instance.new("Frame")
					label.AutomaticSize = Enum.AutomaticSize.Y
					label.BackgroundTransparency = 1; label.BorderSizePixel = 0
					label.Size = UDim2.new(1,0,0,38); label.Parent = section

					local lTxt = Instance.new("TextLabel")
					lTxt.FontFace = Font.new(assets.interFont)
					lTxt.RichText = true
					lTxt.Text = Settings.Text or Settings.Name
					lTxt.TextColor3 = Color3.fromRGB(255,255,255); lTxt.TextSize = 13
					lTxt.TextTransparency = 0.5; lTxt.TextWrapped = true
					lTxt.TextXAlignment = Enum.TextXAlignment.Left
					lTxt.AutomaticSize = Enum.AutomaticSize.Y
					lTxt.BackgroundTransparency = 1; lTxt.BorderSizePixel = 0
					lTxt.Size = UDim2.fromScale(1,1); lTxt.Parent = label

					function LF:UpdateName(n) lTxt.Text = n end
					function LF:SetVisibility(s) label.Visible = s end
					if Flag then MacLib.Options[Flag] = LF end
					return LF
				end

				-- Paragraph
				function SectionFunctions:Paragraph(Settings, Flag)
					local PF = { Settings = Settings }
					local para = Instance.new("Frame")
					para.AutomaticSize = Enum.AutomaticSize.Y
					para.BackgroundTransparency = 1; para.BorderSizePixel = 0
					para.Size = UDim2.new(1,0,0,38); para.Parent = section

					local pHead = Instance.new("TextLabel")
					pHead.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
					pHead.RichText = true; pHead.Text = Settings.Header
					pHead.TextColor3 = Color3.fromRGB(255,255,255); pHead.TextSize = 15
					pHead.TextTransparency = 0.4; pHead.TextWrapped = true
					pHead.TextXAlignment = Enum.TextXAlignment.Left
					pHead.AutomaticSize = Enum.AutomaticSize.Y
					pHead.BackgroundTransparency = 1; pHead.BorderSizePixel = 0
					pHead.Size = UDim2.fromScale(1,0); pHead.Parent = para

					local pLayout = Instance.new("UIListLayout")
					pLayout.Padding = UDim.new(0,5); pLayout.SortOrder = Enum.SortOrder.LayoutOrder
					pLayout.Parent = para

					local pBody = Instance.new("TextLabel")
					pBody.FontFace = Font.new(assets.interFont)
					pBody.RichText = true; pBody.Text = Settings.Body
					pBody.TextColor3 = Color3.fromRGB(255,255,255); pBody.TextSize = 13
					pBody.TextTransparency = 0.5; pBody.TextWrapped = true
					pBody.TextXAlignment = Enum.TextXAlignment.Left
					pBody.AutomaticSize = Enum.AutomaticSize.Y
					pBody.BackgroundTransparency = 1; pBody.BorderSizePixel = 0
					pBody.LayoutOrder = 1; pBody.Size = UDim2.fromScale(1,0); pBody.Parent = para

					function PF:UpdateHeader(n) pHead.Text = n end
					function PF:UpdateBody(n) pBody.Text = n end
					function PF:SetVisibility(s) para.Visible = s end
					if Flag then MacLib.Options[Flag] = PF end
					return PF
				end

				-- Divider
				function SectionFunctions:Divider()
					local DF = {}
					local div = Instance.new("Frame")
					div.AutomaticSize = Enum.AutomaticSize.Y
					div.BackgroundTransparency = 1; div.BorderSizePixel = 0
					div.Size = UDim2.new(1,0,0,1); div.Parent = section

					local divPad = Instance.new("UIPadding")
					divPad.PaddingBottom = UDim.new(0,8); divPad.PaddingTop = UDim.new(0,8)
					divPad.Parent = div

					local divLayout = Instance.new("UIListLayout")
					divLayout.SortOrder = Enum.SortOrder.LayoutOrder; divLayout.Parent = div

					local line = Instance.new("Frame")
					line.BackgroundColor3 = Color3.fromRGB(255,255,255)
					line.BackgroundTransparency = 0.9; line.BorderSizePixel = 0
					line.Size = UDim2.new(1,0,0,1); line.Parent = div

					function DF:Remove() div:Destroy() end
					function DF:SetVisibility(s) div.Visible = s end
					return DF
				end

				return SectionFunctions
			end

			return TabFunctions
		end

		return CategoryFunctions
	end

	-- Notifications
	function WindowFunctions:Notify(Settings)
		local NF = {}
		local notif = Instance.new("Frame")
		notif.AnchorPoint = Vector2.new(0.5,0.5)
		notif.AutomaticSize = Enum.AutomaticSize.Y
		notif.BackgroundColor3 = Color3.fromRGB(15,15,15)
		notif.BorderSizePixel = 0
		notif.Position = UDim2.fromScale(0.5,0.5)
		notif.Size = UDim2.fromOffset(Settings.SizeX or 250, 0)
		notif.Parent = notifications

		local nStroke = Instance.new("UIStroke")
		nStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		nStroke.Color = Color3.fromRGB(255,255,255); nStroke.Transparency = 0.9
		nStroke.Parent = notif

		local nCorner = Instance.new("UICorner")
		nCorner.CornerRadius = UDim.new(0,10); nCorner.Parent = notif

		local nScale = Instance.new("UIScale")
		nScale.Scale = 0; nScale.Parent = notif

		local nInfo = Instance.new("Frame")
		nInfo.AutomaticSize = Enum.AutomaticSize.Y
		nInfo.BackgroundTransparency = 1; nInfo.BorderSizePixel = 0
		nInfo.Size = UDim2.fromScale(1,1); nInfo.Parent = notif

		local nTitle = Instance.new("TextLabel")
		nTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold)
		nTitle.RichText = true; nTitle.Text = Settings.Title
		nTitle.TextColor3 = Color3.fromRGB(255,255,255); nTitle.TextSize = 13
		nTitle.TextTransparency = 0.2; nTitle.TextTruncate = Enum.TextTruncate.SplitWord
		nTitle.TextXAlignment = Enum.TextXAlignment.Left; nTitle.TextYAlignment = Enum.TextYAlignment.Top
		nTitle.AutomaticSize = Enum.AutomaticSize.XY; nTitle.BackgroundTransparency = 1
		nTitle.BorderSizePixel = 0; nTitle.Size = UDim2.new(1,-12,0,0)
		nTitle.Parent = nInfo

		local nDesc = Instance.new("TextLabel")
		nDesc.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
		nDesc.Text = Settings.Description
		nDesc.TextColor3 = Color3.fromRGB(255,255,255); nDesc.TextSize = 11
		nDesc.TextTransparency = 0.5; nDesc.TextWrapped = true; nDesc.RichText = true
		nDesc.TextXAlignment = Enum.TextXAlignment.Left; nDesc.TextYAlignment = Enum.TextYAlignment.Top
		nDesc.AutomaticSize = Enum.AutomaticSize.XY; nDesc.BackgroundTransparency = 1
		nDesc.BorderSizePixel = 0; nDesc.Size = UDim2.new(1,-12,0,0)

		local nDescPad = Instance.new("UIPadding")
		nDescPad.PaddingRight = UDim.new(0,25); nDescPad.PaddingTop = UDim.new(0,17)
		nDescPad.Parent = nDesc; nDesc.Parent = nInfo

		local nPad = Instance.new("UIPadding")
		nPad.PaddingBottom = UDim.new(0,12); nPad.PaddingLeft = UDim.new(0,10)
		nPad.PaddingRight = UDim.new(0,10); nPad.PaddingTop = UDim.new(0,10)
		nPad.Parent = nInfo

		local tweens = {
			In = Tween(nScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = Settings.Scale or 1 }),
			Out = Tween(nScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Scale = 0 }),
		}

		local AnimateNotification = task.spawn(function()
			tweens.In:Play()
			Settings.Lifetime = Settings.Lifetime or 3
			if Settings.Lifetime ~= 0 then
				task.wait(Settings.Lifetime)
				tweens.Out:Play(); tweens.Out.Completed:Wait()
				notif:Destroy()
			end
		end)

		function NF:Cancel()
			task.cancel(AnimateNotification)
			tweens.Out:Play(); tweens.Out.Completed:Wait()
			notif:Destroy()
		end
		function NF:UpdateTitle(n) nTitle.Text = n end
		function NF:UpdateDescription(n) nDesc.Text = n end
		return NF
	end

	-- Dialog
	function WindowFunctions:Dialog(Settings)
		local DF = {}
		local dCanvas = Instance.new("CanvasGroup")
		dCanvas.BackgroundTransparency = 1; dCanvas.BorderSizePixel = 0
		dCanvas.Size = UDim2.fromScale(1,1); dCanvas.GroupTransparency = 1
		dCanvas.Parent = base

		local dialog = Instance.new("Frame")
		dialog.BackgroundColor3 = Color3.fromRGB(0,0,0); dialog.BackgroundTransparency = 0.5
		dialog.BorderSizePixel = 0; dialog.Size = UDim2.fromScale(1,1)
		local dCorner = Instance.new("UICorner"); dCorner.CornerRadius = UDim.new(0,10); dCorner.Parent = dialog

		local prompt = Instance.new("Frame")
		prompt.AnchorPoint = Vector2.new(0.5,0.5); prompt.AutomaticSize = Enum.AutomaticSize.Y
		prompt.BackgroundColor3 = Color3.fromRGB(15,15,15); prompt.BorderSizePixel = 0
		prompt.Position = UDim2.fromScale(0.5,0.5); prompt.Size = UDim2.fromOffset(280,0)

		local pScale = Instance.new("UIScale"); pScale.Scale = 0.95; pScale.Parent = prompt
		local pStroke = Instance.new("UIStroke"); pStroke.Color = Color3.fromRGB(255,255,255)
		pStroke.Transparency = 0.9; pStroke.Parent = prompt
		local pCorner = Instance.new("UICorner"); pCorner.CornerRadius = UDim.new(0,10); pCorner.Parent = prompt
		local pPad = Instance.new("UIPadding")
		pPad.PaddingBottom = UDim.new(0,20); pPad.PaddingLeft = UDim.new(0,20)
		pPad.PaddingRight = UDim.new(0,20); pPad.PaddingTop = UDim.new(0,20)
		pPad.Parent = prompt

		local pHead = Instance.new("TextLabel")
		pHead.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
		pHead.RichText = true; pHead.Text = Settings.Title
		pHead.TextColor3 = Color3.fromRGB(255,255,255); pHead.TextSize = 18
		pHead.TextTransparency = 0.4; pHead.TextWrapped = true
		pHead.AutomaticSize = Enum.AutomaticSize.Y; pHead.BackgroundTransparency = 1
		pHead.BorderSizePixel = 0; pHead.Size = UDim2.fromScale(1,0); pHead.Parent = prompt

		local pLayout = Instance.new("UIListLayout")
		pLayout.Padding = UDim.new(0,15); pLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pLayout.Parent = prompt

		local pBody = Instance.new("TextLabel")
		pBody.FontFace = Font.new(assets.interFont)
		pBody.RichText = true; pBody.Text = Settings.Description
		pBody.TextColor3 = Color3.fromRGB(255,255,255); pBody.TextSize = 14
		pBody.TextTransparency = 0.5; pBody.TextWrapped = true
		pBody.AutomaticSize = Enum.AutomaticSize.Y; pBody.BackgroundTransparency = 1
		pBody.BorderSizePixel = 0; pBody.LayoutOrder = 1; pBody.Size = UDim2.fromScale(1,0)
		pBody.Parent = prompt

		local interactions = Instance.new("Frame")
		interactions.AutomaticSize = Enum.AutomaticSize.Y; interactions.BackgroundTransparency = 1
		interactions.BorderSizePixel = 0; interactions.LayoutOrder = 2; interactions.Size = UDim2.fromScale(1,0)
		local iLayout = Instance.new("UIListLayout")
		iLayout.Padding = UDim.new(0,10); iLayout.SortOrder = Enum.SortOrder.LayoutOrder; iLayout.Parent = interactions
		local iPad = Instance.new("UIPadding"); iPad.PaddingTop = UDim.new(0,20); iPad.Parent = interactions
		interactions.Parent = prompt

		local pLayout2 = Instance.new("UIListLayout")
		pLayout2.SortOrder = Enum.SortOrder.LayoutOrder; pLayout2.Parent = prompt

		prompt.Parent = dialog; dialog.Parent = dCanvas

		local cIn = Tween(dCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 0 })
		local cOut = Tween(dCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 1 })
		local sIn = Tween(pScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 1 })
		local sOut = Tween(pScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 0.95 })

		local function dialogIn()
			cIn:Play(); sIn:Play(); cIn.Completed:Wait(); dialog.Parent = base
		end
		local function dialogOut()
			if not dialog.Parent then return end
			dialog.Parent = dCanvas; cOut:Play(); sOut:Play()
			cOut.Completed:Wait(); dCanvas:Destroy()
		end

		for _, v in pairs(Settings.Buttons) do
			local btn = Instance.new("TextButton")
			btn.FontFace = Font.new(assets.interFont)
			btn.Text = v.Name; btn.TextColor3 = Color3.fromRGB(255,255,255)
			btn.TextSize = 15; btn.TextTransparency = 0.5
			btn.AutoButtonColor = false; btn.AutomaticSize = Enum.AutomaticSize.Y
			btn.BackgroundColor3 = Color3.fromRGB(25,25,25); btn.BorderSizePixel = 0
			btn.Size = UDim2.fromScale(1,0); btn.Parent = interactions

			local bPad = Instance.new("UIPadding")
			bPad.PaddingBottom = UDim.new(0,9); bPad.PaddingLeft = UDim.new(0,10)
			bPad.PaddingRight = UDim.new(0,10); bPad.PaddingTop = UDim.new(0,9); bPad.Parent = btn

			local bCorner = Instance.new("UICorner"); bCorner.CornerRadius = UDim.new(0,10); bCorner.Parent = btn

			btn.MouseEnter:Connect(function()
				Tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.3, TextTransparency = 0.6 }):Play()
			end)
			btn.MouseLeave:Connect(function()
				Tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { BackgroundTransparency = 0, TextTransparency = 0.5 }):Play()
			end)
			btn.MouseButton1Click:Connect(function()
				if dCanvas.GroupTransparency ~= 0 then return end
				if v.Callback then v.Callback() end
				dialogOut()
			end)
		end

		dialogIn()
		function DF:UpdateTitle(n) pHead.Text = n end
		function DF:UpdateDescription(n) pBody.Text = n end
		function DF:Cancel() dialogOut() end
		return DF
	end

	-- State functions
	function WindowFunctions:SetNotificationsState(s) notifications.Visible = s end
	function WindowFunctions:GetNotificationsState() return notifications.Visible end
	function WindowFunctions:SetState(s) windowState = s; base.Visible = s end
	function WindowFunctions:GetState() return windowState end

	local onUnloadCallback
	function WindowFunctions:Unload()
		if onUnloadCallback then onUnloadCallback() end
		macLib:Destroy(); unloaded = true
	end
	function WindowFunctions.onUnloaded(cb) onUnloadCallback = cb end

	function WindowFunctions:SetAcrylicBlurState(s)
		acrylicBlur = s; base.BackgroundTransparency = s and 0.05 or 0
	end
	function WindowFunctions:GetAcrylicBlurState() return acrylicBlur end

	-- User info
	local function _SetUserInfoState(State)
		if State then
			headshot.Image = (isReady and headshotImage) or "rbxassetid://0"
			username.Text = "@" .. LocalPlayer.Name
			displayName.Text = LocalPlayer.DisplayName
		else
			headshot.Image = assets.userInfoBlurred
			username.Text = "@" .. string.rep(".", #LocalPlayer.Name)
			displayName.Text = string.rep(".", #LocalPlayer.DisplayName)
		end
	end
	local showUserInfo = Settings.ShowUserInfo ~= nil and Settings.ShowUserInfo or true
	_SetUserInfoState(showUserInfo)
	function WindowFunctions:SetUserInfoState(s) _SetUserInfoState(s) end
	function WindowFunctions:GetUserInfoState() return showUserInfo end

	function WindowFunctions:SetSize(s) base.Size = s end
	function WindowFunctions:GetSize() return base.Size end
	function WindowFunctions:SetScale(s) baseUIScale.Scale = s end
	function WindowFunctions:GetScale() return baseUIScale.Scale end

	-- Menu keybind
	local MenuKeybind = Settings.Keybind or Enum.KeyCode.RightControl
	local function ToggleMenu()
		local state = not WindowFunctions:GetState()
		WindowFunctions:SetState(state)
		WindowFunctions:Notify({
			Title = Settings.Title,
			Description = (state and "Maximized " or "Minimized ") .. "the menu. Use " .. tostring(MenuKeybind.Name) .. " to toggle it.",
			Lifetime = 5
		})
	end

	UserInputService.InputEnded:Connect(function(inp, gpe)
		if gpe then return end
		if inp.KeyCode == MenuKeybind then ToggleMenu() end
	end)
	minimizeDot.MouseButton1Click:Connect(ToggleMenu)
	exitDot.MouseButton1Click:Connect(function()
		WindowFunctions:Dialog({
			Title = Settings.Title,
			Description = "Are you sure you want to exit the menu?",
			Buttons = {
				{ Name = "Confirm", Callback = function() WindowFunctions:Unload() end },
				{ Name = "Cancel" }
			}
		})
	end)

	function WindowFunctions:SetKeybind(k) MenuKeybind = k end

	-- Config system (ย่อเอาจาก original)
	local ClassParser = {
		["Toggle"] = {
			Save = function(Flag, data) return { type="Toggle", flag=Flag, state=data.State or false } end,
			Load = function(Flag, data)
				if MacLib.Options[Flag] and data.state then MacLib.Options[Flag]:UpdateState(data.state) end
			end
		},
		["Slider"] = {
			Save = function(Flag, data) return { type="Slider", flag=Flag, value=data.Value and tostring(data.Value) or false } end,
			Load = function(Flag, data)
				if MacLib.Options[Flag] and data.value then MacLib.Options[Flag]:UpdateValue(data.value) end
			end
		},
	}

	local function BuildFolderTree()
		if isStudio or not (isfolder and makefolder) then return end
		local paths = { MacLib.Folder, MacLib.Folder.."/settings" }
		for _, p in ipairs(paths) do if not isfolder(p) then makefolder(p) end end
	end

	function MacLib:SetFolder(Folder)
		MacLib.Folder = Folder; BuildFolderTree()
	end

	function MacLib:SaveConfig(Path)
		if isStudio or not writefile then return false, "Unavailable" end
		if not Path then return false, "No path" end
		local data = { objects = {} }
		for flag, option in next, MacLib.Options do
			if ClassParser[option.Class] and not option.IgnoreConfig then
				table.insert(data.objects, ClassParser[option.Class].Save(flag, option))
			end
		end
		local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
		if not ok then return false, "JSON encode failed" end
		writefile(MacLib.Folder.."/settings/"..Path..".json", enc)
		return true
	end

	function MacLib:LoadConfig(Path)
		if isStudio or not (isfile and readfile) then return false, "Unavailable" end
		if not Path then return false, "No path" end
		local file = MacLib.Folder.."/settings/"..Path..".json"
		if not isfile(file) then return false, "File not found" end
		local ok, dec = pcall(HttpService.JSONDecode, HttpService, readfile(file))
		if not ok then return false, "JSON decode failed" end
		for _, option in next, dec.objects do
			if ClassParser[option.type] then
				task.spawn(function() ClassParser[option.type].Load(option.flag, option) end)
			end
		end
		return true
	end

	function MacLib:LoadAutoLoadConfig()
		if isStudio or not (isfile and readfile) then return end
		if isfile(MacLib.Folder.."/settings/autoload.txt") then
			local name = readfile(MacLib.Folder.."/settings/autoload.txt")
			local suc, err = MacLib:LoadConfig(name)
			if not suc then
				WindowFunctions:Notify({ Title="Interface", Description="Error loading autoload: "..err })
			else
				WindowFunctions:Notify({ Title="Interface", Description=string.format("Autoloaded: %q", name) })
			end
		end
	end

	-- Preload assets
	macLib.Enabled = false
	local assetList = {}
	for _, id in pairs(assets) do table.insert(assetList, id) end
	ContentProvider:PreloadAsync(assetList)
	macLib.Enabled = true
	windowState = true

	return WindowFunctions
end

-- =============================================
-- Demo สำหรับทดสอบโครงสร้างใหม่
-- =============================================
function MacLib:Demo()
	local Window = MacLib:Window({
		Title = "Thanathip x Dev",
		Subtitle = "บริการรับเขียนสคริปต์คุณภาพสูง ราคาถูก",
		Size = UDim2.fromOffset(868, 650),
		DragStyle = 1,
		ShowUserInfo = true,
		Keybind = Enum.KeyCode.RightControl,
		AcrylicBlur = true,
	})

	-- หมวดหมู่ 1 : HOME
	local homeCategory = Window:Category({ Name = "HOME", Order = 1 })

	-- หัวข้อ 1 : Home
	local homeTab = homeCategory:Tab({
		Name = "Home",
		Image = "rbxassetid://10002460780"  -- house icon
	})

	-- Section ฝั่งซ้าย
	local homeSection = homeTab:Section({ Side = "Left" })

	-- แถบแสดงข้อมูล (InfoCard)
	homeSection:InfoCard({
		MainText = "กำลังมองหาค่ายเขียนสคริปต์รึป่าว?",
		SubText = "ติดต่อไปที่นี่สิ่  Facebook : Thanathip Lamlert",
	})

	homeTab:Select()

	Window.onUnloaded(function()
		print("Unloaded!")
	end)
end

return MacLib
