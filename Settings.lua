---@type string, FocusCastBar
local addonName, Private = ...

---@class FocusCastBarSettings
Private.Settings = {}

Private.Settings.Keys = {
	Width = 200,
	height = 18,
	-- Direction = copy
	LoadConditionContentType = {
		-- copy
	},
	LoadConditionRole = {
		-- copy
	},
	ShowIcon = true,
	ShowDuration = true,
	ShowDurationFractions = true,
	Opacity = 1,
	-- border?
	GlowImportant = true,
	-- GlowType = copy
}

function Private.Settings.GetSettingsDisplayOrder()
	return {}
end

function Private.Settings.GetDefaultEditModeFramePosition()
	return { point = "CENTER", x = 0, y = 100 }
end

function Private.Settings.GetSliderSettingsForOption(key)
	error(
		string.format(
			"Slider Settings for key '%s' are either not implemented or you're calling this with the wrong key.",
			key
		)
	)
end

---@return SavedVariablesSettings
function Private.Settings.GetDefaultSettings()
	return {}
end

table.insert(Private.LoginFnQueue, function()
	local L = Private.L
	local settingsName = C_AddOns.GetAddOnMetadata(addonName, "Title")
	local category, layout = Settings.RegisterVerticalLayoutCategory(settingsName)

	---@class SettingConfig
	---@field initializer table
	---@field hideSteppers boolean
	---@field IsSectionEnabled nil|fun(): boolean

	---@param key string
	---@param defaults SavedVariablesSettingsSelf|SavedVariablesSettingsParty
	---@return SettingConfig
	local function CreateSetting(key, defaults)
		error(string.format("CreateSetting not implemented for key '%s'", key))
	end

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.Settings.EditModeReminder))

	local generalCategoryEnabledInitializer

	local function IsSectionEnabled()
		return FocusCastBarSaved.Settings.Self.Enabled
	end

	local settingsOrder = Private.Settings.GetSettingsDisplayOrder()
	local defaults = Private.Settings.GetDefaultSettings()

	for i, key in ipairs(settingsOrder) do
		local config = CreateSetting(key, defaults)

		if key == Private.Settings.Keys.Enabled then
			generalCategoryEnabledInitializer = config.initializer
		else
			if config.hideSteppers then
				config.initializer.hideSteppers = true
			end

			config.initializer:SetParentInitializer(
				generalCategoryEnabledInitializer,
				config.IsSectionEnabled or IsSectionEnabled
			)
		end
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
