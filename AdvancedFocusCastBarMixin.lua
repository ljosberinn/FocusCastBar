---@type string, AdvancedFocusCastBar
local addonName, Private = ...
local LibCustomGlow = LibStub("LibCustomGlow-1.0")
local LibEditMode = LibStub("LibEditMode")
local LibSharedMedia = LibStub("LibSharedMedia-3.0")

---@class AdvancedFocusCastBarMixin
AdvancedFocusCastBarMixin = {}

function AdvancedFocusCastBarMixin:OnLoad()
	self:Hide()

	-- initial layouting
	do
		self.CastBar.InterruptBar.Tick = self.CastBar.InterruptBar:CreateTexture()

		do
			local color = CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorInterruptTick)
			self.CastBar.InterruptBar.Tick:SetColorTexture(color.r, color.g, color.b)
		end

		self.CastBar.InterruptBar.Tick:SetSize(2, AdvancedFocusCastBarSaved.Settings.Height)
		self:AdjustDirection(false)
		self.CastBar.InterruptBar.Tick:AddMaskTexture(self.CastBar.Mask)
		self.CastBar:SetStatusBarTexture(AdvancedFocusCastBarSaved.Settings.Texture)

		PixelUtil.SetSize(self, AdvancedFocusCastBarSaved.Settings.Width, AdvancedFocusCastBarSaved.Settings.Height)
		PixelUtil.SetSize(
			self.Icon,
			AdvancedFocusCastBarSaved.Settings.Height,
			AdvancedFocusCastBarSaved.Settings.Height
		)
		self:AdjustIconLayout(AdvancedFocusCastBarSaved.Settings.ShowIcon)
		self:AdjustSpellNameTextWidth()

		do
			local texture = self.CastBar:GetStatusBarTexture()
			if texture then
				texture:SetDrawLayer("BORDER")
			end
		end

		self.Border:SetBackdrop({
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
		})
		self.Border:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
		self.Border:SetShown(AdvancedFocusCastBarSaved.Settings.ShowBorder)
		self:SetFontAndFontSize()
		self:ToggleTargetNameVisibility()
	end

	-- edit mode setup
	do
		self.firstFrameTimestamp = 0

		LibEditMode:RegisterCallback("enter", GenerateClosure(self.OnEditModeEnter, self))
		LibEditMode:RegisterCallback("exit", GenerateClosure(self.OnEditModeExit, self))
		LibEditMode:RegisterCallback("layout", GenerateClosure(self.RestoreEditModePosition, self))

		Private.EventRegistry:RegisterCallback(
			Private.Enum.Events.EDIT_MODE_POSITION_CHANGED,
			self.OnEvent,
			self,
			Private.Enum.Events.EDIT_MODE_POSITION_CHANGED
		)

		local defaults = Private.Settings.GetDefaultSettings()

		LibEditMode:AddFrame(self, GenerateClosure(self.OnEditModePositionChange, self), {
			point = defaults.Point,
			x = defaults.OffsetX,
			y = defaults.OffsetY,
		}, Private.L.EditMode.AddonName)

		---@param key SettingKey
		---@return SliderSettings
		local function GetSliderSettingsForOption(key)
			if key == Private.Enum.SettingsKey.TickWidth then
				return {
					min = 0,
					max = 16,
					step = 1,
				}
			end

			if key == Private.Enum.SettingsKey.FontSize then
				return {
					min = 8,
					max = 32,
					step = 1,
				}
			end

			if key == Private.Enum.SettingsKey.Opacity then
				return {
					min = 0.2,
					max = 1,
					step = 0.01,
				}
			end

			if key == Private.Enum.SettingsKey.OutOfRangeOpacity then
				return {
					min = 0.2,
					max = 1,
					step = 0.01,
				}
			end

			if key == Private.Enum.SettingsKey.BackgroundOpacity then
				return {
					min = 0,
					max = 1,
					step = 0.01,
				}
			end

			if key == Private.Enum.SettingsKey.Width then
				return {
					min = 10,
					max = 400,
					step = 1,
				}
			end

			if key == Private.Enum.SettingsKey.Height then
				return {
					min = 10,
					max = 200,
					step = 1,
				}
			end

			if key == Private.Enum.SettingsKey.OffsetX then
				local width = GetPhysicalScreenSize()

				return {
					min = -(width / 2),
					max = (width / 2),
					step = 1,
				}
			end

			if key == Private.Enum.SettingsKey.OffsetY then
				local width, height = GetPhysicalScreenSize()

				return {
					min = -(height / 2),
					max = height / 2,
					step = 1,
				}
			end

			error(
				string.format(
					"Slider Settings for key '%s' are either not implemented or you're calling this with the wrong key.",
					key
				)
			)
		end

		---@param key SettingKey
		---@return LibEditModeSetting
		local function CreateSetting(key)
			if key == Private.Enum.SettingsKey.PlayFocusTTSReminder then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.PlayFocusTTSReminder
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.PlayFocusTTSReminder = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.PlayFocusTTSReminderLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.PlayFocusTTSReminderTooltip,
					default = defaults.PlayFocusTTSReminder,
					get = Get,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.Opacity then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.Opacity
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					value = math.floor(value * 100) / 100
					if value ~= AdvancedFocusCastBarSaved.Settings.Opacity then
						AdvancedFocusCastBarSaved.Settings.Opacity = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.OpacityLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.Opacity,
					desc = Private.L.Settings.OpacityTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
					formatter = FormatPercentage,
				}
			end

			if key == Private.Enum.SettingsKey.OutOfRangeOpacity then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.OutOfRangeOpacity
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					value = math.floor(value * 100) / 100
					if value ~= AdvancedFocusCastBarSaved.Settings.OutOfRangeOpacity then
						AdvancedFocusCastBarSaved.Settings.OutOfRangeOpacity = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.OutOfRangeOpacityLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.OutOfRangeOpacity,
					desc = Private.L.Settings.OutOfRangeOpacityTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
					formatter = FormatPercentage,
				}
			end

			if key == Private.Enum.SettingsKey.BackgroundOpacity then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.BackgroundOpacity
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					value = math.floor(value * 100) / 100
					if value ~= AdvancedFocusCastBarSaved.Settings.BackgroundOpacity then
						AdvancedFocusCastBarSaved.Settings.BackgroundOpacity = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.BackgroundOpacityLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.BackgroundOpacity,
					desc = Private.L.Settings.BackgroundOpacityTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
					formatter = FormatPercentage,
				}
			end

			if key == Private.Enum.SettingsKey.TickWidth then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.TickWidth
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.TickWidth then
						AdvancedFocusCastBarSaved.Settings.TickWidth = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.TickWidthLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.TickWidth,
					desc = Private.L.Settings.TickWidthTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
				}
			end

			if key == Private.Enum.SettingsKey.FontSize then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.FontSize
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.FontSize then
						AdvancedFocusCastBarSaved.Settings.FontSize = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.FontSizeLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.FontSize,
					desc = Private.L.Settings.FontSizeTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
				}
			end

			if key == Private.Enum.SettingsKey.ShowTargetMarker then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowTargetMarker
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.ShowTargetMarker = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.ShowTargetMarkerLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.ShowTargetMarkerTooltip,
					default = defaults.ShowTargetMarker,
					get = Get,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.GlowImportant then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.GlowImportant
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.GlowImportant = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.GlowImportantLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.GlowImportantTooltip,
					default = defaults.GlowImportant,
					get = Get,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.Font then
				---@param layoutName string
				---@param value string
				local function Set(layoutName, value)
					if AdvancedFocusCastBarSaved.Settings.Font ~= value then
						AdvancedFocusCastBarSaved.Settings.Font = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				---@param path string
				---@param label string
				---@return string globalName
				local function CreateAndGetFontIfNeeded(path, label)
					local sanitizedName = string.gsub(label, " ", "")
					local globalName = addonName .. "_" .. sanitizedName

					if _G[globalName] == nil then
						local locale = GAME_LOCALE or GetLocale()
						local overrideAlphabet = "roman"
						if locale == "koKR" then
							overrideAlphabet = "korean"
						elseif locale == "zhCN" then
							overrideAlphabet = "simplifiedchinese"
						elseif locale == "zhTW" then
							overrideAlphabet = "traditionalchinese"
						elseif locale == "ruRU" then
							overrideAlphabet = "russian"
						end

						local members = {}
						local coreFont = GameFontNormal
						local alphabets = { "roman", "korean", "simplifiedchinese", "traditionalchinese", "russian" }
						for _, alphabet in ipairs(alphabets) do
							local forAlphabet = coreFont:GetFontObjectForAlphabet(alphabet)
							local file, size, _ = forAlphabet:GetFont()
							if alphabet == overrideAlphabet then
								table.insert(members, {
									alphabet = alphabet,
									file = path,
									height = size,
									flags = "",
								})
							else
								table.insert(members, {
									alphabet = alphabet,
									file = file,
									height = size,
									flags = "",
								})
							end
						end

						local font = CreateFontFamily(globalName, members)
						font:SetTextColor(1, 1, 1)
						_G[globalName] = font
					end

					return globalName
				end

				local function Generator(owner, rootDescription, data)
					local fonts = CopyTable(LibSharedMedia:List(LibSharedMedia.MediaType.FONT))
					table.sort(fonts)
					local byLabel = LibSharedMedia:HashTable(LibSharedMedia.MediaType.FONT)

					for index, label in pairs(fonts) do
						local path = byLabel[label]

						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.Font == path
						end

						local function SetProxy()
							Set(LibEditMode:GetActiveLayoutName(), path)
						end

						local radio = rootDescription:CreateRadio(label, IsEnabled, SetProxy)

						radio:AddInitializer(function(button, elementDescription, menu)
							local globalName = CreateAndGetFontIfNeeded(path, label)
							button.fontString:SetFontObject(globalName)
						end)
					end

					rootDescription:SetScrollMode(30 * 20)
				end

				---@type LibEditModeDropdown
				return {
					name = Private.L.Settings.FontLabel,
					kind = Enum.EditModeSettingDisplayType.Dropdown,
					desc = Private.L.Settings.FontTooltip,
					default = defaults.Font,
					multiple = false,
					generator = Generator,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.Point then
				---@param layoutName string
				---@param value string
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.Point = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.EDIT_MODE_POSITION_CHANGED)
				end

				local function Generator(owner, rootDescription, data)
					for pointKey, value in pairs(Private.Enum.Point) do
						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.Point == value
						end

						local function SetProxy()
							Set(LibEditMode:GetActiveLayoutName(), value)
						end

						rootDescription:CreateRadio(value, IsEnabled, SetProxy)
					end
				end

				---@type LibEditModeDropdown
				return {
					name = Private.L.Settings.PointLabel,
					kind = Enum.EditModeSettingDisplayType.Dropdown,
					desc = Private.L.Settings.PointTooltip,
					default = defaults.Point,
					multiple = false,
					generator = Generator,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.Texture then
				---@param layoutName string
				---@param value string
				local function Set(layoutName, value)
					if AdvancedFocusCastBarSaved.Settings.Texture ~= value then
						AdvancedFocusCastBarSaved.Settings.Texture = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				local function Generator(owner, rootDescription, data)
					local textures = CopyTable(LibSharedMedia:List(LibSharedMedia.MediaType.STATUSBAR))
					table.sort(textures)
					local byLabel = LibSharedMedia:HashTable(LibSharedMedia.MediaType.STATUSBAR)

					for index, label in pairs(textures) do
						local path = byLabel[label]

						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.Texture == path
						end

						local function SetProxy()
							Set(LibEditMode:GetActiveLayoutName(), path)
						end

						rootDescription:CreateRadio(
							string.format("|T%s:%d:%d|t %s", path, 19, 19, label),
							IsEnabled,
							SetProxy
						)
					end

					rootDescription:SetScrollMode(30 * 20)
				end

				---@type LibEditModeDropdown
				return {
					name = Private.L.Settings.TextureLabel,
					kind = Enum.EditModeSettingDisplayType.Dropdown,
					desc = Private.L.Settings.TextureTooltip,
					default = defaults.Texture,
					multiple = false,
					generator = Generator,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.ColorUninterruptible then
				---@param layoutName string
				---@param value ColorMixin
				local function Set(layoutName, value)
					local color = value:GenerateHexColor()

					if AdvancedFocusCastBarSaved.Settings.ColorUninterruptible ~= color then
						AdvancedFocusCastBarSaved.Settings.ColorUninterruptible = color
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, color)
					end
				end

				---@return colorRGBA
				local function Get()
					return CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorUninterruptible)
				end

				---@type LibEditModeColorPicker
				return {
					name = Private.L.Settings.ColorUninterruptibleLabel,
					desc = Private.L.Settings.ColorUninterruptibleTooltip,
					default = CreateColorFromHexString(defaults.ColorUninterruptible),
					set = Set,
					get = Get,
					kind = LibEditMode.SettingType.ColorPicker,
				}
			end

			if key == Private.Enum.SettingsKey.ColorInterruptibleCanInterrupt then
				---@param layoutName string
				---@param value ColorMixin
				local function Set(layoutName, value)
					local color = value:GenerateHexColor()
					if AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt ~= color then
						AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt = color
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, color)
					end
				end

				---@return colorRGBA
				local function Get()
					return CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt)
				end

				---@type LibEditModeColorPicker
				return {
					name = Private.L.Settings.ColorInterruptibleCanInterruptLabel,
					desc = Private.L.Settings.ColorInterruptibleCanInterruptTooltip,
					default = CreateColorFromHexString(defaults.ColorInterruptibleCanInterrupt),
					set = Set,
					get = Get,
					kind = LibEditMode.SettingType.ColorPicker,
				}
			end

			if key == Private.Enum.SettingsKey.ColorInterruptibleCannotInterrupt then
				---@param layoutName string
				---@param value ColorMixin
				local function Set(layoutName, value)
					local color = value:GenerateHexColor()

					if AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt ~= color then
						AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt = color
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, color)
					end
				end

				---@return colorRGBA
				local function Get()
					return CreateColorFromHexString(
						AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt
					)
				end

				---@type LibEditModeColorPicker
				return {
					name = Private.L.Settings.ColorInterruptibleCannotInterruptLabel,
					desc = Private.L.Settings.ColorInterruptibleCannotInterruptTooltip,
					default = CreateColorFromHexString(defaults.ColorInterruptibleCannotInterrupt),
					set = Set,
					get = Get,
					kind = LibEditMode.SettingType.ColorPicker,
				}
			end

			if key == Private.Enum.SettingsKey.ColorInterruptTick then
				---@param layoutName string
				---@param value ColorMixin
				local function Set(layoutName, value)
					local color = value:GenerateHexColor()

					if AdvancedFocusCastBarSaved.Settings.ColorInterruptTick ~= color then
						AdvancedFocusCastBarSaved.Settings.ColorInterruptTick = color
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, color)
					end
				end

				---@return colorRGBA
				local function Get()
					return CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorInterruptTick)
				end

				---@type LibEditModeColorPicker
				return {
					name = Private.L.Settings.ColorInterruptTickLabel,
					desc = Private.L.Settings.ColorInterruptTickTooltip,
					default = CreateColorFromHexString(defaults.ColorInterruptTick),
					set = Set,
					get = Get,
					kind = LibEditMode.SettingType.ColorPicker,
				}
			end

			if key == Private.Enum.SettingsKey.ShowBorder then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowBorder
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.ShowBorder = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.ShowBorderLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.ShowBorderTooltip,
					default = defaults.ShowBorder,
					get = Get,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.ShowTargetName then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowTargetName
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.ShowTargetName = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)

					if value then
						LibEditMode:EnableFrameSetting(self, Private.L.Settings.ShowTargetClassColorLabel)
					else
						LibEditMode:DisableFrameSetting(self, Private.L.Settings.ShowTargetClassColorLabel)
					end
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.ShowTargetNameLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.ShowTargetNameTooltip,
					default = defaults.ShowTargetName,
					get = Get,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.ShowTargetClassColor then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowTargetClassColor
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.ShowTargetClassColor = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.ShowTargetClassColorLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.ShowTargetClassColorTooltip,
					default = defaults.ShowTargetClassColor,
					get = Get,
					set = Set,
					disabled = not AdvancedFocusCastBarSaved.Settings.ShowTargetName,
				}
			end

			if key == Private.Enum.SettingsKey.IgnoreFriendlies then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.IgnoreFriendlies
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.IgnoreFriendlies = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.IgnoreFriendliesLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.IgnoreFriendliesTooltip,
					default = defaults.IgnoreFriendlies,
					get = Get,
					set = Set,
					disabled = not AdvancedFocusCastBarSaved.Settings.ShowTargetName,
				}
			end

			if key == Private.Enum.SettingsKey.ShowIcon then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowIcon
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.ShowIcon = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.ShowIconLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.ShowIconTooltip,
					default = defaults.ShowIcon,
					get = Get,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.ShowCastTime then
				---@param layoutName string
				---@return boolean
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowCastTime
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					AdvancedFocusCastBarSaved.Settings.ShowCastTime = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end

				---@type LibEditModeCheckbox
				return {
					name = Private.L.Settings.ShowCastTimeLabel,
					kind = Enum.EditModeSettingDisplayType.Checkbox,
					desc = Private.L.Settings.ShowCastTimeTooltip,
					default = defaults.ShowCastTime,
					get = Get,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.LoadConditionContentType then
				local function Generator(owner, rootDescription, data)
					for label, id in pairs(Private.Enum.ContentType) do
						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.LoadConditionContentType[id]
						end

						local function Toggle()
							AdvancedFocusCastBarSaved.Settings.LoadConditionContentType[id] =
								not AdvancedFocusCastBarSaved.Settings.LoadConditionContentType[id]

							Private.EventRegistry:TriggerEvent(
								Private.Enum.Events.SETTING_CHANGED,
								key,
								AdvancedFocusCastBarSaved.Settings.LoadConditionContentType
							)
						end

						local translated = Private.L.Settings.LoadConditionContentTypeLabels[id]
						rootDescription:CreateCheckbox(translated, IsEnabled, Toggle, {
							value = label,
							multiple = true,
						})
					end
				end

				---@param layoutName string
				---@param values table<string, boolean>
				local function Set(layoutName, values)
					local hasChanges = false

					for id, bool in pairs(values) do
						if AdvancedFocusCastBarSaved.Settings.LoadConditionContentType[id] ~= bool then
							AdvancedFocusCastBarSaved.Settings.LoadConditionContentType[id] = bool
							hasChanges = true
						end
					end

					if hasChanges then
						Private.EventRegistry:TriggerEvent(
							Private.Enum.Events.SETTING_CHANGED,
							key,
							AdvancedFocusCastBarSaved.Settings.LoadConditionContentType
						)
					end
				end

				---@type LibEditModeDropdown
				return {
					name = Private.L.Settings.LoadConditionContentTypeLabelAbbreviated,
					kind = Enum.EditModeSettingDisplayType.Dropdown,
					default = defaults.LoadConditionContentType,
					desc = Private.L.Settings.LoadConditionContentTypeTooltip,
					generator = Generator,
					-- technically is a reset only
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.LoadConditionRole then
				local function Generator(owner, rootDescription, data)
					for label, id in pairs(Private.Enum.Role) do
						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.LoadConditionRole[id] == true
						end

						local function Toggle()
							AdvancedFocusCastBarSaved.Settings.LoadConditionRole[id] =
								not AdvancedFocusCastBarSaved.Settings.LoadConditionRole[id]

							Private.EventRegistry:TriggerEvent(
								Private.Enum.Events.SETTING_CHANGED,
								key,
								AdvancedFocusCastBarSaved.Settings.LoadConditionRole
							)
						end

						local translated = Private.L.Settings.LoadConditionRoleLabels[id]

						rootDescription:CreateCheckbox(translated, IsEnabled, Toggle, {
							value = label,
							multiple = true,
						})
					end
				end

				---@param layoutName string
				---@param values table<string, boolean>
				local function Set(layoutName, values)
					local hasChanges = false

					for id, bool in pairs(values) do
						if AdvancedFocusCastBarSaved.Settings.LoadConditionRole[id] ~= bool then
							AdvancedFocusCastBarSaved.Settings.LoadConditionRole[id] = bool
							hasChanges = true
						end
					end

					if hasChanges then
						Private.EventRegistry:TriggerEvent(
							Private.Enum.Events.SETTING_CHANGED,
							key,
							AdvancedFocusCastBarSaved.Settings.LoadConditionRole
						)
					end
				end

				---@type LibEditModeDropdown
				return {
					name = Private.L.Settings.LoadConditionRoleLabelAbbreviated,
					kind = Enum.EditModeSettingDisplayType.Dropdown,
					default = defaults.LoadConditionRole,
					desc = Private.L.Settings.LoadConditionRoleTooltip,
					generator = Generator,
					-- technically is a reset only
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.Width then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.Width
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.Width then
						AdvancedFocusCastBarSaved.Settings.Width = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.FrameWidthLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.Width,
					desc = Private.L.Settings.FrameWidthTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
				}
			end

			if key == Private.Enum.SettingsKey.Height then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.Height
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.Height then
						AdvancedFocusCastBarSaved.Settings.Height = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.FrameHeightLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.Height,
					desc = Private.L.Settings.FrameHeightTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
				}
			end

			if key == Private.Enum.SettingsKey.OffsetX then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.OffsetX
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.OffsetX then
						AdvancedFocusCastBarSaved.Settings.OffsetX = value

						Private.EventRegistry:TriggerEvent(Private.Enum.Events.EDIT_MODE_POSITION_CHANGED)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.OffsetXLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.OffsetX,
					desc = Private.L.Settings.OffsetXTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
				}
			end

			if key == Private.Enum.SettingsKey.OffsetY then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				---@return number
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.OffsetY
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.OffsetY then
						AdvancedFocusCastBarSaved.Settings.OffsetY = value

						Private.EventRegistry:TriggerEvent(Private.Enum.Events.EDIT_MODE_POSITION_CHANGED)
					end
				end

				---@type LibEditModeSlider
				return {
					name = Private.L.Settings.OffsetYLabel,
					kind = Enum.EditModeSettingDisplayType.Slider,
					default = defaults.OffsetY,
					desc = Private.L.Settings.OffsetYTooltip,
					get = Get,
					set = Set,
					minValue = sliderSettings.min,
					maxValue = sliderSettings.max,
					valueStep = sliderSettings.step,
				}
			end

			error(
				string.format(
					"Edit Mode Settings for key '%s' are either not implemented or you're calling this with the wrong key.",
					key or "NO KEY"
				)
			)
		end

		local settingsOrder = {
			Private.Enum.SettingsKey.Width,
			Private.Enum.SettingsKey.Height,
			Private.Enum.SettingsKey.LoadConditionContentType,
			Private.Enum.SettingsKey.LoadConditionRole,
			Private.Enum.SettingsKey.Texture,
			Private.Enum.SettingsKey.ShowIcon,
			Private.Enum.SettingsKey.ShowCastTime,
			Private.Enum.SettingsKey.Opacity,
			Private.Enum.SettingsKey.OutOfRangeOpacity,
			Private.Enum.SettingsKey.BackgroundOpacity,
			Private.Enum.SettingsKey.Font,
			Private.Enum.SettingsKey.FontSize,
			Private.Enum.SettingsKey.ShowBorder,
			Private.Enum.SettingsKey.GlowImportant,
			Private.Enum.SettingsKey.ColorUninterruptible,
			Private.Enum.SettingsKey.ColorInterruptibleCanInterrupt,
			Private.Enum.SettingsKey.ColorInterruptibleCannotInterrupt,
			Private.Enum.SettingsKey.ColorInterruptTick,
			Private.Enum.SettingsKey.TickWidth,
			Private.Enum.SettingsKey.ShowTargetMarker,
			Private.Enum.SettingsKey.ShowTargetName,
			Private.Enum.SettingsKey.ShowTargetClassColor,
			Private.Enum.SettingsKey.PlayFocusTTSReminder,
			Private.Enum.SettingsKey.IgnoreFriendlies,
			Private.Enum.SettingsKey.Point,
			Private.Enum.SettingsKey.OffsetX,
			Private.Enum.SettingsKey.OffsetY,
		}

		local settings = {}

		for i, key in ipairs(settingsOrder) do
			table.insert(settings, CreateSetting(key))
		end

		LibEditMode:AddFrameSettings(self, settings)

		local function OnImportButtonClick()
			StaticPopupDialogs[addonName] = {
				id = addonName,
				whileDead = true,
				text = Private.L.Settings.Import,
				button1 = Private.L.Settings.Import,
				button2 = CLOSE,
				hasEditBox = true,
				hasWideEditBox = true,
				editBoxWidth = 350,
				hideOnEscape = true,
				OnAccept = function(popupSelf)
					local editBox = popupSelf:GetEditBox()
					local importString = editBox:GetText()

					local ok, result = pcall(function()
						-- return C_EncodingUtil.DeserializeJSON(importString)
						return C_EncodingUtil.DeserializeCBOR(C_EncodingUtil.DecodeBase64(importString))
					end, string)

					if not ok then
						if result ~= nil then
							print(result)
						end

						return false
					end

					-- just a type check
					if result == nil then
						return false
					end

					local hasAnyChange = false

					for key, defaultValue in pairs(defaults) do
						local newValue = result[key]
						local expectedType = type(defaultValue)

						if newValue ~= nil and type(newValue) == expectedType then
							local eventKey = Private.Enum.SettingsKey[key]
							local event = Private.Enum.Events.SETTING_CHANGED
							if
								eventKey == Private.Enum.SettingsKey.Point
								or eventKey == Private.Enum.SettingsKey.OffsetX
								or eventKey == Private.Enum.SettingsKey.OffsetY
							then
								event = Private.Enum.Events.EDIT_MODE_POSITION_CHANGED
							end
							local hasChanges = false

							if expectedType == "table" then
								local enumToCompareAgainst = nil
								if key == "LoadConditionContentType" then
									enumToCompareAgainst = Private.Enum.ContentType
								elseif key == "LoadConditionRole" then
									enumToCompareAgainst = Private.Enum.Role
								end

								if enumToCompareAgainst then
									local newTable = {}

									for _, id in pairs(enumToCompareAgainst) do
										if newValue[id] == nil then
											newTable[id] = AdvancedFocusCastBarSaved.Settings[key][id]
										else
											newTable[id] = newValue[id]

											if newValue[id] ~= AdvancedFocusCastBarSaved.Settings[key][id] then
												hasChanges = true
											end
										end
									end

									if hasChanges then
										AdvancedFocusCastBarSaved.Settings[key] = newTable
										Private.EventRegistry:TriggerEvent(event, eventKey, newTable)
									end
								end
							elseif newValue ~= AdvancedFocusCastBarSaved.Settings[key] then
								AdvancedFocusCastBarSaved.Settings[key] = newValue
								hasChanges = true

								if eventKey and hasChanges then
									Private.EventRegistry:TriggerEvent(event, eventKey, newValue)
								end
							end

							if hasChanges then
								hasAnyChange = true
							end
						end
					end

					if hasAnyChange and LibEditMode:IsInEditMode() then
						LibEditMode:RefreshFrameSettings(self)
					end
				end,
			}

			StaticPopup_Hide(addonName)
			StaticPopup_Show(addonName)
		end

		local function OnExportButtonClick()
			local exportString =
				C_EncodingUtil.EncodeBase64(C_EncodingUtil.SerializeCBOR(AdvancedFocusCastBarSaved.Settings))
			-- local exportString = C_EncodingUtil.SerializeJSON(AdvancedFocusCastBarSaved.Settings)

			StaticPopupDialogs[addonName] = {
				id = addonName,
				whileDead = true,
				text = Private.L.Settings.Export,
				button1 = ACCEPT,
				hasEditBox = true,
				hasWideEditBox = true,
				editBoxWidth = 350,
				hideOnEscape = true,
				OnShow = function(popupSelf)
					local editBox = popupSelf:GetEditBox()
					editBox:SetText(exportString)
					editBox:HighlightText()

					local ctrlDown = false

					editBox:SetScript("OnKeyDown", function(_, key)
						if key == "LCTRL" or key == "RCTRL" or key == "LMETA" or key == "RMETA" then
							ctrlDown = true
						end
					end)
					editBox:SetScript("OnKeyUp", function(_, key)
						C_Timer.After(0.2, function()
							ctrlDown = false
						end)

						if ctrlDown and (key == "C" or key == "X") then
							StaticPopup_Hide(addonName)
						end
					end)
				end,
				EditBoxOnEscapePressed = function(popupSelf)
					popupSelf:GetParent():Hide()
				end,
				EditBoxOnTextChanged = function(popupSelf)
					-- ctrl + x sets the text to "" but this triggers hiding and shouldn't trigger resetting the text
					local currentText = popupSelf:GetText()

					if currentText == "" or currentText == exportString then
						return
					end

					popupSelf:SetText(exportString)
				end,
			}

			StaticPopup_Hide(addonName)
			StaticPopup_Show(addonName)
		end

		LibEditMode:AddFrameSettingsButtons(self, {
			{
				click = OnImportButtonClick,
				text = Private.L.Settings.Import,
			},
			{
				click = OnExportButtonClick,
				text = Private.L.Settings.Export,
			},
		})

		-- dummy cast text is already AdvancedFocusCastBar and the selection label layering
		-- makes it impossible to see some of the options changing in real time
		self.Selection.Label:HookScript("OnShow", function(labelSelf)
			labelSelf:Hide()
		end)
	end

	Private.EventRegistry:RegisterCallback(Private.Enum.Events.SETTING_CHANGED, self.OnSettingsChange, self)

	self.colors = {
		ColorUninterruptible = CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorUninterruptible),
		ColorInterruptibleCanInterrupt = CreateColorFromHexString(
			AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt
		),
		ColorInterruptibleCannotInterrupt = CreateColorFromHexString(
			AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt
		),
	}

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("LOADING_SCREEN_DISABLED")
	self:RegisterEvent("UPDATE_INSTANCE_INFO")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("FIRST_FRAME_RENDERED")
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	-- start or update events
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "focus")
	-- end or failed events
	self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "focus")
	-- meta events
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "focus")
	self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "focus")
	self:ToggleTargetMarkerIntegration()
end

function AdvancedFocusCastBarMixin:AdjustSpellNameTextWidth()
	local iconSize = AdvancedFocusCastBarSaved.Settings.ShowIcon and AdvancedFocusCastBarSaved.Settings.Height or 0
	local castTimeSize = AdvancedFocusCastBarSaved.Settings.ShowCastTime
			and 2 * AdvancedFocusCastBarSaved.Settings.Height
		or 0
	local maxWidth = AdvancedFocusCastBarSaved.Settings.Width - 4 - iconSize - castTimeSize

	self.CastBar.SpellNameText:SetWidth(maxWidth)
end

function AdvancedFocusCastBarMixin:AdjustDirection(isChannel)
	self.CastBar:SetReverseFill(isChannel)
	self.CastBar.Positioner:SetReverseFill(isChannel)
	self.CastBar.InterruptBar:SetReverseFill(isChannel)

	self.CastBar.InterruptBar:ClearAllPoints()
	self.CastBar.InterruptBar.Tick:ClearAllPoints()

	if isChannel then
		self.CastBar.InterruptBar:SetPoint("RIGHT", self.CastBar.Positioner:GetStatusBarTexture(), "LEFT")
		self.CastBar.InterruptBar.Tick:SetPoint("RIGHT", self.CastBar.InterruptBar:GetStatusBarTexture(), "LEFT")
	else
		self.CastBar.InterruptBar:SetPoint("LEFT", self.CastBar.Positioner:GetStatusBarTexture(), "RIGHT")
		self.CastBar.InterruptBar.Tick:SetPoint("LEFT", self.CastBar.InterruptBar:GetStatusBarTexture(), "RIGHT")
	end
end

function AdvancedFocusCastBarMixin:IsPastLoadingScreen()
	return self.firstFrameTimestamp > 0 and (GetTime() - self.firstFrameTimestamp) > 1
end

function AdvancedFocusCastBarMixin:ToggleTargetMarkerIntegration()
	if AdvancedFocusCastBarSaved.Settings.ShowTargetMarker then
		self:RegisterEvent("RAID_TARGET_UPDATE")
	else
		self:UnregisterEvent("RAID_TARGET_UPDATE")
	end
end

function AdvancedFocusCastBarMixin:AdjustIconLayout(shown)
	self.CastBar:ClearAllPoints()

	PixelUtil.SetSize(self.Icon, AdvancedFocusCastBarSaved.Settings.Height, AdvancedFocusCastBarSaved.Settings.Height)

	if shown then
		self.Icon:ClearAllPoints()
		self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.Icon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.Icon:Show()

		self.CastBar:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 0)
		self.CastBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

		local adjustedWidth = AdvancedFocusCastBarSaved.Settings.Width - AdvancedFocusCastBarSaved.Settings.Height
		PixelUtil.SetSize(self.CastBar, adjustedWidth, AdvancedFocusCastBarSaved.Settings.Height)
		PixelUtil.SetSize(self.CastBar.Mask, adjustedWidth, AdvancedFocusCastBarSaved.Settings.Height)
		PixelUtil.SetSize(self.CastBar.Positioner, adjustedWidth, AdvancedFocusCastBarSaved.Settings.Height)
		PixelUtil.SetSize(self.CastBar.InterruptBar, adjustedWidth, AdvancedFocusCastBarSaved.Settings.Height)
		PixelUtil.SetSize(
			self.CastBar.InterruptBar.Tick,
			AdvancedFocusCastBarSaved.Settings.TickWidth,
			AdvancedFocusCastBarSaved.Settings.Height
		)
	else
		self.Icon:Hide()

		self.CastBar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.CastBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

		PixelUtil.SetSize(
			self.CastBar,
			AdvancedFocusCastBarSaved.Settings.Width,
			AdvancedFocusCastBarSaved.Settings.Height
		)

		PixelUtil.SetSize(
			self.CastBar.Mask,
			AdvancedFocusCastBarSaved.Settings.Width,
			AdvancedFocusCastBarSaved.Settings.Height
		)
		PixelUtil.SetSize(
			self.CastBar.Positioner,
			AdvancedFocusCastBarSaved.Settings.Width,
			AdvancedFocusCastBarSaved.Settings.Height
		)
		PixelUtil.SetSize(
			self.CastBar.InterruptBar,
			AdvancedFocusCastBarSaved.Settings.Width,
			AdvancedFocusCastBarSaved.Settings.Height
		)
		PixelUtil.SetSize(
			self.CastBar.InterruptBar.Tick,
			AdvancedFocusCastBarSaved.Settings.TickWidth,
			AdvancedFocusCastBarSaved.Settings.Height
		)
	end
end

function AdvancedFocusCastBarMixin:OnSettingsChange(key, value)
	if key == Private.Enum.SettingsKey.Width then
		self:SetWidth(value)
		self:AdjustIconLayout(AdvancedFocusCastBarSaved.Settings.ShowIcon)
		self:AdjustSpellNameTextWidth()
		self:HideGlow()
		self:ShowGlow(false)
	elseif key == Private.Enum.SettingsKey.Height then
		self:SetHeight(value)
		self:AdjustIconLayout(AdvancedFocusCastBarSaved.Settings.ShowIcon)
		self:AdjustSpellNameTextWidth()
		self:HideGlow()
		self:ShowGlow(false)
	elseif key == Private.Enum.SettingsKey.ShowIcon then
		self:AdjustIconLayout(value)
		self:AdjustSpellNameTextWidth()
	elseif key == Private.Enum.SettingsKey.ShowCastTime then
		self.CastBar.CastTimeText:SetShown(value)
		self:AdjustSpellNameTextWidth()
	elseif key == Private.Enum.SettingsKey.Opacity then
		self:SetAlpha(value)
	elseif key == Private.Enum.SettingsKey.ShowBorder then
		self:HideGlow()
		self.Border:SetShown(value)
		self:ShowGlow(false)
	elseif key == Private.Enum.SettingsKey.Texture then
		self.CastBar:SetStatusBarTexture(value)
	elseif key == Private.Enum.SettingsKey.Font then
		self:SetFontAndFontSize()
	elseif key == Private.Enum.SettingsKey.FontSize then
		self:SetFontAndFontSize()
	elseif key == Private.Enum.SettingsKey.GlowImportant then
		if value then
		else
			self:HideGlow()
		end
	elseif key == Private.Enum.SettingsKey.ColorUninterruptible then
		self.colors.ColorUninterruptible = CreateColorFromHexString(value)
	elseif key == Private.Enum.SettingsKey.ColorInterruptibleCanInterrupt then
		self.colors.ColorInterruptibleCanInterrupt = CreateColorFromHexString(value)
	elseif key == Private.Enum.SettingsKey.ColorInterruptibleCannotInterrupt then
		self.colors.ColorInterruptibleCannotInterrupt = CreateColorFromHexString(value)
	elseif key == Private.Enum.SettingsKey.ColorInterruptTick then
		self.colors.ColorInterruptTick = CreateColorFromHexString(value)
	elseif key == Private.Enum.SettingsKey.ShowTargetMarker then
		self:ToggleTargetMarkerIntegration()
		self.TargetMarkerFrame:SetShown(value)
	elseif key == Private.Enum.SettingsKey.BackgroundOpacity then
		self.CastBar.Background:SetAlpha(value)
	elseif key == Private.Enum.SettingsKey.ShowTargetName then
		self:ToggleTargetNameVisibility()
	elseif key == Private.Enum.SettingsKey.TickWidth then
		self.CastBar.InterruptBar.Tick:SetShown(value > 0)
		self.CastBar.InterruptBar.Tick:SetWidth(value)
	elseif key == Private.Enum.SettingsKey.OutOfRangeOpacity then
		if value == 1 then
			self:SetAlpha(1)
		end
	end
end

function AdvancedFocusCastBarMixin:ToggleTargetNameVisibility()
	for i = 1, 5 do
		local targetNameFrame = self.TargetNameFrame["TargetNameText" .. i]
		targetNameFrame:SetShown(AdvancedFocusCastBarSaved.Settings.ShowTargetName)
	end
end

function AdvancedFocusCastBarMixin:SetFontAndFontSize()
	local smallerSize = 0.66 * AdvancedFocusCastBarSaved.Settings.FontSize

	local frames = {
		[self.CastBar.CastTimeText] = AdvancedFocusCastBarSaved.Settings.FontSize,
		[self.CastBar.SpellNameText] = AdvancedFocusCastBarSaved.Settings.FontSize,
		[self.TargetNameFrame.TargetNameText1] = smallerSize,
		[self.TargetNameFrame.TargetNameText2] = smallerSize,
		[self.TargetNameFrame.TargetNameText3] = smallerSize,
		[self.TargetNameFrame.TargetNameText4] = smallerSize,
		[self.TargetNameFrame.TargetNameText5] = smallerSize,
	}

	for frame, targetFontSize in pairs(frames) do
		local font, size, flags = frame:GetFont()

		frame:SetFont(AdvancedFocusCastBarSaved.Settings.Font, targetFontSize, flags)
	end
end

function AdvancedFocusCastBarMixin:RestoreEditModePosition()
	self:ClearAllPoints()
	self:SetPoint(
		AdvancedFocusCastBarSaved.Settings.Point,
		AdvancedFocusCastBarSaved.Settings.OffsetX,
		AdvancedFocusCastBarSaved.Settings.OffsetY
	)
end

function AdvancedFocusCastBarMixin:OnEditModePositionChange(frame, layoutName, point, x, y)
	x = math.floor(x)
	y = math.floor(y)

	AdvancedFocusCastBarSaved.Settings.Point = point
	AdvancedFocusCastBarSaved.Settings.OffsetX = x
	AdvancedFocusCastBarSaved.Settings.OffsetY = y

	Private.EventRegistry:TriggerEvent(Private.Enum.Events.EDIT_MODE_POSITION_CHANGED)
end

do
	local PreviewIconDataProvider = nil

	function AdvancedFocusCastBarMixin:GetRandomIcon()
		if PreviewIconDataProvider == nil then
			PreviewIconDataProvider =
				CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook, true)
		end

		return PreviewIconDataProvider:GetRandomIcon()
	end
end

function AdvancedFocusCastBarMixin:LoopPreview()
	if not self:IsPastLoadingScreen() then
		return
	end

	local dummyDuration = C_DurationUtil.CreateDuration()
	dummyDuration:SetTimeFromStart(GetTime(), 3)

	self.castInformation = {
		duration = dummyDuration,
		isChannel = math.random(0, 1) == 1,
		name = addonName,
		notInterruptible = math.random(0, 1) == 1,
		texture = self:GetRandomIcon(),
		isImportant = math.random(0, 1) == 1,
	}

	if AdvancedFocusCastBarSaved.Settings.ShowTargetMarker then
		local index = math.random(0, 8)
		if index > 0 then
			SetRaidTargetIconTexture(self.TargetMarkerFrame.TargetMarker, index)
			self.TargetMarkerFrame.TargetMarker:Show()
		else
			self.TargetMarkerFrame.TargetMarker:Hide()
		end
	else
		self.TargetMarkerFrame.TargetMarker:Hide()
	end

	-- this will collide with regular processing of the setting when edited in a dungeon
	if AdvancedFocusCastBarSaved.Settings.ShowTargetName then
		local name = UnitName("player")

		if AdvancedFocusCastBarSaved.Settings.ShowTargetClassColor then
			local class = select(2, UnitClass("player"))
			local color = C_ClassColor.GetClassColor(class)

			name = color:WrapTextInColorCode(name)
		end

		self.TargetNameFrame.TargetNameText1:SetText(name)
	end

	self:ProcessCastInformation()
	self:Show()
end

-- /run AdvancedFocusCastBarParent:ToggleDemo()
function AdvancedFocusCastBarMixin:ToggleDemo()
	if self.demoInterval == nil then
		self:OnEditModeEnter()
	else
		self:OnEditModeExit()
	end
end

function AdvancedFocusCastBarMixin:OnEditModeEnter()
	if not self:IsPastLoadingScreen() then
		return
	end

	if self.demoInterval ~= nil then
		self.demoInterval:Cancel()
		self.demoInterval = nil
	end

	self.demoInterval = C_Timer.NewTicker(3, GenerateClosure(self.LoopPreview, self))
	self:LoopPreview()
	self:SetScript("OnEvent", nil)
end

function AdvancedFocusCastBarMixin:OnEditModeExit()
	if self.demoInterval ~= nil then
		self.demoInterval:Cancel()
		self.demoInterval = nil
	end

	self:SetScript("OnEvent", self.OnEvent)
	self:Hide()
end

function AdvancedFocusCastBarMixin:OnUpdate(elapsed)
	if AdvancedFocusCastBarSaved.Settings.ShowCastTime then
		self.CastBar.CastTimeText:SetFormattedText("%.1f", self.castInformation.duration:GetRemainingDuration())
	end

	if self.interruptId ~= nil then
		if AdvancedFocusCastBarSaved.Settings.OutOfRangeOpacity < 1 then
			local inRange = C_Spell.IsSpellInRange(self.interruptId, "focus")
			if inRange ~= nil then
				self:SetAlpha(inRange == true and 1 or AdvancedFocusCastBarSaved.Settings.OutOfRangeOpacity)
			end
		end

		local interruptDuration = C_Spell.GetSpellCooldownDuration(self.interruptId)

		if interruptDuration == nil then
			return
		end

		self:DeriveAndSetNextColor(interruptDuration)

		self.CastBar.Positioner:SetValue(self.castInformation.duration:GetElapsedDuration())
		self.CastBar.InterruptBar:SetValue(interruptDuration:GetRemainingDuration())
		self.CastBar.InterruptBar:SetAlphaFromBoolean(
			interruptDuration:IsZero(),
			0,
			C_CurveUtil.EvaluateColorValueFromBoolean(self.castInformation.notInterruptible, 0, 1)
		)
	end
end

function AdvancedFocusCastBarMixin:ShowGlow(isImportant)
	local frame = AdvancedFocusCastBarSaved.Settings.ShowBorder and self.Border or self

	if frame._PixelGlow == nil then
		LibCustomGlow.PixelGlow_Start(
			frame, -- frame
			nil, -- color
			nil, -- N
			nil, -- frequency
			nil, -- length
			nil, -- th
			nil, -- xOffset
			nil, -- yOffset
			nil, -- border
			nil, -- key
			nil -- frameLevel
		)

		-- needed to layer above the glow
		local nextLevel = frame._PixelGlow:GetFrameLevel() + 1
		self.TargetMarkerFrame:SetFrameLevel(nextLevel)
		self.TargetNameFrame:SetFrameLevel(nextLevel)
	end

	frame._PixelGlow:SetAlphaFromBoolean(isImportant)
end

function AdvancedFocusCastBarMixin:HideGlow()
	LibCustomGlow.PixelGlow_Stop(AdvancedFocusCastBarSaved.Settings.ShowBorder and self.Border or self)
end

function AdvancedFocusCastBarMixin:LoadConditionsProhibitExecution()
	if not AdvancedFocusCastBarSaved.Settings.LoadConditionRole[self.role] then
		return true
	end

	if not AdvancedFocusCastBarSaved.Settings.LoadConditionContentType[self.contentType] then
		return true
	end

	return false
end

function AdvancedFocusCastBarMixin:UnitIsIrrelevant()
	if not UnitExists("focus") then
		return true
	end

	if AdvancedFocusCastBarSaved.Settings.IgnoreFriendlies and not UnitCanAttack("player", "focus") then
		return true
	end

	return false
end

function AdvancedFocusCastBarMixin:DetectInterruptId()
	local playerClass = select(3, UnitClass("player"))

	local classInterruptMap = {
		[1] = { 6552 }, -- Warrior
		[2] = { 31935, 96231 }, -- Paladin
		[3] = { 147362, 187707 }, -- Hunter
		[4] = { 1766 }, -- Rogue
		[5] = { 15487 }, -- Priest
		[6] = { 47528 }, -- Death Knight
		[7] = { 57994 }, -- Shaman
		[8] = { 2139 }, -- Mage
		[9] = { 19647, 89766, 119910, 1276467, 132409 }, -- Warlock
		[10] = { 116705 }, -- Monk
		[11] = { 38675, 78675, 106839 }, -- Druid
		[12] = { 183752 }, -- Demon Hunter
		[13] = { 351338 }, -- Evoker
	}

	local eligibleInterrupts = classInterruptMap[playerClass]

	for i = 1, #eligibleInterrupts do
		local id = eligibleInterrupts[i]

		if
			C_SpellBook.IsSpellKnownOrInSpellBook(id)
			or C_SpellBook.IsSpellKnownOrInSpellBook(id, Enum.SpellBookSpellBank.Pet)
		then
			return id
		end
	end

	return nil
end

function AdvancedFocusCastBarMixin:DeriveAndSetNextColor(interruptDuration)
	if self.interruptId == nil then
		return
	end

	local bool = (interruptDuration or C_Spell.GetSpellCooldownDuration(self.interruptId)):IsZero()

	-- todo: cache this
	local canInterruptR, canInterruptG, canInterruptB = self.colors.ColorInterruptibleCanInterrupt:GetRGB()
	local cannotInterruptR, cannotInterruptG, cannotInterruptB = self.colors.ColorInterruptibleCannotInterrupt:GetRGB()

	self.CastBar:GetStatusBarTexture():SetVertexColorFromBoolean(
		self.castInformation.notInterruptible,
		self.colors.ColorUninterruptible,
		-- C_CurveUtil.EvaluateColorFromBoolean exists and works but has perf problems
		CreateColor(
			C_CurveUtil.EvaluateColorValueFromBoolean(bool, canInterruptR, cannotInterruptR),
			C_CurveUtil.EvaluateColorValueFromBoolean(bool, canInterruptG, cannotInterruptG),
			C_CurveUtil.EvaluateColorValueFromBoolean(bool, canInterruptB, cannotInterruptB)
		)
	)
end

function AdvancedFocusCastBarMixin:QueryCastInformation()
	local duration = UnitCastingDuration("focus")
	local isChannel = false

	if duration == nil then
		duration = UnitChannelDuration("focus")
		isChannel = true
	end

	if duration == nil then
		return
	end

	local name, texture, notInterruptible, spellId

	if isChannel then
		_, name, texture, _, _, _, notInterruptible, spellId = UnitChannelInfo("focus")
	else
		_, name, texture, _, _, _, _, notInterruptible, spellId = UnitCastingInfo("focus")
	end

	return {
		duration = duration,
		isChannel = isChannel,
		name = name,
		texture = texture,
		notInterruptible = notInterruptible,
		isImportant = C_Spell.IsSpellImportant(spellId),
	}
end

function AdvancedFocusCastBarMixin:ProcessCastInformation()
	self.CastBar:SetTimerDuration(self.castInformation.duration)
	local totalDuration = self.castInformation.duration:GetTotalDuration()
	self.CastBar.Positioner:SetMinMaxValues(0, totalDuration)
	self.CastBar.InterruptBar:SetMinMaxValues(0, totalDuration)
	self.Icon:SetTexture(self.castInformation.texture)
	self.CastBar.SpellNameText:SetText(self.castInformation.name)
	self:DeriveAndSetNextColor()
	self:AdjustDirection(self.castInformation.isChannel)

	if AdvancedFocusCastBarSaved.Settings.GlowImportant then
		self:ShowGlow(self.castInformation.isImportant)
	else
		self:ShowGlow(false)
	end

	-- interruptId won't change while the castbar is visible, so its set once outside to prevent spamming this
	if self.interruptId == nil then
		self.CastBar:GetStatusBarTexture():SetVertexColorFromBoolean(
			self.castInformation.notInterruptible,
			self.colors.ColorUninterruptible,
			self.colors.ColorInterruptibleCannotInterrupt
		)
	end

	-- prevents colliding with preview in Edit Mode
	if self.demoInterval == nil then
		if
			AdvancedFocusCastBarSaved.Settings.ShowTargetName
			and self.contentType == Private.Enum.ContentType.Dungeon
		then
			self.TargetNameFrame:Show()

			local partyMembers = GetNumGroupMembers()

			for i = 1, partyMembers do
				local unit = i == partyMembers and "player" or "party" .. i
				local name = UnitName(unit)

				if AdvancedFocusCastBarSaved.Settings.ShowTargetClassColor then
					local class = select(2, UnitClass(unit))
					local color = C_ClassColor.GetClassColor(class)

					name = color:WrapTextInColorCode(name)
				end

				local frame = self.TargetNameFrame["TargetNameText" .. i]
				frame:SetText(name)
				frame:SetAlphaFromBoolean(UnitIsSpellTarget("focus", unit), 1, 0)
			end
		else
			self.TargetNameFrame:Hide()
		end
	else
		self.TargetNameFrame:Show()
	end
end

function AdvancedFocusCastBarMixin:FindApporpriateTTSVoiceID()
	if self.ttsVoiceId then
		return self.ttsVoiceId
	end

	local ttsVoiceId = C_TTSSettings.GetVoiceOptionID(Enum.TtsVoiceType.Standard)
	local patternToLookFor = "English"

	for _, voice in pairs(C_VoiceChat.GetTtsVoices()) do
		if string.find(voice.name, patternToLookFor) ~= nil then
			self.ttsVoiceId = voice.voiceID
			return voice.voiceID
		end
	end

	self.ttsVoiceId = ttsVoiceId
	return ttsVoiceId
end

function AdvancedFocusCastBarMixin:OnEvent(event, ...)
	if
		event == "UNIT_SPELLCAST_START"
		or event == "UNIT_SPELLCAST_DELAYED"
		or event == "UNIT_SPELLCAST_CHANNEL_START"
		or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
		or event == "UNIT_SPELLCAST_EMPOWER_START"
		or event == "UNIT_SPELLCAST_EMPOWER_UPDATE"
	then
		if self:LoadConditionsProhibitExecution() or self:UnitIsIrrelevant() then
			return
		end

		self.castInformation = self:QueryCastInformation()

		if self.castInformation == nil then
			return
		end

		self:ProcessCastInformation()
		self:Show()
	elseif
		event == "UNIT_SPELLCAST_STOP"
		or event == "UNIT_SPELLCAST_FAILED"
		or event == "UNIT_SPELLCAST_INTERRUPTED"
		or event == "UNIT_SPELLCAST_CHANNEL_STOP"
		or event == "UNIT_SPELLCAST_EMPOWER_STOP"
	then
		if self:LoadConditionsProhibitExecution() then
			return
		end

		self.castInformation = self:QueryCastInformation()

		if self.castInformation == nil then
			self:Hide()
			return
		end

		self:ProcessCastInformation()
		self:Show()
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if self:LoadConditionsProhibitExecution() then
			return
		end

		if not UnitExists("focus") then
			if self:IsShown() then
				self:Hide()
			end

			if
				AdvancedFocusCastBarSaved.Settings.PlayFocusTTSReminder
				and self.contentType == Private.Enum.ContentType.Dungeon
			then
				-- delay this as focus target dying may imply leaving combat
				C_Timer.After(1, function()
					if InCombatLockdown() then
						C_VoiceChat.SpeakText(
							self:FindApporpriateTTSVoiceID(),
							"focus",
							3,
							C_TTSSettings.GetSpeechVolume()
						)
					end
				end)
			end

			return
		end

		self.castInformation = self:QueryCastInformation()

		if self.castInformation == nil then
			if self:IsShown() then
				self:Hide()
			end

			return
		end

		self:ProcessCastInformation()
		self:Show()
	elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
		if self:LoadConditionsProhibitExecution() then
			return
		end

		self.castInformation = self:QueryCastInformation()

		if self.castInformation == nil then
			return
		end

		self:DeriveAndSetNextColor()
	elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
		if self:LoadConditionsProhibitExecution() then
			return
		end

		self.castInformation = self:QueryCastInformation()

		if self.castInformation == nil then
			return
		end

		self:DeriveAndSetNextColor()
	elseif event == "RAID_TARGET_UPDATE" then
		local index = GetRaidTargetIndex("focus")

		if index == nil then
			self.TargetMarkerFrame.TargetMarker:Hide()
		else
			SetRaidTargetIconTexture(self.TargetMarkerFrame.TargetMarker, index)
			self.TargetMarkerFrame.TargetMarker:Show()
		end
	elseif
		event == "ZONE_CHANGED_NEW_AREA"
		or event == "LOADING_SCREEN_DISABLED"
		or event == "PLAYER_SPECIALIZATION_CHANGED"
		or event == "UPDATE_INSTANCE_INFO"
	then
		self.interruptId = self:DetectInterruptId()

		local _, instanceType, difficultyId = GetInstanceInfo()
		-- equivalent to `instanceType == "none"`
		local nextContentType = Private.Enum.ContentType.OpenWorld

		if instanceType == "raid" then
			nextContentType = Private.Enum.ContentType.Raid
		elseif instanceType == "party" then
			if
				difficultyId == DifficultyUtil.ID.DungeonTimewalker
				or difficultyId == DifficultyUtil.ID.DungeonNormal
				or difficultyId == DifficultyUtil.ID.DungeonHeroic
				or difficultyId == DifficultyUtil.ID.DungeonMythic
				or difficultyId == DifficultyUtil.ID.DungeonChallenge
				or difficultyId == 205 -- follower dungeons
			then
				nextContentType = Private.Enum.ContentType.Dungeon
			end
		elseif instanceType == "pvp" then
			nextContentType = Private.Enum.ContentType.Battleground
		elseif instanceType == "arena" then
			nextContentType = Private.Enum.ContentType.Arena
		elseif instanceType == "scenario" then
			if difficultyId == 208 then
				nextContentType = Private.Enum.ContentType.Delve
			end
		end

		self.contentType = nextContentType

		local specId = PlayerUtil.GetCurrentSpecID()

		if
			specId == 105 -- restoration druid
			or specId == 1468 -- preservation evoker
			or specId == 270 -- mistweaver monk
			or specId == 65 -- holy paladin
			or specId == 256 -- discipline priest
			or specId == 257 -- holy priest
			or specId == 264 -- restoration shaman
		then
			self.role = Private.Enum.Role.Healer
		elseif
			specId == 250 -- blood death knight
			or specId == 581 -- vengeance demon hunter
			or specId == 104 -- guardian druid
			or specId == 268 -- brewmaster monk
			or specId == 66 -- protection paladin
			or specId == 73 -- protection warrior
		then
			self.role = Private.Enum.Role.Tank
		else
			self.role = Private.Enum.Role.Damager
		end
	elseif event == Private.Enum.Events.EDIT_MODE_POSITION_CHANGED then
		self:ClearAllPoints()
		self:SetPoint(
			AdvancedFocusCastBarSaved.Settings.Point,
			AdvancedFocusCastBarSaved.Settings.OffsetX,
			AdvancedFocusCastBarSaved.Settings.OffsetY
		)
	elseif event == "FIRST_FRAME_RENDERED" then
		self.firstFrameTimestamp = GetTime()
		self:UnregisterEvent("FIRST_FRAME_RENDERED")
	end
end

table.insert(Private.LoginFnQueue, function()
	CreateFrame("Frame", "AdvancedFocusCastBarParent", UIParent, "AdvancedFocusCastBarFrameTemplate")
end)
