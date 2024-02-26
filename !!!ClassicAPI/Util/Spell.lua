local PickupSpell = PickupSpell
local GetSpellName  = GetSpellName
local GetSpellInfo = GetSpellInfo
local GameTooltip = GameTooltip

-- function PickupSpellBookItem(id, bookType)
-- 	return PickupSpell(id, bookType)
-- end
--
-- function GetSpellBookItemName(id, bookType)
-- 	return GetSpellName(id, bookType)
-- end

function GetSpellDescription(spellID)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetHyperlink("spell:"..spellID)

	local Num = GameTooltip:NumLines()
	if ( Num > 0 ) then
		return _G["GameTooltipTextLeft"..Num]:GetText()
	end

	GameTooltip:Hide()
end

function C_GetSpellTexture(spell, bookType)
	local _, icon
	if ( bookType ) then
		icon = GetSpellTexture(spell, bookType)
	else
		_, _, icon = GetSpellInfo(spell)
	end
	return icon
end

function C_GetSpellInfo(spell)
	local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange
	if ( spell ) then
		name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spell)
	end
	return name, rank, icon, castTime, minRange, maxRange
end

function GetSpellSubtext(id)
	if ( id ) then
		local _, rank = GetSpellInfo(id)

		return rank
	end
end