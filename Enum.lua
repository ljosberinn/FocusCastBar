---@type string, FocusCastBar
local addonName, Private = ...

---@class FocusCastBarEnums
Private.Enum = {}

---@enum CustomEvents
Private.Enum.Events = {
	SETTING_CHANGED = "SETTING_CHANGED",
	EDIT_MODE_POSITION_CHANGED = "EDIT_MODE_POSITION_CHANGED",
}

---@enum Direction
Private.Enum.Direction = {
	Horizontal = 1,
	Vertical = 2,
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

---@enum GlowType
Private.Enum.GlowType = {
	PixelGlow = 1,
	AutoCastGlow = 2,
	ButtonGlow = 3,
	ProcGlow = 4,
}
