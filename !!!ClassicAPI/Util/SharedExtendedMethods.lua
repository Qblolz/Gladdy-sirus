local _G = _G
local IsType = type
local Max = math.max
local Assert = assert
local GetTime = GetTime
local Floor = math.floor
local ToNumber = tonumber
local Format = string.format
local TableInsert = table.insert
local GetMetaTable = getmetatable
local Format = string.format
local Date = date

local FrameRef = CreateFrame("Frame")
local ButtonRef = CreateFrame("Button")
local SliderRef = CreateFrame("Slider")
local CooldownRef = CreateFrame("Cooldown")
local StatusBarRef = CreateFrame("StatusBar")
local ScrollFrameRef = CreateFrame("ScrollFrame")
local CheckButtonRef = CreateFrame("CheckButton")
local PlayerModelRef = CreateFrame("PlayerModel")

local Frame = getmetatable(FrameRef).__index
local Button = getmetatable(ButtonRef).__index
local Slider = getmetatable(SliderRef).__index
local Cooldown = getmetatable(CooldownRef).__index
local StatusBar = getmetatable(StatusBarRef).__index
local ScrollFrame = getmetatable(ScrollFrameRef).__index
local CheckButton = getmetatable(CheckButtonRef).__index
local PlayerModel = getmetatable(PlayerModelRef).__index
local FrameTexture = getmetatable(FrameRef:CreateTexture()).__index
local FrameFontString = getmetatable(FrameRef:CreateFontString()).__index

local CONST_ATLAS_WIDTH			= 1
local CONST_ATLAS_HEIGHT		= 2
local CONST_ATLAS_LEFT			= 3
local CONST_ATLAS_RIGHT			= 4
local CONST_ATLAS_TOP			= 5
local CONST_ATLAS_BOTTOM		= 6
local CONST_ATLAS_TILESHORIZ	= 7
local CONST_ATLAS_TILESVERT		= 8
local CONST_ATLAS_TEXTUREPATH	= 9

local GRAY_FONT_COLOR = GRAY_FONT_COLOR
local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR

local PANELS = { "CollectionsJournal", "EncounterJournal" }

-- We can also emulate SetReverse so it hides the cooldown frame by
-- creating a hidden sub-cooldown and if onhide hook is set then hide on that.
-- though idk how to tell if from xml...
local function Method_SetCooldown(Self, Start, Duration, Modrate)
	Self.___Start = Start
	Self.___Duration = Duration
end

local function Method_GetCooldownTimes(Self)
	-- This might not work entirely blizz-like, needs testing.
	local Start = Self.___Start or 0
	local Duration = Self.___Duration or 0

	if ( Duration > 0 ) then
		if ( ((Start + Duration) - GetTime()) <= 0 ) then
			Start = 0
			Duration = 0

			Self.Start = nil
			Self.Duration = nil
		end
	end

	return Start, Duration
end

local function GetCooldownDuration(Self, ...)
	local Duration = 0

	if ( Self.___Duration ) then
		Duration = Self.___Duration - (Self.___Start - GetTime())

		if ( Duration <= 0 ) then
			Self.Start = nil
			Self.Duration = nil
		end
	end

	return Duration
end

local function Method_SetShown(Self, ...)
	if ... then
		Self:Show()
	else
		Self:Hide()
	end
end

local function Method_SetEnabled(Self, ...)
	if ... then
		Self:Enable()
	else
		Self:Disable()
	end
end

local function Method_SetRemainingTime(Self, Time, DaysFormat)
	local DayInSec = 86400
	local Days = ""

	Self:SetText("")

	if ( type(Time) ~= "number" ) then
		-- printc("EROR: Method_SetRemainingTime time is not number. Frame "..Self:GetName())
		return
	end

	if ( DaysFormat ) then
		if ( Time > 86400 ) then
			Self:SetText(Floor(Time / DayInSec)..Format(" |4день:дня:дней", Time % 10))
		else
			Self:SetText(Date("!%X", Time))
		end
	else
		if ( Time > DayInSec ) then
			Days = Floor(Time / DayInSec) .. "д "
			Time = Time % DayInSec
		end

		if ( Time and Time >= 0 ) then
			Self:SetText(Days .. Date("!%X", Time))
		end
	end
end

local function Method_SetSubTexCoord(Self, Left, Right, Top, Bottom)
	local UL_X, UL_Y, LL_X, LL_Y, UR_X, UR_Y, LR_X, LR_Y = Self:GetTexCoord()

	local LeftEdge = UL_X
	local RightEdge = UR_X
	local TopEdge = UL_Y
	local BottomEdge = LL_Y

	local Width  = RightEdge - LeftEdge
	local Height = BottomEdge - TopEdge

	LeftEdge = UL_X + Width * Left
	TopEdge  = UL_Y  + Height * Top
	RightEdge = Max(RightEdge * Right, UL_X)
	BottomEdge = Max(BottomEdge * Bottom, UL_Y)

	UL_X = LeftEdge
	UL_Y = TopEdge
	LL_X = LeftEdge
	LL_Y = BottomEdge
	UR_X = RightEdge
	UR_Y = TopEdge
	LR_X = RightEdge
	LR_Y = BottomEdge

	Self:SetTexCoord(UL_X, UL_Y, LL_X, LL_Y, UR_X, UR_Y, LR_X, LR_Y)
end

local function Method_SetPortrait(Self, DisplayID)
	Self:SetTexture("Interface\\PORTRAITS\\Portrait_model_"..ToNumber(DisplayID))
end

local function Method_FixOpenPanel(Self)
	-- Hack, due to the oddities of the positioning system.
	-- Necessary for the correct operation of the system of Professions.
	for i = 1, #PANELS do
		local Panel = _G[PANELS[i]]

		if ( Panel ) then
			if Panel:IsShown() then
				HideUIPanel(Panel)
				ShowUIPanel(Self)
				return true
			end
		end
	end
end

local function Method_SetAtlas(Self, AtlasName, UseAtlasSize, FilterMode)
	Assert(Self, "SetAtlas: not found object")
	Assert(AtlasName, "SetAtlas: AtlasName must be specified")
	Assert(ATLAS_INFO_STORAGE[AtlasName], "SetAtlas: Atlas named "..AtlasName.." does not exist")

	local Atlas = ATLAS_INFO_STORAGE[AtlasName]

	Self:SetTexture(Atlas[CONST_ATLAS_TEXTUREPATH] or "", Atlas[CONST_ATLAS_TILESHORIZ], Atlas[CONST_ATLAS_TILESVERT])

	if ( UseAtlasSize ) then
		Self:SetWidth(Atlas[CONST_ATLAS_WIDTH])
		Self:SetHeight(Atlas[CONST_ATLAS_HEIGHT])
	end

	Self:SetTexCoord(Atlas[CONST_ATLAS_LEFT], Atlas[CONST_ATLAS_RIGHT], Atlas[CONST_ATLAS_TOP], Atlas[CONST_ATLAS_BOTTOM])

	Self:SetHorizTile(Atlas[CONST_ATLAS_TILESHORIZ])
	Self:SetVertTile(Atlas[CONST_ATLAS_TILESVERT])

	Self.___AtlasName = AtlasName
end

local function Method_GetAtlas(Self)
	return Self.___AtlasName
end

local function Method_SmoothSetValue(Self, value)
	-- local SmoothFrame = Self._SmoothUpdateFrame or CreateFrame("Frame")
	-- Self._SmoothUpdateFrame =  SmoothFrame
end

local function Method_SetDesaturated(Self, Toggle, Color)
	if ( Toggle ) then
		Self:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	else
		if ( Color ) then
			Self:SetTextColor(Color.r, Color.g, Color.b)
		else
			Self:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
	end
end

local function Method_SetParentArray(Self, ArrayName, Element, SetInSelf)
	local Parent = (not SetInSelf) and Self:GetParent() or Self

	if ( not Parent[ArrayName] ) then
		Parent[ArrayName] = {}
	end

	TableInsert(Parent[ArrayName], Element or Self)
end

local function Method_ClearAndSetPoint(Self, ...)
	Self:ClearAllPoints()
	Self:SetPoint(...)
end

local function Method_CreateLine(Self, ...)
	-- Self is NineSlice
	local Line = Self:CreateTexture(...)
	Line.IsLine = true
	return Line
end

local function Method_IsRectValid(Self, ...)
	return true
end

local function Method_TODO(Self, ...)
	-- Empty, like my soul.
end

-- FRAME
--Frame.SetShown = Method_SetShown
--Frame.FixOpenPanel = Method_FixOpenPanel
Frame.SetParentArray = Method_SetParentArray
Frame.ClearAndSetPoint = Method_ClearAndSetPoint
Frame.IsRectValid = Method_IsRectValid
Frame.SetIgnoreParentScale = Method_TODO
Frame.CreateMaskTexture = Method_TODO
Frame.SetClipsChildren = Method_TODO
Frame.SetPortraitZoom = Method_TODO
Frame.SetForbidden = Method_TODO
Frame.IsForbidden = Method_TODO
	-- Line
		Frame.CreateLine = Method_CreateLine

	-- TEXTURE (FRAME)
	--	FrameTexture.SetShown = Method_SetShown
	--	FrameTexture.SetSubTexCoord = Method_SetSubTexCoord
		--FrameTexture.SetPortrait = Method_SetPortrait -- This doesn't actually exist in WoW API
		--FrameTexture.SetAtlas = Method_SetAtlas
		--FrameTexture.GetAtlas = Method_GetAtlas
		FrameTexture.SetParentArray = Method_SetParentArray
		FrameTexture.ClearAndSetPoint = Method_ClearAndSetPoint
		FrameTexture.SetMask = Method_TODO
		FrameTexture.GetNumMaskTextures = function(Self) return 0 end
		FrameTexture.SetSnapToPixelGrid = Method_TODO
		FrameTexture.SetTexelSnappingBias = Method_TODO
		FrameTexture.SetColorTexture = function(Self, ...) Self:SetVertexColor(...) end
			-- Line
				FrameTexture.SetThickness = Method_TODO
				FrameTexture.SetStartPoint = Method_TODO
				FrameTexture.SetEndPoint = Method_TODO
				FrameTexture.SetIgnoreParentAlpha = Method_TODO

	-- FONTSTRING (FRAME)
	--	FrameFontString.SetShown = Method_SetShown
		FrameFontString.SetRemainingTime = Method_SetRemainingTime
		FrameFontString.SetDesaturated = Method_SetDesaturated
		FrameFontString.SetParentArray = Method_SetParentArray
		FrameFontString.ClearAndSetPoint = Method_ClearAndSetPoint

-- BUTTON
--Button.SetShown = Method_SetShown
--Button.SetEnabled = Method_SetEnabled
Button.SetParentArray = Method_SetParentArray
Button.ClearAndSetPoint = Method_ClearAndSetPoint
--Button.SetNormalAtlas = function(Self, ...) Method_SetAtlas(Self:GetNormalTexture(), ...)  end
--Button.SetPushedAtlas = function(Self, ...) Method_SetAtlas(Self:GetPushedTexture(), ...)  end
--Button.SetDisabledAtlas = function(Self, ...) Method_SetAtlas(Self:GetDisabledTexture(), ...)  end
--Button.SetHighlightAtlas = function(Self, ...) Method_SetAtlas(Self:GetHighlightTexture(), ...)  end
Button.SetForbidden = Method_TODO
Button.IsForbidden = Method_TODO

-- SLIDER
--Slider.SetShown = Method_SetShown
Slider.SetParentArray = Method_SetParentArray
Slider.ClearAndSetPoint = Method_ClearAndSetPoint

-- STATUSBAR
--StatusBar.SetShown = Method_SetShown
StatusBar.SmoothSetValue = Method_SmoothSetValue
StatusBar.SetParentArray = Method_SetParentArray
StatusBar.ClearAndSetPoint = Method_ClearAndSetPoint

-- SCROLLFRAME
--ScrollFrame.SetShown = Method_SetShown
ScrollFrame.SetParentArray = Method_SetParentArray
ScrollFrame.ClearAndSetPoint = Method_ClearAndSetPoint

-- CHECKBUTTON
--CheckButton.SetShown = Method_SetShown
--CheckButton.SetEnabled = Method_SetEnabled
CheckButton.SetParentArray = Method_SetParentArray
CheckButton.ClearAndSetPoint = Method_ClearAndSetPoint

-- COOLDOWN
hooksecurefunc(Cooldown, "SetCooldown", Method_SetCooldown)
Cooldown.Clear = function(Self) Self:SetCooldown(0, 0) end
Cooldown.SetHideCountdownNumbers = function(Self, Hide) Self.noCooldownCount = (Hide) and true or nil end
Cooldown.SetDrawBling = Method_TODO
Cooldown.SetDrawSwipe = Method_TODO
Cooldown.IsPaused = Method_TODO
Cooldown.Pause = Method_TODO
Cooldown.Resume = Method_TODO
Cooldown.SetSwipeTexture = Method_TODO
Cooldown.SetSwipeColor = Method_TODO
Cooldown.GetCooldownTimes = Method_GetCooldownTimes
Cooldown.GetCooldownDuration = Method_GetCooldownDuration