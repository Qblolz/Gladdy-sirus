local UnitGUID = UnitGUID
local UnitIsConnected = UnitIsConnected
local GetPlayerMapPosition = GetPlayerMapPosition
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsTappedByAllThreatList = UnitIsTappedByAllThreatList

local UNIT_ID_ALL
local UNIT_ID_TOTAL

function FindUnitID(GUID)
	local UnitID

	if ( not UNIT_ID_ALL ) then
		UNIT_ID_ALL = {"target", "focus", "player", "party1", "party2", "party3", "party4"}

		for i=1, 40 do
			UNIT_ID_ALL[#UNIT_ID_ALL+1] = "raid"..i
		end

		UNIT_ID_TOTAL = #UNIT_ID_ALL
	end

	for i=1, UNIT_ID_TOTAL do
		local ID = UNIT_ID_ALL[i]

		if ( GUID == UnitGUID(ID) ) then
			UnitID = ID
			break
		end
	end

	return UnitID
end

function UnitPhaseReason(unit)

end

function UnitDistanceSquared(unit)
	if ( UnitIsConnected(unit) ) then
		local px, py = GetPlayerMapPosition("player")
		local ux, uy = GetPlayerMapPosition(unit)
		return CalculateDistance(px, py, ux, uy) * 100000, true
	end
	return 0, false
end

function UnitIsTapDenied(unit)
	return UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit)
end

function UnitShouldDisplayName(unitToken)
	return unitToken
end

function UnitNameplateShowsWidgetsOnly(unitToken)
	return false
end

function C_UnitCastingInfo(Unit)
	local name, rank, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo(Unit)

	return name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId
end

function C_UnitChannelInfo(Unit)
	local name, rank, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo(Unit)

	return name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId
end

function UnitFullName(Unit)
	local name, realm = UnitName(Unit)

	if ( Unit == "player" ) then
		realm = GetNormalizedRealmName()
	end

	return name, realm
end