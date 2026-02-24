local weaponSkins = {
    ["Bow"] = {"Compound Bow", "Raven Bow"},
    ["Assault Rifle"] = {"AK-47", "AUG"},
    ["Chainsaw"] = {"Blobsaw", "Handsaws"},
    ["RPG"] = {"Nuke Launcher", "RPKEY", "Spaceship Launcher"},
    ["Burst Rifle"] = {"Aqua Burst", "Electro Rifle"},
    ["Exogun"] = {"Singularity", "Wondergun"},
    ["Fists"] = {"Boxing Gloves", "Brass Knuckles"},
    ["Flamethrower"] = {"Lamethrower", "Pixel Flamethrower"},
    ["Flare Gun"] = {"Dynamite Gun", "Firework Gun"},
    ["Freeze Ray"] = {"Bubble Ray", "Temporal Ray"},
    ["Grenade"] = {"Water Balloon", "Whoopee Cushion"},
    ["Grenade Launcher"] = {"Swashbuckler", "Uranium Launcher"},
    ["Handgun"] = {"Blaster"},
    ["Katana"] = {"Lightning Bolt", "Saber"},
    ["Minigun"] = {"Lasergun 3000", "Pixel Minigun"},
    ["Paintball Gun"] = {"Boba Gun", "Slime Gun"},
    ["Revolver"] = {"Sheriff"},
    ["Slingshot"] = {"Goalpost", "Stick"},
    ["Subspace Tripmine"] = {"Don't Press", "Spring"},
    ["Uzi"] = {"Electro Uzi", "Water Uzi"},
    ["Sniper"] = {"Pixel Sniper", "Hyper Sniper"},
    ["Knife"] = {"Karambit", "Chancla"},
}

local activeWeapons = {}
local playerName = game:GetService("Players").LocalPlayer.Name
local assetFolder = game:GetService("Players").LocalPlayer.PlayerScripts.Assets.ViewModels
local Functions = {}

function Functions:swapWeaponSkins(normalWeaponName, skinName, State)
    if not normalWeaponName then return end
    
    local normalWeapon = assetFolder:FindFirstChild(normalWeaponName)
    if not normalWeapon then return end

    if State then
        if skinName then
            local skin = assetFolder:FindFirstChild(skinName)
            if not skin then return end

            normalWeapon:ClearAllChildren()
            for _, child in pairs(skin:GetChildren()) do
                local newChild = child:Clone()
                newChild.Parent = normalWeapon
            end
            activeWeapons[normalWeaponName] = true
        end
    else
        activeWeapons[normalWeaponName] = nil
    end
end

local mainapi = {
	Tabs = {};
	Keybind = {'RightShift','RightControl'};
    Font = Enum.Font.BuilderSans;
	Loaded = false;
	Modules = {};
    Catalogs = {};
    Libraries = {};
    Binds = {};
	Place = game.PlaceId;
    ThreadFix = setthreadidentity and true or false;
	Scale = {Value = 1};
    GradientKeypoints = 5;
    TargetHudFrame = Instance.new("Frame");
    MainScreenGui = Instance.new('ScreenGui');
    ClickGuiStatus = false;
}

local cloneref = cloneref or function(obj) return obj end
local UserInputService = cloneref(game:GetService('UserInputService'))
local TextChatService = cloneref(game:GetService("TextChatService"))
local TweenService = cloneref(game:GetService('TweenService'))
local TextService = cloneref(game:GetService('TextService'))
local GuiService = cloneref(game:GetService('GuiService'))
local RunService = cloneref(game:GetService('RunService'))
local HttpService = cloneref(game:GetService('HttpService'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Players = cloneref(game:GetService('Players'))
local LocalPlayer = Players.LocalPlayer
local fontsize = Instance.new('GetTextBoundsParams')
fontsize.Width = math.huge

local run = function(func) func() end

local getfontsize = function(text, size, font)
	fontsize.Text = text
	fontsize.Size = size
	if typeof(font) == 'Font' then fontsize.Font = font end
	return TextService:GetTextBoundsAsync(fontsize)
end

local function getTableSize(tab)
	local ind = 0
	for _ in tab do ind += 1 end
	return ind
end

local function removeTags(str)
	str = str:gsub('<br%s*/>', '\n')
	return (str:gsub('<[^<>]->', ''))
end

local function addMaid(object)
	object.Connections = {}
	function object:Clean(callback)
		if typeof(callback) == 'Instance' then
			table.insert(self.Connections, {Disconnect = function() callback:ClearAllChildren() callback:Destroy() end})
		elseif type(callback) == 'function' then
			table.insert(self.Connections, {Disconnect = callback})
		else
			table.insert(self.Connections, callback)
		end
	end
end

addMaid(mainapi)

local function makeDraggable(obj, window)
	obj.InputBegan:Connect(function(inputObj)
		if not mainapi.ClickGuiStatus then return end
		if (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch) and (inputObj.Position.Y - obj.AbsolutePosition.Y < 40 or window) then
			local dragPosition = Vector2.new(obj.AbsolutePosition.X - inputObj.Position.X, obj.AbsolutePosition.Y - inputObj.Position.Y + GuiService:GetGuiInset().Y) / mainapi.Scale.Value
			local changed = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position = input.Position
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end
					obj.Position = UDim2.fromOffset((position.X / mainapi.Scale.Value) + dragPosition.X, (position.Y / mainapi.Scale.Value) + dragPosition.Y)
				end
			end)
			local ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then changed:Disconnect() end
					if ended then ended:Disconnect() end
				end
			end)
		end
	end)
end

local function addCorner(parent, radius)
	local corner = Instance.new('UICorner')
	corner.CornerRadius = radius or UDim.new(0, 5)
	corner.Parent = parent
	return corner
end

local function addBlur(parent)
	local blur = Instance.new('ImageLabel')
	blur.Name = 'Blur'
	blur.Size = UDim2.new(1, 89, 1, 52)
	blur.Position = UDim2.fromOffset(-48, -31)
	blur.BackgroundTransparency = 1
	blur.Image = "rbxassetid://74663567791967"
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(52, 31, 261, 502)
    blur.ZIndex = -100
	blur.Parent = parent
	return blur
end

local function loopClean(tab)
	for i, v in tab do
		if type(v) == 'table' then loopClean(v) end
		tab[i] = nil
	end
end

local function loadJson(path)
	local suc, res = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	return suc and type(res) == 'table' and res or nil
end

local uipallet = {
    MainColor = Color3.fromRGB(0, 0, 0);
    SecondaryColor = Color3.fromRGB(255, 255, 255);
}

local function getBlendFactor(vec)
    return math.sin(DateTime.now().UnixTimestampMillis / 600 + vec.X * 0.005 + vec.Y * 0.06) * 0.5 + 0.5
end

function mainapi:GetColor(vec)
    local blend = getBlendFactor(vector.create(vec.x,0))
    if uipallet.ThirdColor then
        if blend <= 0.5 then return uipallet.MainColor:Lerp(uipallet.SecondaryColor, blend * 2) end
        return uipallet.SecondaryColor:Lerp(uipallet.ThirdColor, (blend - 0.5) * 2)
    end
    return uipallet.SecondaryColor:Lerp(uipallet.MainColor, blend)
end

local InterfaceMode = {}
local Gradients = {}
local function addGradient(parent)
    local UIGradient = Instance.new('UIGradient')
    local keypoints = {}
    if InterfaceMode.Value ~= "Static" then
        for i = 0, mainapi.GradientKeypoints do
            local position = i / mainapi.GradientKeypoints
            local offset = parent.AbsoluteSize * position
            table.insert(keypoints, ColorSequenceKeypoint.new(position, mainapi:GetColor(InterfaceMode.Value ~= "Breathe" and parent.AbsolutePosition + offset or vector.zero)))
        end
    else
        table.insert(keypoints, ColorSequenceKeypoint.new(0, uipallet.MainColor))
        if uipallet.ThirdColor then
            table.insert(keypoints, ColorSequenceKeypoint.new(0.5, uipallet.SecondaryColor))
            table.insert(keypoints, ColorSequenceKeypoint.new(1, uipallet.ThirdColor))
        else
            table.insert(keypoints, ColorSequenceKeypoint.new(1, uipallet.SecondaryColor))
        end
    end
    UIGradient.Color = ColorSequence.new(keypoints)
    table.insert(Gradients,UIGradient)
    UIGradient.Parent = parent
    return UIGradient
end

mainapi:Clean(RunService.PreSimulation:Connect(function()
	for i,v in next, Gradients do
		if v.Parent then
			local keypoints = {}
            if InterfaceMode.Value ~= "Static" then
                for i = 0, mainapi.GradientKeypoints do
                    local position = i / mainapi.GradientKeypoints
                    local offset = v.Parent.AbsoluteSize * position
                    table.insert(keypoints, ColorSequenceKeypoint.new(position, mainapi:GetColor(InterfaceMode.Value ~= "Breathe" and v.Parent.AbsolutePosition + offset or vector.zero)))
                end
            else
                if uipallet.ThirdColor then
                    table.insert(keypoints, ColorSequenceKeypoint.new(0, uipallet.MainColor))
                    table.insert(keypoints, ColorSequenceKeypoint.new(0.5, uipallet.SecondaryColor))
                    table.insert(keypoints, ColorSequenceKeypoint.new(1, uipallet.ThirdColor))
                else
                    table.insert(keypoints, ColorSequenceKeypoint.new(0, uipallet.MainColor))
                    table.insert(keypoints, ColorSequenceKeypoint.new(1, uipallet.SecondaryColor))
                end
            end
			v.Color = ColorSequence.new(keypoints)
		end
	end
    uipallet.FinalColor = mainapi:GetColor(vector.zero)
end))

if shared.Modern then shared.Modern:Uninject() end

mainapi.Libraries = { getfontsize = getfontsize; uipallet = uipallet; addGradient = addGradient; }

local SoundEffect = Instance.new("Sound")
SoundEffect.SoundId = "rbxassetid://137273815815490"
SoundEffect.TimePosition = 0.21
SoundEffect.PlayOnRemove = true

local Main, ClickGui, Gradient, Gradient2, NotifyList, ArrayList
local UICornors = {}

function mainapi:CreateGUI()
    Main = mainapi.MainScreenGui
    Main.Name = 'Modern'
    Main.DisplayOrder = 2147483647
    Main.ScreenInsets = Enum.ScreenInsets.None
    Main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if mainapi.ThreadFix then Main.Parent = cloneref(game:GetService('CoreGui')) else Main.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui Main.ResetOnSpawn = false end
    ClickGui = Instance.new('Frame')
    ClickGui.Name = 'ClickGui'
    ClickGui.Size = UDim2.fromScale(1.3, 0.5)
    ClickGui.Position = UDim2.fromScale(0.5, 0.35)
    ClickGui.AnchorPoint = Vector2.new(0.5, 0.5)
    ClickGui.BackgroundTransparency = 1
    ClickGui.SizeConstraint = Enum.SizeConstraint.RelativeYY
    ClickGui.Visible = true
    ClickGui.Parent = Main

    local Modal = Instance.new('TextButton')
    Modal.Name = "Modal"
	Modal.BackgroundTransparency = 1
	Modal.Text = ''
	Modal.Modal = true
    Modal.Visible = self.ClickGuiStatus
	Modal.Parent = Main

    local MainFrame = Instance.new('Frame')
    MainFrame.Name = 'Main'
    MainFrame.Size = UDim2.fromScale(1, 1)
    MainFrame.BackgroundTransparency = 1
    MainFrame.Visible = true
    MainFrame.Parent = Main

    ArrayList = Instance.new('Frame')
    ArrayList.Name = 'ArrayList'
    ArrayList.Size = UDim2.fromScale(1, 1)
    ArrayList.BackgroundTransparency = 1
    ArrayList.Visible = false
    ArrayList.Parent = Main

    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.FillDirection = Enum.FillDirection.Vertical    
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ArrayList

    local UIPadding = Instance.new('UIPadding')
    UIPadding.PaddingBottom = UDim.new(0.03, 0)
    UIPadding.PaddingTop = UDim.new(0.03, 0)
    UIPadding.PaddingLeft = UDim.new(0.01, 0)
    UIPadding.PaddingRight = UDim.new(0.01, 0)
    UIPadding.Parent = ArrayList

    local UIScale = Instance.new('UIScale',ClickGui)
    UIScale.Scale = mainapi.ClickGuiStatus and mainapi.Scale.Value or 0

    Gradient = Instance.new('ImageLabel')
    Gradient.Name = 'Gradient'
    Gradient.AnchorPoint = Vector2.new(0.5, 1)
    Gradient.Position = UDim2.fromScale(0.5, 1)
    Gradient.Size = UDim2.fromScale(1, 1)
    Gradient.Image = 'rbxassetid://107200271119058'
    Gradient.ImageTransparency = mainapi.ClickGuiStatus and 0.76 or 1
    Gradient.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Gradient.BackgroundTransparency = mainapi.ClickGuiStatus and 0.6 or 1
    Gradient.ZIndex = -10
    Gradient.Visible = true
    Gradient.Parent = Main
    
    Gradient2 = Gradient:Clone()
    Gradient2.Size = UDim2.fromScale(1, 2)
    Gradient2.ImageTransparency = mainapi.ClickGuiStatus and 0.9 or 1
    Gradient2.Parent = Gradient

    addGradient(Gradient)
    addGradient(Gradient2)

    NotifyList = Instance.new('Frame')
    NotifyList.Name = 'NotifyList'
    NotifyList.Size = UDim2.fromScale(0.2, 1)
    NotifyList.Position = UDim2.fromScale(1, 0)
    NotifyList.AnchorPoint = Vector2.new(1, 0)
    NotifyList.BackgroundTransparency = 1
    NotifyList.Visible = true
    NotifyList.Parent = Main

    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0.01, 0)
    UIListLayout.Parent = NotifyList

    local UIPadding = Instance.new('UIPadding')
    UIPadding.PaddingBottom = UDim.new(0.05, 0)
    UIPadding.PaddingTop = UDim.new(0.05, 0)
    UIPadding.Parent = NotifyList

    local UIAspectRatioConstraint = Instance.new('UIAspectRatioConstraint')
    UIAspectRatioConstraint.AspectRatio = 10
    UIAspectRatioConstraint.Parent = ClickGui

    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0.03, 0)
    UIListLayout.Parent = ClickGui

    self.AddCatalog = function(self,arg)
        local Catalog = {
            Name = arg['Name'] or '';
            Frame = Instance.new('CanvasGroup');
            AddModule = function()end;
            Modules = {};
        }
        local CatalogButton = Catalog.Frame
        CatalogButton.Name = arg['Name']..'_Catalog'
        CatalogButton.Size = UDim2.fromScale(0.13, 4)
        CatalogButton.BackgroundTransparency = 1
        CatalogButton.Parent = ClickGui

        local CatalogName = Instance.new('Frame')
        CatalogName.Size = UDim2.fromScale(1, 0.07)
        CatalogName.ClipsDescendants = true
        CatalogName.BackgroundTransparency = 1
        CatalogName.Parent = CatalogButton
        
        local CatalogNameText = Instance.new('TextButton')
        CatalogNameText.Name = "CatalogName"
        CatalogNameText.AutoButtonColor = false
        CatalogNameText.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        CatalogNameText.BorderSizePixel = 0
        CatalogNameText.Size = UDim2.fromScale(1, 2)
        CatalogNameText.Font = Enum.Font.BuilderSansBold
        CatalogNameText.TextScaled = true
        CatalogNameText.Text = Catalog.Name
        CatalogNameText.Parent = CatalogName
        CatalogNameText.TextColor3 = Color3.fromRGB(255, 255, 255)
        table.insert(UICornors,addCorner(CatalogNameText, UDim.new(0.2, 0)).Parent)

        local UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingBottom = UDim.new(0.63, 0)
        UIPadding.PaddingTop = UDim.new(0.1, 0)
        UIPadding.Parent = CatalogNameText

        local CatalogList = Instance.new('CanvasGroup')
        CatalogList.Name = "List"
        CatalogList.Size = UDim2.fromScale(1, 0.5)
        CatalogList.Position = UDim2.new(0, 0, 0, 0)
        CatalogList.BackgroundTransparency = 1
        CatalogList.Parent = CatalogButton
        table.insert(UICornors,addCorner(CatalogList, UDim.new(0.1, 0)).Parent)

        local ScrollingFrame = Instance.new('ScrollingFrame')
        ScrollingFrame.Position = UDim2.new(0, 0, 0, CatalogNameText.AbsoluteSize.Y/2)
        ScrollingFrame.Size = UDim2.fromScale(1, 0.94)
        ScrollingFrame.BackgroundTransparency = 1
        ScrollingFrame.ScrollBarThickness = 0
        ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ScrollingFrame.ScrollBarImageTransparency = 1
        ScrollingFrame.Parent = CatalogList

        mainapi:Clean(CatalogNameText:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            if mainapi.ClickGuiStatus then
                ScrollingFrame.Position = UDim2.new(0, 0, 0, CatalogNameText.AbsoluteSize.Y/2)
            end
        end))

        mainapi:Clean(RunService.RenderStepped:Connect(function()
            if mainapi.ClickGuiStatus then
                local Size = 0
                for i,v in next, ScrollingFrame:GetChildren() do
                    if v:IsA('Frame') or v:IsA('CanvasGroup') and v.Visible then
                        Size += v.AbsoluteSize.Y
                    end
                end
                CatalogList.Size = Size >= CatalogButton.AbsoluteSize.Y and UDim2.new(1, 0, 0, CatalogButton.AbsoluteSize.Y) or UDim2.new(1, 0, 0, Size + CatalogNameText.AbsoluteSize.Y/2)
                ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, Size)
            end
        end))
        

        local UIListLayout = Instance.new('UIListLayout')
        UIListLayout.FillDirection = Enum.FillDirection.Vertical
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = ScrollingFrame

        local Shadow = Instance.new('ImageLabel')
        Shadow.Size = UDim2.fromScale(1, 1)
        Shadow.Image = 'rbxassetid://107200271119058'
        Shadow.ImageTransparency = 0.4
        Shadow.Rotation = 180
        Shadow.BackgroundTransparency = 1
        Shadow.ImageColor3 = Color3.fromRGB(30, 30, 30)
        
        local Count = 0
        Catalog.AddModule = function(self,arg)
            local Module = {
                Name = arg['Name'];
                Frame = Instance.new('TextButton');
                Children = Instance.new('Frame');
                Expanded = arg['Expanded'] or false;
                Enabled = arg['Enabled'] or arg['Default'] or false;
                ExtraText = arg['ExtraText'] or function() return '' end;
                Bind = {};
                Settings = {};
            };
            addMaid(Module)
            Count += 1

            if mainapi.Modules[arg['Name']] then
                mainapi.Modules[arg['Name']]:Delete()
            end

            local MainFrame = Instance.new('Frame')
            MainFrame.Size = UDim2.new(1, 0, 0, CatalogNameText.AbsoluteSize.Y*0.33)
            MainFrame.BorderSizePixel = 0
            MainFrame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            MainFrame.Parent = ScrollingFrame
            mainapi:Clean(CatalogNameText:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
                if mainapi.ClickGuiStatus then
                    MainFrame.Size = UDim2.new(1, 0, 0, CatalogNameText.AbsoluteSize.Y * 0.33)
                    local Size = 0
                    for i,v in next, ScrollingFrame:GetChildren() do
                        if v:IsA('Frame') or v:IsA('CanvasGroup') and v.Visible then
                            Size += v.AbsoluteSize.Y
                        end
                    end
                    CatalogList.Size = Size >= CatalogButton.AbsoluteSize.Y and UDim2.new(1, 0, 0, CatalogButton.AbsoluteSize.Y) or UDim2.new(1, 0, 0, Size + CatalogNameText.AbsoluteSize.Y/2)
                    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, Size)
                end
            end))

            local MainButton = Module.Frame
            MainButton.Size = UDim2.fromScale(1, 1)
            MainButton.BorderSizePixel = 0
            MainButton.BackgroundColor3 = Color3.fromRGB(31, 32, 28)
            MainButton.BackgroundTransparency = 0
            MainButton.AutoButtonColor = false
            MainButton.Text = Module.Name
            MainButton.TextScaled = true
            MainButton.Font = Enum.Font.BuilderSansMedium
            MainButton.TextColor3 = Module.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(227, 227, 227)
            MainFrame.LayoutOrder = -((getfontsize(MainButton.Text, 10, Enum.Font.BuilderSansMedium).X+10)*100 -Count)
            MainButton.Parent = MainFrame
            addGradient(MainFrame)
            local Temp = 1/0
            local ChangeFrame
            for i,v in next, ScrollingFrame:GetChildren() do
                if v:IsA('Frame') and v.LayoutOrder < Temp then
                    Temp = v.LayoutOrder
                    ChangeFrame = v
                end
            end
            Shadow.Parent = ChangeFrame
            Module.Function = arg['Function'] or function()end

            if Module.Enabled then
                TweenService:Create(MainButton,TweenInfo.new(0.3, Enum.EasingStyle.Exponential),{BackgroundTransparency = 1}):Play()
                MainButton.TextColor3 = Module.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(227, 227, 227)
                task.spawn(Module.Function, Module.Enabled)
            end

            function Module:Toggle(val)
                Module.Enabled = not Module.Enabled
                TweenService:Create(MainButton,TweenInfo.new(0.3, Enum.EasingStyle.Exponential),{BackgroundTransparency = Module.Enabled and 1 or 0}):Play()
                MainButton.TextColor3 = Module.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(227, 227, 227)
                if not Module.Enabled then
                    for _, v in Module.Connections do v:Disconnect() end
                    table.clear(Module.Connections)
                end
                mainapi:UpdateArrayList()
                task.spawn(Module.Function, Module.Enabled)
            end

            MainButton.MouseButton1Click:Connect(Module.Toggle)
            MainButton.MouseButton1Click:Connect(function()
                local Clone = SoundEffect:Clone()
                Clone.Volume = 0.6
                Clone.Parent = mainapi.MainScreenGui
                Clone:Play()
            end)

            local UIPadding = Instance.new('UIPadding')
            UIPadding.PaddingBottom = UDim.new(0.13, 0)
            UIPadding.PaddingTop = UDim.new(0.13, 0)
            UIPadding.Parent = MainButton

            local Children = Module.Children
            Children.Name = 'Children'
            Children.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Children.BorderSizePixel = 0
            Children.LayoutOrder = -((getfontsize(MainButton.Text, 10, Enum.Font.BuilderSansMedium).X+10)*100 -Count-1)
            Children.ClipsDescendants = true
            Children.Parent = ScrollingFrame

            local UIListLayout = Instance.new('UIListLayout')
            UIListLayout.FillDirection = Enum.FillDirection.Vertical
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, CatalogNameText.AbsoluteSize.Y*0.04)
            UIListLayout.Parent = Children

            local UIPadding = Instance.new('UIPadding')
            UIPadding.PaddingTop = UDim.new(0, CatalogNameText.AbsoluteSize.Y*0.05)
            UIPadding.Parent = Children

            function Module:Delete()
                local old = Module.Enabled
                Module.Enabled = false
                for _, v in Module.Connections do v:Disconnect() end
                table.clear(Module.Connections)
                if old then task.spawn(Module.Function, false) end
                Shadow.Parent = CoreGui
                Children:ClearAllChildren()
                MainFrame:ClearAllChildren()
                Children:Destroy()
                MainFrame:Destroy()
                Module = nil
            end
            function Module.getChilrenSize()
                local Size = CatalogNameText.AbsoluteSize.Y*0.05
                for i,v in next,Children:GetChildren() do
                    if v:IsA('Frame') and v.Visible then
                        Size += v.AbsoluteSize.Y + CatalogNameText.AbsoluteSize.Y*0.05
                    end
                end
                if Size == CatalogNameText.AbsoluteSize.Y*0.05 then return 0 end
                return Size
            end

            if Module.Expanded then Module:Expand() end
            function Module:Expand()
                Module.Expanded = not Module.Expanded
                TweenService:Create(Children, TweenInfo.new(0.2, Enum.EasingStyle.Exponential),{Size = Module.Expanded and UDim2.new(1, 0, 0, Module.getChilrenSize()) or UDim2.new(1, 0, 0, 0)}):Play()
                for i,v in next, Children:GetDescendants() do
                    if v:IsA('Frame') and v.Name == 'Slider_Fill' then
                        if Module.Expanded then
                            v.Size = UDim2.fromScale(0, 1) 
                            TweenService:Create(v, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),{Size = UDim2.fromScale(v:GetAttribute('Value'), 1)}):Play()
                        end
                    end
                end
            end
            
            MainButton.MouseButton2Click:Connect(Module.Expand)
            MainButton.MouseButton2Click:Connect(function()
                if Module.getChilrenSize() ~= 0 then
                    local Clone = SoundEffect:Clone()
                    Clone.Volume = 0.7
                    Clone.Parent = mainapi.MainScreenGui
                    Clone:Play()
                end
            end)
            mainapi:Clean(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                if mainapi.ClickGuiStatus then
                    if ClickGui.UIScale.Scale == mainapi.Scale.Value or ClickGui.UIScale.Scale == 0 then
                        TweenService:Create(Children, TweenInfo.new(0.1, Enum.EasingStyle.Exponential),{Size = Module.Expanded and UDim2.new(1, 0, 0, Module.getChilrenSize()) or UDim2.new(1, 0, 0, 0)}):Play()
                    end
                    UIListLayout.Padding = UDim.new(0, CatalogNameText.AbsoluteSize.Y*0.05)
                    UIPadding.PaddingTop = UDim.new(0, CatalogNameText.AbsoluteSize.Y*0.05)
                end
            end))

            function Module:SetBind(key)
                Module.Bind = key
            end

            Module.AddToggle = function(self,arg)
                local Toggle = {
                    Name = arg['Name'] or '';
                    Frame = Instance.new('Frame');
                    Enabled = arg['Enabled'] or arg['Default'] or false;
                    Function = arg['Function'] or arg['function'] or function()end;
                }

                local ToggleFrame = Toggle.Frame
                ToggleFrame.Size = UDim2.new(1, 0, 0, MainButton.AbsoluteSize.Y * 0.8)
                ToggleFrame.BackgroundTransparency = 1
                if arg['Visible'] == false then ToggleFrame.Visible = false end
                ToggleFrame.Parent = Children

                mainapi:Clean(MainButton:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
                    if mainapi.ClickGuiStatus then
                        ToggleFrame.Size = UDim2.new(1, 0, 0, MainButton.AbsoluteSize.Y * 0.8)
                    end
                end))

                local ToggleText = Instance.new('TextLabel')
                ToggleText.Name = 'Alias'
                ToggleText.Text = arg['Text'] or Toggle.Name
                ToggleText.BackgroundTransparency = 1
                ToggleText.Size = UDim2.fromScale(1, 1)
                ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleText.TextScaled = true
                ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                ToggleText.Font = Enum.Font.BuilderSansMedium
                ToggleText.Parent = ToggleFrame

                local UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingBottom = UDim.new(0.1, 0)
                UIPadding.PaddingLeft = UDim.new(0.05, 0)
                UIPadding.PaddingRight = UDim.new(0.3, 0)
                UIPadding.PaddingTop = UDim.new(0.1, 0)
                UIPadding.Parent = ToggleText

                local ToggleButton = Instance.new('TextButton')
                ToggleButton.Name = 'Button'
                ToggleButton.Text = ''
                ToggleButton.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
                ToggleButton.Position = UDim2.fromScale(0.93, 0.5)
                ToggleButton.BorderSizePixel = 0
                ToggleButton.AnchorPoint = Vector2.new(0.9, 0.5)
                ToggleButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
                ToggleButton.AutoButtonColor = false
                ToggleButton.Size = UDim2.fromScale(1.75, 0.8)
                ToggleButton.Parent = ToggleFrame
                addCorner(ToggleButton, UDim.new(1, 0))
                local GradientColor = addGradient(ToggleButton)
                GradientColor.Enabled = Toggle.Enabled
                local ToggleButtonFill = Instance.new('TextButton')
                ToggleButtonFill.Name = 'Button'
                ToggleButtonFill.Text = ''
                ToggleButtonFill.Interactable = false
                ToggleButtonFill.BackgroundTransparency = 0
                ToggleButtonFill.BackgroundColor3 = Color3.fromRGB(208, 208, 208)
                ToggleButtonFill.Position = UDim2.fromScale(0.25, 0.5)
                ToggleButtonFill.BorderSizePixel = 0
                ToggleButtonFill.AnchorPoint = Vector2.new(0.5, 0.5)
                ToggleButtonFill.SizeConstraint = Enum.SizeConstraint.RelativeYY
                ToggleButtonFill.Size = UDim2.fromScale(0.7, 0.7)
                ToggleButtonFill.Parent = ToggleButton
                addCorner(ToggleButtonFill, UDim.new(1, 0))
                local GlowEffect = Instance.new('ImageLabel')
                GlowEffect.BackgroundTransparency = 1
                GlowEffect.Position = UDim2.fromScale(0.5, 0.5)
                GlowEffect.Size = Toggle.Enabled and UDim2.fromScale(3, 3) or UDim2.fromScale(0, 0)
                GlowEffect.Parent = ToggleButtonFill
                GlowEffect.AnchorPoint = Vector2.new(0.5, 0.5)
                GlowEffect.Image = 'rbxassetid://77031034070194'

                if Toggle.Enabled then
                    TweenService:Create(ToggleButtonFill,TweenInfo.new(0.5, Enum.EasingStyle.Exponential),{Position = UDim2.fromScale(0.75, 0.5)}):Play()
                    TweenService:Create(GlowEffect,TweenInfo.new(0.3, Enum.EasingStyle.Exponential),{Size = UDim2.fromScale(3, 3)}):Play()
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                end

                function Toggle:Toggle(val)
                    Toggle.Enabled = val or not Toggle.Enabled
                    TweenService:Create(ToggleButtonFill,TweenInfo.new(0.5 ,Enum.EasingStyle.Exponential),{Position = Toggle.Enabled and UDim2.fromScale(0.75, 0.5) or UDim2.fromScale(0.25, 0.5)}):Play()
                    TweenService:Create(GlowEffect,TweenInfo.new(0.3, Enum.EasingStyle.Exponential),{Size = Toggle.Enabled and UDim2.fromScale(3, 3) or UDim2.fromScale(0, 0)}):Play()
                    GradientColor.Enabled = Toggle.Enabled
                    ToggleButton.BackgroundColor3 = Toggle.Enabled and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(52, 52, 52)
                    Toggle.Function(Toggle.Enabled)
                end

                ToggleButton.MouseButton1Click:Connect(Toggle.Toggle)
                ToggleButton.MouseButton1Click:Connect(function()
                    local Clone = SoundEffect:Clone()
                    Clone.Volume = 0.6
                    Clone.Parent = mainapi.MainScreenGui
                    Clone:Play()
                end)

                function Toggle:Save(tab)
                    tab[Toggle.Name] = {Enabled = Toggle.Enabled;}
                end
                function Toggle:Load(tab)
                    if tab and Toggle.Enabled ~= tab.Enabled then Toggle:Toggle(tab.Enabled) end
                end

                self.Settings[Toggle.Name] = Toggle
                return Toggle
            end
            Module.AddSlider = function(self, arg)
                local Slider = {
                    Name = arg['Name'] or '';
                    Frame = Instance.new('Frame');
                    Max = arg['Max'] or arg['max'] or 100;
                    Min = arg['Min'] or arg['min'] or 1;
                    Value = arg['default'] or arg['Default'] or arg['Value'] or (arg['Min'] or arg['min'] or 1);
                    Decimal = arg['Decimal'] or arg['decimal'] or 1;
                    Suffix = arg['Suffix'];
                    Function = arg['Function'] or arg['function'] or function()end;
                    Visible = arg['Visible'] or true;
                }

                local SliderFrame = Slider.Frame
                SliderFrame.Size = UDim2.new(1, 0, 0, MainButton.AbsoluteSize.Y * 1.2)
                SliderFrame.BackgroundTransparency = 1
                if arg['Visible'] == false then SliderFrame.Visible = false end
                SliderFrame.Parent = Children

                mainapi:Clean(MainButton:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() 
                    if mainapi.ClickGuiStatus then
                        SliderFrame.Size = UDim2.new(1, 0, 0, MainButton.AbsoluteSize.Y * 1.2)
                    end
                end))

                local SliderText = Instance.new('TextLabel')
                SliderText.Name = 'Alias'
                SliderText.Text = arg['Text'] or Slider.Name
                SliderText.BackgroundTransparency = 1
                SliderText.Size = UDim2.fromScale(1, 0.66)
                SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderText.TextScaled = true
                SliderText.TextXAlignment = Enum.TextXAlignment.Left
                SliderText.Font = Enum.Font.BuilderSansMedium
                SliderText.Parent = SliderFrame

                local UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingBottom = UDim.new(0.1, 0)
                UIPadding.PaddingLeft = UDim.new(0.05, 0)
                UIPadding.PaddingRight = UDim.new(0.4, 0)
                UIPadding.PaddingTop = UDim.new(0.1, 0)
                UIPadding.Parent = SliderText

                local SliderValue = Instance.new('TextLabel')
                SliderValue.Name = 'Select'
                SliderValue.Text = Slider.Value..(Slider.Suffix and ' '..(type(Slider.Suffix) == 'function' and Slider.Suffix(Slider.Value) or Slider.Suffix) or '')
                SliderValue.BackgroundTransparency = 1
                SliderValue.Size = UDim2.fromScale(1, 0.66)
                SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderValue.TextScaled = true
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Font = Enum.Font.BuilderSansMedium
                SliderValue.Parent = SliderFrame

                local UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingBottom = UDim.new(0.1, 0)
                UIPadding.PaddingLeft = UDim.new(0.4, 0)
                UIPadding.PaddingRight = UDim.new(0.05, 0)
                UIPadding.PaddingTop = UDim.new(0.1, 0)
                UIPadding.Parent = SliderValue

                local SliderLine = Instance.new('Frame')
                SliderLine.Name = 'Slider'
                SliderLine.AnchorPoint = Vector2.new(0, 0.5)
                SliderLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderLine.BackgroundTransparency = 1
                SliderLine.Position = UDim2.fromScale(0, 0.75)
                SliderLine.Size = UDim2.fromScale(1, 0.08)
                SliderLine.Parent = SliderFrame

                local UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingLeft = UDim.new(0.07, 0)
                UIPadding.PaddingRight = UDim.new(0.07, 0)
                UIPadding.Parent = SliderLine

                local SliderLine2 = Instance.new('Frame')
                SliderLine2.Name = 'Line'
                SliderLine2.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderLine2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderLine2.BackgroundTransparency = 0
                SliderLine2.Position = UDim2.fromScale(0.5, 0.5)
                SliderLine2.Size = UDim2.fromScale(1, 1)
                SliderLine2.Parent = SliderLine

                local SliderLine3 = Instance.new('Frame')
                SliderLine3.Name = 'Slider_Fill'
                SliderLine3.AnchorPoint = Vector2.new(0, 0.5)
                SliderLine3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderLine3.BackgroundTransparency = 0
                SliderLine3.Position = UDim2.fromScale(0, 0.5)
                SliderLine3.Size = UDim2.fromScale(Slider.Value/Slider.Max, 1)
                SliderLine3.BorderSizePixel = 0
                SliderLine3.Parent = SliderLine2
                SliderLine3:SetAttribute('Value', Slider.Value/Slider.Max)
                addGradient(SliderLine3)

                local SliderLine4 = Instance.new('Frame')
                SliderLine4.Name = 'BALL'
                SliderLine4.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderLine4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderLine4.BackgroundTransparency = 0
                SliderLine4.Position = UDim2.fromScale(1, 0.5)
                SliderLine4.Size = UDim2.fromScale(3, 3.05)
                SliderLine4.SizeConstraint = Enum.SizeConstraint.RelativeYY
                SliderLine4.BorderSizePixel = 0
                SliderLine4.Parent = SliderLine3
                addCorner(SliderLine4, UDim.new(10, 0))
                addGradient(SliderLine4)

                local GlowEffect = Instance.new('ImageLabel')
                GlowEffect.BackgroundTransparency = 1
                GlowEffect.Position = UDim2.fromScale(0.5, 0.5)
                GlowEffect.Size = UDim2.fromScale(3, 3)
                GlowEffect.AnchorPoint = Vector2.new(0.5, 0.5)
                GlowEffect.Image = 'rbxassetid://77031034070194'
                GlowEffect.Parent = SliderLine4
                addGradient(GlowEffect)

                local SliderInput = Instance.new('TextButton')
                SliderInput.Name = 'Input'
                SliderInput.Text = ''
                SliderInput.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderInput.AutoButtonColor = false
                SliderInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderInput.BackgroundTransparency = 1
                SliderInput.Position = UDim2.fromScale(0.5, 0.5)
                SliderInput.Size = UDim2.fromScale(1, 7)
                SliderInput.Parent = SliderLine

                local function SetValue(val, val2, final, skip)
                    local check = Slider.Value ~= val2
                    if not skip then
                        TweenService:Create(SliderLine3, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),{Size = UDim2.fromScale(val, 1)}):Play()
                    end
                    Slider.Value = val2
                    SliderValue.Text = Slider.Value..(Slider.Suffix and ' '..(type(Slider.Suffix) == 'function' and Slider.Suffix(Slider.Value) or Slider.Suffix) or '')
                    SliderLine3:SetAttribute('Value', val)
                    if check or final then Slider.Function(val2, final) end
                end
                SliderInput.InputBegan:Connect(function(inputObj)
                    if (inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch) then
                        local newPosition = math.clamp((inputObj.Position.X - SliderLine2.AbsolutePosition.X) / SliderLine2.AbsoluteSize.X, 0, 1)
                        local newValue = math.floor((Slider.Min + (Slider.Max - Slider.Min) * newPosition) * Slider.Decimal) / Slider.Decimal
                        SetValue(newPosition, newValue)
                        local lastPosition = newPosition
                        local lastValue = newValue
                
                        local changed = UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
                                local newPosition = math.clamp((input.Position.X - SliderLine2.AbsolutePosition.X) / SliderLine2.AbsoluteSize.X, 0, 1)
                                local newValue = math.floor((Slider.Min + (Slider.Max - Slider.Min) * newPosition) * Slider.Decimal) / Slider.Decimal
                                SetValue(newPosition, newValue)
                                if lastValue ~= newValue then
                                    local Clone = SoundEffect:Clone()
                                    Clone.Volume = 0.2
                                    Clone.Parent = mainapi.MainScreenGui
                                    Clone:Play()
                                end
                                lastValue = newValue
                                lastPosition = newPosition
                            end
                        end)
                
                        local ended = inputObj.Changed:Connect(function()
                            if inputObj.UserInputState == Enum.UserInputState.End then
                                if changed then changed:Disconnect() end
                                if ended then ended:Disconnect() end
                                SetValue(lastPosition, lastValue, true)
                            end
                        end)
                    end
                end)
                
                function Slider:Save(tab)
                    tab[Slider.Name] = {Max = Slider.Max; Min = Slider.Min; Value = Slider.Value;}
                end

                function Slider:Load(tab)
                    if tab and tab.Max and Slider.Min and tab.Max == Slider.Max and tab.Min == Slider.Min and tab.Value then
                        local newPosition = math.clamp((tab.Value - tab.Min) / (tab.Max - tab.Min), 0, 1)
                        Slider.Value = tab.Value
                        SetValue(newPosition, tab.Value, true, true)
                    end
                end
                self.Settings[Slider.Name] = Slider
                return Slider
            end
            Module.AddDropdown = function(self,arg)
                local Dropdown = {
                    Name = arg['Name'] or arg['Text'] or '';
                    Frame = Instance.new('Frame');
                    Value = arg['Default'] or arg['List'][1] or 'None';
                    Function = arg['Function'] or arg['function'] or function()end;
                }

                local DropdownFrame = Dropdown.Frame
                DropdownFrame.Size = UDim2.new(1, 0, 0, MainButton.AbsoluteSize.Y * 0.8)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = Children

                mainapi:Clean(MainButton:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
                    if mainapi.ClickGuiStatus then
                        DropdownFrame.Size = UDim2.new(1, 0, 0, MainButton.AbsoluteSize.Y * 0.8)
                    end
                end))

                local DropdownText = Instance.new('TextLabel')
                DropdownText.Name = 'Alias'
                DropdownText.Text = Dropdown.Name
                DropdownText.BackgroundTransparency = 1
                DropdownText.Size = UDim2.fromScale(1, 1)
                DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownText.TextScaled = true
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                DropdownText.Font = Enum.Font.BuilderSansMedium
                DropdownText.Parent = DropdownFrame

                local UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingBottom = UDim.new(0.1, 0)
                UIPadding.PaddingLeft = UDim.new(0.05, 0)
                UIPadding.PaddingRight = UDim.new(0.4, 0)
                UIPadding.PaddingTop = UDim.new(0.1, 0)
                UIPadding.Parent = DropdownText

                local DropdownSelect = Instance.new('TextButton')
                DropdownSelect.Name = 'Select'
                DropdownSelect.Text = Dropdown.Value
                DropdownSelect.BackgroundTransparency = 1
                DropdownSelect.Size = UDim2.fromScale(1, 1)
                DropdownSelect.TextColor3 = Color3.fromRGB(230, 230, 230)
                DropdownSelect.TextScaled = true
                DropdownSelect.TextXAlignment = Enum.TextXAlignment.Right
                DropdownSelect.Font = Enum.Font.BuilderSansMedium
                DropdownSelect.Parent = DropdownFrame

                local UIPadding = Instance.new('UIPadding')
                UIPadding.PaddingBottom = UDim.new(0.1, 0)
                UIPadding.PaddingLeft = UDim.new(0.5, 0)
                UIPadding.PaddingRight = UDim.new(0.05, 0)
                UIPadding.PaddingTop = UDim.new(0.1, 0)
                UIPadding.Parent = DropdownSelect

                DropdownSelect.MouseButton1Click:Connect(function()
                    local currentIndex = table.find(arg['List'], Dropdown.Value) or 1
                    currentIndex = currentIndex % #arg['List'] + 1
                    Dropdown.Value = arg['List'][currentIndex]
                    DropdownSelect.Text = arg['List'][currentIndex]
                    local Clone = SoundEffect:Clone()
                    Clone.Volume = 1
                    Clone.Parent = mainapi.MainScreenGui
                    Clone:Play()
                    Dropdown.Function(arg['List'][currentIndex])
                end)

                function Dropdown:Save(tab)
                    tab[Dropdown.Name] = {Value = Dropdown.Value;}
                end

                function Dropdown:Load(tab)
                    if tab and tab.Value then
                        Dropdown.Value = tab.Value
                        DropdownSelect.Text = tab.Value
                    end
                end

                Module.Settings[Dropdown.Name] = Dropdown
                return Dropdown
            end
            mainapi.Modules[arg['Name']] = Module
            Catalog.Modules[arg['Name']] = Module
            return Module
        end
        mainapi.Catalogs[arg['Name']] = Catalog
        return Catalog
    end
end

mainapi:CreateGUI()

local Array
local ArrayListTransparency, ArrayListGlowLine = {}, {}
do
    function mainapi:GetArrayListColor(vec)
        local blend = getBlendFactor(vec)
        if uipallet.ThirdColor then
            if blend <= 0.5 then return uipallet.MainColor:Lerp(uipallet.SecondaryColor, blend * 2) end
            return uipallet.SecondaryColor:Lerp(uipallet.ThirdColor, (blend - 0.5) * 2)
        end
        return uipallet.SecondaryColor:Lerp(uipallet.MainColor, blend)
    end

    local ArrayListMain = Instance.new("Frame")
    ArrayListMain.Size = UDim2.new(0, 0, 0, mainapi.MainScreenGui.AbsoluteSize.Y/45)
    ArrayListMain.BackgroundTransparency = 1
    ArrayListMain.AnchorPoint = Vector2.new(1, 0)
    ArrayListMain.Position = UDim2.fromScale(0, 0)

    local ArrayListFrame = Instance.new("TextLabel")
    ArrayListFrame.Name = "TextLabel"
    ArrayListFrame.Size = UDim2.fromScale(1, 1)
    ArrayListFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    ArrayListFrame.BorderSizePixel = 0
    ArrayListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ArrayListFrame.BackgroundTransparency = 0.3
    ArrayListFrame.RichText = true
    ArrayListFrame.Font = Enum.Font.BuilderSansMedium
    ArrayListFrame.TextSize = ArrayListMain.AbsoluteSize.Y
    ArrayListFrame.Parent = ArrayListMain

    local ArrayListExtraMain = Instance.new("Frame")
    ArrayListExtraMain.BackgroundTransparency = 1
    ArrayListExtraMain.AnchorPoint = Vector2.new(1, 0.5)
    ArrayListExtraMain.ClipsDescendants = true
    ArrayListExtraMain.Position = UDim2.fromScale(1, 0)
    ArrayListExtraMain.Parent = ArrayListFrame

    local ArrayListExtra = Instance.new("Frame")
    ArrayListExtra.Size = UDim2.fromScale(0.6, 0.3)
    ArrayListExtra.BackgroundTransparency = 0
    ArrayListExtra.AnchorPoint = Vector2.new(0, 0.5)
    ArrayListExtra.Position = UDim2.fromScale(-0.3, 0.5)
    ArrayListExtra.Parent = ArrayListExtraMain

    local GlowEffect = Instance.new('ImageLabel')
    GlowEffect.BackgroundTransparency = 1
    GlowEffect.AnchorPoint = Vector2.new(0, 0.5)
    GlowEffect.Position = UDim2.fromScale(-8, 0.5)
    GlowEffect.ZIndex = -10
    GlowEffect.Size = UDim2.fromScale(10, 1.3)
    GlowEffect.ImageTransparency = 0.6
    GlowEffect.Image = 'rbxassetid://93106615966363'
    GlowEffect.Parent = ArrayListExtra

    addCorner(GlowEffect, UDim.new(999, 0))
    addCorner(ArrayListExtra, UDim.new(999, 0))
    addBlur(ArrayListFrame)
    addCorner(ArrayListFrame)

    local old = {}
    function mainapi:UpdateArrayList()
        local new, remove = {}, {}

        for i,v in next, self.Modules do
            if v.Enabled and not old[i] then
                old[i] = i
                table.insert(new, i)
            elseif not v.Enabled and old[i] then
                table.insert(remove, i)
                old[i] = nil
            end
        end

        for i,v in ArrayList:GetChildren() do
            if v:IsA("Frame") then
                if table.find(remove, v.Name) then
                    TweenService:Create(v.UIScale, TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Scale = 0}):Play()
                    task.delay(0.3,function() v:Destroy() end)
                end
            end
        end

        for i,v in next, new do
            local Clone = ArrayListMain:Clone()
            Clone.Parent = ArrayList
            Clone.Name = v
            local Color = mainapi:GetArrayListColor(Clone.AbsolutePosition)
            Clone.TextLabel.Text = '<font color="rgb('..tostring(math.floor(Color.R * 255))..','..tostring(math.floor(Color.G * 255))..','..tostring(math.floor(Color.B * 255))..')">'..v..'</font>'
            local selfModule = self.Modules[v]
            if selfModule and selfModule.ExtraText then
                local Extra = selfModule.ExtraText()
                Clone.TextLabel.Text ..= Extra ~= '' and ' '..Extra or Extra
            end
            local Size = UDim2.new(0, getfontsize(removeTags(Clone.TextLabel.Text), Clone.TextLabel.TextSize, Clone.TextLabel.FontFace, Vector2.new(100000, 100000)).X + mainapi.MainScreenGui.AbsoluteSize.Y/90, 0, mainapi.MainScreenGui.AbsoluteSize.Y/45)
            Clone.Size = Size
            Clone.LayoutOrder = -getfontsize(removeTags(Clone.TextLabel.Text), Clone.TextLabel.TextSize, Clone.TextLabel.FontFace, Vector2.new(100000, 100000)).X

            if ArrayListTransparency.Value then Clone.TextLabel.BackgroundTransparency = 1 - ArrayListTransparency.Value end
 
            Clone.TextLabel.Frame.Visible = ArrayListGlowLine.Enabled or false

            local UIScale = Instance.new("UIScale")
            UIScale.Parent = Clone

            UIScale.Scale = 0
            TweenService:Create(UIScale,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Scale = 1}):Play()
        end
    end
    mainapi:Clean(RunService.PreSimulation:Connect(function()
        if Array.Enabled then
            for i,v in next, ArrayList:GetChildren() do
                if v:IsA("Frame") then
                    local Color = mainapi:GetArrayListColor(v.AbsolutePosition)
                    v.TextLabel.Text = '<font color="rgb('..tostring(math.floor(Color.R * 255))..','..tostring(math.floor(Color.G * 255))..','..tostring(math.floor(Color.B * 255))..')">'..v.Name..'</font>'
                    local selfModule = mainapi.Modules[v.Name]
                    if selfModule and selfModule.ExtraText then
                        local Extra = selfModule.ExtraText()
                        v.TextLabel.Text ..= Extra ~= '' and ' '..Extra or Extra
                    end
                    v.TextLabel.Frame.Frame.BackgroundColor3 = mainapi:GetArrayListColor(v.AbsolutePosition)
                    v.TextLabel.BackgroundTransparency = 1 - ArrayListTransparency.Value
                    v.TextLabel.Frame.Frame.ImageLabel.ImageColor3 = mainapi:GetArrayListColor(v.AbsolutePosition)
                    local Size = UDim2.new(0, getfontsize(removeTags(v.TextLabel.Text), v.TextLabel.TextSize, v.TextLabel.FontFace, Vector2.new(100000, 100000)).X + mainapi.MainScreenGui.AbsoluteSize.Y/90, 0, mainapi.MainScreenGui.AbsoluteSize.Y/45)
                    v.Size = Size
                    v.TextLabel.TextSize = mainapi.MainScreenGui.AbsoluteSize.Y/45
                    v.TextLabel.Frame.Size = UDim2.new(0, mainapi.MainScreenGui.AbsoluteSize.Y/60, 3, 0)
                    v.TextLabel.Frame.Position = UDim2.new(1, mainapi.MainScreenGui.AbsoluteSize.Y/70, 0.5, 0)
                end
            end
        end
    end))
end

local TargetHud
local TargetHudMain = mainapi.TargetHudFrame
TargetHudMain.Size = UDim2.new(0, mainapi.MainScreenGui.AbsoluteSize.Y/6, 0, mainapi.MainScreenGui.AbsoluteSize.Y/14)
TargetHudMain.BackgroundTransparency = 1
TargetHudMain.Parent = mainapi.MainScreenGui
TargetHudMain.Visible = false

local TargetHudFrame = Instance.new("Frame")
TargetHudFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TargetHudFrame.Position = UDim2.fromScale(0.5, 0.5)
TargetHudFrame.Size = UDim2.fromScale(1, 1)
TargetHudFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TargetHudFrame.BackgroundTransparency = 0.1
TargetHudFrame.BorderSizePixel = 0
TargetHudFrame.Parent = TargetHudMain

local TargetHudText = Instance.new("TextLabel")
TargetHudText.TextScaled = true
TargetHudText.BackgroundTransparency = 1
TargetHudText.Text = "None"
TargetHudText.TextColor3 = Color3.fromRGB(240, 240, 240)
TargetHudText.Size = UDim2.fromScale(1, 0.5)
TargetHudText.TextXAlignment = Enum.TextXAlignment.Left
TargetHudText.Parent = TargetHudFrame

local UIPadding = Instance.new('UIPadding')
UIPadding.PaddingBottom = UDim.new(0.15, 0)
UIPadding.PaddingTop = UDim.new(0.4, 0)
UIPadding.PaddingLeft = UDim.new(0.42, 0)
UIPadding.PaddingRight = UDim.new(0.1, 0)
UIPadding.Parent = TargetHudText

addCorner(TargetHudFrame)
addBlur(TargetHudFrame)

local TargetHudHealth = Instance.new("CanvasGroup")
TargetHudHealth.AnchorPoint = Vector2.new(0, 0.5)
TargetHudHealth.Position = UDim2.fromScale(0.42, 0.7)
TargetHudHealth.Size = UDim2.fromScale(0.46, 0.12)
TargetHudHealth.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
TargetHudHealth.BackgroundTransparency = 0.7
TargetHudHealth.BorderSizePixel = 0
TargetHudHealth.Parent = TargetHudFrame
addBlur(TargetHudHealth)
addCorner(TargetHudHealth, UDim.new(1, 0))

local TargetHudHealthText = Instance.new("TextLabel")
TargetHudHealthText.Text = "0"
TargetHudHealthText.TextXAlignment = Enum.TextXAlignment.Left
TargetHudHealthText.AnchorPoint = Vector2.new(0, 0.5)
TargetHudHealthText.Position = UDim2.fromScale(0.42, 0.5)
TargetHudHealthText.Size = UDim2.fromScale(0.5, 0.2)
TargetHudHealthText.TextScaled = true
TargetHudHealthText.TextColor3 = Color3.fromRGB(240, 240, 240)
TargetHudHealthText.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TargetHudHealthText.BackgroundTransparency = 1
TargetHudHealthText.BorderSizePixel = 0
TargetHudHealthText.Parent = TargetHudFrame

local TargetHudHealthFill = Instance.new("Frame")
TargetHudHealthFill.AnchorPoint = Vector2.new(0, 0.5)
TargetHudHealthFill.Position = UDim2.fromScale(0, 0.5)
TargetHudHealthFill.Size = UDim2.fromScale(0, 1)
TargetHudHealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TargetHudHealthFill.BackgroundTransparency = 0.1
TargetHudHealthFill.BorderSizePixel = 0
TargetHudHealthFill.Parent = TargetHudHealth

local TargetImage = Instance.new("ImageLabel")
TargetImage.AnchorPoint = Vector2.new(0.5, 0.5)
TargetImage.Position = UDim2.fromScale(0.2, 0.5)
TargetImage.BackgroundTransparency = 1
TargetImage.Image = "http://www.roblox.com/asset/?id=106901765836307"
TargetImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
TargetImage.Size = UDim2.fromScale(0.7, 0.7)
TargetImage.Parent = TargetHudFrame
TargetImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
addCorner(TargetImage)
addBlur(TargetImage)

makeDraggable(TargetHudMain, mainapi.MainScreenGui.ClickGui)

local UIScale = Instance.new('UIScale', TargetHudFrame)
UIScale.Scale = mainapi.ClickGuiStatus and mainapi.Scale.Value or 0

local UIScale2 = Instance.new('UIScale', TargetImage)
UIScale2.Scale = 1

local TargetHudSoundEffect
local lasthealth = 0
local lastmaxhealth = 0
local TargetHudScale
local Targetinfo = {
	Targets = {},
	Object = TargetHudFrame,
	UpdateInfo = function(self)
		local entitylib = mainapi.Libraries.entitylib
		if not entitylib then return end

		for i, v in self.Targets do
			if v < tick() then self.Targets[i] = nil end
		end

		local v, highest = nil, tick()
		for i, check in self.Targets do
			if check > highest then v = i highest = check end
		end
        local Tween
		if v ~= nil or mainapi.ClickGuiStatus and UIScale.Scale == 0 and not Tween then
            Tween = TweenService:Create(UIScale,TweenInfo.new(0.1,Enum.EasingStyle.Bounce),{Scale = TargetHudScale.Value or 1}):Play()
        elseif not mainapi.ClickGuiStatus and not Tween then
            Tween = TweenService:Create(UIScale,TweenInfo.new(0.1,Enum.EasingStyle.Bounce),{Scale = 0}):Play()
        end
		if v then
			TargetHudText.Text = v.Player and (v.Player.Name) or v.Character and v.Character.Name or TargetHudText.Text
			if not v.Character then
				v.Health = v.Health or 0
				v.MaxHealth = v.MaxHealth or 100
			end

            TargetHudHealthText.Text = ("%2d HP"):format(v.Health)
            if entitylib.character.Humanoid.Health == v.Health then
                TargetHudHealthText.Text = TargetHudHealthText.Text.." Drawing"
            elseif entitylib.character.Humanoid.Health < v.Health then
                TargetHudHealthText.Text = TargetHudHealthText.Text.." Losing"
            elseif entitylib.character.Humanoid.Health > v.Health then
                TargetHudHealthText.Text = TargetHudHealthText.Text.." Winning"
            end

			if v.Health ~= lasthealth then
				local percent = math.max(v.Health / v.MaxHealth, 0)
                TweenService:Create(TargetHudHealthFill, TweenInfo.new(0.3), {Size = UDim2.fromScale(math.min(percent, 1), 1), BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)}):Play()
				if lasthealth > v.Health and self.LastTarget == v then
					TargetImage.ImageColor3 = Color3.fromRGB(255, 0, 0)
                    UIScale2.Scale = 0.8
                    TweenService:Create(TargetImage, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    TargetImage.Rotation = 20
                    TweenService:Create(TargetImage, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    TweenService:Create(UIScale2, TweenInfo.new(0.3,Enum.EasingStyle.Bounce), {Scale = 1}):Play()
                    if TargetHudSoundEffect and TargetHudSoundEffect.Enabled then
                        local Clone = SoundEffect:Clone()
                        Clone.Volume = 0.7
                        Clone.Parent = mainapi.MainScreenGui
                        Clone:Play()
                    end
				end
				lasthealth = v.Health
				lastmaxhealth = v.MaxHealth
			end

			if not v.Character then table.clear(v) end
			self.LastTarget = v
		end
		return v
	end
}
mainapi.Libraries.Targetinfo = Targetinfo

function mainapi:Notify(arg)
    local Notify = {
        Text = arg["Text"] or "None";
        Duration = arg["Duration"] or arg["Durn"] or 2;
        Frame = Instance.new('Frame');
        Sound = arg["Sound"];
        Status = false;
    }
    local NotifyFrame = Notify.Frame
    NotifyFrame.Size = UDim2.fromScale(0.8, 0.05)
    NotifyFrame.BackgroundTransparency = 1
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NotifyFrame.Parent = NotifyList
    
    local UIScale = Instance.new('UIScale',NotifyFrame)
    UIScale.Scale = 0

    local NotifyMain = Instance.new('Frame');
    NotifyMain.Name = "NotifyMain"
    NotifyMain.Size = UDim2.fromScale(1, 1)
    NotifyMain.Position = UDim2.fromScale(2, 0.2)
    NotifyMain.BackgroundTransparency = 0.3
    NotifyMain.BorderSizePixel = 0
    NotifyMain.ZIndex = -1
    NotifyMain.ClipsDescendants = false
    NotifyMain.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NotifyMain.Parent = NotifyFrame
    addBlur(NotifyMain)
    addCorner(NotifyMain)

    local NotifyText = Instance.new('TextButton')
    NotifyText.Size = UDim2.fromScale(1, 1)
    NotifyText.Text = Notify.Text
    NotifyText.Font = mainapi.Font
    NotifyText.BorderSizePixel = 0
    NotifyText.BackgroundTransparency = 1
    NotifyText.ZIndex = 10
    NotifyText.TextScaled = true
    NotifyText.TextXAlignment = Enum.TextXAlignment.Left
    NotifyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifyText.Parent = NotifyMain

    local UIPadding = Instance.new('UIPadding')
    UIPadding.PaddingBottom = UDim.new(0.25, 0)
    UIPadding.PaddingLeft = UDim.new(0.1, 0)
    UIPadding.PaddingRight = UDim.new(0.1, 0)
    UIPadding.PaddingTop = UDim.new(0.25, 0)
    UIPadding.Parent = NotifyText

    local NotifyFill = Instance.new('Frame')
    NotifyFill.Size = UDim2.fromScale(0, 1)
    NotifyFill.BorderSizePixel = 0
    NotifyFill.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
    NotifyFill.BackgroundTransparency = 0
    NotifyFill.Parent = NotifyMain
    addGradient(NotifyFill)
    addCorner(NotifyFill)
    addBlur(NotifyFill)

    TweenService:Create(NotifyMain,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Position = UDim2.fromScale(0, 0)}):Play()
    TweenService:Create(UIScale,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Scale = 1}):Play()
    TweenService:Create(NotifyFill,TweenInfo.new(Notify.Duration,Enum.EasingStyle.Linear),{Size =  UDim2.fromScale(1, 1)}):Play()

    function Notify:Delete()
        if Notify.Status then return end
        Notify.Status = true
        TweenService:Create(NotifyMain,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Position = UDim2.fromScale(2, 0.2)}):Play()
        wait(1)
        NotifyFrame:ClearAllChildren()
        NotifyFrame:Destroy()
    end
    NotifyText.MouseButton1Click:Connect(Notify.Delete)
    task.delay(Notify.Duration, Notify.Delete)
end

mainapi:Clean(UserInputService.InputBegan:Connect(function(inputObj)
	if not UserInputService:GetFocusedTextBox() and inputObj.KeyCode ~= Enum.KeyCode.Unknown then
		if table.find(mainapi.Keybind, inputObj.KeyCode.Name) then
			if mainapi.ThreadFix then setthreadidentity(8) end
			mainapi.ClickGuiStatus = not mainapi.ClickGuiStatus
            mainapi.MainScreenGui.Modal.Visible = mainapi.ClickGuiStatus
            TweenService:Create(ClickGui.UIScale,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Scale = mainapi.ClickGuiStatus and mainapi.Scale.Value or 0}):Play()
            TweenService:Create(Gradient,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Transparency = mainapi.ClickGuiStatus and 0.6 or 1}):Play()
            TweenService:Create(Gradient2,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Transparency = mainapi.ClickGuiStatus and 0.6 or 1}):Play()
            TweenService:Create(Gradient,TweenInfo.new(2,Enum.EasingStyle.Exponential),{ImageTransparency = mainapi.ClickGuiStatus and 0.76 or 1}):Play()
            TweenService:Create(Gradient2,TweenInfo.new(2,Enum.EasingStyle.Exponential),{ImageTransparency = mainapi.ClickGuiStatus and 0.9 or 1}):Play()
            TweenService:Create(mainapi.TargetHudFrame.Frame.UIScale,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{Scale = mainapi.ClickGuiStatus and (TargetHudScale.Value or 1) or 0}):Play()
		end
	end
    for i, v in mainapi.Modules do
        if inputObj.KeyCode.Name == v.Bind.Name then
            v:Toggle()
            mainapi:Notify({Text = v.Name.." has been "..(v.Enabled and "Enabled" or "Disabled"); Duration = 1.5;})
        end
    end
end))

local Theme = {}
function mainapi:SaveOptions(object, savedoptions)
	if not savedoptions then return end
	savedoptions = {}
	for _, v in object.Settings do
		if not v.Save then continue end
		v:Save(savedoptions)
	end
	return savedoptions
end

function mainapi:Save()
    local savedata = {Modules = {}}
    for i, v in self.Modules do
		savedata.Modules[i] = {
			Enabled = v.Enabled;
            Expanded = v.Expanded;
			Bind = v.Bind.Name;
			Settings = mainapi:SaveOptions(v, true);
		}
	end
    local guidata = {TargetHud = {};}
    guidata.Theme = Theme.Value
    guidata.TargetHud = {X = TargetHudMain.AbsolutePosition.X; Y = TargetHudMain.AbsolutePosition.Y;}
    writefile('Modern/Config/'..self.Place..'.txt', HttpService:JSONEncode(savedata))
    writefile('Modern/Config/Gui.txt', HttpService:JSONEncode(guidata))
end

function mainapi:LoadOptions(object, savedoptions)
	for i, v in savedoptions do
		local option = object.Settings[i]
		if not option then continue end
		option:Load(v)
	end
end
function mainapi:Load()
    local savecheck = true
    if isfile('Modern/Config/'..self.Place..'.txt') then
		local savedata = loadJson('Modern/Config/'..self.Place..'.txt')
		if not savedata then savedata = {Modules = {}} savecheck = false end
		for i, v in savedata.Modules do
			local object = self.Modules[i]
			if not object then continue end
			if object.Settings and v.Settings then self:LoadOptions(object, v.Settings) end
			if v.Enabled ~= object.Enabled then object:Toggle() end
            if v.Expanded ~= object.Expanded then object:Expand() end
            local keycode
            pcall(function() keycode = Enum.KeyCode[v.Bind] end)
            if keycode then object:SetBind(keycode) end
		end
    end
    if isfile('Modern/Config/Gui.txt') then
        local savedata = loadJson('Modern/Config/Gui.txt')
        if not savedata then savedata = {} end
        if savedata.TargetHud.X and savedata.TargetHud.Y then
            if TargetHudMain then TargetHudMain.Position = UDim2.fromOffset(savedata.TargetHud.X, savedata.TargetHud.Y) end
        end
        if savedata.Theme and self.Modules.Interface then
            self.Modules.Interface.Settings.Theme:Load({Value = savedata.Theme})
            self.Modules.Interface:Toggle()
        end
    end
    self.Loaded = savecheck
end

function mainapi:Uninject()
    mainapi:Save()
    mainapi.Loaded = nil
    for _, v in self.Modules do if v.Enabled then v:Toggle() end end
    for _, v in mainapi.Connections do pcall(function() v:Disconnect() end) end
    if mainapi.ThreadFix then setthreadidentity(8) end
    mainapi.MainScreenGui:ClearAllChildren()
    mainapi.MainScreenGui:Destroy()
    table.clear(mainapi.Libraries)
    loopClean(mainapi)
    shared.Modern = nil
end

function mainapi:SendChat(Text)
    game:GetService("TextChatService").TextChannels.RBXSystem:DisplaySystemMessage("<b><font color = \"rgb(150, 150, 150)\">[</font><font color = \"rgb(84, 140, 209)\">Modern Client</font><font color = \"rgb(150, 150, 150)\">]</font></b>: "..Text)
end
local function Bind(message)
    if message.TextSource and message.Status == Enum.TextChatMessageStatus.Sending then
        if message.Text:find('^.bind') then
            local Text = message.Text:split(' ')
            local keycode
            pcall(function() keycode = Enum.KeyCode[Text[3]] end)
            if Text[2] then Text[2] = Text[2]:gsub("_", " ") end
			if #Text == 3 and keycode and mainapi.Modules[Text[2]] then
                mainapi.Modules[Text[2]]:SetBind(keycode)
                mainapi:SendChat(Text[2].." has been bound to "..Text[3])
            else
                mainapi:SendChat("Error")
            end
			message.Text = ""
		elseif message.Text:find('^.clearbind') or message.Text:find('^.unbind') then
            local Text = message.Text:split(' ')
            if Text[2] then Text[2] = Text[2]:gsub("_", " ") end
            if #Text == 2 and mainapi.Modules[Text[2]] then
                mainapi.Modules[Text[2]]:SetBind({})
                mainapi:SendChat("Unbound "..Text[2])
            else
                mainapi:SendChat("Error")
            end
            message.Text = ""
        end
	end
end
task.spawn(function()
    repeat
        TextChatService.OnIncomingMessage = Bind
        task.wait(1)
    until not (mainapi.Loaded or shared.ModernLoading)
end)

local Combat = mainapi:AddCatalog({Name = 'Combat';});
local Render = mainapi:AddCatalog({Name = 'Render';});
local Movement = mainapi:AddCatalog({Name = 'Movement';});
local Player = mainapi:AddCatalog({Name = 'Player';});
local Other = mainapi:AddCatalog({Name = 'Other';});
local Visual = mainapi:AddCatalog({Name = 'Visual';});

run(function()
    local 스킨체인저 = Visual:AddModule({
        Name = "스킨 체인저",
        Function = function(callback) end
    })

    for weapon, skins in pairs(weaponSkins) do
        if #skins > 0 then
            local 옵션 = {"기본"}
            for _, skin in ipairs(skins) do
                table.insert(옵션, skin)
            end

            스킨체인저:AddDropdown({
                Name = weapon,
                List = 옵션,
                Default = "기본",
                Function = function(selected)
                    if selected == "기본" then
                        Functions:swapWeaponSkins(weapon, nil, false)
                    else
                        Functions:swapWeaponSkins(weapon, selected, true)
                    end
                end
            })
        end
    end

    local 설명 = 스킨체인저:AddToggle({
        Name = "설명",
        Default = false,
        Function = function() end
    })
    설명.ExtraText = function()
        return "(뷰모델 스킨 변경)"
    end
end)

shared.Modern = mainapi
