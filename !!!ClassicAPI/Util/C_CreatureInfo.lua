C_CreatureInfo = C_CreatureInfo or {}

local _C_CreatureInfo_RaceData = {
	[1] = {
		raceName = "Human",
		clientFileString = "Human",
	},
	[2] = {
		raceName = "Orc",
		clientFileString = "Orc",
	},
	[3] = {
		raceName = "Dwarf",
		clientFileString = "Dwarf",
	},
	[4] = {
		raceName = "Night Elf",
		clientFileString = "NightElf",
	},
	[5] = {
		raceName = "Undead",
		clientFileString = "Scourge",
	},
	[6] = {
		raceName = "Tauren",
		clientFileString = "Tauren",
	},
	[7] = {
		raceName = "Gnome",
		clientFileString = "Gnome",
	},
	[8] = {
		raceName = "Troll",
		clientFileString = "Troll",
	},
	[9] = {
		raceName = "Goblin",
		clientFileString = "Goblin",
	},
	[10] = {
		raceName = "Blood Elf",
		clientFileString = "BloodElf",
	},
	[11] = {
		raceName = "Draenei",
		clientFileString = "Draenei",
	},
}

local _C_CreatureInfo_ClassData = {
	[1] = {
		className = "Warrior",
		classFile = "WARRIOR",
	},
	[2] = {
		className = "Paladin",
		classFile = "PALADIN",
	},
	[3] = {
		className = "Hunter",
		classFile = "HUNTER",
	},
	[4] = {
		className = "Rogue",
		classFile = "ROGUE",
	},
	[5] = {
		className = "Priest",
		classFile = "PRIEST",
	},
	[6] = {
		className = "Death Knight",
		classFile = "DEATHKNIGHT",
	},
	[7] = {
		className = "Shaman",
		classFile = "SHAMAN",
	},
	[8] = {
		className = "Mage",
		classFile = "MAGE",
	},
	[9] = {
		className = "Warlock",
		classFile = "WARLOCK",
	},
	--[10] = { MONK }
	[11] = {
		className = "Druid",
		classFile = "DRUID",
	},
}

function C_CreatureInfo._GetClassInfo(classID)
	local classInfo = _C_CreatureInfo_ClassData[classID]

	if ( classInfo ) then
		if ( not classInfo[classID] ) then
			classInfo.classID = classID
		end
	end

	return classInfo
end

function C_CreatureInfo._GetRaceInfo(raceID)
	return _C_CreatureInfo_RaceData[raceID]
end