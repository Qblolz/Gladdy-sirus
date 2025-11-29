local ceil, str_gsub = ceil, string.gsub

local CreateFrame = CreateFrame
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Racial = Gladdy:NewModule("Racial", 79, {
	racialFont = "DorisPP",
	racialFontScale = 1,
	racialFontEnabled = true,
	racialEnabled = true,
	racialSize = 60 + 20 + 1,
	racialWidthFactor = 0.9,
	racialIconZoomed = false,
	racialXOffset = 0,
	racialYOffset = 0,
	racialBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp", 
	racialBorderColor = { r = 0, g = 0, b = 0, a = 1 },
	racialDisableCircle = false,
	racialCooldownAlpha = 1,
	racialCooldownNumberAlpha = 1,
	racialFrameStrata = "MEDIUM",
	racialFrameLevel = 5,
	racialGroup = false,
	racialGroupDirection = "DOWN",
})

local List_constellations = {
	[1] = 371796, -- Human
	[2] = 371804, -- Scourge
	[3] = 371805, -- Tauren
	[4] = 371788, -- BloodElf
	[5] = 371798, -- Naga
	[6] = 371803, -- Queldo
	[7] = 371802, -- Pandaren
	[8] = 371801, -- Orc
	[9] = 371806, -- Troll
	[10] = 371800, -- NightElf
	[11] = 371791, -- Draenei
	[12] = 371808, -- Vulpera
	[13] = 371794, -- Gnome
	[14] = 371792, -- Dwarf
	[15] = 371809, -- Worgen
	[16] = 371799, -- Nightborne
	[17] = 371807, -- VoidElf
	[18] = 371795, -- Goblin
	[19] = 371789, -- DarkIronDwarf
	[20] = 371793, -- Eredar
	[21] = 371810, -- ZandalariTroll
	[22] = 371797, -- Lightforged
	[22] = 371790, -- Dracthyr
	[23] = "None"
}

function Racial:Initialize()
	self.frames = {}

	if Gladdy.db.racialEnabled then
		self:RegisterMessage("JOINED_ARENA")
		self:RegisterMessage("ENEMY_SPOTTED")
		self:RegisterMessage("RACIAL_USED")
		self:RegisterMessage("TRINKET_USED")
	end
end

function Racial:UpdateFrameOnce()
	if Gladdy.db.racialEnabled then
		self:RegisterMessage("JOINED_ARENA")
		self:RegisterMessage("ENEMY_SPOTTED")
		self:RegisterMessage("RACIAL_USED")
		self:RegisterMessage("TRINKET_USED")
	else
		self:UnregisterAllMessages()
	end
end

function Racial:Reset()
	self:SetScript("OnEvent", nil)
end

function Racial:ResetUnit(unit)
	local racial = self.frames[unit]
	if not racial then return end
	
	racial:SetIcon(nil)
	racial.timeLeft = nil
	racial.active = false
	racial:StopCooldown()
	--racial:UpdateBorder(Gladdy.db.racialBorderStyle, Gladdy.db.racialBorderColor)
end

function Racial:CreateFrame(unit)
	-- Создаем фрейм иконки с помощью утилиты
	local racial = Gladdy:CreateIconFrame(Gladdy.buttons[unit], "GladdyRacialButton" .. unit, {
		frameStrata = Gladdy.db.racialFrameStrata,
		frameLevel = Gladdy.db.racialFrameLevel,
		iconZoomed = Gladdy.db.racialIconZoomed,
		cooldownAlpha = Gladdy.db.racialCooldownAlpha,
		fontAlpha = Gladdy.db.racialCooldownNumberAlpha,
		fontOption = "racialFont",
		fontScale = Gladdy.db.racialFontScale,
		borderStyle = Gladdy.db.racialBorderStyle,
		borderColor = Gladdy.db.racialBorderColor,
		fontEnabled = Gladdy.db.racialFontEnabled,
		disableCircle = Gladdy.db.racialDisableCircle
	})

	-- Устанавливаем размеры
	racial:SetWidth(Gladdy.db.racialSize)
	racial:SetHeight(Gladdy.db.racialSize)

	-- Сохраняем фрейм
	self.frames[unit] = racial
end

function Racial:UpdateFrame(unit)
	local racial = self.frames[unit]
	if not racial then return end

	racial:UpdateConfig({
		frameStrata = Gladdy.db.racialFrameStrata,
		frameLevel = Gladdy.db.racialFrameLevel,
		iconZoomed = Gladdy.db.racialIconZoomed,
		cooldownAlpha = Gladdy.db.racialCooldownAlpha,
		fontAlpha = Gladdy.db.racialCooldownNumberAlpha,
		fontOption = "racialFont",
		fontScale = Gladdy.db.racialFontScale,
		borderStyle = Gladdy.db.racialBorderStyle,
		borderColor = Gladdy.db.racialBorderColor,
		disableCircle = Gladdy.db.racialDisableCircle,
		fontEnabled = Gladdy.db.racialFontEnabled
	})

	-- Обновляем размеры
	local width, height = Gladdy.db.racialSize * Gladdy.db.racialWidthFactor, Gladdy.db.racialSize
	racial:SetWidth(width)
	racial:SetHeight(height)

	-- Обновляем позицию
	if not Gladdy.db.racialGroup or unit == "arena1" then
		Gladdy:SetPosition(racial, unit, "racialXOffset", "racialYOffset", Racial)
	end

	-- Обновляем группировку
	if Gladdy.db.racialGroup then
		if unit ~= "arena1" then
			local previousUnit = "arena" .. str_gsub(unit, "arena", "") - 1
			racial:ClearAllPoints()
			if Gladdy.db.racialGroupDirection == "RIGHT" then
				racial:SetPoint("LEFT", self.frames[previousUnit], "RIGHT", 0, 0)
			elseif Gladdy.db.racialGroupDirection == "LEFT" then
				racial:SetPoint("RIGHT", self.frames[previousUnit], "LEFT", 0, 0)
			elseif Gladdy.db.racialGroupDirection == "UP" then
				racial:SetPoint("BOTTOM", self.frames[previousUnit], "TOP", 0, 0)
			elseif Gladdy.db.racialGroupDirection == "DOWN" then
				racial:SetPoint("TOP", self.frames[previousUnit], "BOTTOM", 0, 0)
			end
		end
	end

	-- Создаем мувер для первой арены
	if unit == "arena1" then
		Gladdy:CreateMover(racial, "racialXOffset", "racialYOffset", L["Racial"],
			{"TOPLEFT", "TOPLEFT"},
			width, height,
			0, 0, "racialEnabled")
	end

	-- Показываем/скрываем в зависимости от настроек
	if Gladdy.db.racialEnabled then
		racial:Show()
	else
		racial:Hide()
	end
end

function Racial:JOINED_ARENA()
	if (not Gladdy.db.racialEnabled) then return end
	
	self:SetScript("OnEvent", function(self, event, ...)
		if self[event] then
			self[event](self, ...)
		end
	end)
end

function Racial:ENEMY_SPOTTED(unit)
	if (not Gladdy.db.racialEnabled) then return end

	local racial = self.frames[unit]
	local constellation = Gladdy.buttons[unit].constellation
	if not racial or not constellation then return end
	
	racial:SetIcon(constellation.icon)
	racial:Show()
end

function Racial:RACIAL_USED(unit, expirationTime, spellId)
	if (not Gladdy.db.racialEnabled) then return end

	local racial = self.frames[unit]
	local button = Gladdy.buttons[unit]
	local constellation = button.constellation
	if (not racial or not button or not button.constellation or not Gladdy.db.racialEnabled) then
		return
	end

	if expirationTime and constellation.id ~= spellId then
		return
	end

	local startTime = expirationTime or GetTime()
	Racial:Used(unit, startTime, constellation.cd)
end

function Racial:TRINKET_USED(unit) -- Wrath only
	if (not Gladdy.db.racialEnabled) then return end

	local racial = self.frames[unit]
	local button = Gladdy.buttons[unit]
	if (not racial or not button or not button.constellation) then
		return
	end
	-- human
	if button.constellation.id == 371796 then
		if racial.active and racial.timeLeft >= 90 then
			-- do nothing
		else
			self:Used(unit, GetTime(), 90)
		end
	--scourge
	elseif button.constellation.id == 371804 then
		if racial.active and racial.timeLeft >= 60 then
			-- do nothing
		else
			self:Used(unit, GetTime(), 60)
		end
	end
end

function Racial:Used(unit, startTime, duration)
	local racial = self.frames[unit]
	if not racial then return end

	if not racial.active then
		racial.timeLeft = duration
		if not Gladdy.db.racialDisableCircle then
			racial.cooldown:SetCooldown(startTime, duration)
		end
		racial.active = true
	end
end

function Racial:Test(unit)
	local button = Gladdy.buttons[unit]
	local constellations = Gladdy:Constellations()
	local rndValue = math.random(#List_constellations - 1)
	button.constellation = constellations[List_constellations[rndValue]]
	
	Racial:ENEMY_SPOTTED(unit)
	
	-- Set up cooldown on some units
	if (unit == "arena2" or unit == "arena3") then
		Gladdy:SendMessage("RACIAL_USED", unit)
	end
end

function Racial:GetOptions()
	return {
		headerRacial = {
			type = "header",
			name = L["Racial"],
			order = 2,
		},
		racialEnabled = Gladdy:option({
			type = "toggle",
			name = L["Enabled"],
			desc = L["Enable racial icon"],
			order = 3,
		}),
		racialGroup = Gladdy:option({
			type = "toggle",
			name = L["Group"] .. " " .. L["Racial"],
			order = 4,
			disabled = function() return not Gladdy.db.racialEnabled end,
		}),
		racialGroupDirection = Gladdy:option({
			type = "select",
			name = L["Group direction"],
			order = 5,
			values = {
				["RIGHT"] = L["Right"],
				["LEFT"] = L["Left"],
				["UP"] = L["Up"],
				["DOWN"] = L["Down"],
			},
			disabled = function()
				return not Gladdy.db.racialGroup or not Gladdy.db.racialEnabled
			end,
		}),
		group = {
			type = "group",
			childGroups = "tree",
			name = L["Frame"],
			order = 6,
			disabled = function() return not Gladdy.db.racialEnabled end,
			args = {
				general = {
					type = "group",
					name = L["Icon"],
					order = 1,
					args = {
						header = {
							type = "header",
							name = L["Icon"],
							order = 1,
						},
						racialIconZoomed = Gladdy:option({
							type = "toggle",
							name = L["Zoomed Icon"],
							desc = L["Zooms the icon to remove borders"],
							order = 2,
							width = "full",
						}),
						racialSize = Gladdy:option({
							type = "range",
							name = L["Icon size"],
							min = 5,
							max = 100,
							step = 1,
							order = 3,
							width = "full",
						}),
						racialWidthFactor = Gladdy:option({
							type = "range",
							name = L["Icon width factor"],
							min = 0.5,
							max = 2,
							step = 0.05,
							order = 4,
							width = "full",
						}),
					},
				},
				cooldown = {
					type = "group",
					name = L["Cooldown"],
					order = 2,
					args = {
						header = {
							type = "header",
							name = L["Cooldown"],
							order = 4,
						},
						racialDisableCircle = Gladdy:option({
							type = "toggle",
							name = L["No Cooldown Circle"],
							order = 7,
							width = "full",
						}),
						racialCooldownAlpha = Gladdy:option({
							type = "range",
							name = L["Cooldown circle alpha"],
							min = 0,
							max = 1,
							step = 0.1,
							order = 8,
							width = "full",
						}),
						racialCooldownNumberAlpha = Gladdy:option({
							type = "range",
							name = L["Cooldown number alpha"],
							min = 0,
							max = 1,
							step = 0.1,
							order = 9,
							width = "full",
						}),
					},
				},
				font = {
					type = "group",
					name = L["Font"],
					order = 3,
					args = {
						header = {
							type = "header",
							name = L["Font"],
							order = 4,
						},
						racialFontEnabled = Gladdy:option({
							type = "toggle",
							name = L["Font Enabled"],
							order = 10,
							width = "full",
						}),
						racialFont = Gladdy:option({
							type = "select",
							name = L["Font"],
							desc = L["Font of the cooldown"],
							order = 11,
							dialogControl = "LSM30_Font",
							values = AceGUIWidgetLSMlists.font,
						}),
						racialFontScale = Gladdy:option({
							type = "range",
							name = L["Font scale"],
							desc = L["Scale of the font"],
							order = 12,
							min = 0.1,
							max = 2,
							step = 0.1,
							width = "full",
						}),
					},
				},
				position = {
					type = "group",
					name = L["Position"],
					order = 5,
					args = {
						header = {
							type = "header",
							name = L["Icon position"],
							order = 4,
						},
						racialXOffset = Gladdy:option({
							type = "range",
							name = L["Horizontal offset"],
							order = 23,
							min = -400,
							max = 400,
							step = 0.1,
							width = "full",
						}),
						racialYOffset = Gladdy:option({
							type = "range",
							name = L["Vertical offset"],
							order = 24,
							min = -400,
							max = 400,
							step = 0.1,
							width = "full",
						}),
					},
				},
				border = {
					type = "group",
					name = L["Border"],
					order = 4,
					args = {
						header = {
							type = "header",
							name = L["Border"],
							order = 4,
						},
						racialBorderStyle = Gladdy:option({
							type = "select",
							name = L["Border style"],
							order = 31,
							values = Gladdy:GetIconStyles()
						}),
						racialBorderColor = Gladdy:colorOption({
							type = "color",
							name = L["Border color"],
							desc = L["Color of the border"],
							order = 32,
							hasAlpha = true,
						}),
					},
				},
				frameStrata = {
					type = "group",
					name = L["Frame Strata and Level"],
					order = 6,
					args = {
						headerAuraLevel = {
							type = "header",
							name = L["Frame Strata and Level"],
							order = 1,
						},
						racialFrameStrata = Gladdy:option({
							type = "select",
							name = L["Frame Strata"],
							order = 2,
							values = Gladdy.frameStrata,
							sorting = Gladdy.frameStrataSorting,
							width = "full",
						}),
						racialFrameLevel = Gladdy:option({
							type = "range",
							name = L["Frame Level"],
							min = 0,
							max = 500,
							step = 1,
							order = 3,
							width = "full",
						}),
					},
				},
			},
		},
	}
end