---@type string, AdvancedFocusCastBar
local addonName, Private = ...

---@class AdvancedFocusCastBarEnums
Private.Enum = {}

---@enum CustomEvents
Private.Enum.Events = {
	SETTING_CHANGED = "SETTING_CHANGED",
	EDIT_MODE_POSITION_CHANGED = "EDIT_MODE_POSITION_CHANGED",
}

---@enum Direction
Private.Enum.Direction = {
	Horizontal = 0,
	Vertical = 1,
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

---@enum GlowType
Private.Enum.GlowType = {
	PixelGlow = 0,
	AutoCastGlow = 1,
	ButtonGlow = 2,
	ProcGlow = 3,
}
