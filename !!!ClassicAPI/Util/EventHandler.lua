local BitBand = bit.band
local UnitGUID = UnitGUID
local GetMetaTable = getmetatable
local HookSecureFunc = hooksecurefunc
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers

local EventHandler = CreateFrame("Frame")
local ___RegisterEvent = EventHandler.RegisterEvent
local ___UnregisterEvent = EventHandler.UnregisterEvent

local EVENT_STORAGE = {}
local CLASSIC_EVENT
local HANDLER_EVENT

--[[

	CALLBACK SYSTEM

]]

local function EventHandler_Unregister(Self, Function, Event, Event2)
	local EventData = EVENT_STORAGE[Event]

	if ( EventData ) then
		local EventDataTotal, Index = 0

		for i=1,#EventData do
			local Callback = EventData[i]

			if ( Callback ) then
				EventDataTotal = EventDataTotal + 1

				if ( Callback.Func == Function ) then
					Index = i
					if ( EventDataTotal > 1 ) then break end
				end
			end
		end

		if ( Index ) then
			if ( EventDataTotal == 1 ) then
				EVENT_STORAGE[Event] = nil
				___UnregisterEvent(EventHandler, Event2)

				local UnregisterFunc = EventHandler[Event.."_UNREGISTER"]
				if ( UnregisterFunc ) then
					UnregisterFunc(nil, Self)
				end
			else
				EventData[Index] = false
			end
		end
	end
end

local function EventHandler_Register(Self, Function, Event, Event2)
	local EventData = EVENT_STORAGE[Event]
	local EventDataTotal = 0

	if ( not EventData ) then
		local _ = {}
		EVENT_STORAGE[Event] = _
		EventData = _
	else
		EventDataTotal = #EventData

		for i=1,EventDataTotal do
			if ( EventData[i].Func == Function ) then
				return
			end
		end
	end

	EventData[EventDataTotal + 1] = {Func = Function, Self = Self}
	___RegisterEvent(EventHandler, Event2)
end

local function EventHandler_Fire(Self, Event, ...)
	Event = HANDLER_EVENT[Event] or Event

	local TriggerFunc = EventHandler[Event.."_TRIGGER"]
	if ( TriggerFunc and TriggerFunc(nil, Self, Event, ...) == false ) then
		return
	end

	local EventData, Shuffle = EVENT_STORAGE[Event], 1
	for i=1,#EventData do
		local Callback = EventData[i]

		if ( Callback ) then
			Callback.Func(Callback.Self, Event, ...)

			if ( i ~= Shuffle ) then
				EventData[Shuffle] = Callback
				EventData[i] = nil
			end

			Shuffle = Shuffle + 1
		else
			EventData[i] = nil
		end
	end
end
EventHandler:SetScript("OnEvent", EventHandler_Fire)

--[[

	METHOD REPLACEMENT 

]]
local function Method_RegisterEvent(Self, Event)
	local ClassicEvent = CLASSIC_EVENT[Event]

	if ( ClassicEvent ) then
		local OnEvent = Self:GetScript("OnEvent")

		if ( OnEvent ) then
			local RegisterFunc = EventHandler[Event.."_REGISTER"]
			if ( RegisterFunc and RegisterFunc(nil, Self) == false ) then
				return
			end

			if ( ClassicEvent[1] ) then
				for i=1,#ClassicEvent do
					EventHandler_Register(Self, OnEvent, Event, ClassicEvent[i])
				end
			else
				EventHandler_Register(Self, OnEvent, Event, ClassicEvent)
			end
		end
	end
end

local function Method_UnregisterEvent(Self, Event)
	local ClassicEvent = CLASSIC_EVENT[Event]

	if ( ClassicEvent ) then
		local OnEvent = Self:GetScript("OnEvent")

		if ( OnEvent ) then
			if ( ClassicEvent[1] ) then
				for i=1,#ClassicEvent do
					EventHandler_Unregister(Self, OnEvent, Event, ClassicEvent[i])
				end
			else
				EventHandler_Unregister(Self, OnEvent, Event, ClassicEvent)
			end
		end
	end
end

local function Method_RegisterUnitEvent(Self, Event, Unit1, Unit2)
	local UnitEvent = Self.___UnitEvent

	if ( not UnitEvent ) then
		UnitEvent = CreateFrame("Frame")
		Self.___UnitEvent = UnitEvent

		UnitEvent:SetScript("OnEvent", function(_, Event, ...)
			local Units = UnitEvent[Event]
			if ( Units ) then
				local Unit = ...
				if ( Units[1] == Unit or Units[2] == Unit ) then
					local OnEvent = Self:GetScript("OnEvent")
					if ( OnEvent ) then
						OnEvent(Self, Event, ...)
					end
				end
			end
		end)

		HookSecureFunc(Self, "UnregisterEvent", function(_, Event)
			if ( UnitEvent[Event] ) then
				UnitEvent[Event] = nil
				___UnregisterEvent(UnitEvent, Event) -- Stop extra method call.
			end
		end)
	end

	local Units = UnitEvent[Event]
	if ( not Units ) then
		Units = {}
		UnitEvent[Event] = Units
		UnitEvent:RegisterEvent(Event)
	end

	Units[1] = Unit1
	if ( Unit2 ) then
		Units[2] = Unit2
	end
end

local FrameMeta = GetMetaTable(EventHandler).__index
local ButtonMeta = GetMetaTable(CreateFrame("Button")).__index
FrameMeta.RegisterUnitEvent = Method_RegisterUnitEvent
ButtonMeta.RegisterUnitEvent = Method_RegisterUnitEvent
HookSecureFunc(FrameMeta, "RegisterEvent", Method_RegisterEvent)
HookSecureFunc(FrameMeta, "UnregisterEvent", Method_UnregisterEvent)
HookSecureFunc(ButtonMeta, "RegisterEvent", Method_RegisterEvent)
HookSecureFunc(ButtonMeta, "UnregisterEvent", Method_UnregisterEvent)

--[[

	UNIT_HEAL_PREDICTION

]]

local HEALCOMM
local HEALCOMM_GUID
local UHP = "UNIT_HEAL_PREDICTION"
local UHP_UNIT = {"player", "target", "focus", "pet", "party1", "party2", "party3", "party4"}

local function UNIT_HEAL_PREDICTION(Limit, GUID, ...)
	if ( not Limit ) then
		local Raid = GetNumRaidMembers()
		Limit = 4 + (Raid > 0 and 4 + Raid or GetNumPartyMembers())
	end

	if ( ... ) then
		UNIT_HEAL_PREDICTION(Limit, ...)
	end

	for i=1,Limit do
		local UnitID = UHP_UNIT[i]
		if ( UnitGUID(UnitID) == GUID ) then
			EventHandler_Fire(nil, UHP, UnitID)
		end
	end
end

local function HealComm_HealStarted(_, Event, SrcGUID, SpellID, Type, EndTime, ...)
	if ( SrcGUID == HEALCOMM_GUID and BitBand(Type, HEALCOMM.CASTED_HEALS) > 0 ) then
		UNIT_HEAL_PREDICTION(nil, ...)
	end
end

local function HealComm_ModifierChanged(_, _, SrcGUID)
	UNIT_HEAL_PREDICTION(nil, SrcGUID)
end

function EventHandler:UNIT_HEAL_PREDICTION_REGISTER()
	if ( HEALCOMM == nil ) then
		HEALCOMM = LibStub:GetLibrary("LibHealComm-4.0", true) or false

		if ( HEALCOMM ) then
			HEALCOMM_GUID = UnitGUID("player")

			for i=1,40 do
				UHP_UNIT[#UHP_UNIT+1] = "raid"..i
			end
		end
	end

	local EH = EventHandler
	if ( HEALCOMM and not EH.HealComm_HealStarted) then
		EH.HealComm_HealStarted = HealComm_HealStarted
		EH.HealComm_ModifierChanged = HealComm_ModifierChanged

		HEALCOMM.RegisterCallback(EH, "HealComm_HealStarted")
		HEALCOMM.RegisterCallback(EH, "HealComm_HealDelayed", "HealComm_HealStarted")
		HEALCOMM.RegisterCallback(EH, "HealComm_HealUpdated", "HealComm_HealStarted")
		HEALCOMM.RegisterCallback(EH, "HealComm_HealStopped", "HealComm_HealStarted")
	end
end

function EventHandler:UNIT_HEAL_PREDICTION_UNREGISTER()
	local EH = EventHandler
	if ( HEALCOMM and EH.HealComm_HealStarted ) then
		HEALCOMM.UnregisterCallback(EH, "HealComm_HealStarted")
		HEALCOMM.UnregisterCallback(EH, "HealComm_HealDelayed")
		HEALCOMM.UnregisterCallback(EH, "HealComm_HealUpdated")
		HEALCOMM.UnregisterCallback(EH, "HealComm_HealStopped")

		EH.HealComm_HealStarted = nil
		EH.HealComm_ModifierChanged = nil
	end
end

function EventHandler:GROUP_ROSTER_UPDATE_TRIGGER(_, Event)
	if ( Event == "PARTY_MEMBERS_CHANGED" and GetNumRaidMembers() > 0 ) then
		return false
	end
end

--[[

	EVENT SUPPORT

]]

CLASSIC_EVENT = {
	["GROUP_ROSTER_UPDATE"] = {"PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE"},
	--["INSPECT_READY"] = "INSPECT_TALENT_READY",
	[UHP] = UHP,
}

HANDLER_EVENT = {
	["PARTY_MEMBERS_CHANGED"] = "GROUP_ROSTER_UPDATE",
	["RAID_ROSTER_UPDATE"] = "GROUP_ROSTER_UPDATE",
	--["INSPECT_TALENT_READY"] = "INSPECT_READY",
}