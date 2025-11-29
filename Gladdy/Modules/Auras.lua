local pairs, ipairs, select, tinsert, tbl_sort, tostring, tonumber, rand = pairs, ipairs, select, tinsert, table.sort, tostring, tonumber, math.random
local str_gsub = string.gsub
local GetSpellInfo = GetSpellInfo
local CreateFrame, GetTime = CreateFrame, GetTime
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local function defaultSpells(auraType)
	local spells = {}
	for _,v in pairs(Gladdy:GetImportantAuras()) do
		if not auraType or auraType == v.track then
			spells[tostring(v.spellID)] = {}
			spells[tostring(v.spellID)].enabled = true
			spells[tostring(v.spellID)].priority = v.priority
			spells[tostring(v.spellID)].track = v.track
		end
	end
	return spells
end
local function defaultInterrupts()
	local spells = {}
	for _,v in pairs(Gladdy:GetInterrupts()) do
		spells[tostring(v.spellID)] = {}
		spells[tostring(v.spellID)].enabled = true
		spells[tostring(v.spellID)].priority = v.priority
	end
	return spells
end

local Auras = Gladdy:NewModule("Auras", nil, {
	auraEnabled = true,
	auraFontEnabled = true,
	auraFont = "DorisPP",
	auraFontSizeScale = 1,
	auraFontColor = { r = 1, g = 1, b = 0, a = 1 },
	auraBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
	auraBuffBorderColor = { r = 1, g = 0, b = 0, a = 1 },
	auraDebuffBorderColor = { r = 0, g = 1, b = 0, a = 1 },
	auraDisableCircle = false,
	auraCooldownAlpha = 1,
	auraListDefault = defaultSpells(),
	auraListInterrupts = defaultInterrupts(),
	auraInterruptColorsEnabled = true,
	auraInterruptColors = Gladdy:GetSpellSchoolColors(),
	auraDetached = false,
	auraXOffset = 0,
	auraYOffset = 0,
	auraSize = 60 + 20 + 1,
	auraWidthFactor = 0.9,
	auraIconZoomed = false,
	auraInterruptDetached = false,
	auraInterruptXOffset = 0,
	auraInterruptYOffset = 0,
	auraInterruptSize = 60 + 20 + 1,
	auraInterruptWidthFactor = 0.9,
	auraInterruptIconZoomed = false,
	auraFrameStrata = "MEDIUM",
	auraFrameLevel = 5,
	auraInterruptFrameStrata = "MEDIUM",
	auraInterruptFrameLevel = 5,
	auraGroup = false,
	auraGroupDirection = "DOWN",
	auraInterruptGroup = false,
	auraInterruptGroupDirection = "DOWN",
	specialSpells = {
		[8178] = 45,  -- Grounding Totem Effect
		[50461] = 10,  -- Anti-Magic Zone
	},
})

function Auras:Initialize()
	self.frames = {}

	if Gladdy.db.auraEnabled then
		self.auras = Gladdy:GetImportantAuras()

		self:RegisterMessage("JOINED_ARENA")
		self:RegisterMessage("UNIT_DEATH")
		self:RegisterMessage("AURA_GAIN")
		self:RegisterMessage("AURA_FADE")
		self:RegisterMessage("SPELL_INTERRUPT")
	end
end

function Auras:CreateFrame(unit)
	local config = {
		type = "aura",
		unit = unit,
		frameStrata = Gladdy.db.auraFrameStrata,
		frameLevel = Gladdy.db.auraFrameLevel,
		fontEnabled = Gladdy.db.auraFontEnabled,
		fontOption = "auraFont",
		fontScale = Gladdy.db.auraFontSizeScale,
		fontAlpha = Gladdy.db.auraFontColor.a,
		detached = Gladdy.db.auraDetached,
		interruptDetached = Gladdy.db.auraInterruptDetached,
		cooldownAlpha = Gladdy.db.auraCooldownAlpha,
		iconZoomed = Gladdy.db.auraIconZoomed,
		borderStyle = Gladdy.db.auraBorderStyle,
		specialSpells = Gladdy.db.specialSpells,
		disableCircle = Gladdy.db.auraDisableCircle,
	}

	local auraFrame = Gladdy:CreateSomeFrame(Gladdy.buttons[unit], "GladdyAura_" .. unit, config)
	
	-- Устанавливаем позицию
	local classIcon = Gladdy.modules["Class Icon"].frames[unit]
	auraFrame:ClearAllPoints()
	auraFrame:SetAllPoints(classIcon)

	Gladdy.buttons[unit].aura = auraFrame
	self.frames[unit] = auraFrame
	self:CreateInterrupt(unit)
	self:ResetUnit(unit)
end

function Auras:UpdateFrame(unit)
	local auraFrame = self.frames[unit]
	if (not auraFrame) then return end

	local borderColor =  { r = 0, g = 0, b = 0, a = 1 }

	if auraFrame.track and auraFrame.track == AURA_TYPE_DEBUFF then
		borderColor = Gladdy.db.auraDebuffBorderColor
	elseif auraFrame.track and auraFrame.track == AURA_TYPE_BUFF then
		borderColor = Gladdy.db.auraBuffBorderColor
	end

	auraFrame:UpdateConfig({
		frameStrata = Gladdy.db.auraFrameStrata,
		frameLevel = Gladdy.db.auraFrameLevel,
		cooldownAlpha = Gladdy.db.auraCooldownAlpha,
		iconZoomed = Gladdy.db.auraIconZoomed,
		borderStyle = Gladdy.db.auraBorderStyle,
		borderColor = borderColor,
		fontEnabled = Gladdy.db.auraFontEnabled,
		fontOption = "auraFont",
		fontScale = Gladdy.db.auraFontSizeScale,
		fontAlpha = Gladdy.db.auraFontColor.a,
		detached = Gladdy.db.auraDetached,
		disableCircle = Gladdy.db.auraDisableCircle,
	})

	local width, height

	if Gladdy.db.auraDetached then
		width, height = Gladdy.db.auraSize * Gladdy.db.auraWidthFactor, Gladdy.db.auraSize

		auraFrame:ClearAllPoints()
		Gladdy:SetPosition(auraFrame, unit, "auraXOffset", "auraYOffset", true, Auras)

		if (Gladdy.db.auraGroup) then
			if (unit ~= "arena1") then
				local previousUnit = "arena" .. str_gsub(unit, "arena", "") - 1
				self.frames[unit]:ClearAllPoints()
				if Gladdy.db.auraGroupDirection == "RIGHT" then
					self.frames[unit]:SetPoint("LEFT", self.frames[previousUnit], "RIGHT", 0, 0)
				elseif Gladdy.db.auraGroupDirection == "LEFT" then
					self.frames[unit]:SetPoint("RIGHT", self.frames[previousUnit], "LEFT", 0, 0)
				elseif Gladdy.db.auraGroupDirection == "UP" then
					self.frames[unit]:SetPoint("BOTTOM", self.frames[previousUnit], "TOP", 0, 0)
				elseif Gladdy.db.auraGroupDirection == "DOWN" then
					self.frames[unit]:SetPoint("TOP", self.frames[previousUnit], "BOTTOM", 0, 0)
				end
			end
		end

		if (unit == "arena1") then
			Gladdy:CreateMover(auraFrame, "auraXOffset", "auraYOffset", L["Auras"],
					{"TOPLEFT", "TOPLEFT"},
					width,
					height,
					0,
					0)
		end
	else
		width, height = Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor, Gladdy.db.classIconSize

		auraFrame:ClearAllPoints()
		auraFrame:SetPoint("TOPLEFT", Gladdy.modules["Class Icon"].frames[unit], "TOPLEFT")
		if auraFrame.mover then
			auraFrame.mover:Hide()
		end
	end

	local testAgain = false

	auraFrame:SetWidth(width)
	auraFrame:SetHeight(height)
	auraFrame.frame:SetWidth(height)
	auraFrame.frame:SetHeight(height)

	if Gladdy.db.auraIconZoomed then
		auraFrame.cooldown:SetWidth(width)
		auraFrame.cooldown:SetHeight(height)
	else
		auraFrame.cooldown:SetWidth(width - width/16)
		auraFrame.cooldown:SetHeight(height - height/16)
	end

	auraFrame.text:SetFont(Gladdy:SMFetch("font", "auraFont"), (width/2 - 1) * Gladdy.db.auraFontSizeScale, "OUTLINE")
	auraFrame.text:SetTextColor(Gladdy:SetColor(Gladdy.db.auraFontColor))

	testAgain = testAgain or self:UpdateInterruptFrame(unit)

	if testAgain then
		Auras:ResetUnit(unit)
		Auras:Test(unit)
	end
end

function Auras:CreateInterrupt(unit)
	local config = {
		type = "interrupt",
		unit = unit,
		frameStrata = Gladdy.db.auraInterruptFrameStrata,
		frameLevel = Gladdy.db.auraInterruptFrameLevel,
		fontEnabled = true,
		fontOption = "auraFont",
		fontScale = Gladdy.db.auraFontSizeScale,
		fontAlpha = Gladdy.db.auraFontColor.a,
		detached = Gladdy.db.auraInterruptDetached,
		cooldownAlpha = Gladdy.db.auraCooldownAlpha,
		iconZoomed = Gladdy.db.auraInterruptIconZoomed,
		borderStyle = Gladdy.db.auraBorderStyle,
		disableCircle = Gladdy.db.auraDisableCircle,
	}

	local interruptFrame = Gladdy:CreateSomeFrame(Gladdy.buttons[unit], "GladdyInterrupt_" .. unit, config)
	
	-- Устанавливаем позицию
	local classIcon = Gladdy.modules["Class Icon"].frames[unit]
	interruptFrame:ClearAllPoints()
	interruptFrame:SetAllPoints(classIcon)

	Gladdy.buttons[unit].interruptFrame = interruptFrame
	self.frames[unit].interruptFrame = interruptFrame
	self:ResetUnit(unit)
end

function Auras:UpdateInterruptFrame(unit)
	local interruptFrame = self.frames[unit] and self.frames[unit].interruptFrame
	if (not interruptFrame) then
		return
	end

	local borderColor = { r = 0, g = 0, b = 0, a = 1 }
	if interruptFrame.spellSchool then
		borderColor = self:GetInterruptColor(interruptFrame.spellSchool)
	end

	interruptFrame:UpdateConfig({
		frameStrata = Gladdy.db.auraInterruptFrameStrata,
		frameLevel = Gladdy.db.auraInterruptFrameLevel,
		cooldownAlpha = Gladdy.db.auraCooldownAlpha,
		iconZoomed = Gladdy.db.auraInterruptIconZoomed,
		borderStyle = Gladdy.db.auraBorderStyle,
		borderColor = borderColor,
		fontEnabled = Gladdy.db.auraFontEnabled,
		fontOption = "auraFont",
		fontScale = Gladdy.db.auraFontSizeScale,
		fontAlpha = Gladdy.db.auraFontColor.a,
		detached = Gladdy.db.auraInterruptDetached,
		disableCircle = Gladdy.db.auraDisableCircle,
	})

	local width, height

	if Gladdy.db.auraInterruptDetached then
		width, height = Gladdy.db.auraInterruptSize * Gladdy.db.auraInterruptWidthFactor, Gladdy.db.auraInterruptSize

		interruptFrame:ClearAllPoints()
		Gladdy:SetPosition(interruptFrame, unit, "auraInterruptXOffset", "auraInterruptYOffset", true, Auras)

		if (Gladdy.db.auraInterruptGroup) then
			if (unit ~= "arena1") then
				local previousUnit = "arena" .. str_gsub(unit, "arena", "") - 1
				self.frames[unit].interruptFrame:ClearAllPoints()
				if Gladdy.db.auraInterruptGroupDirection == "RIGHT" then
					self.frames[unit].interruptFrame:SetPoint("LEFT", self.frames[previousUnit].interruptFrame, "RIGHT", 0, 0)
				elseif Gladdy.db.auraInterruptGroupDirection == "LEFT" then
					self.frames[unit].interruptFrame:SetPoint("RIGHT", self.frames[previousUnit].interruptFrame, "LEFT", 0, 0)
				elseif Gladdy.db.auraInterruptGroupDirection == "UP" then
					self.frames[unit].interruptFrame:SetPoint("BOTTOM", self.frames[previousUnit].interruptFrame, "TOP", 0, 0)
				elseif Gladdy.db.auraInterruptGroupDirection == "DOWN" then
					self.frames[unit].interruptFrame:SetPoint("TOP", self.frames[previousUnit].interruptFrame, "BOTTOM", 0, 0)
				end
			end
		end

		if (unit == "arena1") then
			Gladdy:CreateMover(interruptFrame, "auraInterruptXOffset", "auraInterruptYOffset", L["Interrupts"],
					{"TOPLEFT", "TOPLEFT"},
					width,
					height,
					0,
					0)
		end
	else
		if Gladdy.db.auraDetached then
			width, height = Gladdy.db.auraSize * Gladdy.db.auraWidthFactor, Gladdy.db.auraSize

			interruptFrame:ClearAllPoints()
			interruptFrame:SetAllPoints(self.frames[unit])
			if interruptFrame.mover then
				interruptFrame.mover:Hide()
			end
		else
			width, height = Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor, Gladdy.db.classIconSize

			interruptFrame:ClearAllPoints()
			interruptFrame:SetPoint("TOPLEFT", Gladdy.modules["Class Icon"].frames[unit], "TOPLEFT")
			if interruptFrame.mover then
				interruptFrame.mover:Hide()
			end
		end
	end

	local testAgain = false

	interruptFrame:SetWidth(width)
	interruptFrame:SetHeight(height)
	interruptFrame.frame:SetWidth(width)
	interruptFrame.frame:SetHeight(height)
	interruptFrame.cooldownFrame:ClearAllPoints()
	interruptFrame.cooldownFrame:SetAllPoints(interruptFrame.frame)

	interruptFrame.cooldown:ClearAllPoints()
	interruptFrame.cooldown:SetPoint("CENTER", interruptFrame, "CENTER")
	if Gladdy.db.auraInterruptIconZoomed then
		interruptFrame.cooldown:SetWidth(width)
		interruptFrame.cooldown:SetHeight(height)
	else
		interruptFrame.cooldown:SetWidth(width - width/16)
		interruptFrame.cooldown:SetHeight(height - height/16)
	end

	interruptFrame.text:SetFont(Gladdy:SMFetch("font", "auraFont"), (width/2 - 1) * Gladdy.db.auraFontSizeScale, "OUTLINE")
	interruptFrame.text:SetTextColor(Gladdy:SetColor(Gladdy.db.auraFontColor))
	
	if not interruptFrame.active then
		interruptFrame.icon.overlay:Hide()
	end

	return testAgain
end

function Auras:JOINED_ARENA()
	-- Skip if module disabled
	if not Gladdy.db.auraEnabled then
		return
	end

	for i = 1, Gladdy.curBracket do
		local unit = "arena" .. i
		self.frames[unit].interruptFrame.active = false
		self.frames[unit].active = false
		self:AURA_FADE(unit, AURA_TYPE_DEBUFF)
		self:AURA_FADE(unit, AURA_TYPE_BUFF)
		self.frames[unit]:Show()
		self.frames[unit].interruptFrame:Show()
	end
end

function Auras:AURA_GAIN(unit, auraType, spellID, spellName, icon, duration, expirationTime, count, debuffType)
	-- Skip if module disabled
	if not Gladdy.db.auraEnabled then return end

	local auraFrame = self.frames[unit]
	if not auraFrame then return end

	local auraInfo = self.auras[spellName]
	if not auraInfo then return end

	local spellIDStr = tostring(auraInfo.spellID)
	local auraConfig = Gladdy.db.auraListDefault[spellIDStr]
	if not auraConfig or not auraConfig.enabled or auraConfig.track ~= auraType then
		return
	end

	-- Проверяем приоритет
	if auraFrame.priority and auraFrame.priority > auraConfig.priority then
		return
	end

	-- Устанавливаем параметры ауры
	auraFrame.startTime = expirationTime - duration
	auraFrame.endTime = expirationTime
	auraFrame.name = spellName
	auraFrame.spellID = spellID
	auraFrame.priority = auraConfig.priority
	auraFrame.icon:SetTexture(Gladdy:GetImportantAuras()[GetSpellInfo(auraInfo.spellID)] and Gladdy:GetImportantAuras()[GetSpellInfo(auraInfo.spellID)].texture or icon)
	auraFrame.track = auraType
	auraFrame.active = true
	auraFrame.cooldownFrame:Show()

	-- Показываем рамку и устанавливаем её цвет
	if Gladdy.db.auraBorderStyle and Gladdy.db.auraBorderStyle ~= "None" then
		if auraFrame.icon and auraFrame.icon.overlay then
			auraFrame.icon.overlay:SetTexture(Gladdy.db.auraBorderStyle)
			auraFrame.icon.overlay:Show()
			if auraType == AURA_TYPE_BUFF then
				auraFrame.icon.overlay:SetVertexColor(Gladdy:SetColor(Gladdy.db.auraBuffBorderColor))
			elseif auraType == AURA_TYPE_DEBUFF then
				auraFrame.icon.overlay:SetVertexColor(Gladdy:SetColor(Gladdy.db.auraDebuffBorderColor))
			else
				auraFrame.icon.overlay:SetVertexColor(Gladdy:SetColor(Gladdy.db.frameBorderColor))
			end
		end
	else
		if auraFrame.icon and auraFrame.icon.overlay then
			auraFrame.icon.overlay:Hide()
		end
	end

	-- Устанавливаем время для специальных спеллов
	local specialSpells = Gladdy.db.specialSpells
	if specialSpells[spellID] then
		auraFrame.timeLeft = specialSpells[spellID]
	else
		auraFrame.timeLeft = expirationTime - GetTime()
	end

	-- Управляем отображением круга кулдауна
	if not Gladdy.db.auraDisableCircle and not specialSpells[spellID] then
		auraFrame.cooldown:Show()
		auraFrame.cooldown:SetCooldown(auraFrame.startTime, duration)
	else
		auraFrame.cooldown:Hide()
	end
end

function Auras:AURA_FADE(unit, auraType, force)
	-- Skip if module disabled
	if not Gladdy.db.auraEnabled then
		return
	end

	local auraFrame = self.frames[unit]
	if (not auraFrame or auraFrame.track ~= auraType or not Gladdy.buttons[unit] or (not force and Gladdy.buttons[unit].stealthed)) then
		return
	end

	if auraFrame.active then
		auraFrame:StopCooldown()
	end

	auraFrame.active = false
	auraFrame.name = nil
	auraFrame.timeLeft = 0
	auraFrame.priority = nil
	auraFrame.startTime = nil
	auraFrame.endTime = nil
	auraFrame:SetIcon(nil)
	auraFrame.text:SetText("")
end

function Auras:SPELL_INTERRUPT(unit,spellID,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool)
	-- Skip if module disabled
	if not Gladdy.db.auraEnabled then
		return
	end

	-- Safely check for all required objects
	if not self.frames or not unit or not self.frames[unit] then
		return
	end

	local auraFrame = self.frames[unit]
	local interruptFrame = auraFrame ~= nil and auraFrame.interruptFrame
	local button = Gladdy.buttons[unit]
	if not interruptFrame or not button then
		return
	end

	-- Check if the interrupt is valid before accessing properties
	local interrupts = Gladdy:GetInterrupts()
	if not interrupts or not interrupts[spellName] then
		return
	end

	local interruptSpellId = tostring(interrupts[spellName].spellID)
	-- Инициализируем запись, если она не существует
	if not Gladdy.db.auraListInterrupts[interruptSpellId] then
		Gladdy.db.auraListInterrupts[interruptSpellId] = {
			enabled = true,
			priority = 0
		}
	end
	if not Gladdy.db.auraListInterrupts[interruptSpellId].enabled then
		return
	end
	if (interruptFrame.priority and interruptFrame.priority > Gladdy.db.auraListInterrupts[interruptSpellId].priority) then
		return
	end
	local multiplier = ((button.spec == L["Restoration"] and button.class == "SHAMAN") or (button.spec == L["Holy"] and button.class == "PALADIN")) and 0.7 or 1

	local duration = Gladdy:GetInterrupts()[spellName].duration * multiplier

	interruptFrame.startTime = GetTime()
	interruptFrame.endTime = GetTime() + duration
	interruptFrame.name = spellName
	interruptFrame.timeLeft = duration
	interruptFrame.priority = Gladdy.db.auraListInterrupts[interruptSpellId].priority
	-- Set icon texture
	interruptFrame.icon:SetTexture(Gladdy:GetInterrupts()[spellName].texture)

	-- Apply texture coordinates based on zoom setting
	if Gladdy.db.auraInterruptIconZoomed then
		interruptFrame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	else
		interruptFrame.icon:SetTexCoord(0, 1, 0, 1)
	end

	interruptFrame.spellSchool = extraSpellSchool
	interruptFrame.active = true
	interruptFrame.cooldownFrame:Show()

	-- Update border display
	if Gladdy.db.auraBorderStyle and Gladdy.db.auraBorderStyle ~= "None" then
		-- Reset texture and set fresh
		interruptFrame.icon.overlay:SetTexture(nil)
		interruptFrame.icon.overlay:SetTexture(Gladdy.db.auraBorderStyle)

		-- Apply color using the interrupt color function
		local r, g, b, a = self:GetInterruptColor(extraSpellSchool)
		interruptFrame.icon.overlay:SetVertexColor(r, g, b, a)

		-- Force refresh by showing the overlay
		interruptFrame.icon.overlay:Show()
	else
		if interruptFrame.icon.overlay then
			interruptFrame.icon.overlay:Hide()
		end
	end

	if not Gladdy.db.auraDisableCircle then
		interruptFrame.cooldown:Show()
		interruptFrame.cooldown:SetCooldown(interruptFrame.startTime, duration)
	end
end

function Auras:ResetUnit(unit)
	-- Проверка существования фрейма и его компонентов
	if not self.frames[unit] then return end

	-- Проверяем существование каждого компонента перед его использованием
	if self.frames[unit].interruptFrame then
		self.frames[unit].interruptFrame.active = false
		self.frames[unit].interruptFrame:Hide()
		self.frames[unit].interruptFrame.priority = nil
		self.frames[unit].interruptFrame.spellSchool = nil
	end

	if self.frames[unit].active ~= nil then
		self.frames[unit].active = false
	end

	self:AURA_FADE(unit, AURA_TYPE_DEBUFF)
	self:AURA_FADE(unit, AURA_TYPE_BUFF)
	self.frames[unit]:UnregisterAllEvents()
	self.frames[unit]:Hide()
end

function Auras:Test(unit)
	local spellName, spellid, icon, limit

	self:AURA_FADE(unit, AURA_TYPE_BUFF)
	self:AURA_FADE(unit, AURA_TYPE_DEBUFF)
	if not self.frames[unit]:IsShown() then
		self.frames[unit]:Show()
		self.frames[unit].interruptFrame:Show()
	end

	--Auras
	local enabledDebuffs, enabledBuffs, testauras = {}, {}
	for spellIdStr,value in pairs(Gladdy.db.auraListDefault) do
		if value.enabled then
			if value.track == AURA_TYPE_BUFF then
				tinsert(enabledBuffs, {value = value, spellIdStr = spellIdStr})
			else
				tinsert(enabledDebuffs, {value = value, spellIdStr = spellIdStr})
			end
		end
	end
	if unit == "arena2" then
		testauras = enabledBuffs
	else
		testauras = enabledDebuffs
	end

	if #testauras > 0 then
		limit = rand(1, #testauras)
		local v = testauras[rand(1, #testauras)]
		spellid = tonumber(v.spellIdStr)
		spellName = select(1, GetSpellInfo(tonumber(v.spellIdStr)))
		icon = select(3, GetSpellInfo(tonumber(v.spellIdStr)))
		if Gladdy.exceptionNames[spellid] then
			spellName = Gladdy.exceptionNames[spellid]
		end
		local duration = math.random(2,10)
		if (unit == "arena2") then
			if (v.value.track == AURA_TYPE_BUFF) then
				self:AURA_GAIN(unit,v.value.track, spellid, spellName, icon, duration, GetTime() + duration)
			end
		else
			self:AURA_GAIN(unit,v.value.track, spellid, spellName, icon, duration, GetTime() + duration)
		end
	end

	--Interrupts
	if (unit == "arena1" or unit == "arena3") then
		local enabledInterrupts = {}
		local spellSchools = {}
		for k,_ in pairs(Gladdy:GetSpellSchoolColors()) do
			tinsert(spellSchools, k)
		end
		for spellIdStr, value in pairs(Gladdy.db.auraListInterrupts) do
			if value.enabled then
				tinsert(enabledInterrupts, spellIdStr)
			end
		end
		if #enabledInterrupts > 0 then
			local extraSpellSchool = spellSchools[rand(1, #spellSchools)]
			spellid = tonumber(enabledInterrupts[rand(1, #enabledInterrupts)])
			spellName = select(1, GetSpellInfo(spellid))
			Gladdy:SendMessage("SPELL_INTERRUPT", unit,spellid, spellName, "physical", spellid, spellName, extraSpellSchool)
		end
	end
end

function Auras:GetInterruptColor(extraSpellSchool)
	if not Gladdy.db.auraInterruptColorsEnabled then
		return Gladdy:SetColor(Gladdy.db.auraDebuffBorderColor)
	else
		local color = Gladdy.db.auraInterruptColors[extraSpellSchool] or Gladdy.db.auraInterruptColors["unknown"]
		return color.r, color.g, color.b, color.a
	end
end

function Auras:GetOptions()
	return {
		headerGeneral = {
			type = "header",
			name = L["General"],
			order = 1,
		},
		auraEnabled = Gladdy:option({
			type = "toggle",
			name = L["Enabled"],
			desc = L["Enable auras"],
			order = 2,
		}),
		generalSettings = {
			type = "group",
			childGroups = "tab",
			name = L["Display Settings"],
			order = 3,
			args = {
				iconGroup = {
					type = "group",
					name = L["Icon"],
					order = 1,
					args = {
						headerIcon = {
							type = "header",
							name = L["Icon Settings"],
							order = 1,
						},
						auraIconZoomed = Gladdy:option({
							type = "toggle",
							name = L["Zoomed Icon"],
							desc = L["Zooms the icon to remove borders"],
							order = 2,
							width = "full",
						}),
						auraDisableCircle = Gladdy:option({
							type = "toggle",
							name = L["No Cooldown Circle"],
							order = 3,
							width = "full"
						}),
						auraCooldownAlpha = Gladdy:option({
							type = "range",
							name = L["Cooldown circle alpha"],
							min = 0,
							max = 1,
							step = 0.1,
							order = 4,
							width = "full",
						}),
					},
				},
				fontGroup = {
					type = "group",
					name = L["Font"],
					order = 2,
					args = {
						headerFont = {
							type = "header",
							name = L["Font Settings"],
							order = 1,
						},
						auraFont = Gladdy:option({
							type = "select",
							name = L["Font"],
							desc = L["Font of the cooldown"],
							order = 2,
							dialogControl = "LSM30_Font",
							values = AceGUIWidgetLSMlists.font,
						}),
						auraFontSizeScale = Gladdy:option({
							type = "range",
							name = L["Font scale"],
							desc = L["Scale of the text"],
							order = 3,
							min = 0.1,
							max = 2,
							step = 0.1,
							width = "full",
						}),
						auraFontColor = Gladdy:colorOption({
							type = "color",
							name = L["Font color"],
							desc = L["Color of the text"],
							order = 4,
							hasAlpha = true,
						}),
					},
				},
				borderGroup = {
					type = "group",
					name = L["Border"],
					order = 3,
					args = self:GetBorderArgs(),
				},
			},
		},
		positionSettings = {
			type = "group",
			childGroups = "tab",
			name = L["Position Settings"],
			order = 4,
			args = {
				auraPosition = {
					type = "group",
					name = L["Auras"],
					order = 1,
					args = {
						headerAuraPosition = {
							type = "header",
							name = L["Aura Position"],
							order = 1,
						},
						auraDetached = Gladdy:option({
							type = "toggle",
							name = L["Detach from Class Icon"],
							order = 2,
							width = "full",
						}),
						auraSize = Gladdy:option({
							type = "range",
							name = L["Size"],
							min = 3,
							max = 100,
							step = 0.1,
							order = 3,
							width = "full",
							disabled = function() return not Gladdy.db.auraDetached end,
						}),
						auraWidthFactor = Gladdy:option({
							type = "range",
							name = L["Width factor"],
							min = 0.5,
							max = 2,
							step = 0.05,
							order = 4,
							width = "full",
							disabled = function() return not Gladdy.db.auraDetached end,
						}),
						auraXOffset = Gladdy:option({
							type = "range",
							name = L["X Offset"],
							disabled = function() return not Gladdy.db.auraDetached end,
							min = -1000,
							max = 1000,
							step = 0.1,
							order = 5,
							width = "full",
						}),
						auraYOffset = Gladdy:option({
							type = "range",
							name = L["Y Offset"],
							disabled = function() return not Gladdy.db.auraDetached end,
							min = -1000,
							max = 1000,
							step = 0.1,
							order = 6,
							width = "full",
						}),
						headerAuraGroup = {
							type = "header",
							name = L["Group Settings"],
							order = 7,
						},
						auraGroup = Gladdy:option({
							type = "toggle",
							name = L["Enable Group Mode"],
							order = 8,
							width = "full",
							disabled = function() return not Gladdy.db.auraDetached end,
						}),
						auraGroupDirection = Gladdy:option({
							type = "select",
							name = L["Group Direction"],
							order = 9,
							values = {
								["RIGHT"] = L["Right"],
								["LEFT"] = L["Left"],
								["UP"] = L["Up"],
								["DOWN"] = L["Down"],
							},
							disabled = function() return not Gladdy.db.auraDetached or not Gladdy.db.auraGroup end,
							width = "full",
						}),
						headerFrame = {
							type = "header",
							name = L["Frame Settings"],
							order = 10,
						},
						auraFrameStrata = Gladdy:option({
							type = "select",
							name = L["Frame Strata"],
							order = 11,
							values = Gladdy.frameStrata,
							sorting = Gladdy.frameStrataSorting,
							width = "full",
							disabled = function() return not Gladdy.db.auraDetached end,
						}),
						auraFrameLevel = Gladdy:option({
							type = "range",
							name = L["Frame Level"],
							min = 0,
							max = 500,
							step = 1,
							order = 12,
							width = "full",
							disabled = function() return not Gladdy.db.auraDetached end,
						}),
					},
				},
				interruptPosition = {
					type = "group",
					name = L["Interrupts"],
					order = 2,
					args = {
						headerInterruptPosition = {
							type = "header",
							name = L["Interrupt Position"],
							order = 1,
						},
						auraInterruptDetached = Gladdy:option({
							type = "toggle",
							name = L["Detach from Class Icon"],
							order = 2,
							width = "full",
						}),
						auraInterruptSize = Gladdy:option({
							type = "range",
							name = L["Size"],
							min = 3,
							max = 100,
							step = 0.1,
							order = 3,
							width = "full",
							disabled = function() return not Gladdy.db.auraInterruptDetached end,
						}),
						auraInterruptWidthFactor = Gladdy:option({
							type = "range",
							name = L["Width factor"],
							min = 0.5,
							max = 2,
							step = 0.05,
							order = 4,
							width = "full",
							disabled = function() return not Gladdy.db.auraInterruptDetached end,
						}),
						auraInterruptXOffset = Gladdy:option({
							type = "range",
							name = L["X Offset"],
							disabled = function() return not Gladdy.db.auraInterruptDetached end,
							min = -1000,
							max = 1000,
							step = 0.1,
							order = 5,
							width = "full",
						}),
						auraInterruptYOffset = Gladdy:option({
							type = "range",
							name = L["Y Offset"],
							disabled = function() return not Gladdy.db.auraInterruptDetached end,
							min = -1000,
							max = 1000,
							step = 0.1,
							order = 6,
							width = "full",
						}),
						headerInterruptGroup = {
							type = "header",
							name = L["Group Settings"],
							order = 7,
						},
						auraInterruptGroup = Gladdy:option({
							type = "toggle",
							name = L["Enable Group Mode"],
							order = 8,
							width = "full",
							disabled = function() return not Gladdy.db.auraInterruptDetached end,
						}),
						auraInterruptGroupDirection = Gladdy:option({
							type = "select",
							name = L["Group Direction"],
							order = 9,
							values = {
								["RIGHT"] = L["Right"],
								["LEFT"] = L["Left"],
								["UP"] = L["Up"],
								["DOWN"] = L["Down"],
							},
							disabled = function() return not Gladdy.db.auraInterruptDetached or not Gladdy.db.auraInterruptGroup end,
							width = "full",
						}),
						headerFrame = {
							type = "header",
							name = L["Frame Settings"],
							order = 10,
						},
						auraInterruptFrameStrata = Gladdy:option({
							type = "select",
							name = L["Frame Strata"],
							order = 11,
							values = Gladdy.frameStrata,
							sorting = Gladdy.frameStrataSorting,
							width = "full",
							disabled = function() return not Gladdy.db.auraInterruptDetached end,
						}),
						auraInterruptFrameLevel = Gladdy:option({
							type = "range",
							name = L["Frame Level"],
							min = 0,
							max = 500,
							step = 1,
							order = 12,
							width = "full",
							disabled = function() return not Gladdy.db.auraInterruptDetached end,
						}),
					},
				},
			},
		},
		spellSettings = {
			type = "group",
			childGroups = "tab",
			name = L["Spell Lists"],
			order = 5,
			args = {
				debuffList = {
					type = "group",
					name = L["Debuffs"],
					order = 1,
					args = self:GetAuraOptions(AURA_TYPE_DEBUFF),
				},
				buffList = {
					type = "group",
					name = L["Buffs"],
					order = 2,
					args = self:GetAuraOptions(AURA_TYPE_BUFF),
				},
				interruptList = {
					type = "group",
					name = L["Interrupts"],
					order = 3,
					args = self:GetInterruptOptions(),
				},
			},
		},
	}
end

function Auras:GetBorderArgs()
	local borderArgs = {
		headerAuras = {
			type = "header",
			name = L["Border"],
			order = 2,
		},
		auraBorderStyle = Gladdy:option({
			type = "select",
			name = L["Border style"],
			order = 9,
			values = Gladdy:GetIconStyles(),
		}),
		auraBuffBorderColor = Gladdy:colorOption({
			type = "color",
			name = L["Buff color"],
			desc = L["Color of the text"],
			order = 10,
			hasAlpha = true,
			width = "0.8",
		}),
		auraDebuffBorderColor = Gladdy:colorOption({
			type = "color",
			name = L["Debuff color"],
			desc = L["Color of the text"],
			order = 11,
			hasAlpha = true,
			width = "0.8",
		}),
		headerColors = {
			type = "header",
			name = L["Interrupt Spells School Colors"],
			order = 12,
		},
		auraInterruptColorsEnabled = Gladdy:option({
			type = "toggle",
			name = L["Enable Interrupt Spell School Colors"],
			width = "full",
			desc = L["Will use Debuff Color if disabled"],
			order = 13,
		}),
	}
	local list = {}
	for k,v in pairs(Gladdy:GetSpellSchoolColors()) do
		tinsert(list, { key = k, val = v})
	end
	tbl_sort(list, function(a, b) return a.val.type < b.val.type end)
	for i,v in ipairs(list) do
		borderArgs["auraSpellSchool" .. v.key] = {
			type = "color",
			name = L[v.val.type],
			order = i + 13,
			hasAlpha = true,
			width = "0.8",
			set = function(_, r, g, b, a)
				Gladdy.db.auraInterruptColors[v.key].r = r
				Gladdy.db.auraInterruptColors[v.key].g = g
				Gladdy.db.auraInterruptColors[v.key].b = b
				Gladdy.db.auraInterruptColors[v.key].a = a
			end,
			get = function()
				local color = Gladdy.db.auraInterruptColors[v.key]
				return color.r, color.g, color.b, color.a
			end
		}
	end

	return borderArgs
end

function Auras:GetAuraOptions(auraType)
	local options = {
		ckeckAll = {
			order = 1,
			width = "0.7",
			name = L["Check All"],
			type = "execute",
			func = function()
				for k,_ in pairs(defaultSpells(auraType)) do
					Gladdy.db.auraListDefault[k].enabled = true
				end
			end,
		},
		uncheckAll = {
			order = 2,
			width = "0.7",
			name = L["Uncheck All"],
			type = "execute",
			func = function()
				for k,_ in pairs(defaultSpells(auraType)) do
					Gladdy.db.auraListDefault[k].enabled = false
				end
			end,
		},
	}
	local auras = {}
	for _,v in pairs(Gladdy:GetImportantAuras()) do
		if v.track == auraType then
			tinsert(auras, v.spellID)
		end
	end
	tbl_sort(auras, function(a, b) return GetSpellInfo(a) < GetSpellInfo(b) end)
	for i,k in ipairs(auras) do
		options[tostring(k)] = {
			type = "group",
			name = Gladdy:GetExceptionSpellName(k),
			order = i+2,
			icon = Gladdy:GetImportantAuras()[GetSpellInfo(k)] and Gladdy:GetImportantAuras()[GetSpellInfo(k)].texture or select(3, GetSpellInfo(k)),
			args = {
				enabled = {
					order = 1,
					name = L["Enabled"],
					type = "toggle",
					image = Gladdy:GetImportantAuras()[GetSpellInfo(k)] and Gladdy:GetImportantAuras()[GetSpellInfo(k)].texture or select(3, GetSpellInfo(k)),
					width = "2",
					set = function(_, value)
						if not Gladdy.db.auraListDefault[tostring(k)] then
							Gladdy.db.auraListDefault[tostring(k)] = {
								enabled = true,
								priority = 0,
								track = AURA_TYPE_DEBUFF
							}
						end
						Gladdy.db.auraListDefault[tostring(k)].enabled = value
					end,
					get = function()
						if not Gladdy.db.auraListDefault[tostring(k)] then
							Gladdy.db.auraListDefault[tostring(k)] = {
								enabled = true,
								priority = 0,
								track = AURA_TYPE_DEBUFF
							}
						end
						return Gladdy.db.auraListDefault[tostring(k)].enabled
					end
				},
				priority = {
					order = 2,
					name = L["Priority"],
					type = "range",
					min = 0,
					max = 50,
					width = "2",
					step = 1,
					get = function()
						if not Gladdy.db.auraListDefault[tostring(k)] then
							Gladdy.db.auraListDefault[tostring(k)] = {
								enabled = true,
								priority = 0,
								track = AURA_TYPE_DEBUFF
							}
						end
						return Gladdy.db.auraListDefault[tostring(k)].priority
					end,
					set = function(_, value)
						if not Gladdy.db.auraListDefault[tostring(k)] then
							Gladdy.db.auraListDefault[tostring(k)] = {
								enabled = true,
								priority = 0,
								track = AURA_TYPE_DEBUFF
							}
						end
						Gladdy.db.auraListDefault[tostring(k)].priority = value
					end,
					width = "full",
				}
			}
		}
	end
	return options
end

function Auras:GetInterruptOptions()
	local options = {
		checkAll = {
			order = 1,
			width = "0.7",
			name = L["Check All"],
			type = "execute",
			func = function()
				for k,_ in pairs(defaultInterrupts()) do
					Gladdy.db.auraListInterrupts[k].enabled = true
				end
			end,
		},
		uncheckAll = {
			order = 2,
			width = "0.7",
			name = L["Uncheck All"],
			type = "execute",
			func = function()
				for k,_ in pairs(defaultInterrupts()) do
					Gladdy.db.auraListInterrupts[k].enabled = false
				end
			end,
		},
	}
	local auras = {}
	for _,v in pairs(Gladdy:GetInterrupts()) do
		tinsert(auras, v.spellID)
	end
	tbl_sort(auras, function(a, b) return GetSpellInfo(a) < GetSpellInfo(b) end)
	for i,k in ipairs(auras) do
		options[tostring(k)] = {
			type = "group",
			name = GetSpellInfo(k),
			order = i+2,
			icon = Gladdy:GetInterrupts()[GetSpellInfo(k)] and Gladdy:GetInterrupts()[GetSpellInfo(k)].texture or select(3, GetSpellInfo(k)),
			args = {
				enabled = {
					order = 1,
					name = L["Enabled"],
					type = "toggle",
					image = Gladdy:GetInterrupts()[GetSpellInfo(k)] and Gladdy:GetInterrupts()[GetSpellInfo(k)].texture or select(3, GetSpellInfo(k)),
					width = "2",
					set = function(_, value)
						if not Gladdy.db.auraListInterrupts[tostring(k)] then
							Gladdy.db.auraListInterrupts[tostring(k)] = {
								enabled = true,
								priority = 0
							}
						end
						Gladdy.db.auraListInterrupts[tostring(k)].enabled = value
					end,
					get = function()
						if not Gladdy.db.auraListInterrupts[tostring(k)] then
							Gladdy.db.auraListInterrupts[tostring(k)] = {
								enabled = true,
								priority = 0
							}
						end
						return Gladdy.db.auraListInterrupts[tostring(k)].enabled
					end
				},
				priority = {
					order = 2,
					name = L["Priority"],
					type = "range",
					min = 0,
					max = 50,
					width = "2",
					step = 1,
					get = function()
						if not Gladdy.db.auraListInterrupts[tostring(k)] then
							Gladdy.db.auraListInterrupts[tostring(k)] = {
								enabled = true,
								priority = 0
							}
						end
						return Gladdy.db.auraListInterrupts[tostring(k)].priority
					end,
					set = function(_, value)
						if not Gladdy.db.auraListInterrupts[tostring(k)] then
							Gladdy.db.auraListInterrupts[tostring(k)] = {
								enabled = true,
								priority = 0
							}
						end
						Gladdy.db.auraListInterrupts[tostring(k)].priority = value
					end,
					width = "full",
				}
			}
		}
	end
	return options
end