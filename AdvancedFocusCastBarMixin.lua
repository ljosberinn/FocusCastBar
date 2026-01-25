---@type string, AdvancedFocusCastBar
local addonName, Private = ...

---@class AdvancedFocusCastBarMixin
AdvancedFocusCastBarMixin = {}

function AdvancedFocusCastBarMixin:OnLoad()
	self.Icon:SetWidth(16)
	print("OnLoad")

	self:SetStatusBarTexture(AdvancedFocusCastBarSaved.Settings.Texture)
	do
		local texture = self:GetStatusBarTexture()
		if texture then
			texture:SetDrawLayer("BORDER")
		end
	end

	self.Border:SetBackdrop({
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	})
	self.Border:SetBackdropBorderColor(0, 0, 0, 1)

	self.SpellNameText:SetFont(select(1, self.SpellNameText:GetFont()), 16, "OUTLINE")
	self.SpellNameText:SetShadowOffset(0, 0)
	self.CastTimeText:SetFont(select(1, self.CastTimeText:GetFont()), 16, "OUTLINE")
	self.CastTimeText:SetShadowOffset(0, 0)

	local mask = self:CreateMaskTexture()
	mask:SetPoint("CENTER")
	mask:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetTextureSliceMargins(1, 1, 1, 1)
	mask:SetSize(AdvancedFocusCastBarSaved.Settings.Width, AdvancedFocusCastBarSaved.Settings.Height)
	self.Mask = mask

	self.InterruptBar:SetStatusBarTexture("dungeons/textures/common/transparent")
	self.InterruptBar:SetFrameLevel(self:GetFrameLevel() + 1)
	self.InterruptBar:ClearAllPoints()
	self.InterruptBar:SetPoint("LEFT", self:GetStatusBarTexture(), "RIGHT")
	self.InterruptBar:SetSize(AdvancedFocusCastBarSaved.Settings.Width, AdvancedFocusCastBarSaved.Settings.Height)

	self.InterruptBar.Tick:SetPoint("CENTER", self.InterruptBar:GetStatusBarTexture(), "RIGHT")
	self.InterruptBar.Tick:AddMaskTexture(mask)
	self.InterruptBar.Tick:SetSize(2, AdvancedFocusCastBarSaved.Settings.Height)
end

function AdvancedFocusCastBarMixin:SetNotInterruptible(notInterruptible)
	self.notInterruptible = notInterruptible
end

function AdvancedFocusCastBarMixin:SetShowBorder(shown)
	self.Border:SetShown(shown)
end

function AdvancedFocusCastBarMixin:SetShowIcon(shown)
	self.Icon:SetShown(shown)

	self.SpellNameText:ClearAllPoints()
	if shown then
		self.SpellNameText:SetPoint("LEFT", self.Icon, "RIGHT", 4, 0)
	else
		self.SpellNameText:SetPoint("LEFT", self, "LEFT", 4, 0)
	end
end

function AdvancedFocusCastBarMixin:SetTickColor(color)
	self.InterruptBar.Tick:SetColorTexture(color:GetRGB())
end

function AdvancedFocusCastBarMixin:AdjustDirection(isChannel)
	self.InterruptBar:ClearAllPoints()
	self.InterruptBar.Tick:ClearAllPoints()
	self.InterruptBar:SetReverseFill(isChannel)

	local castBarTexture = self:GetStatusBarTexture()
	local interruptBarTexture = self.InterruptBar:GetStatusBarTexture()

	if isChannel then
		self.InterruptBar:SetPoint("RIGHT", castBarTexture, "LEFT")
		self.InterruptBar.Tick:SetPoint("CENTER", interruptBarTexture, "LEFT")
	else
		self.InterruptBar:SetPoint("LEFT", castBarTexture, "RIGHT")
		self.InterruptBar.Tick:SetPoint("CENTER", interruptBarTexture, "RIGHT")
	end
end

function AdvancedFocusCastBarMixin:SetBarSize(width, height)
	print("SetBarSize")

	self:SetSize(width, height)
	self.InterruptBar:SetSize(width, height)
	self.InterruptBar.Tick:SetHeight(height)
	self.Mask:SetSize(width, height)
end

function AdvancedFocusCastBarMixin:SetBarWidth(width)
	self:SetWidth(width)
	self.InterruptBar:SetWidth(width)
	self.Mask:SetWidth(width)
end

function AdvancedFocusCastBarMixin:SetBarHeight(height)
	self:SetHeight(height)
	self.InterruptBar:SetHeight(height)
	self.InterruptBar.Tick:SetHeight(height)
	self.Mask:SetHeight(height)
end

function AdvancedFocusCastBarMixin:ApplyCastInfo(info)
	self:SetNotInterruptible(info.notInterruptible)
	self:SetTimerDuration(info.castingInfo)
	self.InterruptBar:SetMinMaxValues(0, info.castingInfo:GetTotalDuration())
	self:SetReverseFill(info.isChannel)
	self.Icon:SetTexture(info.texture)
	self.SpellNameText:SetText(info.name)
	self:AdjustDirection(info.isChannel)
end
