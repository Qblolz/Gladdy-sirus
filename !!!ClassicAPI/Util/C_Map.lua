local tinsert = tinsert
local select = select
local GetMapZones = GetMapZones

C_Map = C_Map or {}
C_Map.WorldMap = {}

local function LoadZones(obj, ...)
	local n = select('#', ...)
	for i=1, n do
		local zone = select(i, ...)
		tinsert(obj, zone)
	end
end

for continentIndex = 1, 4 do
	LoadZones(C_Map.WorldMap, GetMapZones(continentIndex))
end

function C_Map.IsWorldMap(uiMap)
	for _, value in pairs(C_Map.WorldMap) do
		if ( value == uiMap ) then
			return true
		end
	end
end

function C_Map.GetBestMapForUnit()

end