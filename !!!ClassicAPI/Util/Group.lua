local GetNumRaidMembers = GetNumRaidMembers
local GetNumPartyMembers = GetNumPartyMembers
local GetPartyLeaderIndex = GetPartyLeaderIndex
local UnitIsRaidOfficer = UnitIsRaidOfficer
local UnitExists = UnitExists
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsEnemy = UnitIsEnemy
local GetRealNumRaidMembers = GetRealNumRaidMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitName = UnitName
local PromoteToAssistant = PromoteToAssistant
local DemoteAssistant = DemoteAssistant

function IsRaidMarkerActive(index)
    return false
end

function _GetDisplayedAllyFrames()
end

function _IsInGroup()
	return GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0
end

function _IsInRaid()
	return GetNumRaidMembers() > 0
end

function _GetNumSubgroupMembers()
	return GetNumPartyMembers()
end

function _GetNumGroupMembers()
	return IsInRaid() and GetNumRaidMembers() or GetNumPartyMembers()
end

function UnitIsGroupLeader(unit)
	local isLeader

	if ( not _IsInGroup() ) then
		isLeader = false
	elseif ( unit == "player" ) then
		isLeader = IsInRaid() and IsRaidLeader() or IsPartyLeader()
	else
		local index = unit:match("%d+")
		isLeader = index and GetPartyLeaderIndex() == index
	end

	return isLeader
end

function UnitIsGroupAssistant(unit)
	local isAssistant = false
	if ( IsInRaid() ) then
		-- UnitIsRaidOfficer return correctly also for party
		isAssistant = UnitIsRaidOfficer(unit) and not UnitIsGroupLeader(unit)
	end
	return isAssistant
end

local isAllAssistant = false
function IsEveryoneAssistant()
	return isAllAssistant
end

function CanBeRaidTarget(unit)
	if ( not unit ) then
		return
	end

	if ( UnitExists(unit) and UnitIsConnected(unit) ) then
		return not ( UnitIsPlayer(unit) and UnitIsEnemy("player", unit) )
	end
end

function UnitInOtherParty(unit)
	if not C_Map.IsWorldMap(GetZoneText()) or UnitPhaseReason(unit) then
		return false
	end

	if not ( IsInRaid() and UnitIsConnected(unit) ) then
		return
	end

	for i = 1, GetRealNumRaidMembers() do
		local name, rank, subgroup, level, class, fileName, zone = GetRaidRosterInfo(i)
		if ( name == UnitName(unit) ) then
			return not C_Map.IsWorldMap(zone)
		end
	end
end

function GetGroupMemberCountsForDisplay()
	local data = GetGroupMemberCounts();
	data.DAMAGER = data.DAMAGER + data.NOROLE; --People without a role count as damage
	data.NOROLE = 0;
	return data;
end