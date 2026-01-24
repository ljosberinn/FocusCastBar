-----@type string, FocusCastBar
local addonName, Private = ...

---@class FocusCastBarDriver
local FocusCastBarDriver = {}

function FocusCastBarDriver:Init()
	self.interruptId = nil
	self.colors = {
		ColorUninterruptible = CreateColorFromHexString(FocusCastBarSaved.Settings.ColorUninterruptible),
		ColorInterruptibleCanInterrupt = CreateColorFromHexString(
			FocusCastBarSaved.Settings.ColorInterruptibleCanInterrupt
		),
		ColorInterruptibleCannotInterrupt = CreateColorFromHexString(
			FocusCastBarSaved.Settings.ColorInterruptibleCannotInterrupt
		),
		ColorInterruptTick = CreateColorFromHexString(FocusCastBarSaved.Settings.ColorInterruptTick),
	}

	self.frame = CreateFrame("Frame", "FocusCastBarParent", UIParent)
	self.frame:SetSize(FocusCastBarSaved.Settings.Width, FocusCastBarSaved.Settings.Height)
	self.frame:ClearAllPoints()
	self.frame:SetPoint(
		FocusCastBarSaved.Settings.Position.point,
		FocusCastBarSaved.Settings.Position.x,
		FocusCastBarSaved.Settings.Position.y
	)

	local castBar = CreateFrame("StatusBar", nil, self.frame)
	castBar:SetStatusBarTexture(FocusCastBarSaved.Settings.Texture)
	castBar:SetSize(FocusCastBarSaved.Settings.Width, FocusCastBarSaved.Settings.Height)
	self.frame.CastBar = castBar

	do
		local texture = castBar:GetStatusBarTexture()
		if texture then
			texture:SetDrawLayer("BACKGROUND")
		end
	end

	local background = self.frame:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints(castBar)
	background:SetColorTexture(0.1, 0.1, 0.1, 1)
	self.frame.Background = background

	local border = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
	border:SetPoint("TOPLEFT", self.frame, -1, 1)
	border:SetPoint("BOTTOMRIGHT", self.frame, 1, -1)
	border:SetBackdrop({
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	})
	border:SetBackdropBorderColor(0, 0, 0, 1)
	self.frame.Border = border

	self:OnShowBorderChanged(FocusCastBarSaved.Settings.ShowBorder)

	local icon = self.frame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	icon:ClearAllPoints()
	icon:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
	icon:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0)
	icon:SetWidth(16)
	self.frame.Icon = icon

	self:OnShowIconChanged(FocusCastBarSaved.Settings.ShowIcon)

	local spellNameText = castBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellNameText:SetJustifyH("LEFT")
	spellNameText:SetFont(select(1, spellNameText:GetFont()), 16, "OUTLINE")
	spellNameText:SetShadowOffset(0, 0)
	spellNameText:SetPoint("LEFT", castBar, "LEFT", 4, 0)
	self.frame.SpellNameText = spellNameText

	local timeText = castBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	timeText:SetJustifyH("RIGHT")
	timeText:SetFont(select(1, timeText:GetFont()), 16, "OUTLINE")
	timeText:SetShadowOffset(0, 0)
	timeText:SetPoint("RIGHT", castBar, "RIGHT", -4, 0)
	self.frame.TimeText = timeText

	function castBar:OnUpdate(elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		-- no point updating more than once per 100ms if we don't render more
		if self.elapsed >= 0.099 then
			self.elapsed = 0
			local duration = self:GetTimerDuration()
			timeText:SetFormattedText("%.1f", duration:GetRemainingDuration())
		end
	end

	if FocusCastBarSaved.Settings.ShowCastTime then
		castBar:SetScript("OnUpdate", castBar.OnUpdate)
	end

	self.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self.frame:RegisterEvent("LOADING_SCREEN_DISABLED")
	self.frame:RegisterEvent("UPDATE_INSTANCE_INFO")
	self.frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self.frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	-- start or update events
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "focus")
	-- end or failed events
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "focus")
	-- meta events
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "focus")
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "focus")

	-- closure here is to mimic other callsites passing a redundant 1st argument so we can proxy everything through
	-- this script
	self.frame:SetScript("OnEvent", GenerateClosure(self.OnFrameEvent, self))

	Private.EventRegistry:RegisterCallback(
		Private.Enum.Events.EDIT_MODE_POSITION_CHANGED,
		self.OnFrameEvent,
		self,
		self.frame,
		Private.Enum.Events.EDIT_MODE_POSITION_CHANGED
		-- the remaining args are being passed when the event gets triggered
	)

	Private.EventRegistry:RegisterCallback(Private.Enum.Events.SETTING_CHANGED, self.OnSettingsChanged, self)
end

function FocusCastBarDriver:LoadConditionsProhibitExecution()
	return false
end

function FocusCastBarDriver:OnSettingsChanged(key, value)
	if key == Private.Settings.Keys.Width then
		self.frame:SetWidth(value)
		self.frame.CastBar:SetWidth(value)
	elseif key == Private.Settings.Keys.Height then
		self.frame:SetHeight(value)
		self.frame.CastBar:SetHeight(value)
	elseif key == Private.Settings.Keys.ShowCastTime then
		local enabled = value

		self.frame.CastBar:SetScript("OnUpdate", enabled and self.frame.CastBar.OnUpdate or nil)
		self.frame.TimeText:SetShown(enabled)
		print("onupdate", enabled)
	elseif key == Private.Settings.Keys.ColorUninterruptible then
		self.colors.ColorUninterruptible = CreateColorFromHexString(value)
	elseif key == Private.Settings.Keys.ColorInterruptibleCanInterrupt then
		self.colors.ColorInterruptibleCanInterrupt = CreateColorFromHexString(value)
	elseif key == Private.Settings.Keys.ColorInterruptibleCannotInterrupt then
		self.colors.ColorInterruptibleCannotInterrupt = CreateColorFromHexString(value)
	elseif key == Private.Settings.Keys.ColorInterruptTick then
		self.colors.ColorInterruptTick = CreateColorFromHexString(value)
	elseif key == Private.Settings.Keys.ShowIcon then
		local shown = value

		self:OnShowIconChanged(shown)
	elseif key == Private.Settings.Keys.ShowBorder then
		local shown = value

		self:OnShowBorderChanged(shown)
	end
end

function FocusCastBarDriver:OnShowBorderChanged(shown)
	self.frame.Border:SetShown(shown)
end

function FocusCastBarDriver:OnShowIconChanged(shown)
	self.frame.CastBar:ClearAllPoints()

	if shown then
		self.frame.Icon:Show()
		self.frame.CastBar:SetPoint("TOPLEFT", self.frame.Icon, "TOPRIGHT", 0, 0)
		self.frame.CastBar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)
	else
		self.frame.Icon:Hide()
		self.frame.CastBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
		self.frame.CastBar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)
	end
end

function FocusCastBarDriver:UnitIsIrrelevant()
	-- if not UnitExists("focus") then
	-- 	return true
	-- end

	-- if not UnitCanAttack("player", "focus") then
	-- 	return true
	-- end

	return false
end

function FocusCastBarDriver:GetCastMetaInformation()
	local castingInfo = UnitCastingDuration("focus")
	local isChannel = false

	if castingInfo == nil then
		castingInfo = UnitChannelDuration("focus")
		isChannel = true
	end

	local name, texture, notInterruptible

	if isChannel then
		_, name, texture, _, _, _, notInterruptible = UnitChannelInfo("focus")
	else
		_, name, texture, _, _, _, _, notInterruptible = UnitCastingInfo("focus")
	end

	return {
		castingInfo = castingInfo,
		isChannel = isChannel,
		name = name,
		texture = texture,
		notInterruptible = notInterruptible,
	}
end

function FocusCastBarDriver:DetectInterruptId()
	local playerClass = select(3, UnitClass("player"))

	local classInterruptMap = {
		[1] = { { id = 6552 } }, -- Warrior
		[2] = { { id = 96231 } }, -- Paladin
		[3] = { { id = 19647 } }, -- Hunter
		[4] = { { id = 1766 } }, -- Rogue
		[5] = { { id = 15487 } }, -- Priest
		[6] = { { id = 47528 } }, -- Death Knight
		[7] = { { id = 57994 } }, -- Shaman
		[8] = { { id = 2139 } }, -- Mage
		[9] = {
			{
				id = 89766,
				override = function()
					return C_SpellBook.IsSpellKnown(89766, Enum.SpellBookSpellBank.Pet)
				end,
			},
			{
				id = 19647,
				override = function()
					return C_SpellBook.IsSpellKnown(19647, Enum.SpellBookSpellBank.Pet)
				end,
			},
			{
				id = 132409,
				override = function()
					-- incomplete as C_UnitAuras.GetPlayerAuraBySpellID(196099) ~= nil is missing but won't work in restricted environments
					return C_SpellBook.IsSpellKnownOrInSpellBook(132409)
				end,
			},
		}, -- Warlock
		[10] = { { id = 116705 } }, -- Monk
		[11] = { { id = 78675 }, { id = 106839 } }, -- Druid
		[12] = { { id = 183752 } }, -- Demon Hunter
		[13] = { { id = 351338 } }, -- Evoker
	}

	local eligibleInterrupts = classInterruptMap[playerClass]

	for i = 1, #eligibleInterrupts do
		local info = eligibleInterrupts[i]

		if info.override and info.override() then
			return info.id
		end

		if C_SpellBook.IsSpellKnown(info.id) then
			return info.id
		end
	end

	return nil
end

function FocusCastBarDriver:DeriveAndSetNextColor(notInterruptible)
	local texture = self.frame.CastBar:GetStatusBarTexture()

	if self.frame.interruptId == nil then
		texture:SetVertexColorFromBoolean(
			notInterruptible,
			self.colors.ColorUninterruptible,
			self.colors.ColorInterruptibleCannotInterrupt
		)
	else
		local bool = C_Spell.GetSpellCooldownDuration(self.frame.interruptId):IsZero()

		local canInterruptR, canInterruptG, canInterruptB = self.colors.ColorInterruptibleCanInterrupt:GetRGB()
		local cannotInterruptR, cannotInterruptG, cannotInterruptB =
			self.colors.ColorInterruptibleCannotInterrupt:GetRGB()

		texture:SetVertexColorFromBoolean(
			notInterruptible,
			self.colors.ColorUninterruptible,
			CreateColor(
				C_CurveUtil.EvaluateColorValueFromBoolean(bool, canInterruptR, cannotInterruptR),
				C_CurveUtil.EvaluateColorValueFromBoolean(bool, canInterruptG, cannotInterruptG),
				C_CurveUtil.EvaluateColorValueFromBoolean(bool, canInterruptB, cannotInterruptB)
			)
		)
	end
end

---@param _ Frame -- identical to self.frame
---@param event "UNIT_SPELLCAST_START" | "UNIT_SPELLCAST_STOP" | "UNIT_SPELLCAST_FAILED" | "UNIT_SPELLCAST_INTERRUPTED" | "UNIT_SPELLCAST_DELAYED" | "UNIT_SPELLCAST_CHANNEL_START" | "UNIT_SPELLCAST_CHANNEL_UPDATE" | "UNIT_SPELLCAST_CHANNEL_STOP" | "UNIT_SPELLCAST_EMPOWER_START" | "UNIT_SPELLCAST_EMPOWER_UPDATE" | "UNIT_SPELLCAST_EMPOWER_STOP" | "UNIT_SPELLCAST_INTERRUPTIBLE" | "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" | "ZONE_CHANGED_NEW_AREA"| "LOADING_SCREEN_DISABLED"| "UPDATE_INSTANCE_INFO"| "PLAYER_FOCUS_CHANGED"| "PLAYER_SPECIALIZATION_CHANGED"
function FocusCastBarDriver:OnFrameEvent(_, event, ...)
	if
		event == "UNIT_SPELLCAST_START"
		or event == "UNIT_SPELLCAST_DELAYED"
		or event == "UNIT_SPELLCAST_CHANNEL_START"
		or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
		or event == "UNIT_SPELLCAST_EMPOWER_START"
		or event == "UNIT_SPELLCAST_EMPOWER_UPDATE"
	then
		if self:LoadConditionsProhibitExecution() then
			return
		end

		if self:UnitIsIrrelevant() then
			return
		end

		print("focus started casting")

		local info = self:GetCastMetaInformation()

		if info.castingInfo == nil then
			return
		end

		self.frame.CastBar:SetTimerDuration(info.castingInfo)
		self.frame.CastBar:SetReverseFill(info.isChannel)
		self.frame.Icon:SetTexture(info.texture)
		self.frame.SpellNameText:SetText(info.name)
		self:DeriveAndSetNextColor(info.notInterruptible)

		print("showing because", event)
		self.frame:Show()
	elseif
		event == "UNIT_SPELLCAST_STOP"
		or event == "UNIT_SPELLCAST_FAILED"
		or event == "UNIT_SPELLCAST_INTERRUPTED"
		or event == "UNIT_SPELLCAST_CHANNEL_STOP"
		or event == "UNIT_SPELLCAST_EMPOWER_STOP"
	then
		if self:LoadConditionsProhibitExecution() then
			return
		end

		self.frame:Hide()
		print("focus stopped casting")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if self:LoadConditionsProhibitExecution() then
			return
		end

		print("player focus changed")
		if not UnitExists("focus") then
			if self.frame:IsShown() then
				self.frame:Hide()
				print("hiding, focus is gone")
			end

			return
		end

		local info = self:GetCastMetaInformation()

		if info.castingInfo == nil then
			if self.frame:IsShown() then
				self.frame:Hide()
				print("hiding, focus is gone")
			end

			return
		end

		self.frame.CastBar:SetTimerDuration(info.castingInfo)
		self.frame.CastBar:SetReverseFill(info.isChannel)
		self.frame.Icon:SetTexture(info.texture)
		self.frame.SpellNameText:SetText(info.name)
		self:DeriveAndSetNextColor(info.notInterruptible)

		print("showing because", event)

		self.frame:Show()
	elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
		if self:LoadConditionsProhibitExecution() then
			return
		end
	elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
		if self:LoadConditionsProhibitExecution() then
			return
		end
	elseif
		event == "ZONE_CHANGED_NEW_AREA"
		or event == "LOADING_SCREEN_DISABLED"
		or event == "PLAYER_SPECIALIZATION_CHANGED"
		or event == "UPDATE_INSTANCE_INFO"
	then
		self.frame.interruptId = self:DetectInterruptId()

		local _, instanceType, difficultyId = GetInstanceInfo()
		-- equivalent to `instanceType == "none"`
		local nextContentType = Private.Enum.ContentType.OpenWorld

		if instanceType == "raid" then
			nextContentType = Private.Enum.ContentType.Raid
		elseif instanceType == "party" then
			if
				difficultyId == DifficultyUtil.ID.DungeonTimewalker
				or difficultyId == DifficultyUtil.ID.DungeonNormal
				or difficultyId == DifficultyUtil.ID.DungeonHeroic
				or difficultyId == DifficultyUtil.ID.DungeonMythic
				or difficultyId == DifficultyUtil.ID.DungeonChallenge
				or difficultyId == 205 -- follower dungeons
			then
				nextContentType = Private.Enum.ContentType.Dungeon
			end
		elseif instanceType == "pvp" then
			nextContentType = Private.Enum.ContentType.Battleground
		elseif instanceType == "arena" then
			nextContentType = Private.Enum.ContentType.Arena
		elseif instanceType == "scenario" then
			if difficultyId == 208 then
				nextContentType = Private.Enum.ContentType.Delve
			end
		end

		self.contentType = nextContentType

		local specId = PlayerUtil.GetCurrentSpecID()

		if
			specId == 105 -- restoration druid
			or specId == 1468 -- preservation evoker
			or specId == 270 -- mistweaver monk
			or specId == 65 -- holy paladin
			or specId == 256 -- discipline priest
			or specId == 257 -- holy priest
			or specId == 264 -- restoration shaman
		then
			self.role = Private.Enum.Role.Healer
		elseif
			specId == 250 -- blood death knight
			or specId == 581 -- vengeance demon hunter
			or specId == 104 -- guardian druid
			or specId == 268 -- brewmaster monk
			or specId == 66 -- protection paladin
			or specId == 73 -- protection warrior
		then
			self.role = Private.Enum.Role.Tank
		else
			self.role = Private.Enum.Role.Damager
		end
	elseif event == Private.Enum.Events.EDIT_MODE_POSITION_CHANGED then
		local point, x, y = ...

		self.frame:ClearAllPoints()
		self.frame:SetPoint(point, x, y)
	end
end

table.insert(Private.LoginFnQueue, GenerateClosure(FocusCastBarDriver.Init, FocusCastBarDriver))
