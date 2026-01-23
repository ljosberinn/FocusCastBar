---@type string, FocusCastBar
local addonName, Private = ...

---@class FocusCastBarSettings
Private.Settings = {}

Private.Settings.Keys = {
	Width = "WIDTH",
	Height = "HEIGHT",
	Direction = "DIRECTION",
	LoadConditionContentType = "LOAD_CONDITION_CONTENT_TYPE",
	LoadConditionRole = "LOAD_CONDITION_ROLE",
	ShowIcon = "SHOW_ICON",
	ShowCastTime = "SHOW_CAST_TIME",
	ShowCastTimeFractions = "SHOW_CAST_TIME_FRACTIONS",
	Opacity = "OPACITY",
	ShowBorder = "SHOW_BORDER",
	GlowImportant = "GLOW_IMPORTANT",
	GlowType = "GLOW_TYPE",
	OffsetX = "OFFSET_X",
	OffsetY = "OFFSET_Y",
	ShowInterruptTick = "SHOW_INTERRUPT_TICK",
	ColorUninterruptible = "COLOR_UNINTERRUPTIBLE",
	ColorInterruptibleCanInterrupt = "COLOR_INTERRUPTIBLE_CAN_INTERRUPT",
	ColorInterruptibleCannotInterrupt = "COLOR_INTERRUPTIBLE_CANNOT_INTERRUPT",
	ColorInterruptTick = "COLOR_INTERRUPT_TICK",
}

function Private.Settings.GetSettingsDisplayOrder()
	return {
		Private.Settings.Keys.Width,
		Private.Settings.Keys.Height,
		Private.Settings.Keys.LoadConditionContentType,
		Private.Settings.Keys.LoadConditionRole,
		Private.Settings.Keys.OffsetX,
		Private.Settings.Keys.OffsetY,
		Private.Settings.Keys.ShowIcon,
		Private.Settings.Keys.ShowCastTime,
		Private.Settings.Keys.ShowCastTimeFractions,
		Private.Settings.Keys.Opacity,
		Private.Settings.Keys.ShowBorder,
		Private.Settings.Keys.GlowImportant,
		Private.Settings.Keys.GlowType,
		Private.Settings.Keys.ColorUninterruptible,
		Private.Settings.Keys.ColorInterruptibleCanInterrupt,
		Private.Settings.Keys.ColorInterruptibleCannotInterrupt,
		Private.Settings.Keys.ColorInterruptTick,
	}
end

function Private.Settings.GetDefaultEditModeFramePosition()
	return { point = "CENTER", x = 0, y = 100 }
end

function Private.Settings.GetSliderSettingsForOption(key)
	if key == Private.Settings.Keys.Opacity then
		return {
			min = 0.2,
			max = 1,
			step = 0.01,
		}
	end

	if key == Private.Settings.Keys.Width or key == Private.Settings.Keys.Height then
		return {
			min = 10,
			max = 200,
			step = 1,
		}
	end

	if key == Private.Settings.Keys.OffsetX or key == Private.Settings.Keys.OffsetY then
		return {
			min = -200,
			max = 200,
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

---@return SavedVariablesSettings
function Private.Settings.GetDefaultSettings()
	return {
		Width = 200,
		Height = 20,
		Direction = Private.Enum.Direction.Horizontal,
		LoadConditionContentType = {
			[Private.Enum.ContentType.OpenWorld] = false,
			[Private.Enum.ContentType.Delve] = true,
			[Private.Enum.ContentType.Dungeon] = true,
			[Private.Enum.ContentType.Raid] = true,
			[Private.Enum.ContentType.Arena] = true,
			[Private.Enum.ContentType.Battleground] = false,
		},
		LoadConditionRole = {
			[Private.Enum.Role.Healer] = true,
			[Private.Enum.Role.Tank] = true,
			[Private.Enum.Role.Damager] = true,
		},
		ShowCastTime = true,
		ShowCastTimeFractions = true,
		Position = Private.Settings.GetDefaultEditModeFramePosition(),
		Opacity = 1,
		ShowBorder = true,
		GlowImportant = true,
		ShowIcon = true,
		OffsetX = 0,
		OffsetY = 0,
		GlowType = Private.Enum.GlowType.PixelGlow,
		ColorUninterruptible = "FFE07800",
		ColorInterruptibleCanInterrupt = "FF00FF00",
		ColorInterruptibleCannotInterrupt = "FFFF0000",
		ColorInterruptTick = "FF00FF00",
	}
end

table.insert(Private.LoginFnQueue, function()
	local L = Private.L
	local settingsName = C_AddOns.GetAddOnMetadata(addonName, "Title")
	local category, layout = Settings.RegisterVerticalLayoutCategory(settingsName)

	---@param enum table<string, number>
	---@param IsEnabled fun(id: number): boolean
	---@return number
	local function GetMask(enum, IsEnabled)
		local mask = 0

		for label, id in pairs(enum) do
			if IsEnabled(id) then
				mask = bit.bor(mask, bit.lshift(1, id - 1))
			end
		end

		return mask
	end

	---@param value number
	---@return boolean
	local function DecodeBitToBool(mask, value)
		return bit.band(mask, bit.lshift(1, value - 1)) ~= 0
	end

	-- shared color between all pickers
	local currentColor = CreateColor(0, 0, 0, 0)

	---@param key string
	---@param label string
	---@param tooltip string?
	---@param GetValue fun(): string
	---@param SetValue fun(value: string)
	local function CreateColorPicker(key, label, tooltip, GetValue, SetValue)
		-- this doesn't actually do anything and is only there so clicking the checkbox
		-- which also doesn't do anything doesn't throw errors when toggled. we're here for the
		-- color picker after all
		local dummySetting = Settings.RegisterProxySetting(
			category,
			string.format("%s_DUMMY", key),
			Settings.VarType.Boolean,
			label,
			true,
			function()
				return true
			end,
			function() end
		)

		local function OpenColorPicker(swatch, button, isDown)
			local info = {
				swatch = swatch,
			}
			info.swatch = swatch

			local color = CreateColorFromHexString(GetValue())
			info.r, info.g, info.b = color:GetRGB()

			info.swatchFunc = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				currentColor:SetRGB(r, g, b)
				SetValue(currentColor:GenerateHexColor())
			end

			info.cancelFunc = function()
				local r, g, b = ColorPickerFrame:GetPreviousValues()
				currentColor:SetRGB(r, g, b)
				SetValue(currentColor:GenerateHexColor())
			end

			ColorPickerFrame:SetupColorPickerAndShow(info)
		end

		return CreateSettingsCheckboxWithColorSwatchInitializer(
			dummySetting,
			OpenColorPicker,
			false,
			false,
			tooltip,
			function()
				return CreateColorFromHexString(GetValue())
			end
		)
	end

	---@param key string
	---@param defaults SavedVariablesSettings
	local function CreateSetting(key, defaults)
		if key == Private.Settings.Keys.ColorUninterruptible then
			local function GetValue()
				return FocusCastBarSaved.Settings.ColorUninterruptible
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ColorUninterruptible = value
			end

			local initializer = CreateColorPicker(key, L.Settings.ColorUninterruptibleLabel, nil, GetValue, SetValue)

			layout:AddInitializer(initializer)
		elseif key == Private.Settings.Keys.ColorInterruptibleCanInterrupt then
			local function GetValue()
				return FocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt = value
			end

			local initializer =
				CreateColorPicker(key, L.Settings.ColorInterruptibleCanInterruptLabel, nil, GetValue, SetValue)

			layout:AddInitializer(initializer)
		elseif key == Private.Settings.Keys.ColorInterruptibleCannotInterrupt then
			local function GetValue()
				return FocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt = value
			end

			local initializer = CreateColorPicker(
				key,
				L.Settings.ColorInterruptibleCannotInterruptLabel,
				L.Settings.ColorInterruptibleCannotInterruptTooltip,
				GetValue,
				SetValue
			)

			layout:AddInitializer(initializer)
		elseif key == Private.Settings.Keys.ColorInterruptTick then
			local function GetValue()
				return FocusCastBarSaved.Settings.ColorInterruptTick
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ColorInterruptTick = value
			end

			local initializer = CreateColorPicker(key, L.Settings.ColorInterruptTickLabel, nil, GetValue, SetValue)

			layout:AddInitializer(initializer)
		elseif key == Private.Settings.Keys.OffsetX then
			local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

			local function GetValue()
				return FocusCastBarSaved.Settings.OffsetX
			end

			local function SetValue(value)
				if FocusCastBarSaved.Settings.OffsetX ~= value then
					FocusCastBarSaved.Settings.OffsetX = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.OffsetXLabel,
				defaults.OffsetX,
				GetValue,
				SetValue
			)
			local options = Settings.CreateSliderOptions(sliderSettings.min, sliderSettings.max, sliderSettings.step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

			Settings.CreateSlider(category, setting, options, L.Settings.OffsetXLabelTooltip)
		elseif key == Private.Settings.Keys.OffsetY then
			local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

			local function GetValue()
				return FocusCastBarSaved.Settings.OffsetY
			end

			local function SetValue(value)
				if FocusCastBarSaved.Settings.OffsetY ~= value then
					FocusCastBarSaved.Settings.OffsetY = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.OffsetYLabel,
				defaults.OffsetY,
				GetValue,
				SetValue
			)
			local options = Settings.CreateSliderOptions(sliderSettings.min, sliderSettings.max, sliderSettings.step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

			Settings.CreateSlider(category, setting, options, L.Settings.OffsetYLabelTooltip)
		elseif key == Private.Settings.Keys.Height then
			local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

			local function GetValue()
				return FocusCastBarSaved.Settings.Height
			end

			local function SetValue(value)
				if FocusCastBarSaved.Settings.Height ~= value then
					FocusCastBarSaved.Settings.Height = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.FrameHeightLabel,
				defaults.Height,
				GetValue,
				SetValue
			)
			local options = Settings.CreateSliderOptions(sliderSettings.min, sliderSettings.max, sliderSettings.step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

			Settings.CreateSlider(category, setting, options, L.Settings.FrameHeightTooltip)
		elseif key == Private.Settings.Keys.Width then
			local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

			local function GetValue()
				return FocusCastBarSaved.Settings.Width
			end

			local function SetValue(value)
				if value ~= FocusCastBarSaved.Settings.Width then
					FocusCastBarSaved.Settings.Width = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.FrameWidthLabel,
				defaults.Width,
				GetValue,
				SetValue
			)
			local options = Settings.CreateSliderOptions(sliderSettings.min, sliderSettings.max, sliderSettings.step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

			Settings.CreateSlider(category, setting, options, L.Settings.FrameWidthTooltip)
		elseif key == Private.Settings.Keys.LoadConditionRole then
			local defaultValue = GetMask(Private.Enum.Role, function(id)
				return defaults.LoadConditionRole[id]
			end)

			local function GetValue()
				return GetMask(Private.Enum.Role, function(id)
					return FocusCastBarSaved.Settings.LoadConditionRole[id]
				end)
			end

			local function SetValue(mask)
				local hasChanges = false

				for label, id in pairs(Private.Enum.Role) do
					local enabled = DecodeBitToBool(mask, id)

					if enabled ~= FocusCastBarSaved.Settings.LoadConditionRole[id] then
						FocusCastBarSaved.Settings.LoadConditionRole[id] = enabled
						hasChanges = true
					end
				end

				if not hasChanges then
					return
				end

				Private.EventRegistry:TriggerEvent(
					Private.Enum.Events.SETTING_CHANGED,
					key,
					FocusCastBarSaved.Settings.LoadConditionRole
				)
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.LoadConditionRoleLabel,
				defaultValue,
				GetValue,
				SetValue
			)

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()

				for label, id in pairs(Private.Enum.Role) do
					local translated = L.Settings.LoadConditionRoleLabels[id]

					container:AddCheckbox(id, translated, L.Settings.LoadConditionRoleTooltip)
				end

				return container:GetData()
			end

			local initializer =
				Settings.CreateDropdown(category, setting, GetOptions, L.Settings.LoadConditionRoleTooltip)
			initializer.hideSteppers = true
		elseif key == Private.Settings.Keys.LoadConditionContentType then
			local defaultValue = GetMask(Private.Enum.ContentType, function(id)
				return defaults.LoadConditionContentType[id]
			end)

			local function GetValue()
				return GetMask(Private.Enum.ContentType, function(id)
					return FocusCastBarSaved.Settings.LoadConditionContentType[id]
				end)
			end

			local function SetValue(mask)
				local hasChanges = false

				for label, id in pairs(Private.Enum.ContentType) do
					local enabled = DecodeBitToBool(mask, id)

					if enabled ~= FocusCastBarSaved.Settings.LoadConditionContentType[id] then
						FocusCastBarSaved.Settings.LoadConditionContentType[id] = enabled
						hasChanges = true
					end
				end

				if not hasChanges then
					return
				end

				Private.EventRegistry:TriggerEvent(
					Private.Enum.Events.SETTING_CHANGED,
					key,
					FocusCastBarSaved.Settings.LoadConditionContentType
				)
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.LoadConditionContentTypeLabel,
				defaultValue,
				GetValue,
				SetValue
			)

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()

				for label, id in pairs(Private.Enum.ContentType) do
					local function IsEnabled()
						return FocusCastBarSaved.Settings.LoadConditionContentType[id]
					end

					local function Toggle()
						FocusCastBarSaved.Settings.LoadConditionContentType[id] =
							not FocusCastBarSaved.Settings.LoadConditionContentType[id]
					end

					local translated = L.Settings.LoadConditionContentTypeLabels[id]

					container:AddCheckbox(id, translated, L.Settings.LoadConditionContentTypeTooltip, IsEnabled, Toggle)
				end

				return container:GetData()
			end

			local initializer =
				Settings.CreateDropdown(category, setting, GetOptions, L.Settings.LoadConditionContentTypeTooltip)
			initializer.hideSteppers = true
		elseif key == Private.Settings.Keys.Direction then
			local function GetValue()
				return FocusCastBarSaved.Settings.Direction
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.Direction = value

				Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
			end

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()

				for label, id in pairs(Private.Enum.Direction) do
					local translated = id == Private.Enum.Direction.Horizontal and L.Settings.FrameDirectionHorizontal
						or L.Settings.FrameDirectionVertical
					container:Add(id, translated)
				end

				return container:GetData()
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.FrameDirectionLabel,
				defaults.Direction,
				GetValue,
				SetValue
			)

			Settings.CreateDropdown(category, setting, GetOptions, L.Settings.FrameDirectionTooltip)
		elseif key == Private.Settings.Keys.ShowCastTimeFractions then
			local function GetValue()
				return FocusCastBarSaved.Settings.ShowCastTimeFractions
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ShowCastTimeFractions = not FocusCastBarSaved.Settings.ShowCastTimeFractions
				Private.EventRegistry:TriggerEvent(
					Private.Enum.Events.SETTING_CHANGED,
					key,
					FocusCastBarSaved.Settings.ShowCastTimeFractions
				)
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Boolean,
				L.Settings.ShowCastTimeFractionsLabel,
				defaults.ShowCastTimeFractions,
				GetValue,
				SetValue
			)

			Settings.CreateCheckbox(category, setting, L.Settings.ShowCastTimeFractionsTooltip)
		elseif key == Private.Settings.Keys.OffsetY then
			local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

			local function GetValue()
				return FocusCastBarSaved.Settings.OffsetY
			end

			local function SetValue(value)
				if value ~= FocusCastBarSaved.Settings.OffsetY then
					FocusCastBarSaved.Settings.OffsetY = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.FrameOffsetYLabel,
				defaults.OffsetY,
				GetValue,
				SetValue
			)
			local options = Settings.CreateSliderOptions(sliderSettings.min, sliderSettings.max, sliderSettings.step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

			Settings.CreateSlider(category, setting, options, L.Settings.FrameOffsetYTooltip)
		elseif key == Private.Settings.Keys.OffsetX then
			local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

			local function GetValue()
				return FocusCastBarSaved.Settings.OffsetX
			end

			local function SetValue(value)
				if value ~= FocusCastBarSaved.Settings.OffsetX then
					FocusCastBarSaved.Settings.OffsetX = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.FrameOffsetXLabel,
				defaults.OffsetX,
				GetValue,
				SetValue
			)
			local options = Settings.CreateSliderOptions(sliderSettings.min, sliderSettings.max, sliderSettings.step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)

			Settings.CreateSlider(category, setting, options, L.Settings.FrameOffsetXTooltip)
		elseif key == Private.Settings.Keys.Opacity then
			local sliderSettings = Private.Settings.GetSliderSettingsForOption(key)

			local function GetValue()
				return FocusCastBarSaved.Settings.Opacity
			end

			local function SetValue(value)
				if value ~= FocusCastBarSaved.Settings.Opacity then
					FocusCastBarSaved.Settings.Opacity = value

					Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
				end
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.OpacityLabel,
				defaults.Opacity,
				GetValue,
				SetValue
			)
			local options = Settings.CreateSliderOptions(sliderSettings.min, sliderSettings.max, sliderSettings.step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage)

			Settings.CreateSlider(category, setting, options, L.Settings.OpacityTooltip)
		elseif key == Private.Settings.Keys.ShowBorder then
			local function GetValue()
				return FocusCastBarSaved.Settings.ShowBorder
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ShowBorder = not FocusCastBarSaved.Settings.ShowBorder
				Private.EventRegistry:TriggerEvent(
					Private.Enum.Events.SETTING_CHANGED,
					key,
					FocusCastBarSaved.Settings.ShowBorder
				)
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Boolean,
				L.Settings.ShowBorderLabel,
				defaults.ShowBorder,
				GetValue,
				SetValue
			)

			Settings.CreateCheckbox(category, setting, L.Settings.ShowBorderTooltip)
		elseif key == Private.Settings.Keys.ShowCastTime then
			local function GetValue()
				return FocusCastBarSaved.Settings.ShowCastTime
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ShowCastTime = not FocusCastBarSaved.Settings.ShowCastTime
				Private.EventRegistry:TriggerEvent(
					Private.Enum.Events.SETTING_CHANGED,
					key,
					FocusCastBarSaved.Settings.ShowCastTime
				)
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Boolean,
				L.Settings.ShowCastTimeLabel,
				defaults.ShowCastTime,
				GetValue,
				SetValue
			)

			Settings.CreateCheckbox(category, setting, L.Settings.ShowCastTimeTooltip)
		elseif key == Private.Settings.Keys.GlowType then
			local function GetValue()
				return FocusCastBarSaved.Settings.GlowType
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.GlowType = value

				Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, key, value)
			end

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()

				for label, id in pairs(Private.Enum.GlowType) do
					local translated = L.Settings.GlowTypeLabels[id]

					container:Add(id, translated)
				end

				return container:GetData()
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Number,
				L.Settings.GlowTypeLabel,
				defaults.GlowType,
				GetValue,
				SetValue
			)

			Settings.CreateDropdown(category, setting, GetOptions, L.Settings.GlowTypeTooltip)
		elseif key == Private.Settings.Keys.GlowImportant then
			local function GetValue()
				return FocusCastBarSaved.Settings.GlowImportant
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.GlowImportant = not FocusCastBarSaved.Settings.GlowImportant
				Private.EventRegistry:TriggerEvent(
					Private.Enum.Events.SETTING_CHANGED,
					key,
					FocusCastBarSaved.Settings.GlowImportant
				)
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Boolean,
				L.Settings.GlowImportantLabel,
				defaults.GlowImportant,
				GetValue,
				SetValue
			)

			Settings.CreateCheckbox(category, setting, L.Settings.GlowImportantTooltip)
		elseif key == Private.Settings.Keys.ShowIcon then
			local function GetValue()
				return FocusCastBarSaved.Settings.ShowIcon
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ShowIcon = not FocusCastBarSaved.Settings.ShowIcon
				Private.EventRegistry:TriggerEvent(
					Private.Enum.Events.SETTING_CHANGED,
					key,
					FocusCastBarSaved.Settings.ShowIcon
				)
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Boolean,
				L.Settings.ShowIconLabel,
				defaults.ShowIcon,
				GetValue,
				SetValue
			)

			Settings.CreateCheckbox(category, setting, L.Settings.ShowIconTooltip)
		elseif key == Private.Settings.Keys.ShowBorder then
			local function GetValue()
				return FocusCastBarSaved.Settings.ShowBorder
			end

			local function SetValue(value)
				FocusCastBarSaved.Settings.ShowBorder = not FocusCastBarSaved.Settings.ShowBorder
				Private.EventRegistry:TriggerEvent(
					Private.Enum.Events.SETTING_CHANGED,
					key,
					FocusCastBarSaved.Settings.ShowBorder
				)
			end

			local setting = Settings.RegisterProxySetting(
				category,
				key,
				Settings.VarType.Boolean,
				L.Settings.ShowBorderLabel,
				defaults.ShowBorder,
				GetValue,
				SetValue
			)

			Settings.CreateCheckbox(category, setting, L.Settings.ShowBorderTooltip)
		end

		error(string.format("CreateSetting not implemented for key '%s'", key))
	end

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.Settings.EditModeReminder))

	local settingsOrder = Private.Settings.GetSettingsDisplayOrder()
	local defaults = Private.Settings.GetDefaultSettings()

	for i, key in ipairs(settingsOrder) do
		if key == Private.Settings.Keys.ColorUninterruptible then
			layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.Settings.SettingsCheckboxInfo1))
			layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.Settings.SettingsCheckboxInfo2))
			layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.Settings.SettingsCheckboxInfo3))
		end

		CreateSetting(key, defaults)
	end

	Settings.RegisterAddOnCategory(category)

	local function OpenSettings()
		Settings.OpenToCategory(category:GetID())
	end

	AddonCompartmentFrame:RegisterAddon({
		text = settingsName,
		icon = C_AddOns.GetAddOnMetadata(addonName, "IconTexture"),
		registerForAnyClick = true,
		notCheckable = true,
		func = OpenSettings,
		funcOnEnter = function(button)
			MenuUtil.ShowTooltip(button, function(tooltip)
				tooltip:SetText(settingsName, 1, 1, 1)
				tooltip:AddLine(L.Settings.ClickToOpenSettingsLabel)
				tooltip:AddLine(" ")
			end)
		end,
		funcOnLeave = function(button)
			MenuUtil.HideTooltip(button)
		end,
	})

	local uppercased = string.upper(settingsName)
	local lowercased = string.lower(settingsName)

	SlashCmdList[uppercased] = function(message)
		local command, rest = message:match("^(%S+)%s*(.*)$")

		if command == "options" or command == "settings" then
			OpenSettings()
		end
	end

	_G[string.format("SLASH_%s1", uppercased)] = string.format("/%s", lowercased)
end)
