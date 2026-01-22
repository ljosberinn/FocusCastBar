---@type string, FocusCastBar
local addonName, Private = ...

Private.L = {}

Private.EventRegistry = CreateFromMixins(CallbackRegistryMixin)
Private.EventRegistry:OnLoad()

do
	local tbl = {}

	for _, value in pairs(Private.Enum.Events) do
		table.insert(tbl, value)
	end

	Private.EventRegistry:GenerateCallbackEvents(tbl)
end

Private.LoginFnQueue = {}

EventUtil.ContinueOnAddOnLoaded(addonName, function()
	---@class SavedVariables
	FocusCastBarSaved = FocusCastBarSaved or {}

	---@class FocusCastBarSettings
	FocusCastBarSaved.Settings = FocusCastBarSaved.Settings or {}
	---@class SavedVariablesSettings
	FocusCastBarSaved.Settings = FocusCastBarSaved.Settings or {}

	for key, value in pairs(Private.Settings.GetDefaultSettings()) do
		if FocusCastBarSaved.Settings[key] == nil or type(value) ~= type(FocusCastBarSaved.Settings[key]) then
			FocusCastBarSaved.Settings[key] = value
		end
	end

	for i = 1, #Private.LoginFnQueue do
		local fn = Private.LoginFnQueue[i]
		fn()
	end

	table.wipe(Private.LoginFnQueue)
end)
