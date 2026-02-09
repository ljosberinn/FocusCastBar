---@type string, AdvancedFocusCastBar
local addonName, Private = ...

local addonNameWithIcon = ""

do
	local icon = C_AddOns.GetAddOnMetadata(addonName, "IconTexture")
	-- width, height, offsetX, offsetY
	addonNameWithIcon = string.format("|T%s:%d:%d:%d:%d|t %s", icon, 20, 20, 0, -4, addonName)
end

local L = Private.L

L.EditMode = {}

L.EditMode.AddonName = "Advanced Focus Cast Bar"

L.Settings = {}

L.Settings.EditModeReminder = "Settings are exclusively available through Edit Mode."

L.Settings.LoadConditionContentTypeLabel = "Load Condition: Content Type"
L.Settings.LoadConditionContentTypeLabelAbbreviated = "Load in Content"
L.Settings.LoadConditionContentTypeTooltip = nil
L.Settings.LoadConditionContentTypeLabels = {
	[Private.Enum.ContentType.OpenWorld] = "Open World",
	[Private.Enum.ContentType.Delve] = "Delves",
	[Private.Enum.ContentType.Dungeon] = "Dungeon",
	[Private.Enum.ContentType.Raid] = "Raid",
	[Private.Enum.ContentType.Arena] = "Arena",
	[Private.Enum.ContentType.Battleground] = "Battleground",
}

L.Settings.LoadConditionRoleLabel = "Load Condition: Role"
L.Settings.LoadConditionRoleLabelAbbreviated = "Load on Role"
L.Settings.LoadConditionRoleTooltip = nil
L.Settings.LoadConditionRoleLabels = {
	[Private.Enum.Role.Healer] = "Healer",
	[Private.Enum.Role.Tank] = "Tank",
	[Private.Enum.Role.Damager] = "DPS",
}

L.Settings.FrameWidthLabel = "Width"
L.Settings.FrameWidthTooltip = nil

L.Settings.FrameHeightLabel = "Height"
L.Settings.FrameHeightTooltip = nil

L.Settings.GlowImportantLabel = "Glow Important Spells"
L.Settings.GlowImportantTooltip = "What's important and what isn't is declared by the game."

L.Settings.ShowCastTimeLabel = "Show Cast Time"
L.Settings.ShowCastTimeTooltip = nil

L.Settings.ShowBorderLabel = "Show Border"
L.Settings.ShowBorderTooltip = nil

L.Settings.OpacityLabel = "Opacity"
L.Settings.OpacityTooltip = nil

L.Settings.OffsetXLabel = "Offset X"
L.Settings.OffsetXTooltip = nil

L.Settings.OffsetYLabel = "Offset Y"
L.Settings.OffsetYTooltip = nil

L.Settings.ClickToOpenSettingsLabel = "Click to open settings"

L.Settings.Import = "Import"
L.Settings.Export = "Export"

L.Settings.ShowIconLabel = "Show Icon"
L.Settings.ShowIconTooltip = nil

L.Settings.ColorUninterruptibleLabel = "Uninterruptible"

L.Settings.ColorInterruptibleCanInterruptLabel = "Interruptible & Can Interrupt"

L.Settings.ColorInterruptibleCannotInterruptLabel = "Interruptible & Cannot Interrupt"
L.Settings.ColorInterruptibleCannotInterruptTooltip =
	"When you cannot interrupt because your spec has no interrupt, you haven't talented or it you're too low level."

L.Settings.ColorInterruptTickLabel = "Tick Color"

L.Settings.SettingsCheckboxInfo1 = "The checkboxes below DO NOT do anything."
L.Settings.SettingsCheckboxInfo2 = "It's all about the color pickers, click those!"
L.Settings.SettingsCheckboxInfo3 = "There's just no better way to do this via settings at this time."

L.Settings.FontSizeLabel = "Font Size"
L.Settings.FontSizeTooltip = nil

L.Settings.TickWidthLabel = "Tick Width"
L.Settings.TickWidthTooltip = "0 hides the tick."

L.Settings.FontLabel = "Font"
L.Settings.FontTooltip = nil

L.Settings.TextureLabel = "Texture"
L.Settings.TextureTooltip = nil

L.Settings.ShowTargetNameLabel = "Show Target Name"
L.Settings.ShowTargetNameTooltip = "Only shows in Arena / Raid / Dungeons."

L.Settings.ShowTargetClassColorLabel = "Show Target Class Color"
L.Settings.ShowTargetClassColorTooltip = "Can have contrast problems depending on background and bar color."

L.Settings.TargetNamePositionLabel = "Target Name Position"
L.Settings.TargetNamePositionTooltip = nil
L.Settings.TargetNamePositionLabels = {
	[Private.Enum.TargetNamePosition.BOTTOMCENTER] = "Bottom Center",
	[Private.Enum.TargetNamePosition.BOTTOMLEFT] = "Bottom Left",
	[Private.Enum.TargetNamePosition.BOTTOMRIGHT] = "Bottom Right",
}

L.Settings.IgnoreFriendliesLabel = "Ignore Friendlies"
L.Settings.IgnoreFriendliesTooltip =
	"Prevents showing the cast bar if the focus target is friendly or unattackable. Disable for testing purposes."

L.Settings.ShowTargetMarkerLabel = "Show Target Marker"
L.Settings.ShowTargetMarkerTooltip = nil

L.Settings.BackgroundOpacityLabel = "Background Opacity"
L.Settings.BackgroundOpacityTooltip = nil

L.Settings.OutOfRangeOpacityLabel = "Out of Range Opacity"
L.Settings.OutOfRangeOpacityTooltip = "100% to disable."

L.Settings.PlayFocusTTSReminderLabel = "Play Focus TTS Reminder"
L.Settings.PlayFocusTTSReminderTooltip =
	"Plays 'focus' text-to-speech when your current focus target disappears as a reminder to pick a new one. Only in dungeons!"

L.Settings.PointLabel = "Point"
L.Settings.PointTooltip =
	"Together with Offset X / Offset Y, allows more granular positioning control in contrast to drag & drop."
