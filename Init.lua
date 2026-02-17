---@type string, AdvancedFocusCastBar
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
	---@type SavedVariables
	AdvancedFocusCastBarSaved = AdvancedFocusCastBarSaved or {}

	---@type AdvancedFocusCastBarSettings
	AdvancedFocusCastBarSaved.Settings = AdvancedFocusCastBarSaved.Settings or {}

	local defaultSettings = Private.Settings.GetDefaultSettings()
	for key, value in pairs(defaultSettings) do
		if
			AdvancedFocusCastBarSaved.Settings[key] == nil
			or type(value) ~= type(AdvancedFocusCastBarSaved.Settings[key])
		then
			AdvancedFocusCastBarSaved.Settings[key] = value
		end
	end

	-- ignore whether it's currently enabled. migrate settings anyway so there's no odd state when next time
	-- the target cast bar gets enabled
	if AdvancedFocusCastBarSaved.Settings.TargetSettings ~= nil then
		for key, value in pairs(defaultSettings) do
			if
				AdvancedFocusCastBarSaved.Settings.TargetSettings[key] == nil
				or type(value) ~= type(AdvancedFocusCastBarSaved.Settings.TargetSettings[key])
			then
				AdvancedFocusCastBarSaved.Settings.TargetSettings[key] = value
			end
		end
	end

	for i = 1, #Private.LoginFnQueue do
		local fn = Private.LoginFnQueue[i]
		fn()
	end

	table.wipe(Private.LoginFnQueue)
end)
