function CombatLogGetCurrentEventInfo(...)
	if ( ... ) then
		-- 3.3.5 payload
		local Timestamp, SubEvent, SrcGUID, SrcName, SrcFlag, DstGUID, DstName, DstFlag = ...

		-- Invalid modern payloads
		local HideCaster = false
		local SrcRaidFlag = nil
		local DstRaidFlag = nil

		-- Return modern payload
		-- Note: Going to straight pass 9th on, may not work if blizz changed order.
		return Timestamp, SubEvent, HideCaster, SrcGUID, SrcName, SrcFlag, SrcRaidFlag, DstGUID, DstName, DstFlag, DstRaidFlag, select(9, ...)
	end
end