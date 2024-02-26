local IsInInstance = IsInInstance
local GetMapInfo = GetMapInfo

C_PvP = C_PvP or {}

local MAX_BATTLEGOUND_UNIT = {
	AlteracValley 		= 40,
	ArathiBasin 		= 15,
	NetherstormArena 	= 15,
	WarsongGulch 		= 10,
	IsleofConquest 		= 40,
	StrandoftheAncients = 15,
	LakeWintergrasp 	= 40,
}

function C_PvP.IsRatedBattleground()
	return false
end

function C_PvP.IsWarModeDesired()
	return false
end

function C_PvP.IsPvPMap()
	local inInstance, instanceType = IsInInstance()
	if ( not inInstance ) then
		return
	end

	return instanceType == "pvp" or instanceType == "arena"
end

function GetMaxUnitNumberBattleground()
	return MAX_BATTLEGOUND_UNIT[GetMapInfo()]
end