local _G = _G
local mod = mod
local pcall = pcall
local ceil = math.ceil
local GetTime = GetTime
-- local __xpcall = xpcall
local floor = math.floor
local gsub = string.gsub
local UnitName = UnitName
local tostring = tostring
local securecall = securecall
local GetAddOnInfo = GetAddOnInfo

function AnimateTexCoords(Self, Width, Height, FWidth, FHeight, NumFrames, Elapsed, Throt)
	local Throt = Throt or Self.throttle or 0.1

	if not Self.frame then
		Self.frame = 1
		Self.Throt = Throt
		Self.numColumns = floor(Width / FWidth)
		Self.numRows = floor(Height / FHeight)
		Self.columnWidth = FWidth / Width
		Self.rowHeight = FHeight / Height
	end
	if not Self.Throt or Self.Throt > Throt then
		local frame = Self.frame
		local framesToAdvance = floor(Self.Throt / Throt)
		while frame + framesToAdvance > NumFrames do
			frame = frame - NumFrames
		end
		frame = frame + framesToAdvance
		Self.Throt = 0
		local left = mod(frame - 1, Self.numColumns) * Self.columnWidth
		local right = left + Self.columnWidth
		local bottom = ceil(frame / Self.numColumns) * Self.rowHeight
		local top = bottom - Self.rowHeight
		Self:SetTexCoord(left, right, top, bottom)
		Self.frame = frame
	else
		Self.Throt = Self.Throt + Elapsed
	end
end

function GetTexCoordsForRoleSmallCircle(role)
    if ( role == "TANK" ) then
        return 0, 19/64, 22/64, 41/64
    elseif ( role == "HEALER" ) then
        return 20/64, 39/64, 1/64, 20/64
    elseif ( role == "DAMAGER" ) then
        return 20/64, 39/64, 22/64, 41/64
    else
        error("Unknown role: "..tostring(role))
    end
end

-- function PassClickToParent(Self, ...)
-- 	local Parent = Self:GetParent()
-- 	if ( Parent.OnClick ) then
-- 		Parent:GetScript("OnClick")(Parent, ...)
-- 	end
-- end

-- function xpcall(Called, Erro, ...)
-- 	-- Weakaura uses this a lot. It doesnt handle self.X function correctly on 3.3.5, so we emulate it.
-- 	local Success, a, b, c, d, e, f = pcall(Called, ...)
-- 	-- We really need a better way to pass the returns...
-- 	-- Could do a loop, slap them in an array and then do what we want.
-- 	-- But array size causes some memory problems when this is called every 0.1 seconds.
--
-- 	if ( Erro and not Success ) then
-- 		Erro(tostring(a))
-- 	end
--
-- 	return Success, a, b, c, d, e, f
-- end
--
-- function _xpcall(...)
-- 	__xpcall(...) -- original
-- end

local function secureexecutenext(tbl, prev, func, ...)
    local key, value = next(tbl, prev)

    if key ~= nil then
        pcall(func, key, value, ...)  -- Errors are silently discarded!
    end

    return key
end

function secureexecuterange(tbl, func, ...)
    local key = nil

    repeat
        key = securecall(secureexecutenext, tbl, key, func, ...)
    until key == nil
end

function securecallfunction(func, ...)
	return securecall(func, ...)
end

function GetAddOnEnableState(character, addon)
	local name, _, _, enabled = GetAddOnInfo(addon)
	return ( name and enabled ) and 2 or 0
end

function HasOverrideActionBar()
	return _G.BonusActionBarFrame:IsShown()
end

function HasVehicleActionBar()
	return _G.VehicleMenuBar:IsShown()
end

function GetServerTime()
	return GetTime()
end

function GetNormalizedRealmName()
	return gsub(GetRealmName(), "[-%s]", "")
end

function Ambiguate(fullName, context)
	-- TODO: Make diff context work properly.
	return fullName
end