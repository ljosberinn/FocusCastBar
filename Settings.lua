---@type string, AdvancedFocusCastBar
local addonName, Private = ...

---@class AdvancedFocusCastBarSettings
Private.Settings = {}

---@return SavedVariables
function Private.Settings.GetDefaultSettings()
	return {
		Width = 300,
		Height = 22,
		LoadConditionContentType = {
			[Private.Enum.ContentType.OpenWorld] = true,
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
		Opacity = 1,
		ShowBorder = true,
		Texture = "Interface\\TargetingFrame\\UI-StatusBar",
		GlowImportant = true,
		ShowIcon = true,
		Point = Private.Enum.Point.CENTER,
		OffsetX = 0,
		OffsetY = 200,
		ColorUninterruptible = "FFE07800",
		ColorInterruptibleCanInterrupt = "FF00FF00",
		ColorInterruptibleCannotInterrupt = "FFFF0000",
		ColorInterruptTick = "FF00FF00",
		Font = "Fonts\\FRIZQT__.TTF",
		FontSize = 18,
		ShowTargetMarker = true,
		BackgroundOpacity = 0.35,
		ShowTargetName = true,
		ShowTargetClassColor = false,
		PlayFocusTTSReminder = true,
	}
end

table.insert(Private.LoginFnQueue, function()
	local L = Private.L
	local settingsName = C_AddOns.GetAddOnMetadata(addonName, "Title")
	local category, layout = Settings.RegisterVerticalLayoutCategory(settingsName)

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.Settings.EditModeReminder))

	Settings.RegisterAddOnCategory(category)
end)
