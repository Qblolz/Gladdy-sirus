function CooldownFrame_Set(self, start, duration, enable, forceShowDrawEdge, modRate)
	if enable and enable ~= 0 and start > 0 and duration > 0 then
		--self:Show()
		self:SetDrawEdge(forceShowDrawEdge)
		self:SetCooldown(start, duration, modRate)
	else
		CooldownFrame_Clear(self)
	end
end

function CooldownFrame_Clear(self)
	self:Hide()
end

function CooldownFrame_SetDisplayAsPercentage(self, percentage)
	local seconds = 100
	--self:Pause()
	self:SetCooldown(GetTime() - seconds * percentage, seconds)
end