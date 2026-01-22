---@meta

---@class FocusCastBar
---@field EventRegistry CallbackRegistryMixin
---@field Events table<string, string>
---@field Enum FocusCastBarEnums
---@field Settings FocusCastBarSettings
---@field LoginFnQueue table<string, function>
---@field L table<string, table<string, string|nil>>

---@class FocusCastBarEnums

---@class SliderSettings
---@field min number
---@field max number
---@field step number

---@class FocusCastBarSettings
---@field Keys table<string, string>>
---@field GetSettingsDisplayOrder fun(): string[]
---@field GetDefaultEditModeFramePosition fun(): FramePosition
---@field GetSliderSettingsForOption fun(key: string): SliderSettings
---@field GetDefaultSettings fun(): SavedVariablesSettings

---@class FramePosition
---@field point string
---@field x number
---@field y number
---@
---@class SavedVariables
---@field Settings SavedVariablesSettings

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

---@class Frame
---@field SetAlphaFromBoolean fun(self: Frame, value: boolean)
---@
---@---@class PlayerUtil
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
UnitCastingDuration = function(unit)
	return {}
end

---@param unit string
---@return DurationObjectDummy
UnitChannelDuration = function(unit)
	return {}
end
