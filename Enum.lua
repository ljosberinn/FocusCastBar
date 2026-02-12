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
	OpenWorld = 1,
	Delve = 2,
	Dungeon = 3,
	Raid = 4,
	Arena = 5,
	Battleground = 6,
}

---@enum Role
Private.Enum.Role = {
	Healer = 1,
	Tank = 2,
	Damager = 3,
}

---@enum Point
Private.Enum.Point = {
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
}

---@enum TargetNamePosition
Private.Enum.TargetNamePosition = {
	BOTTOMCENTER = "BOTTOMCENTER",
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
}

---@enum Setting
Private.Enum.Setting = {
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
	ColorUninterruptible = "COLOR_UNINTERRUPTIBLE",
	ColorInterruptibleCanInterrupt = "COLOR_INTERRUPTIBLE_CAN_INTERRUPT",
	ColorInterruptibleCannotInterrupt = "COLOR_INTERRUPTIBLE_CANNOT_INTERRUPT",
	ColorInterruptTick = "COLOR_INTERRUPT_TICK",
	Font = "FONT",
	FontSize = "FONT_SIZE",
	ShowTargetMarker = "SHOW_TARGET_MARKER",
	BackgroundOpacity = "BACKGROUND_OPACITY",
	ShowTargetName = "SHOW_TARGET_NAME",
	ShowTargetClassColor = "SHOW_TARGET_CLASS_COLOR",
	TargetNamePosition = "TARGET_NAME_POSITION",
	PlayFocusTTSReminder = "PLAY_FOCUS_TTS_REMINDER",
	TickWidth = "TICK_WIDTH",
	IgnoreFriendlies = "IGNORE_FRIENDLIES",
	OutOfRangeOpacity = "OUT_OF_RANGE_OPACITY",
	FontFlags = "FONT_FLAGS",
	ShowInterruptSource = "SHOW_INTERRUPT_SOURCE",
	UseInterruptSourceColor = "USE_INTERRUPT_SOURCE_COLOR",
}

---@enum FontFlags
Private.Enum.FontFlags = {
	OUTLINE = "OUTLINE",
	SHADOW = "SHADOW",
}
