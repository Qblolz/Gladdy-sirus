local ceil, str_gsub = ceil, string.gsub

local CreateFrame = CreateFrame
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Trinket = Gladdy:NewModule("Trinket", 80, {
	trinketFont = "DorisPP",
	trinketFontScale = 1,
	trinketFontEnabled = true,
	trinketEnabled = true,
	trinketSize = 60 + 20 + 1,
	trinketWidthFactor = 0.9,
	trinketIconZoomed = false,
	trinketBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
	trinketBorderColor = { r = 0, g = 0, b = 0, a = 1 },
	trinketDisableCircle = false,
	trinketCooldownAlpha = 1,
	trinketCooldownNumberAlpha = 1,
	trinketXOffset = 0,
	trinketYOffset = 0,
	trinketFrameStrata = "MEDIUM",
	trinketFrameLevel = 5,
	trinketColored = false,
	trinketColoredCd = { r = 1, g = 0, b = 0, a = 1 }, -- Red when on cooldown
	trinketColoredNoCd = { r = 0, g = 1, b = 0, a = 1 }, -- Green when ready
	trinketGroup = false,
	trinketGroupDirection = "DOWN",
	trinketIcon = select(10, GetItemInfo(51377)),
})

function Trinket:Initialize()
	self.frames = {}
	if Gladdy.db.trinketEnabled then
		self:RegisterMessage("JOINED_ARENA")
		self:RegisterMessage("ENEMY_SPOTTED")
		self:RegisterMessage("TRINKET_USED")
		self:RegisterMessage("RACIAL_USED")
	end
end

function Trinket:UpdateFrameOnce()
	if Gladdy.db.trinketEnabled then
		self:RegisterMessage("JOINED_ARENA")
		self:RegisterMessage("RACIAL_USED")
	else
		self:UnregisterAllMessages()
	end
end

function Trinket:Reset()
	--self:UnregisterEvent("ARENA_COOLDOWNS_UPDATE")
	self:SetScript("OnEvent", nil)
end

function Trinket:ResetUnit(unit)
	local trinket = self.frames[unit]
	if not trinket then return end

	trinket.itemID = nil
	trinket.timeLeft = nil
	trinket.active = false
	trinket:StopCooldown()
end

function Trinket:CreateFrame(unit)
	-- Создаем фрейм иконки с помощью утилиты
	local trinket = Gladdy:CreateIconFrame(Gladdy.buttons[unit], "GladdyTrinketButton" .. unit, {
		frameStrata = Gladdy.db.trinketFrameStrata,
		frameLevel = Gladdy.db.trinketFrameLevel,
		iconZoomed = Gladdy.db.trinketIconZoomed,
		cooldownAlpha = Gladdy.db.trinketCooldownAlpha,
		fontAlpha = Gladdy.db.trinketCooldownNumberAlpha,
		fontOption = "trinketFont",
		fontScale = Gladdy.db.trinketFontScale,
		borderStyle = Gladdy.db.trinketBorderStyle,
		borderColor = Gladdy.db.trinketBorderColor,
		fontEnabled = Gladdy.db.trinketFontEnabled,
		disableCircle = Gladdy.db.trinketDisableCircle,
		hasBackdrop = true,
		backdropTexture = "Interface\\AddOns\\Gladdy\\Images\\trinket",
		trinketColored = Gladdy.db.trinketColored,
		trinketColoredNoCd = Gladdy.db.trinketColoredNoCd
	})

	-- Устанавливаем размеры
	trinket:SetWidth(Gladdy.db.trinketSize)
	trinket:SetHeight(Gladdy.db.trinketSize)

	-- Сохраняем фрейм
	self.frames[unit] = trinket
end

function Trinket:UpdateFrame(unit)
	local trinket = self.frames[unit]
	if not trinket then return end

	trinket:UpdateConfig({
		frameStrata = Gladdy.db.trinketFrameStrata,
		frameLevel = Gladdy.db.trinketFrameLevel,
		iconZoomed = Gladdy.db.trinketIconZoomed,
		cooldownAlpha = Gladdy.db.trinketCooldownAlpha,
		fontAlpha = Gladdy.db.trinketCooldownNumberAlpha,
		fontOption = "trinketFont",
		fontScale = Gladdy.db.trinketFontScale,
		borderStyle = Gladdy.db.trinketBorderStyle,
		borderColor = Gladdy.db.trinketBorderColor,
		fontEnabled = Gladdy.db.trinketFontEnabled,
		disableCircle = Gladdy.db.trinketDisableCircle,
		hasBackdrop = true,
		backdropTexture = "Interface\\AddOns\\Gladdy\\Images\\trinket",
		trinketColored = Gladdy.db.trinketColored,
		trinketColoredNoCd = Gladdy.db.trinketColoredNoCd
	})

	-- Обновляем цвет тринкета
	if Gladdy.db.trinketColored then
		if trinket.active then
			trinket:SetBackdropColor(Gladdy:SetColor(Gladdy.db.trinketColoredCd))
		else
			trinket:SetBackdropColor(Gladdy:SetColor(Gladdy.db.trinketColoredNoCd))
		end
		trinket:SetIcon(nil)
	else
		if Gladdy.db.trinketIcon then
			trinket:SetIcon(Gladdy.db.trinketIcon)
		end
	end

	-- Обновляем размеры
	local width, height = Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor, Gladdy.db.trinketSize
	trinket:SetWidth(width)
	trinket:SetHeight(height)

	-- Обновляем позицию
	if not Gladdy.db.trinketGroup or unit == "arena1" then
		Gladdy:SetPosition(trinket, unit, "trinketXOffset", "trinketYOffset", Trinket)
	end

	-- Обновляем группировку
	if Gladdy.db.trinketGroup then
		if unit ~= "arena1" then
			local previousUnit = "arena" .. str_gsub(unit, "arena", "") - 1
			trinket:ClearAllPoints()
			if Gladdy.db.trinketGroupDirection == "RIGHT" then
				trinket:SetPoint("LEFT", self.frames[previousUnit], "RIGHT", 0, 0)
			elseif Gladdy.db.trinketGroupDirection == "LEFT" then
				trinket:SetPoint("RIGHT", self.frames[previousUnit], "LEFT", 0, 0)
			elseif Gladdy.db.trinketGroupDirection == "UP" then
				trinket:SetPoint("BOTTOM", self.frames[previousUnit], "TOP", 0, 0)
			elseif Gladdy.db.trinketGroupDirection == "DOWN" then
				trinket:SetPoint("TOP", self.frames[previousUnit], "BOTTOM", 0, 0)
			end
		end
	end

	-- Создаем мувер для первой арены
	if unit == "arena1" then
		Gladdy:CreateMover(trinket, "trinketXOffset", "trinketYOffset", L["Trinket"],
			{"TOPLEFT", "TOPLEFT"},
			width, height,
			0, 0, "trinketEnabled")
	end

	-- Показываем/скрываем в зависимости от настроек
	if Gladdy.db.trinketEnabled then
		trinket:Show()
	else
		trinket:Hide()
	end
end

function Trinket:JOINED_ARENA()
	if (not Gladdy.db.trinketEnabled) then return end

	self:SetScript("OnEvent", function(self, event, ...)
		if self[event] then
			self[event](self, ...)
		end
	end)
end

function Trinket:ENEMY_SPOTTED(unit)
	if (not Gladdy.db.trinketEnabled) then return end

	local trinket = self.frames[unit]
	if not trinket then return end
	if Gladdy.db.trinketColored then
		trinket:SetBackdropColor(Gladdy:SetColor(Gladdy.db.trinketColoredNoCd))
		trinket:SetIcon(nil)
	else
		if Gladdy.db.trinketIcon then
			trinket:SetIcon(Gladdy.db.trinketIcon)
		end
	end
	trinket:Show()
end

function Trinket:TRINKET_USED(unit)
	if (not Gladdy.db.trinketEnabled) then return end

	if Gladdy.buttons[unit] then
		-- В Wrath кулдаун тринкета PvP всегда 2 минуты
		self:Used(unit, GetTime() * 1000, 120000)
	end
end

function Trinket:RACIAL_USED(unit) -- Wrath only
	if (not Gladdy.db.trinketEnabled) then return end
	
	local trinket = self.frames[unit]
	local button = Gladdy.buttons[unit]
	if (not trinket or not button or not button.constellation) then
		return
	end

	-- human
	if button.constellation.id == 371796 then
		if trinket.active and trinket.timeLeft >= 90 then
		else
			self:Used(unit, GetTime() * 1000, 90 * 1000)
		end
		--scourge
	elseif button.constellation.id == 371804 then
		if trinket.active and trinket.timeLeft >= 60 then
		else
			self:Used(unit, GetTime() * 1000, 60 * 1000)
		end
	end
end

function Trinket:Used(unit, startTime, duration)
	local trinket = self.frames[unit]
	if (not trinket) then return end
	
	trinket.timeLeft = (startTime/1000.0 + duration/1000.0) - GetTime()
	
	-- Set up cooldown animation
	if not Gladdy.db.trinketDisableCircle then
		trinket.cooldown:SetCooldown(startTime/1000.0, duration/1000.0)
	end
	
	-- Make sure cooldown font is properly configured
	if Gladdy.db.trinketFontEnabled then
		trinket.cooldownFont:SetAlpha(Gladdy.db.trinketCooldownNumberAlpha)
	else
		trinket.cooldownFont:SetText("")
	end
	
	trinket.active = true
	
	-- Обновляем цвет при использовании
	if Gladdy.db.trinketColored then
		trinket:SetBackdropColor(Gladdy:SetColor(Gladdy.db.trinketColoredCd))
	end
end

function Trinket:Test(unit)
	local trinket = self.frames[unit]
	if (not trinket) then return end
	
	if (unit == "arena1" or unit == "arena2") then
		Gladdy:SendMessage("TRINKET_USED", unit)
	end
end

function Trinket:GetOptions()
	return {
		headerTrinket = {
			type = "header",
			name = L["Trinket"],
			order = 2,
		},
		trinketEnabled = Gladdy:option({
			type = "toggle",
			name = L["Enabled"],
			desc = L["Enable trinket icon"],
			order = 3,
		}),
		trinketColored = Gladdy:option({
			type = "toggle",
			name = L["Colored trinket"],
			desc = L["Shows a solid colored icon when off/off CD."],
			order = 4,
			disabled = function() return not Gladdy.db.trinketEnabled end,
		}),
		trinketColoredCd = Gladdy:colorOption({
			type = "color",
			name = L["Colored trinket CD"],
			desc = L["Color of the border"],
			order = 5,
			hasAlpha = true,
			disabled = function() return not Gladdy.db.trinketEnabled end,
		}),
		trinketColoredNoCd = Gladdy:colorOption({
			type = "color",
			name = L["Colored trinket No CD"],
			desc = L["Color of the border"],
			order = 6,
			hasAlpha = true,
			disabled = function() return not Gladdy.db.trinketEnabled end,
		}),
		trinketGroup = Gladdy:option({
			type = "toggle",
			name = L["Group"] .. " " .. L["Trinket"],
			order = 7,
			disabled = function() return not Gladdy.db.trinketEnabled end,
		}),
		trinketGroupDirection = Gladdy:option({
			type = "select",
			name = L["Group direction"],
			order = 8,
			values = {
				["RIGHT"] = L["Right"],
				["LEFT"] = L["Left"],
				["UP"] = L["Up"],
				["DOWN"] = L["Down"],
			},
			disabled = function()
				return not Gladdy.db.trinketGroup or not Gladdy.db.trinketEnabled
			end,
		}),
		group = {
			type = "group",
			childGroups = "tree",
			name = L["Frame"],
			order = 5,
			disabled = function() return not Gladdy.db.trinketEnabled end,
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
						trinketIconZoomed = Gladdy:option({
							type = "toggle",
							name = L["Zoomed Icon"],
							desc = L["Zooms the icon to remove borders"],
							order = 2,
							width = "full",
						}),
						trinketSize = Gladdy:option({
							type = "range",
							name = L["Icon size"],
							min = 5,
							max = 100,
							step = 1,
							order = 3,
							width = "full",
						}),
						trinketWidthFactor = Gladdy:option({
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
						trinketDisableCircle = Gladdy:option({
							type = "toggle",
							name = L["No Cooldown Circle"],
							order = 7,
							width = "full",
						}),
						trinketCooldownAlpha = Gladdy:option({
							type = "range",
							name = L["Cooldown circle alpha"],
							min = 0,
							max = 1,
							step = 0.1,
							order = 8,
							width = "full",
						}),
						trinketCooldownNumberAlpha = Gladdy:option({
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
						trinketFontEnabled = Gladdy:option({
							type = "toggle",
							name = L["Font Enabled"],
							order = 10,
							width = "full",
						}),
						trinketFont = Gladdy:option({
							type = "select",
							name = L["Font"],
							desc = L["Font of the cooldown"],
							order = 11,
							dialogControl = "LSM30_Font",
							values = AceGUIWidgetLSMlists.font,
						}),
						trinketFontScale = Gladdy:option({
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
						trinketXOffset = Gladdy:option({
							type = "range",
							name = L["Horizontal offset"],
							order = 23,
							min = -400,
							max = 400,
							step = 0.1,
							width = "full",
						}),
						trinketYOffset = Gladdy:option({
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
						trinketBorderStyle = Gladdy:option({
							type = "select",
							name = L["Border style"],
							order = 31,
							values = Gladdy:GetIconStyles()
						}),
						trinketBorderColor = Gladdy:colorOption({
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
						trinketFrameStrata = Gladdy:option({
							type = "select",
							name = L["Frame Strata"],
							order = 2,
							values = Gladdy.frameStrata,
							sorting = Gladdy.frameStrataSorting,
							width = "full",
						}),
						trinketFrameLevel = Gladdy:option({
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