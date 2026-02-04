---@meta

---@class AdvancedFocusCastBar
---@field EventRegistry CallbackRegistryMixin
---@field Events table<string, string>
---@field Enum AdvancedFocusCastBarEnums
---@field Settings AdvancedFocusCastBarSettings
---@field LoginFnQueue table<string, function>
---@field L table<string, table<string, string|nil>>
---@field Utils AdvancedFocusCastBar
---@field Driver AdvancedFocusCastBarMixin

---@class AdvancedFocusCastBarEnums

---@class SliderSettings
---@field min number
---@field max number
---@field step number

---@class FramePosition
---@field point string
---@field x number
---@field y number

---@class SavedVariables
---@field Settings AdvancedFocusCastBarSettings

---@class AdvancedFocusCastBarSettings
---@field Width number
---@field Height number
---@field Direction Direction
---@field LoadConditionContentType table<ContentType, boolean>
---@field LoadConditionRole table<Role, boolean>
---@field ShowCastTime boolean
---@field Position FramePosition
---@field Opacity number
---@field ShowBorder boolean
---@field Texture string
---@field GlowImportant boolean
---@field GlowType GlowType
---@field OffsetX number
---@field OffsetY number
---@field ShowInterruptTick boolean
---@field ColorUninterruptible string
---@field ColorInterruptibleCanInterrupt string
---@field ColorInterruptibleCannotInterrupt string
---@field ColorInterruptTick string
---@field Font string
---@field FontSize number
---@field ManualAnchorName string

---@class AdvancedFocusCastBarSettings
---@field GetSettingsDisplayOrder fun(): string[]
---@field GetSliderSettingsForOption fun(key: string): SliderSettings
---@field GetDefaultSettings fun(): SavedVariables

---@class InterruptBar : StatusBar
---@field Tick Texture

---@class InterruptMarkerBar : StatusBar
---@field InterruptMarkerPoint Texture

---@class CustomCastBar : StatusBar
---@field SpellNameText FontString
---@field CastTimeText FontString
---@field InterruptBar InterruptBar
---@field Positioner StatusBar
---@field InterruptMarker InterruptMarkerBar
---@field Mask MaskTexture

---@class CastInformation
---@field duration LuaDurationObject
---@field isChannel boolean
---@field name string -- secret
---@field texture string -- secret
---@field notInterruptible boolean -- secret

---@class AdvancedFocusCastBarMixin : Frame
---@field Border BackdropTemplate
---@field CastBar CustomCastBar
---@field Icon Texture
---@field private _AutoCastGlow Frame?
---@field private _ButtonGlow Frame?
---@field private _PixelGlow Frame?
---@field private _ProcGlow Frame?
---@field private interruptId number?
---@field private contentType number?
---@field private role number?
---@field private castInformation CastInformation?
---@field DetectInterruptId fun(self: AdvancedFocusCastBarMixin): number?
---@field LoadConditionsProhibitExecution fun(self: AdvancedFocusCastBarMixin): boolean
---@field UnitIsIrrelevant fun(self: AdvancedFocusCastBarMixin): boolean
---@field OnLoad fun(self: AdvancedFocusCastBarMixin)
---@field QueryCastInformation fun(self: AdvancedFocusCastBarMixin): CastInformation?
---@field DeriveAndSetNextColor fun(self: AdvancedFocusCastBarMixin, cooldownDuration: LuaDurationObject?)

-------- library types

---@class LibEditModeSetting
---@field name string
---@field kind string
---@field desc string?
---@field default number|string|boolean|table
---@field disabled boolean?

---@class LibEditModeGetterSetter
---@field set fun(layoutName: string, value: number|string|boolean|table, fromReset: boolean)
---@field get fun(layoutName: string): number|string|boolean|table

---@class LibEditModeButton
---@field text string
---@field click function

---@class LibEditModeCheckbox : LibEditModeSetting, LibEditModeGetterSetter

---@class LibEditModeDropdownBase : LibEditModeSetting
---@field generator fun(owner, rootDescription, data)
---@field height number?
---@field multiple boolean?

---@class LibEditModeDropdownGenerator : LibEditModeDropdownBase
---@field generator fun(owner, rootDescription, data)

---@class LibEditModeDropdownSet : LibEditModeDropdownBase
---@field set fun(layoutName: string, value: number|string|boolean|table, fromReset: boolean)

---@alias LibEditModeDropdown LibEditModeDropdownGenerator | LibEditModeDropdownSet

---@class LibEditModeSlider : LibEditModeSetting, LibEditModeGetterSetter
---@field minValue number?
---@field maxValue number?
---@field valueStep number?
---@field formatter (fun(value: number): string)|nil

---@class LibEditModeColorPicker : LibEditModeSetting, LibEditModeGetterSetter
---@field hasOpacity boolean?

-------- type patches

---@class LuaDurationObject
---@field Assign fun(self: LuaDurationObject, other: LuaDurationObject)
---@field copy fun(self: LuaDurationObject): LuaDurationObject
---@field EvaluateElapsedPercent fun(self: LuaDurationObject, curve: LuaCurveObject, modifier: number?): number
---@field EvaluateRemainingPercent fun(self: LuaDurationObject, curve: LuaCurveObject, modifier: number?): number
---@field GetElapsedDuration fun(self: LuaDurationObject, modifier: number?): number
---@field GetElapsedPercent fun(self: LuaDurationObject, modifier: number?): number
---@field GetEndTime fun(self: LuaDurationObject, modifier: number?): number
---@field GetModRate fun(self: LuaDurationObject): number
---@field GetRemainingDuration fun(self: LuaDurationObject, modifier: number?): number
---@field GetRemainingPercent fun(self: LuaDurationObject, modifier: number?): number
---@field GetStartTime fun(self: LuaDurationObject, modifier: number?): number
---@field GetTotalDuration fun(self: LuaDurationObject, modifier: number?): number
---@field HasSecretValues fun(self: LuaDurationObject): boolean
---@field IsZero fun(self: LuaDurationObject): boolean
---@field Reset fun(self: LuaDurationObject)
---@field SetTimeFromEnd fun(self: LuaDurationObject, endTime: number, duration: number, modRate: number?)
---@field SetTimeFromStart fun(self: LuaDurationObject, startTime: number, duration: number, modRate: number?)
---@field SetTimeSpan fun(self: LuaDurationObject, startTime: number, endTime: number)
---@field SetToDefaults fun(self: LuaDurationObject)

---@class Frame
---@field SetAlphaFromBoolean fun(self: Frame, bool: boolean, alphaIfTrue: number?, alphaIfFalse: number?)
---@field SetShown fun(self: Frame, bool: boolean)

---@class StatusBar
---@field SetTimerDuration fun(self: StatusBar, duration: LuaDurationObject)

---@param unit string
---@return LuaDurationObject|nil
function UnitCastingDuration(unit)
	return {}
end

---@param unit string
---@return LuaDurationObject|nil
function UnitChannelDuration(unit)
	return {}
end

---@class PlayerUtil
---@field GetCurrentSpecID fun(): number?

---@type PlayerUtil
PlayerUtil = {
	GetCurrentSpecID = function()
		return nil
	end,
}

---@class Texture
---@field SetVertexColorFromBoolean fun(self: Texture, bool: boolean, colorIfTrue: ColorMixin, colorIfFalse: ColorMixin)

---@class BackdropTemplate
---@field SetShown fun(self: BackdropTemplate, bool: boolean)

---@class IconDataProviderMixin
---@field GetRandomIcon fun(self: IconDataProviderMixin): string
