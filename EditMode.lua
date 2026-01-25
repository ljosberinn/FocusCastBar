---@type string, AdvancedFocusCastBar
local addonName, Private = ...
local LibEditMode = LibStub("LibEditMode")

local AdvancedFocusCastBarEditModeMixin = {}

function AdvancedFocusCastBarEditModeMixin:Init()
	self.demoPlaying = false

	self.demoTimer = nil

	self.editModeFrame = CreateFrame("Frame", nil, UIParent)
	self.editModeFrame:SetClampedToScreen(true)
	-- some addons such as BetterCooldownManager toggle the edit mode briefly on login/loading screen end
	-- which would toggle demos on our end. by flipping this bool, we can avoid that entirely, speeding up load time
	self.editModeFrame.firstFrameTimestamp = 0

	self.editModeFrame:RegisterEvent("FIRST_FRAME_RENDERED")
	self.editModeFrame:SetScript("OnEvent", function(self, event)
		self.firstFrameTimestamp = GetTime()
		self:SetScript("OnEvent", nil)
		self:UnregisterAllEvents()
	end)

	self.editModeFrame:SetPoint("CENTER", UIParent)
	self:ResizeEditModeFrame()

	Private.Utils.RegisterEditModeFrame(self.editModeFrame)
	Private.EventRegistry:RegisterCallback(Private.Enum.Events.SETTING_CHANGED, self.OnSettingsChanged, self)

	LibEditMode:RegisterCallback("enter", GenerateClosure(self.StartDemo, self))
	LibEditMode:RegisterCallback("exit", GenerateClosure(self.EndDemo, self))

	LibEditMode:AddFrame(
		self.editModeFrame,
		GenerateClosure(self.OnEditModePositionChanged, self),
		Private.Settings.GetDefaultEditModeFramePosition(),
		"Private.L.EditMode.TargetedSpellsSelfLabel"
	)

	LibEditMode:RegisterCallback("layout", GenerateClosure(self.RestoreEditModePosition, self))

	local settingsOrder = Private.Settings.GetSettingsDisplayOrder()
	local settings = {}
	local defaults = Private.Settings.GetDefaultSettings()

	for i, key in ipairs(settingsOrder) do
		table.insert(settings, self:CreateSetting(key, defaults))
	end

	LibEditMode:AddFrameSettings(self.editModeFrame, settings)
	LibEditMode:AddFrameSettingsButtons(self.editModeFrame, self:CreateImportExportButtons())
end

function AdvancedFocusCastBarEditModeMixin:ResizeEditModeFrame()
	local width, height, direction =
		AdvancedFocusCastBarSaved.Settings.Width,
		AdvancedFocusCastBarSaved.Settings.Height,
		AdvancedFocusCastBarSaved.Settings.Direction

	PixelUtil.SetSize(self.editModeFrame, width, height)
end

function AdvancedFocusCastBarEditModeMixin:OnSettingsChanged(key, value)
	if
		key == Private.Settings.Keys.Direction
		or key == Private.Settings.Keys.Width
		or key == Private.Settings.Keys.Height
		or key == Private.Settings.Keys.GlowImportant
		or key == Private.Settings.Keys.GlowType
	then
		self:OnLayoutSettingChanged(key, value)
	end
end

function AdvancedFocusCastBarEditModeMixin:OnLayoutSettingChanged(key, value)
	if
		key == Private.Settings.Keys.Direction
		or key == Private.Settings.Keys.Width
		or key == Private.Settings.Keys.Height
	then
		if
			key == Private.Settings.Keys.Width
			or key == Private.Settings.Keys.Height
			or key == Private.Settings.Keys.Direction
		then
			self:ResizeEditModeFrame()
		end
	elseif key == Private.Settings.Keys.GlowImportant then
		local glowEnabled = value

		-- for _, frame in pairs(frames) do
		-- 	if glowEnabled and frame:IsVisible() and Private.Utils.RollDice() then
		-- 		frame:ShowGlow(true)
		-- 	else
		-- 		frame:HideGlow()
		-- 	end
		-- end
	elseif key == Private.Settings.Keys.GlowType then
		if not AdvancedFocusCastBarSaved.Settings.GlowImportant then
			return
		end

		-- for _, frame in pairs(self.frames) do
		-- 	if frame:IsVisible() and Private.Utils.RollDice() then
		-- 		frame:ShowGlow(true)
		-- 	else
		-- 		frame:HideGlow()
		-- 	end
		-- end
	end
end

function AdvancedFocusCastBarEditModeMixin:StartDemo() end
function AdvancedFocusCastBarEditModeMixin:EndDemo() end

function AdvancedFocusCastBarEditModeMixin:OnEditModePositionChanged(frame, layoutName, point, x, y)
	AdvancedFocusCastBarSaved.Settings.Position.point = point
	AdvancedFocusCastBarSaved.Settings.Position.x = x
	AdvancedFocusCastBarSaved.Settings.Position.y = y

	Private.EventRegistry:TriggerEvent(Private.Enum.Events.EDIT_MODE_POSITION_CHANGED, point, x, y)
end

function AdvancedFocusCastBarEditModeMixin:RestoreEditModePosition()
	self.editModeFrame:ClearAllPoints()
	self.editModeFrame:SetPoint(
		AdvancedFocusCastBarSaved.Settings.Position.point,
		AdvancedFocusCastBarSaved.Settings.Position.x,
		AdvancedFocusCastBarSaved.Settings.Position.y
	)
end

function AdvancedFocusCastBarEditModeMixin:CreateSetting(key, defaults)
	local L = Private.L

	if key == Private.Settings.Keys.Opacity or key == Private.Settings.Keys.Opacity then
		local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

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
			name = L.Settings.OpacityLabel,
			kind = Enum.EditModeSettingDisplayType.Slider,
			default = defaults.Opacity,
			desc = L.Settings.OpacityTooltip,
			get = Get,
			set = Set,
			minValue = sliderSettings.min,
			maxValue = sliderSettings.max,
			valueStep = sliderSettings.step,
			formatter = FormatPercentage,
		}
	end

	if key == Private.Settings.Keys.GlowImportant or key == Private.Settings.Keys.GlowImportant then
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
				LibEditMode:EnableFrameSetting(self.editModeFrame, L.Settings.GlowTypeLabel)
			else
				LibEditMode:DisableFrameSetting(self.editModeFrame, L.Settings.GlowTypeLabel)
			end
		end

		---@type LibEditModeCheckbox
		return {
			name = L.Settings.GlowImportantLabel,
			kind = Enum.EditModeSettingDisplayType.Checkbox,
			desc = L.Settings.GlowImportantTooltip,
			default = defaults.GlowImportant,
			get = Get,
			set = Set,
		}
	end

	if key == Private.Settings.Keys.Texture then
		---@param layoutName string
		---@param value number
		local function Set(layoutName, value)
			if AdvancedFocusCastBarSaved.Settings.Texture ~= value then
				AdvancedFocusCastBarSaved.Settings.Texture = value
				Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
			end
		end

		local function Generator(owner, rootDescription, data) end

		---@type LibEditModeDropdown
		return {
			name = L.Settings.TextureLabel,
			kind = Enum.EditModeSettingDisplayType.Dropdown,
			desc = L.Settings.TextureTooltip,
			default = defaults.Texture,
			multiple = false,
			generator = Generator,
			set = Set,
		}
	end

	if key == Private.Settings.Keys.ColorUninterruptible then
		---@param layoutName string
		---@param value ColorMixin
		local function Set(layoutName, value)
			if AdvancedFocusCastBarSaved.Settings.ColorUninterruptible ~= value then
				AdvancedFocusCastBarSaved.Settings.ColorUninterruptible = value
				Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
			end
		end

		local function Get()
			return CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorUninterruptible)
		end

		---@type LibEditModeColorPicker
		return {
			name = L.Settings.ColorUninterruptibleLabel,
			desc = L.Settings.ColorUninterruptibleTooltip,
			default = CreateColorFromHexString(defaults.ColorUninterruptible),
			set = Set,
			get = Get,
			kind = LibEditMode.SettingType.ColorPicker,
		}
	end

	if key == Private.Settings.Keys.ColorInterruptibleCanInterrupt then
		---@param layoutName string
		---@param value ColorMixin
		local function Set(layoutName, value)
			if AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt ~= value then
				AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt = value
				Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
			end
		end

		local function Get()
			return CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt)
		end

		---@type LibEditModeColorPicker
		return {
			name = L.Settings.ColorInterruptibleCanInterruptLabel,
			desc = L.Settings.ColorInterruptibleCanInterruptTooltip,
			default = CreateColorFromHexString(defaults.ColorInterruptibleCanInterrupt),
			set = Set,
			get = Get,
			kind = LibEditMode.SettingType.ColorPicker,
		}
	end

	if key == Private.Settings.Keys.ColorInterruptibleCannotInterrupt then
		---@param layoutName string
		---@param value ColorMixin
		local function Set(layoutName, value)
			if AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt ~= value then
				AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt = value
				Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
			end
		end

		local function Get()
			return CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt)
		end

		---@type LibEditModeColorPicker
		return {
			name = L.Settings.ColorInterruptibleCannotInterruptLabel,
			desc = L.Settings.ColorInterruptibleCannotInterruptTooltip,
			default = CreateColorFromHexString(defaults.ColorInterruptibleCannotInterrupt),
			set = Set,
			get = Get,
			kind = LibEditMode.SettingType.ColorPicker,
		}
	end

	if key == Private.Settings.Keys.ColorInterruptTick then
		---@param layoutName string
		---@param value ColorMixin
		local function Set(layoutName, value)
			if AdvancedFocusCastBarSaved.Settings.ColorInterruptTick ~= value then
				AdvancedFocusCastBarSaved.Settings.ColorInterruptTick = value
				Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
			end
		end

		local function Get()
			return CreateColorFromHexString(AdvancedFocusCastBarSaved.Settings.ColorInterruptTick)
		end

		---@type LibEditModeColorPicker
		return {
			name = L.Settings.ColorInterruptTickLabel,
			desc = L.Settings.ColorInterruptTickTooltip,
			default = CreateColorFromHexString(defaults.ColorInterruptTick),
			set = Set,
			get = Get,
			kind = LibEditMode.SettingType.ColorPicker,
		}
	end

	if key == Private.Settings.Keys.GlowType then
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

				local translated = L.Settings.GlowTypeLabels[id]

				rootDescription:CreateCheckbox(translated, IsEnabled, SetProxy, {
					value = label,
					multiple = false,
				})
			end
		end

		---@type LibEditModeDropdown
		return {
			name = L.Settings.GlowTypeLabel,
			kind = Enum.EditModeSettingDisplayType.Dropdown,
			desc = L.Settings.GlowTypeTooltip,
			default = defaults.GlowType,
			multiple = false,
			generator = Generator,
			set = Set,
			disabled = not AdvancedFocusCastBarSaved.Settings.GlowImportant,
		}
	end

	if key == Private.Settings.Keys.ShowBorder then
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
			name = L.Settings.ShowBorderLabel,
			kind = Enum.EditModeSettingDisplayType.Checkbox,
			desc = L.Settings.ShowBorderTooltip,
			default = defaults.ShowBorder,
			get = Get,
			set = Set,
		}
	end

	if key == Private.Settings.Keys.ShowDuration then
		---@param layoutName string
		local function Get(layoutName)
			return AdvancedFocusCastBarSaved.Settings.ShowDuration
		end

		---@param layoutName string
		---@param value boolean
		local function Set(layoutName, value)
			if value ~= AdvancedFocusCastBarSaved.Settings.ShowDuration then
				AdvancedFocusCastBarSaved.Settings.ShowDuration = value
				Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
			end

			if value then
				LibEditMode:EnableFrameSetting(self.editModeFrame, L.Settings.FontSizeLabel)
				LibEditMode:EnableFrameSetting(self.editModeFrame, L.Settings.ShowDurationFractionsLabel)
			else
				LibEditMode:DisableFrameSetting(self.editModeFrame, L.Settings.FontSizeLabel)
				LibEditMode:DisableFrameSetting(self.editModeFrame, L.Settings.ShowDurationFractionsLabel)
			end
		end

		---@type LibEditModeCheckbox
		return {
			name = L.Settings.ShowDurationLabel,
			kind = Enum.EditModeSettingDisplayType.Checkbox,
			desc = L.Settings.ShowDurationTooltip,
			default = defaults.ShowDuration,
			get = Get,
			set = Set,
		}
	end

	if key == Private.Settings.Keys.ShowIcon then
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

			if value then
				LibEditMode:EnableFrameSetting(self.editModeFrame, L.Settings.FontSizeLabel)
				LibEditMode:EnableFrameSetting(self.editModeFrame, L.Settings.ShowIconFractionsLabel)
			else
				LibEditMode:DisableFrameSetting(self.editModeFrame, L.Settings.FontSizeLabel)
				LibEditMode:DisableFrameSetting(self.editModeFrame, L.Settings.ShowIconFractionsLabel)
			end
		end

		---@type LibEditModeCheckbox
		return {
			name = L.Settings.ShowIconLabel,
			kind = Enum.EditModeSettingDisplayType.Checkbox,
			desc = L.Settings.ShowIconTooltip,
			default = defaults.ShowIcon,
			get = Get,
			set = Set,
		}
	end

	if key == Private.Settings.Keys.ShowCastTime then
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
			name = L.Settings.ShowCastTimeLabel,
			kind = Enum.EditModeSettingDisplayType.Checkbox,
			desc = L.Settings.ShowCastTimeTooltip,
			default = defaults.ShowCastTime,
			get = Get,
			set = Set,
		}
	end

	if key == Private.Settings.Keys.LoadConditionContentType then
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

				local translated = L.Settings.LoadConditionContentTypeLabels[id]
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
			name = L.Settings.LoadConditionContentTypeLabelAbbreviated,
			kind = Enum.EditModeSettingDisplayType.Dropdown,
			default = defaults.LoadConditionContentType,
			desc = L.Settings.LoadConditionContentTypeTooltip,
			generator = Generator,
			-- technically is a reset only
			set = Set,
		}
	end

	if key == Private.Settings.Keys.LoadConditionRole then
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

				local translated = L.Settings.LoadConditionRoleLabels[id]

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
			name = L.Settings.LoadConditionRoleLabelAbbreviated,
			kind = Enum.EditModeSettingDisplayType.Dropdown,
			default = defaults.LoadConditionRole,
			desc = L.Settings.LoadConditionRoleTooltip,
			generator = Generator,
			-- technically is a reset only
			set = Set,
		}
	end

	if key == Private.Settings.Keys.Width then
		local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

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
			name = L.Settings.FrameWidthLabel,
			kind = Enum.EditModeSettingDisplayType.Slider,
			default = defaults.Width,
			desc = L.Settings.FrameWidthTooltip,
			get = Get,
			set = Set,
			minValue = sliderSettings.min,
			maxValue = sliderSettings.max,
			valueStep = sliderSettings.step,
		}
	end

	if key == Private.Settings.Keys.Height then
		local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

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
			name = L.Settings.FrameHeightLabel,
			kind = Enum.EditModeSettingDisplayType.Slider,
			default = defaults.Height,
			desc = L.Settings.FrameHeightTooltip,
			get = Get,
			set = Set,
			minValue = sliderSettings.min,
			maxValue = sliderSettings.max,
			valueStep = sliderSettings.step,
		}
	end

	if key == Private.Settings.Keys.Direction or key == Private.Settings.Keys.Direction then
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

				local translated = id == Private.Enum.Direction.Horizontal and L.Settings.FrameDirectionHorizontal
					or L.Settings.FrameDirectionVertical

				rootDescription:CreateCheckbox(translated, IsEnabled, SetProxy, {
					value = id,
					multiple = false,
				})
			end
		end

		---@type LibEditModeDropdown
		return {
			name = L.Settings.FrameDirectionLabel,
			kind = Enum.EditModeSettingDisplayType.Dropdown,
			default = defaults.Direction,
			desc = L.Settings.FrameDirectionTooltip,
			generator = Generator,
			set = Set,
		}
	end

	if key == Private.Settings.Keys.OffsetX then
		local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

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
			name = L.Settings.FrameOffsetXLabel,
			kind = Enum.EditModeSettingDisplayType.Slider,
			default = defaults.OffsetX,
			desc = L.Settings.FrameOffsetXTooltip,
			get = Get,
			set = Set,
			minValue = sliderSettings.min,
			maxValue = sliderSettings.max,
			valueStep = sliderSettings.step,
		}
	end

	if key == Private.Settings.Keys.OffsetY then
		local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

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
			name = L.Settings.FrameOffsetYLabel,
			kind = Enum.EditModeSettingDisplayType.Slider,
			default = defaults.OffsetY,
			desc = L.Settings.FrameOffsetYTooltip,
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

function AdvancedFocusCastBarEditModeMixin:OnImportConfirmation(encodedString)
	local hasAnyChange = Private.Utils.Import(encodedString)

	if hasAnyChange then
		LibEditMode:RefreshFrameSettings(self.editModeFrame)
	end
end

function AdvancedFocusCastBarEditModeMixin:OnImportButtonClick()
	Private.Utils.ShowStaticPopup({
		text = Private.L.Settings.Import,
		button1 = Private.L.Settings.Import,
		button2 = CLOSE,
		hasEditBox = true,
		hasWideEditBox = true,
		editBoxWidth = 350,
		hideOnEscape = true,
		OnAccept = function(popupSelf)
			local editBox = popupSelf:GetEditBox()
			self:OnImportConfirmation(editBox:GetText())
		end,
	})
end

function AdvancedFocusCastBarEditModeMixin:OnExportButtonClick()
	local string = Private.Utils.Export()

	Private.Utils.ShowStaticPopup({
		text = Private.L.Settings.Export,
		button1 = Private.L.Settings.Export,
		hasEditBox = true,
		hasWideEditBox = true,
		editBoxWidth = 350,
		hideOnEscape = true,
		OnShow = function(popupSelf)
			local editBox = popupSelf:GetEditBox()
			editBox:SetText(string)
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

			if currentText == "" or currentText == string then
				return
			end

			popupSelf:SetText(string)
		end,
	})
end

function AdvancedFocusCastBarEditModeMixin:CreateImportExportButtons()
	return {
		{
			click = function()
				self:OnImportButtonClick()
			end,
			text = Private.L.Settings.Import,
		},
		{
			click = function()
				self:OnExportButtonClick()
			end,
			text = Private.L.Settings.Export,
		},
	}
end

table.insert(
	Private.LoginFnQueue,
	GenerateClosure(AdvancedFocusCastBarEditModeMixin.Init, AdvancedFocusCastBarEditModeMixin)
)
