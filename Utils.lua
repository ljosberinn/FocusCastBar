---@type string, AdvancedFocusCastBar
local addonName, Private = ...

---@class AdvancedFocusCastBar
Private.Utils = {}

function Private.Utils.ShowStaticPopup(args)
	args.id = addonName
	args.whileDead = true

	StaticPopupDialogs[addonName] = args

	StaticPopup_Hide(addonName)
	StaticPopup_Show(addonName)
end

function Private.Utils.RollDice()
	return math.random(1, 6) == 6
end

do
	---@type table<string, Frame|nil>
	local editModeFrame = nil

	function Private.Utils.RegisterEditModeFrame(frame)
		editModeFrame = frame
	end

	function Private.Utils.Import(string)
		local ok, result = pcall(function()
			return C_EncodingUtil.DeserializeCBOR(C_EncodingUtil.DecodeBase64(string))
		end, string)

		if not ok then
			if result ~= nil then
				print(result)
			end

			return false
		end

		-- just a type check
		if result == nil then
			return false
		end

		local hasAnyChange = false

		local frame = editModeFrame
		local point, x, y = result.Position.point, result.Position.x, result.Position.y

		if
			frame ~= nil
			and (
				point ~= AdvancedFocusCastBarSaved.Settings.Position.point
				or x ~= AdvancedFocusCastBarSaved.Settings.Position.x
				or y ~= AdvancedFocusCastBarSaved.Settings.Position.y
			)
		then
			frame:ClearAllPoints()
			frame:SetPoint(point, x, y)
			AdvancedFocusCastBarSaved.Settings.Position.point = point
			AdvancedFocusCastBarSaved.Settings.Position.x = x
			AdvancedFocusCastBarSaved.Settings.Position.y = y
		end

		local defaults = Private.Settings.GetDefaultSettings()
		local eventKeys = Private.Settings.Keys

		for key, defaultValue in pairs(defaults) do
			local newValue = result[key]
			local expectedType = type(defaultValue)

			if newValue and type(newValue) == expectedType then
				local eventKey = eventKeys[key]
				local hasChanges = false

				if expectedType == "table" then
					local enumToCompareAgainst = nil
					if key == "LoadConditionContentType" then
						enumToCompareAgainst = Private.Enum.ContentType
					elseif key == "LoadConditionRole" then
						enumToCompareAgainst = Private.Enum.Role
					end

					-- only other case is Position but that's taken care of above

					if enumToCompareAgainst then
						local newTable = {}

						for _, id in pairs(enumToCompareAgainst) do
							if newValue[id] == nil then
								newTable[id] = AdvancedFocusCastBarSaved.Settings[key][id]
							else
								newTable[id] = newValue[id]

								if newValue[id] ~= AdvancedFocusCastBarSaved.Settings[key][id] then
									hasChanges = true
								end
							end
						end

						if hasChanges then
							AdvancedFocusCastBarSaved.Settings[key] = newTable
							Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, eventKey, newTable)
						end
					end
				elseif newValue ~= AdvancedFocusCastBarSaved.Settings[key] then
					AdvancedFocusCastBarSaved.Settings[key] = newValue
					hasChanges = true

					if eventKey and hasChanges then
						Private.EventRegistry:TriggerEvent(Private.Enum.Events.SETTING_CHANGED, eventKey, newValue)
					end
				end

				if hasChanges then
					hasAnyChange = true
				end
			end
		end

		return hasAnyChange
	end

	function Private.Utils.Export()
		return C_EncodingUtil.EncodeBase64(C_EncodingUtil.SerializeCBOR(AdvancedFocusCastBarSaved.Settings))
	end
end

_G.AdvancedFocusCastBarAPI = {
	Import = Private.Utils.Import,
	Export = Private.Utils.Export,
}
