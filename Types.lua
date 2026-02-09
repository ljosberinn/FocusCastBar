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
---@field LoadConditionContentType table<ContentType, boolean>
---@field LoadConditionRole table<Role, boolean>
---@field ShowCastTime boolean
---@field Opacity number
---@field ShowBorder boolean
---@field Texture string
---@field GlowImportant boolean
---@field ShowIcon boolean
---@field Point string
---@field OffsetX number
---@field OffsetY number
---@field ColorUninterruptible string
---@field ColorInterruptibleCanInterrupt string
---@field ColorInterruptibleCannotInterrupt string
---@field ColorInterruptTick string
---@field Font string
---@field FontSize number
---@field TickWidth number
---@field ShowTargetMarker boolean
---@field BackgroundOpacity number
---@field ShowTargetName boolean
---@field ShowTargetClassColor boolean
---@field PlayFocusTTSReminder boolean
---@field IgnoreFriendlies boolean

---@class AdvancedFocusCastBarSettings
---@field GetDefaultEditModeFramePosition fun(): FramePosition
---@field GetDefaultSettings fun(): AdvancedFocusCastBarSettings

---@class InterruptBar : StatusBar
---@field Tick Texture

---@class InterruptMarkerBar : StatusBar
---@field InterruptMarkerPoint Texture

---@class CustomCastBar : StatusBar
---@field Background Texture
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
---@field texture number -- secret
---@field notInterruptible boolean -- secret
---@field isImportant boolean -- secret

---@class AdvancedFocusCastBarTargetMarkerFrame : Frame
---@field TargetMarker Texture

---@class AdvancedFocusCastBarTargetNameFrame : Frame
---@field TargetNameText1 FontString
---@field TargetNameText2 FontString
---@field TargetNameText3 FontString
---@field TargetNameText4 FontString
---@field TargetNameText5 FontString

---@class AdvancedFocusCastBarBorder : BackdropTemplate
---@field _PixelGlow Frame?

---@class AdvancedFocusCastBarColors
---@field ColorUninterruptible ColorMixin
---@field ColorInterruptibleCanInterrupt ColorMixin
---@field ColorInterruptibleCannotInterrupt ColorMixin
---@field ColorInterruptTick ColorMixin?

---@class EditModeSelection : Frame
---@field Label FontString

---@class AdvancedFocusCastBarMixin : Frame
---@field Icon Texture
---@field CastBar CustomCastBar
---@field Border AdvancedFocusCastBarBorder
---@field TargetMarkerFrame AdvancedFocusCastBarTargetMarkerFrame
---@field TargetNameFrame AdvancedFocusCastBarTargetNameFrame
---@field Selection EditModeSelection
---@field private interruptId number?
---@field private contentType number?
---@field private role number?
---@field private castInformation CastInformation?
---@field private colors AdvancedFocusCastBarColors
---@field private demoInterval table?
---@field private ttsVoiceId number?
---@field private firstFrameTimestamp number
---@field OnLoad fun(self: AdvancedFocusCastBarMixin)
---@field IsPastLoadingScreen fun(self: AdvancedFocusCastBarMixin): boolean
---@field ToggleTargetMarkerIntegration fun(self: AdvancedFocusCastBarMixin)
---@field AdjustIconLayout fun(self: AdvancedFocusCastBarMixin, shown: boolean)
---@field OnSettingsChange fun(self: AdvancedFocusCastBarMixin, key: SettingKey, value: any)
---@field ToggleTargetNameVisibility fun(self: AdvancedFocusCastBarMixin)
---@field SetFontAndFontSize fun(self: AdvancedFocusCastBarMixin)
---@field RestoreEditModePosition fun(self: AdvancedFocusCastBarMixin)
---@field OnEditModePositionChange fun(self: AdvancedFocusCastBarMixin, frame: Frame, layoutName: string, point: string, x: number, y: number)
---@field LoopPreview fun(self: AdvancedFocusCastBarMixin)
---@field ToggleDemo fun(self: AdvancedFocusCastBarMixin)
---@field OnEditModeEnter fun(self: AdvancedFocusCastBarMixin)
---@field OnEditModeExit fun(self: AdvancedFocusCastBarMixin)
---@field OnUpdate fun(self: AdvancedFocusCastBarMixin, elapsed: number)
---@field ShowGlow fun(self: AdvancedFocusCastBarMixin, isImportant: boolean)
---@field HideGlow fun(self: AdvancedFocusCastBarMixin)
---@field LoadConditionsProhibitExecution fun(self: AdvancedFocusCastBarMixin): boolean
---@field UnitIsIrrelevant fun(self: AdvancedFocusCastBarMixin): boolean
---@field DetectInterruptId fun(self: AdvancedFocusCastBarMixin): number?
---@field DeriveAndSetNextColor fun(self: AdvancedFocusCastBarMixin, interruptDuration: LuaDurationObject?)
---@field QueryCastInformation fun(self: AdvancedFocusCastBarMixin): CastInformation?
---@field ProcessCastInformation fun(self: AdvancedFocusCastBarMixin)
---@field FindApporpriateTTSVoiceID fun(self: AdvancedFocusCastBarMixin): number
---@field OnEvent fun(self: AdvancedFocusCastBarMixin, event: string, ...)
---@field GetRandomIcon fun(self: AdvancedFocusCastBarMixin): number

-------- library types

---@class LibEditModeSetting
---@field name string
---@field kind string|number
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

---@class BackdropTemplate : Frame
---@field SetShown fun(self: BackdropTemplate, bool: boolean)

---@class IconDataProviderMixin
---@field GetRandomIcon fun(self: IconDataProviderMixin): number

IconDataProviderMixin = {
	GetRandomIcon = function()
		return 1
	end,
}

---@type string?
GAME_LOCALE = nil

PixelUtil = {
	SetSize =
		---@param frame Frame|Texture|MaskTexture
		---@param width number
		---@param height number
		function(frame, width, height) end,
}
