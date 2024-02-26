if ( ColorMixin or CreateColor ) then return end

function ExtractColorValueFromHex(str, index)
	return tonumber(str:sub(index, index + 1), 16) / 255;
end

function CreateColorFromHexString(hexColor)
	if #hexColor == 8 then
		local a, r, g, b = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5), ExtractColorValueFromHex(hexColor, 7);
		return CreateColor(r, g, b, a);
	else
		--GMError("CreateColorFromHexString input must be hexadecimal digits in this format: AARRGGBB.");
	end
end

function CreateColorFromBytes(r, g, b, a)
	return CreateColor(r / 255, g / 255, b / 255, a / 255);
end

function AreColorsEqual(left, right)
	if left and right then
		return left:IsEqualTo(right);
	end
	return left == right;
end

for k, v in pairs(RAID_CLASS_COLORS) do
	if ( v.colorStr ) then
		return
	end

	local colorMixin = CreateColor(v.r, v.g, v.b, 1);
	colorMixin.colorStr = colorMixin:GenerateHexColor();
	RAID_CLASS_COLORS[k] = colorMixin;
end

function GetClassColor(classFilename)
	local color = RAID_CLASS_COLORS[classFilename];
	if color then
		return color.r, color.g, color.b, color.colorStr;
	end
	return 1, 1, 1, "ffffffff";
end

function GetClassColorObj(classFilename)
	-- TODO: Remove this, convert everything that's using GetClassColor to use the object instead, then begin using that again
	return RAID_CLASS_COLORS[classFilename];
end

function GetClassColoredTextForUnit(unit, text)
	local classFilename = select(2, UnitClass(unit));
	local color = GetClassColorObj(classFilename);
	if(color) then 
		return color:WrapTextInColorCode(text);
	end
end

function GetFactionColor(factionGroupTag)
	return PLAYER_FACTION_COLORS[PLAYER_FACTION_GROUP[factionGroupTag]];
end