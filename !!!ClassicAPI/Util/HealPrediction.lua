local UnitGUID = UnitGUID

local LibHealComm
local LibResComm

function UnitGetIncomingHeals(Unit, Healer, GUID)
	if ( Unit ) then
		if ( LibHealComm == nil ) then
			LibHealComm = LibStub:GetLibrary("LibHealComm-4.0", true) or false
		end

		if ( LibHealComm ) then
			if ( not GUID ) then
				Unit = UnitGUID(Unit)
			end

			return LibHealComm:GetHealAmount(Unit, LibHealComm.CASTED_HEALS, GetTime() + 5, UnitGUID("player"))
		end
	end
end

function UnitGetTotalAbsorbs(Unit)
	return 0
end

function UnitGetTotalHealAbsorbs(unit)
	return 0
end

function UnitHasIncomingResurrection(Unit)
	if ( Unit ) then
		if ( LibResComm == nil ) then
			LibResComm = LibStub:GetLibrary("LibResComm-1.0", true) or false
		end
		return (LibResComm) and LibResComm:IsUnitBeingRessed(UnitName(Unit)) or nil
	end
end