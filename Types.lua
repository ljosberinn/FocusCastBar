---@meta

---@class AdvancedFocusCastBar
---@field EventRegistry CallbackRegistryMixin
---@field Events table<string, string>
---@field Enum AdvancedFocusCastBarEnums
---@field Settings AdvancedFocusCastBarSettings
---@field LoginFnQueue table<string, function>
---@field L table<string, table<string, string|nil>>
---@field Utils AdvancedFocusCastBar

---@class AdvancedFocusCastBarUtils
---@field ShowStaticPopup fun(args: StaticPopupDialogsArgs)
---@field Import fun(string: string): boolean
---@field Export fun(): string
---@field RegisterEditModeFrame fun(frame: Frame)
---@field RollDice fun(): boolean

---@class StaticPopupDialogsArgs
---@field text string
---@field button1 string
---@field button2 string?
---@field OnAccept fun()?
---@field hasEditBox boolean?
---@field hasWideEditBox boolean?
---@field editBoxWidth number?
---@field hideOnEscape boolean?

---@class AdvancedFocusCastBarEnums

---@class SliderSettings
---@field min number
---@field max number
---@field step number

---@class AdvancedFocusCastBarSettings
---@field Keys table<string, string>>
---@field GetSettingsDisplayOrder fun(): string[]
---@field GetDefaultEditModeFramePosition fun(): FramePosition
---@field GetSliderSettingsForOption fun(key: string): SliderSettings
---@field GetDefaultSettings fun(): SavedVariablesSettings

---@class FramePosition
---@field point string
---@field x number
---@field y number

---@class SavedVariables
---@field Settings SavedVariablesSettings

---@class SavedVariablesSettings
---@field Width number
---@field Height number
---@field Direction number
---@field LoadConditionContentType boolean[]
---@field LoadConditionRole boolean[]
---@field ShowIcon boolean
---@field ShowCastTime boolean
---@field Opacity number
---@field ShowBorder boolean
---@field GlowImportant boolean
---@field GlowType number
---@field OffsetX number
---@field OffsetY number
---@field ColorUninterruptible string
---@field ColorInterruptibleCanInterrupt string
---@field ColorInterruptibleCannotInterrupt string
---@field ColorInterruptTick string
---@field Texture string
---@field Position FramePosition

---@class StatusBar
---@field SetTimerDuration fun(self: StatusBar, duration: DurationObjectDummy)

---@class InterruptBar: StatusBar
---@field Tick Texture

---@class AdvancedFocusCastBarMixin: StatusBar
---@field Icon Texture
---@field SpellNameText FontString
---@field CastTimeText FontString
---@field Border BackdropTemplate
---@field InterruptBar InterruptBar
---@field Mask MaskTexture

---@class CastMetaInformation
---@field castingInfo DurationObjectDummy
---@field isChannel boolean
---@field name string
---@field texture string
---@field notInterruptible boolean

---@class AdvancedFocusCastBarDriver
---@field private interruptId number?
---@field private role number
---@field private contentType number
---@field private colors table<string, ColorMixin>
---@field private frame AdvancedFocusCastBarMixin
---@field Init fun()
---@field LoadConditionsProhibitExecution fun(): boolean
---@field OnSettingsChanged fun(key: string, value: number|string|boolean|table)
---@field UnitIsIrrelevant fun(): boolean
---@field GetCastMetaInformation fun(): CastMetaInformation
---@field DetectInterruptId fun(): number
---@field DeriveAndSetNextColor fun(notInterruptible: boolean, cooldownDuration: DurationObjectDummy|nil)
---@field OnFrameEvent fun(self: Frame, event: string, ...)

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
---@field default ColorMixin

---@class Frame
---@field SetAlphaFromBoolean fun(self: Frame, value: boolean, alphaIfTrue: number, alphaIfFalse: number)

---@class PlayerUtil
---@field GetCurrentSpecID fun(): number?
---@field GetSpecName fun(specId: number): string

---@type PlayerUtil
PlayerUtil = {
	GetCurrentSpecID = function()
		return nil
	end,
	GetSpecName = function()
		return ""
	end,
}

---@class DurationObjectDummy
---@field Assign fun(self: DurationObjectDummy, other: DurationObjectDummy)
---@field copy fun(self: DurationObjectDummy): DurationObjectDummy
---@field EvaluateElapsedPercent fun(self: DurationObjectDummy, curve: CurveObjectDummy, modifier: number?): number
---@field EvaluateRemainingPercent fun(self: DurationObjectDummy, curve: CurveObjectDummy, modifier: number?): number
---@field GetElapsedDuration fun(self: DurationObjectDummy, modifier: number?): number
---@field GetElapsedPercent fun(self: DurationObjectDummy, modifier: number?): number
---@field GetEndTime fun(self: DurationObjectDummy, modifier: number?): number
---@field GetModRate fun(self: DurationObjectDummy): number
---@field GetRemainingDuration fun(self: DurationObjectDummy, modifier: number?): number
---@field GetRemainingPercent fun(self: DurationObjectDummy, modifier: number?): number
---@field GetStartTime fun(self: DurationObjectDummy, modifier: number?): number
---@field GetTotalDuration fun(self: DurationObjectDummy, modifier: number?): number
---@field HasSecretValues fun(self: DurationObjectDummy): boolean
---@field IsZero fun(self: DurationObjectDummy): boolean
---@field Reset fun(self: DurationObjectDummy)
---@field SetTimeFromEnd fun(self: DurationObjectDummy, endTime: number, duration: number, modRate: number?)
---@field SetTimeFromStart fun(self: DurationObjectDummy, startTime: number, duration: number, modRate: number?)
---@field SetTimeSpan fun(self: DurationObjectDummy, startTime: number, endTime: number)
---@field SetToDefaults fun(self: DurationObjectDummy)

---@param unit string
---@return DurationObjectDummy
function UnitCastingDuration(unit)
	return {}
end

---@param unit string
---@return DurationObjectDummy
function UnitChannelDuration(unit)
	return {}
end

---@param label string
---@return table
function CreateSettingsListSectionHeaderInitializer(label) end

---@param setting table
---@param OpenColorPicker fun(swatch: table, button: table, isDown: boolean)
---@param clickRequiresSet boolean
---@param invertClickRequiresSet boolean
---@param tooltip string?
---@param GetColor fun(): ColorMixin
---@return table
function CreateSettingsCheckboxWithColorSwatchInitializer(
	setting,
	OpenColorPicker,
	clickRequiresSet,
	invertClickRequiresSet,
	tooltip,
	GetColor
)
	return {}
end

C_CurveUtil = {
	EvaluateColorValueFromBoolean =
		---@param bool boolean
		---@param valueIfTrue number
		---@param valueifFalse number
		---@return number
		function(bool, valueIfTrue, valueifFalse)
			return 0
		end,
}

---@class Frame
---@field SetVertexColorFromBoolean fun(self: Frame, bool: boolean, colorIfTrue: ColorMixin, colorIfFalse: ColorMixin)

---@class Texture
---@field SetVertexColorFromBoolean fun(self: Texture, bool: boolean, colorIfTrue: ColorMixin, colorIfFalse: ColorMixin)

---@class PlayerUtil
---@field GetCurrentSpecID fun(): number?

---@type PlayerUtil
PlayerUtil = {
	GetCurrentSpecID = function()
		return nil
	end,
}
