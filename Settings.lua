---@type string, AdvancedFocusCastBar
local addonName, Private = ...

---@class AdvancedFocusCastBarSettings
Private.Settings = {}

function Private.Settings.GetDefaultEditModeFramePosition()
	return { point = "CENTER", x = 0, y = 100 }
end

---@return SavedVariables
function Private.Settings.GetDefaultSettings()
	return {
		Width = 300,
		Height = 25,
		Direction = Private.Enum.Direction.Horizontal,
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
		Position = Private.Settings.GetDefaultEditModeFramePosition(),
		Opacity = 1,
		ShowBorder = true,
		Texture = "Interface\\TargetingFrame\\UI-StatusBar",
		GlowImportant = true,
		ShowIcon = true,
		OffsetX = 0,
		OffsetY = 0,
		GlowType = Private.Enum.GlowType.PixelGlow,
		ColorUninterruptible = "FFE07800",
		ColorInterruptibleCanInterrupt = "FF00FF00",
		ColorInterruptibleCannotInterrupt = "FFFF0000",
		ColorInterruptTick = "FF00FF00",
		Font = "Fonts\\FRIZQT__.TTF",
		FontSize = 20,
		ManualAnchorName = "",
	}
end

table.insert(Private.LoginFnQueue, function()
	local L = Private.L
	local settingsName = C_AddOns.GetAddOnMetadata(addonName, "Title")
	local category, layout = Settings.RegisterVerticalLayoutCategory(settingsName)

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.Settings.EditModeReminder))

	Settings.RegisterAddOnCategory(category)
end)
