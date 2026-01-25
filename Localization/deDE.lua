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
L.Settings = {}

L.Settings.LoadConditionContentTypeLabel = "Ladebedingung: Spielbereich"
L.Settings.LoadConditionContentTypeLabelAbbreviated = "In Spielbereich laden"
L.Settings.LoadConditionContentTypeTooltip = nil
L.Settings.LoadConditionContentTypeLabels = {
	[Private.Enum.ContentType.OpenWorld] = "Offene Welt",
	[Private.Enum.ContentType.Delve] = "Tiefen",
	[Private.Enum.ContentType.Dungeon] = "Instanz",
	[Private.Enum.ContentType.Raid] = "Schlachtzug",
	[Private.Enum.ContentType.Arena] = "Arena",
	[Private.Enum.ContentType.Battleground] = "Schlachtfeld",
}

L.Settings.LoadConditionRoleLabel = "Ladebedingung: Rolle"
L.Settings.LoadConditionRoleLabelAbbreviated = "In Rolle laden"
L.Settings.LoadConditionRoleTooltip = nil

L.Settings.LoadConditionRoleLabels = {
	[Private.Enum.Role.Healer] = "Heiler",
	[Private.Enum.Role.Tank] = "Panzer",
	[Private.Enum.Role.Damager] = "Schadensverursacher",
}

L.Settings.FrameWidthLabel = "Breite"
L.Settings.FrameWidthTooltip = nil

L.Settings.FrameHeightLabel = "Höhe"
L.Settings.FrameHeightTooltip = nil

L.Settings.GlowImportantLabel = "Wichtige Zauber hervorheben"
L.Settings.GlowImportantTooltip =
	"Was wichtig und was nicht wichtig ist wird ausschließlich vom Spiel selbst kommuniziert."

L.Settings.GlowTypeLabel = "Hervorhebungsanimation"
L.Settings.GlowTypeTooltip = nil
L.Settings.GlowTypeLabels = {
	[Private.Enum.GlowType.PixelGlow] = "Pixel Glow",
	[Private.Enum.GlowType.AutoCastGlow] = "Auto Cast Glow",
	[Private.Enum.GlowType.ButtonGlow] = "Button Glow",
	[Private.Enum.GlowType.ProcGlow] = "Proc Glow",
	[Private.Enum.GlowType.Star4] = "Star 4",
}

L.Settings.ShowDurationLabel = "Dauer anzeigen"
L.Settings.ShowDurationTooltip = nil

L.Settings.ShowDurationFractionsLabel = "Sekundenbruchteile anzeigen"
L.Settings.ShowDurationFractionsTooltip = nil

L.Settings.OpacityLabel = "Deckkraft"
L.Settings.OpacityTooltip = nil

L.Settings.FrameOffsetXLabel = "Versatz X-Achse"
L.Settings.FrameOffsetXTooltip = nil

L.Settings.FrameOffsetYLabel = "Versatz Y-Achse"
L.Settings.FrameOffsetYTooltip = nil

L.Settings.ClickToOpenSettingsLabel = "Klicken um Einstellungen zu öffnen"

L.Settings.Import = "Importieren"
L.Settings.Export = "Exportieren"
