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
		local mask = self.CastBar:CreateMaskTexture()
		mask:SetPoint("CENTER")
		mask:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetTextureSliceMargins(1, 1, 1, 1)
		self.CastBar.Mask = mask

		self.CastBar.Positioner:SetStatusBarTexture("dungeons/textures/common/transparent")
		self.CastBar.Positioner:SetPoint("CENTER")

		self.CastBar.InterruptBar:SetStatusBarTexture("dungeons/textures/common/transparent")
		self.CastBar.InterruptBar:SetClipsChildren(true)
		self.CastBar.InterruptBar.Tick = self.CastBar.InterruptBar:CreateTexture()
		self.CastBar.InterruptBar.Tick:SetColorTexture(0, 1, 0)
		self.CastBar.InterruptBar.Tick:SetSize(2, AdvancedFocusCastBarSaved.Settings.Height)
		self.CastBar.InterruptBar:SetPoint("LEFT", self.CastBar.Positioner:GetStatusBarTexture(), "RIGHT")
		self.CastBar.InterruptBar.Tick:SetPoint("LEFT", self.CastBar.InterruptBar:GetStatusBarTexture(), "RIGHT")
		self.CastBar.InterruptBar.Tick:AddMaskTexture(mask)

		self.CastBar:SetStatusBarTexture(AdvancedFocusCastBarSaved.Settings.Texture)

		PixelUtil.SetSize(self, AdvancedFocusCastBarSaved.Settings.Width, AdvancedFocusCastBarSaved.Settings.Height)
		PixelUtil.SetSize(
			self.Icon,
			AdvancedFocusCastBarSaved.Settings.Height,
			AdvancedFocusCastBarSaved.Settings.Height
		)
		self:AdjustIconLayout(AdvancedFocusCastBarSaved.Settings.ShowIcon)

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
		self.Border:SetBackdropBorderColor(0, 0, 0, 1)
		self.Border:SetShown(AdvancedFocusCastBarSaved.Settings.ShowBorder)
		self:SetFont()
		self:SetFontSize()
	end

	-- edit mode setup
	do
		LibEditMode:RegisterCallback("enter", GenerateClosure(self.OnEditModeEnter, self))
		LibEditMode:RegisterCallback("exit", GenerateClosure(self.OnEditModeExit, self))
		LibEditMode:RegisterCallback("layout", GenerateClosure(self.RestoreEditModePosition, self))

		LibEditMode:AddFrame(
			self,
			GenerateClosure(self.OnEditModePositionChange, self),
			Private.Settings.GetDefaultEditModeFramePosition(),
			Private.L.EditMode.AddonName
		)

		local function GetSliderSettingsForOption(key)
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

			if key == Private.Enum.SettingsKey.OffsetX or key == Private.Enum.SettingsKey.OffsetY then
				return {
					min = -400,
					max = 400,
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

		local function CreateSetting(key, defaults)
			if key == Private.Enum.SettingsKey.Opacity then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.Opacity
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
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

			if key == Private.Enum.SettingsKey.FontSize then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
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

			if key == Private.Enum.SettingsKey.GlowImportant then
				---@param layoutName string
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.GlowImportant
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.GlowImportant then
						AdvancedFocusCastBarSaved.Settings.GlowImportant = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end

					if value then
						LibEditMode:EnableFrameSetting(self, Private.L.Settings.GlowTypeLabel)
					else
						LibEditMode:DisableFrameSetting(self, Private.L.Settings.GlowTypeLabel)
					end
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

				local function Generator(owner, rootDescription, data)
					local fonts = LibSharedMedia:HashTable(LibSharedMedia.MediaType.FONT)

					for label, path in pairs(fonts) do
						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.Font == path
						end

						local function SetProxy()
							Set(LibEditMode:GetActiveLayoutName(), path)
						end

						rootDescription:CreateCheckbox(label, IsEnabled, SetProxy, {
							value = path,
							multiple = false,
						})
					end
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
					local textures = LibSharedMedia:HashTable(LibSharedMedia.MediaType.STATUSBAR)

					for label, path in pairs(textures) do
						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.Texture == path
						end

						local function SetProxy()
							Set(LibEditMode:GetActiveLayoutName(), path)
						end

						rootDescription:CreateCheckbox(label, IsEnabled, SetProxy, {
							value = path,
							multiple = false,
						})
					end
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

			if key == Private.Enum.SettingsKey.GlowType then
				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if AdvancedFocusCastBarSaved.Settings.GlowType ~= value then
						AdvancedFocusCastBarSaved.Settings.GlowType = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				local function Generator(owner, rootDescription, data)
					for label, id in pairs(Private.Enum.GlowType) do
						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.GlowType == id
						end

						local function SetProxy()
							Set(LibEditMode:GetActiveLayoutName(), id)
						end

						local translated = Private.L.Settings.GlowTypeLabels[id]

						rootDescription:CreateCheckbox(translated, IsEnabled, SetProxy, {
							value = label,
							multiple = false,
						})
					end
				end

				---@type LibEditModeDropdown
				return {
					name = Private.L.Settings.GlowTypeLabel,
					kind = Enum.EditModeSettingDisplayType.Dropdown,
					desc = Private.L.Settings.GlowTypeTooltip,
					default = defaults.GlowType,
					multiple = false,
					generator = Generator,
					set = Set,
					disabled = not AdvancedFocusCastBarSaved.Settings.GlowImportant,
				}
			end

			if key == Private.Enum.SettingsKey.ShowBorder then
				---@param layoutName string
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowBorder
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.ShowBorder then
						AdvancedFocusCastBarSaved.Settings.ShowBorder = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
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

			if key == Private.Enum.SettingsKey.ShowIcon then
				---@param layoutName string
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowIcon
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.ShowIcon then
						AdvancedFocusCastBarSaved.Settings.ShowIcon = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
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
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.ShowCastTime
				end

				---@param layoutName string
				---@param value boolean
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.ShowCastTime then
						AdvancedFocusCastBarSaved.Settings.ShowCastTime = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
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

			if key == Private.Enum.SettingsKey.Direction then
				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if AdvancedFocusCastBarSaved.Settings.Direction ~= value then
						AdvancedFocusCastBarSaved.Settings.Direction = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
					end
				end

				local function Generator(owner, rootDescription, data)
					for label, id in pairs(Private.Enum.Direction) do
						local function IsEnabled()
							return AdvancedFocusCastBarSaved.Settings.Direction == id
						end

						local function SetProxy()
							Set(LibEditMode:GetActiveLayoutName(), id)
						end

						local translated = id == Private.Enum.Direction.Horizontal
								and Private.L.Settings.FrameDirectionHorizontal
							or Private.L.Settings.FrameDirectionVertical

						rootDescription:CreateCheckbox(translated, IsEnabled, SetProxy, {
							value = id,
							multiple = false,
						})
					end
				end

				---@type LibEditModeDropdown
				return {
					name = Private.L.Settings.FrameDirectionLabel,
					kind = Enum.EditModeSettingDisplayType.Dropdown,
					default = defaults.Direction,
					desc = Private.L.Settings.FrameDirectionTooltip,
					generator = Generator,
					set = Set,
				}
			end

			if key == Private.Enum.SettingsKey.OffsetX then
				local sliderSettings = GetSliderSettingsForOption(key)

				---@param layoutName string
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.OffsetX
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.OffsetX then
						AdvancedFocusCastBarSaved.Settings.OffsetX = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
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
				local function Get(layoutName)
					return AdvancedFocusCastBarSaved.Settings.OffsetY
				end

				---@param layoutName string
				---@param value number
				local function Set(layoutName, value)
					if value ~= AdvancedFocusCastBarSaved.Settings.OffsetY then
						AdvancedFocusCastBarSaved.Settings.OffsetY = value
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
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
			Private.Enum.SettingsKey.OffsetX,
			Private.Enum.SettingsKey.OffsetY,
			Private.Enum.SettingsKey.ShowIcon,
			Private.Enum.SettingsKey.ShowCastTime,
			Private.Enum.SettingsKey.Opacity,
			Private.Enum.SettingsKey.ShowBorder,
			Private.Enum.SettingsKey.Texture,
			Private.Enum.SettingsKey.Font,
			Private.Enum.SettingsKey.FontSize,
			Private.Enum.SettingsKey.GlowImportant,
			Private.Enum.SettingsKey.GlowType,
			Private.Enum.SettingsKey.ColorUninterruptible,
			Private.Enum.SettingsKey.ColorInterruptibleCanInterrupt,
			Private.Enum.SettingsKey.ColorInterruptibleCannotInterrupt,
			Private.Enum.SettingsKey.ColorInterruptTick,
		}

		---@type SavedVariables
		local defaults = Private.Settings.GetDefaultSettings()
		local settings = {}

		for i, key in ipairs(settingsOrder) do
			table.insert(settings, CreateSetting(key, defaults))
		end

		LibEditMode:AddFrameSettings(self, settings)

		local function OnImportButtonClick() end

		local function OnExportButtonClick() end

		LibEditMode:AddFrameSettingsButtons(self, {
			{
				click = function()
					print("NYI")
				end,
				text = Private.L.Settings.ManualAnchorNameLabel,
			},
			{
				click = OnImportButtonClick,
				text = Private.L.Settings.Import,
			},
			{
				click = OnExportButtonClick,
				text = Private.L.Settings.Export,
			},
		})
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
end

function AdvancedFocusCastBarMixin:AdjustIconLayout(shown)
	self.CastBar:ClearAllPoints()

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
	end
end

function AdvancedFocusCastBarMixin:OnSettingsChange(key, value)
	if key == Private.Enum.SettingsKey.Width then
		self:SetWidth(value)

		local effectiveWidth = AdvancedFocusCastBarSaved.Settings.ShowIcon
				and value - AdvancedFocusCastBarSaved.Settings.Height
			or value

		PixelUtil.SetSize(self.CastBar.Mask, effectiveWidth, AdvancedFocusCastBarSaved.Settings.Height)
		self:AdjustIconLayout(AdvancedFocusCastBarSaved.Settings.ShowIcon)
	elseif key == Private.Enum.SettingsKey.Height then
		self:SetHeight(value)

		PixelUtil.SetSize(self.Icon, value, value)
		PixelUtil.SetSize(self.CastBar.Mask, AdvancedFocusCastBarSaved.Settings.Width, value)
		self:AdjustIconLayout(AdvancedFocusCastBarSaved.Settings.ShowIcon)
	elseif key == Private.Enum.SettingsKey.LoadConditionContentType then
	elseif key == Private.Enum.SettingsKey.LoadConditionRole then
	elseif key == Private.Enum.SettingsKey.OffsetX then
	elseif key == Private.Enum.SettingsKey.OffsetY then
	elseif key == Private.Enum.SettingsKey.ShowIcon then
		self:AdjustIconLayout(value)
	elseif key == Private.Enum.SettingsKey.ShowCastTime then
		self.CastBar.CastTimeText:SetShown(value)
	elseif key == Private.Enum.SettingsKey.Opacity then
		self:SetAlpha(value)
	elseif key == Private.Enum.SettingsKey.ShowBorder then
		self.Border:SetShown(value)
	elseif key == Private.Enum.SettingsKey.Texture then
		self.CastBar:SetStatusBarTexture(value)
	elseif key == Private.Enum.SettingsKey.Font then
		self:SetFont()
	elseif key == Private.Enum.SettingsKey.FontSize then
		self:SetFontSize()
	elseif key == Private.Enum.SettingsKey.GlowImportant then
		if value then
		else
			self:HideGlow()
		end
	elseif key == Private.Enum.SettingsKey.GlowType then
	elseif key == Private.Enum.SettingsKey.ColorUninterruptible then
		self.colors.ColorUninterruptible = CreateColorFromHexString(value)
	elseif key == Private.Enum.SettingsKey.ColorInterruptibleCanInterrupt then
		self.colors.ColorInterruptibleCanInterrupt = CreateColorFromHexString(value)
	elseif key == Private.Enum.SettingsKey.ColorInterruptibleCannotInterrupt then
		self.colors.ColorInterruptibleCannotInterrupt = CreateColorFromHexString(value)
	elseif key == Private.Enum.SettingsKey.ColorInterruptTick then
		self.colors.ColorInterruptTick = CreateColorFromHexString(value)
	end
end

function AdvancedFocusCastBarMixin:SetFont()
	local frames = {
		self.CastBar.CastTimeText,
		self.CastBar.SpellNameText,
	}

	for _, frame in pairs(frames) do
		local font, size, flags = frame:GetFont()

		if font == AdvancedFocusCastBarSaved.Settings.Font then
			return
		end

		frame:SetFont(AdvancedFocusCastBarSaved.Settings.Font, size, flags)
	end
end

function AdvancedFocusCastBarMixin:SetFontSize()
	local frames = {
		self.CastBar.CastTimeText,
		self.CastBar.SpellNameText,
	}

	for _, frame in pairs(frames) do
		local font, size, flags = frame:GetFont()

		if font == nil or size == AdvancedFocusCastBarSaved.Settings.FontSize then
			return
		end

		frame:SetFont(font, AdvancedFocusCastBarSaved.Settings.FontSize, flags)
	end
end

function AdvancedFocusCastBarMixin:RestoreEditModePosition()
	self:ClearAllPoints()
	self:SetPoint(
		AdvancedFocusCastBarSaved.Settings.Position.point,
		AdvancedFocusCastBarSaved.Settings.Position.x,
		AdvancedFocusCastBarSaved.Settings.Position.y
	)
end

function AdvancedFocusCastBarMixin:OnEditModePositionChange(frame, layoutName, point, x, y)
	AdvancedFocusCastBarSaved.Settings.Position.point = point
	AdvancedFocusCastBarSaved.Settings.Position.x = x
	AdvancedFocusCastBarSaved.Settings.Position.y = y

	Private.EventRegistry:TriggerEvent(Private.Enum.Events.EDIT_MODE_POSITION_CHANGED, point, x, y)
end

do
	local PreviewIconDataProvider = nil

	---@return IconDataProviderMixin
	function AdvancedFocusCastBarMixin:GetRandomIcon()
		if PreviewIconDataProvider == nil then
			PreviewIconDataProvider =
				CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook, true)
		end

		return PreviewIconDataProvider:GetRandomIcon()
	end
end

function AdvancedFocusCastBarMixin:ToggleDemo()
	if self.demoInterval == nil then
		local function PlayEditModeLoop()
			local dummyDuration = C_DurationUtil.CreateDuration()
			dummyDuration:SetTimeFromStart(GetTime(), 3)

			self.castInformation = {
				duration = dummyDuration,
				isChannel = false,
				name = addonName,
				notInterruptible = false,
				texture = self:GetRandomIcon(),
			}

			self:Show()
			self.CastBar:SetTimerDuration(self.castInformation.duration)
			self.CastBar:SetReverseFill(self.castInformation.isChannel)
			-- self.CastBar.InterruptBar:SetMinMaxValues(0, self.castInformation.duration:GetTotalDuration())
			self.Icon:SetTexture(self.castInformation.texture)
			self.CastBar.SpellNameText:SetText(self.castInformation.name)
			self:DeriveAndSetNextColor()
		end

		PlayEditModeLoop()
		self.demoInterval = C_Timer.NewTicker(3, PlayEditModeLoop)

		self:SetScript("OnEvent", nil)
	else
		self.demoInterval:Cancel()
		self.demoInterval = nil
		self:SetScript("OnEvent", self.OnEvent)
		self:Hide()
	end
end

function AdvancedFocusCastBarMixin:OnEditModeEnter()
	local function PlayEditModeLoop()
		local dummyDuration = C_DurationUtil.CreateDuration()
		dummyDuration:SetTimeFromStart(GetTime(), 3)

		self.castInformation = {
			duration = dummyDuration,
			isChannel = math.random(0, 1) == 1,
			name = addonName,
			notInterruptible = math.random(0, 1) == 1,
			texture = self:GetRandomIcon(),
		}

		self:Show()
		self.CastBar:SetTimerDuration(self.castInformation.duration)
		self.CastBar:SetReverseFill(self.castInformation.isChannel)
		-- self.CastBar.InterruptBar:SetMinMaxValues(0, self.castInformation.duration:GetTotalDuration())
		self.Icon:SetTexture(self.castInformation.texture)
		self.CastBar.SpellNameText:SetText(self.castInformation.name)
		self:DeriveAndSetNextColor()
	end

	PlayEditModeLoop()
	self.demoInterval = C_Timer.NewTicker(3, PlayEditModeLoop)

	self:SetScript("OnEvent", nil)
	self:Show()
end

function AdvancedFocusCastBarMixin:OnEditModeExit()
	if self.demoInterval then
		self.demoInterval:Cancel()
		self.demoInterval = nil
	end

	self:SetScript("OnEvent", self.OnEvent)
	self:Hide()
end

function AdvancedFocusCastBarMixin:OnUpdate(elapsed)
	if AdvancedFocusCastBarSaved.Settings.ShowCastTime then
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed >= 0.099 then
			self.elapsed = 0

			local duration = self.castInformation.duration
			self.CastBar.CastTimeText:SetFormattedText("%.1f", duration:GetRemainingDuration())
		end
	end

	if self.interruptId ~= nil then
		local interruptDuration = C_Spell.GetSpellCooldownDuration(self.interruptId)

		if interruptDuration == nil then
			return
		end

		self:DeriveAndSetNextColor(interruptDuration)
		self.CastBar.Positioner:SetMinMaxValues(0, self.castInformation.duration:GetTotalDuration())
		self.CastBar.Positioner:SetValue(self.castInformation.duration:GetElapsedDuration())
		self.CastBar.InterruptBar:SetMinMaxValues(0, self.castInformation.duration:GetTotalDuration())
		self.CastBar.InterruptBar:SetValue(interruptDuration:GetRemainingDuration())
		self.CastBar.InterruptBar:SetAlphaFromBoolean(
			interruptDuration:IsZero(),
			0,
			C_CurveUtil.EvaluateColorValueFromBoolean(self.castInformation.notInterruptible, 0, 1)
		)
		-- self.CastBar.InterruptPositioner:SetMinMaxValues(0, self.castInformation.duration:GetTotalDuration())
		-- self.CastBar.InterruptPositioner:SetValue(self.castInformation.duration:GetElapsedDuration())
		-- self.CastBar.InterruptMarker:SetMinMaxValues(0, self.castInformation.duration:GetTotalDuration())
		-- self.CastBar.InterruptMarker:SetValue(interruptDuration:GetRemainingDuration())
		-- self.CastBar.InterruptMarker:SetAlphaFromBoolean(
		-- 	interruptDuration:IsZero(),
		-- 	0,
		-- 	C_CurveUtil.EvaluateColorValueFromBoolean(self.castInformation.notInterruptible, 0, 1)
		-- )

		-- self.CastBar.InterruptBar:SetValue(interruptDuration:GetRemainingDuration())
		-- self.CastBar.InterruptBar:SetAlphaFromBoolean(
		-- 	interruptDuration:IsZero(),
		-- 	0,
		-- 	C_CurveUtil.EvaluateColorValueFromBoolean(self.castInformation.notInterruptible, 0, 1)
		-- )
	end
end

function AdvancedFocusCastBarMixin:ShowGlow(isImportant)
	local glowType = AdvancedFocusCastBarSaved.Settings.GlowType

	if glowType == Private.Enum.GlowType.PixelGlow then
		LibCustomGlow.PixelGlow_Start(self)

		self._PixelGlow:SetAlphaFromBoolean(isImportant)
	elseif glowType == Private.Enum.GlowType.AutoCastGlow then
		LibCustomGlow.AutoCastGlow_Start(self)

		self._AutoCastGlow:SetAlphaFromBoolean(isImportant)
	elseif glowType == Private.Enum.GlowType.ButtonGlow then
		LibCustomGlow.ButtonGlow_Start(self)

		self._ButtonGlow:SetAlphaFromBoolean(isImportant)
	elseif glowType == Private.Enum.GlowType.ProcGlow then
		LibCustomGlow.ProcGlow_Start(self)

		self._ProcGlow:SetAlphaFromBoolean(isImportant)
	end
end

function AdvancedFocusCastBarMixin:HideGlow()
	LibCustomGlow.PixelGlow_Stop(self)
	LibCustomGlow.AutoCastGlow_Stop(self)
	LibCustomGlow.ButtonGlow_Stop(self)
	LibCustomGlow.ProcGlow_Stop(self)
end

function AdvancedFocusCastBarMixin:LoadConditionsProhibitExecution()
	if not AdvancedFocusCastBarSaved.Settings.LoadConditionRole[self.role] then
		print("bailing because LoadConditionRole")
		return true
	end

	if not AdvancedFocusCastBarSaved.Settings.LoadConditionContentType[self.contentType] then
		print("bailing because LoadConditionContentType")
		return true
	end

	return false
end

function AdvancedFocusCastBarMixin:UnitIsIrrelevant()
	-- if not UnitExists("focus") then
	-- 	return true
	-- end

	-- if not UnitCanAttack("player", "focus") then
	-- 	return true
	-- end

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

function AdvancedFocusCastBarMixin:DeriveAndSetNextColor(cooldownDuration)
	local texture = self.CastBar:GetStatusBarTexture()

	if self.interruptId == nil then
		texture:SetVertexColorFromBoolean(
			self.castInformation.notInterruptible,
			self.colors.ColorUninterruptible,
			self.colors.ColorInterruptibleCannotInterrupt
		)
	else
		local bool = (cooldownDuration or C_Spell.GetSpellCooldownDuration(self.interruptId)):IsZero()

		local canInterruptR, canInterruptG, canInterruptB = self.colors.ColorInterruptibleCanInterrupt:GetRGB()
		local cannotInterruptR, cannotInterruptG, cannotInterruptB =
			self.colors.ColorInterruptibleCannotInterrupt:GetRGB()

		texture:SetVertexColorFromBoolean(
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

	local name, texture, notInterruptible

	if isChannel then
		_, name, texture, _, _, _, notInterruptible = UnitChannelInfo("focus")
	else
		_, name, texture, _, _, _, _, notInterruptible = UnitCastingInfo("focus")
	end

	return {
		duration = duration,
		isChannel = isChannel,
		name = name,
		texture = texture,
		notInterruptible = notInterruptible,
	}
end

function AdvancedFocusCastBarMixin:ProcessCastInformation()
	self.CastBar:SetTimerDuration(self.castInformation.duration)
	self.CastBar:SetReverseFill(self.castInformation.isChannel)
	-- self.CastBar.InterruptBar:SetMinMaxValues(0, self.castInformation.duration:GetTotalDuration())
	self.Icon:SetTexture(self.castInformation.texture)
	self.CastBar.SpellNameText:SetText(self.castInformation.name)
	self:DeriveAndSetNextColor()
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

		print(event, "showing")
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
			print(event, "focus stopped casting")
			return
		end

		self:ProcessCastInformation()
		self:Show()

		print(event, "showing")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if self:LoadConditionsProhibitExecution() then
			return
		end

		print(event, "player focus changed")
		if not UnitExists("focus") then
			if self:IsShown() then
				self:Hide()
				print(event, "hiding, focus is gone")
			end

			return
		end

		self.castInformation = self:QueryCastInformation()

		if self.castInformation == nil then
			if self:IsShown() then
				self:Hide()
				print(event, "hiding, focus is present but not casting")
			end

			return
		end

		self:ProcessCastInformation()
		self:Show()

		print(event, "showing")
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
		local point, x, y = ...

		self:ClearAllPoints()
		self:SetPoint(point, x, y)
	end
end

table.insert(Private.LoginFnQueue, function()
	CreateFrame("Frame", "AdvancedFocusCastBarParent", UIParent, "AdvancedFocusCastBarFrameTemplate")
end)
