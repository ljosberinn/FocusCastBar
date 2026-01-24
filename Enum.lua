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
Private.Enum.Direction = EnumUtil.MakeEnum("Horizontal", "Vertical")

---@enum ContentType
Private.Enum.ContentType = EnumUtil.MakeEnum("OpenWorld", "Delve", "Dungeon", "Raid", "Arena", "Battleground")

---@enum Role
Private.Enum.Role = EnumUtil.MakeEnum("Healer", "Tank", "Damager")

---@enum GlowType
Private.Enum.GlowType = EnumUtil.MakeEnum("PixelGlow", "AutoCastGlow", "ButtonGlow", "ProcGlow")
