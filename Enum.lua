---@type string, AdvancedFocusCastBar
local addonName, Private = ...

---@class AdvancedFocusCastBarEnums
Private.Enum = {}

---@enum CustomEvents
Private.Enum.Events = {
	SETTING_CHANGED = "SETTING_CHANGED",
	EDIT_MODE_POSITION_CHANGED = "EDIT_MODE_POSITION_CHANGED",
}

---@enum ContentType
Private.Enum.ContentType = {
	OpenWorld = 0,
	Delve = 1,
	Dungeon = 2,
	Raid = 3,
	Arena = 4,
	Battleground = 5,
}

---@enum Role
Private.Enum.Role = {
	Healer = 0,
	Tank = 1,
	Damager = 2,
}

---@enum Point
Private.Enum.Point = {
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
}

---@enum SettingKey
Private.Enum.SettingsKey = {
	Width = "WIDTH",
	Height = "HEIGHT",
	LoadConditionContentType = "LOAD_CONDITION_CONTENT_TYPE",
	LoadConditionRole = "LOAD_CONDITION_ROLE",
	ShowIcon = "SHOW_ICON",
	ShowCastTime = "SHOW_CAST_TIME",
	Opacity = "OPACITY",
	ShowBorder = "SHOW_BORDER",
	Texture = "TEXTURE",
	GlowImportant = "GLOW_IMPORTANT",
	Point = "POINT",
	OffsetX = "OFFSET_X",
	OffsetY = "OFFSET_Y",
	ShowInterruptTick = "SHOW_INTERRUPT_TICK",
	ColorUninterruptible = "COLOR_UNINTERRUPTIBLE",
	ColorInterruptibleCanInterrupt = "COLOR_INTERRUPTIBLE_CAN_INTERRUPT",
	ColorInterruptibleCannotInterrupt = "COLOR_INTERRUPTIBLE_CANNOT_INTERRUPT",
	ColorInterruptTick = "COLOR_INTERRUPT_TICK",
	Font = "FONT",
	FontSize = "FontSize",
	ShowTargetMarker = "SHOW_TARGET_MARKER",
	BackgroundOpacity = "BACKGROUND_OPACITY",
	ShowTargetName = "SHOW_TARGET_NAME",
	ShowTargetClassColor = "SHOW_TARGET_CLASS_COLOR",
	PlayFocusTTSReminder = "PLAY_FOCUS_TTS_REMINDER",
	TickWidth = "TICK_WIDTH",
}
