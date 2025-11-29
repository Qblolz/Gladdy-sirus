local pairs, ipairs = pairs, ipairs
local select = select
local type = type
local floor = math.floor
local str_find, str_gsub, str_sub, str_format = string.find, string.gsub, string.sub, string.format
local tinsert = table.insert
local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AuraUtil = AuraUtil
local GetSpellInfo = GetSpellInfo
local UnitIsUnit = UnitIsUnit

---------------------------

-- TAGS

---------------------------

local tags = {
    ["current"] = true,
    ["max"] = true,
    ["percent"] = true,
    ["race"] = "race",
    ["class"] = "class",
    ["arena"] = true,
    ["name"] = "name",
    ["status"] = true,
    ["spec"] = "spec",
}

local function str_extract(s, pattern)
    local t = {} -- table to store the indices
    local i, j = 0,0
    while true do
        i, j = str_find(s, pattern, i+1) -- find 'next' occurrence
        if i == nil then break end
        tinsert(t, str_sub(s, i, j))
    end
    return t
end

--TODO optimize this function as it's being called often!
local function getTagText(unit, tag, current, max, status)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end

    if str_find(tag, "percent") then
        return current and max and floor(current * 100 / max) .. "%%" or ""
    elseif str_find(tag, "current") then
        return current and max > 999 and ("%.1fk"):format(current / 1000) or current or ""
    elseif str_find(tag, "max") then
        return max and max > 999 and ("%.1fk"):format(max / 1000) or max or ""
    elseif str_find(tag, "status") then
        if str_find(tag, "%|") and status == nil then
            return nil
        else
            return status or ""
        end
    elseif str_find(tag, "name") then
        return button.name or ""
    elseif str_find(tag, "class") then
        return button.classLoc or ""
    elseif str_find(tag, "race") then
        return button.raceLoc or ""
    elseif str_find(tag, "arena") then
        local str,found = str_gsub(unit, "arena", "")
        return found == 1 and str or ""
    elseif str_find(tag, "spec") then
        if str_find(tag, "%|") and button.spec == nil then
            return nil
        else
            return button.spec or ""
        end
    end
end

function Gladdy:SetTag(unit, tagOption, current, max, status)
    local button = self.buttons[unit]
    if not button then
        return
    end

    local returnStr = tagOption

    local t = str_extract(returnStr, "%[[^%[].-%]")
    for _, tag in ipairs(t) do
        local replace
        if str_find(tag, "|") then -- or operator
            local indicators = str_extract(tag, "[%[|%|]%a+[%||%]]")
            local replaces = {}
            for _, indicator in ipairs(indicators) do
                tinsert(replaces, getTagText(unit, indicator, current, max, status))
            end
            replace = replaces[#replaces]
        else
            replace = getTagText(unit, tag, current, max, status)
        end

        if replace then
            local find = str_gsub(tag, "%[", "%%[")
            find = str_gsub(find, "%]", "%%]")
            find = str_gsub(find, "%|", "%%|")
            returnStr = str_gsub(returnStr, find, replace)
        end
    end
    return returnStr
end

function Gladdy:GetTagOption(name, order, enabledOption, func, toggle)
    if toggle then
        return func({
            type = "toggle",
            name = name,
            order = order,
            width = "full",
            desc = L["Custom Tags:\n"..
                    "\n|cff1ac742[current]|r - Shows current\n" ..
                    "\n|cff1ac742[max]|r - Shows max\n" ..
                    "\n|cff1ac742[percent]|r - Shows percent\n" ..
                    "\n|cff1ac742[name]|r - Shows name\n" ..
                    "\n|cff1ac742[arena]|r - Shows arena number\n" ..
                    "\n|cff1ac742[status]|r - Shows status (eg DEATH)\n" ..
                    "\n|cff1ac742[race]|r - Shows race\n" ..
                    "\n|cff1ac742[class]|r - Shows class\n" ..
                    "\n|cff1ac742[spec]|r - Shows spec\n\n" ..
                    "Can be combined with OR operator like |cff1ac742[percent|status]|r. The last valid option will be used.\n"],
        })
    else
        return func({
            type = "input",
            name = name,
            order = order,
            width = "full",
            disabled = function() return not Gladdy.db[enabledOption] end,
            desc = L["Custom Tags:\n"..
                    "\n|cff1ac742[current]|r - Shows current\n" ..
                    "\n|cff1ac742[max]|r - Shows max\n" ..
                    "\n|cff1ac742[percent]|r - Shows percent\n" ..
                    "\n|cff1ac742[name]|r - Shows name\n" ..
                    "\n|cff1ac742[arena]|r - Shows arena number\n" ..
                    "\n|cff1ac742[status]|r - Shows status (eg DEATH)\n" ..
                    "\n|cff1ac742[race]|r - Shows race\n" ..
                    "\n|cff1ac742[class]|r - Shows class\n" ..
                    "\n|cff1ac742[spec]|r - Shows spec\n\n" ..
                    "Can be combined with OR operator like |cff1ac742[percent|status]|r. The last valid option will be used.\n"],
        })
    end
end

function Gladdy:contains(entry, list)
    for _,v in pairs(list) do
        if entry == v then
            return true
        end
    end
    return false
end

local feignDeath = GetSpellInfo(5384)
function Gladdy:isFeignDeath(unit)
    return AuraUtil.FindAuraByName(feignDeath, unit)
end

function Gladdy:GetArenaUnit(unitCaster, unify)
    if unitCaster then
        for i=1,5 do
            local arenaUnit = "arena" .. i
            local arenaUnitPet = "arenapet" .. i
            if unify then
                if unitCaster and (UnitIsUnit(arenaUnit, unitCaster) or UnitIsUnit(arenaUnitPet, unitCaster)) then
                    return arenaUnit
                end
            else
                if unitCaster and UnitIsUnit(arenaUnit, unitCaster) then
                    return arenaUnit
                end
                if unitCaster and UnitIsUnit(arenaUnitPet, unitCaster) then
                    return arenaUnitPet
                end
            end
        end
    end
end

function Gladdy:ShallowCopy(table)
    local copy
    if type(table) == 'table' then
        copy = {}
        for k,v in pairs(table) do
            copy[k] = v
        end
    else -- number, string, boolean, etc
        copy = table
    end
    return copy
end

function Gladdy:DeepCopy(table)
    local copy
    if type(table) == 'table' then
        copy = {}
        for k,v in pairs(table) do
            if type(v) == 'table' then
                copy[k] = self:DeepCopy(v)
            else -- number, string, boolean, etc
                copy[k] = v
            end
        end
    else -- number, string, boolean, etc
        copy = table
    end
    return copy
end

function Gladdy:AddEntriesToTable(table, entries)
    for k,v in pairs(entries) do
        if not table[k] then
            table[k] = v
        end
    end
end

function Gladdy:GetExceptionSpellName(spellID)
    for k,v in pairs(Gladdy.exceptionNames) do
        if k == spellID and Gladdy:GetImportantAuras()[v] and Gladdy:GetImportantAuras()[v].altName then
            return Gladdy:GetImportantAuras()[v].altName
        end
    end
    return select(1, GetSpellInfo(spellID))
end

local function toHex(color)
    if not color or not color.r or not color.g or not color.b then
        return "000000"
    end
    return str_format("%.2x%.2x%.2x", floor(color.r * 255), floor(color.g * 255), floor(color.b * 255))
end
function Gladdy:SetTextColor(text, color)
    return "|cff" .. toHex(color) .. text or "" .. "|r"
end

function Gladdy:ColorAsArray(color)
    return {color.r, color.g, color.b, color.a}
end

function Gladdy:Dump(table, space)
    if type(table) ~= "table" then
        return
    end
    if not space then
        space = ""
    end
    for k,v in pairs(table) do
        Gladdy:Print(space .. k .. " - ", v)
        if type(v) == "table" then
            Gladdy:Dump(v, space .. " ")
        end
    end
end

-- Safely clear a cooldown frame, working in WoW 3.3.5 where some methods might be missing
function Gladdy:SafeCooldownClear(cooldown)
    if not cooldown then return end
    
    -- First try the Clear method if it exists
    if cooldown.Clear then
        cooldown:Clear()
        return
    end
    
    -- Fallback methods
    cooldown:Hide()
    cooldown:Show()
    -- Set a 0-duration cooldown as another way to clear it
    if cooldown.SetCooldown then
        cooldown:SetCooldown(0, 0)
    end
end

function Gladdy:CreateIconFrame(parent, name, config)
    local frame = CreateFrame("Button", name, parent)
    frame:EnableMouse(false)
    frame:SetFrameStrata(config.frameStrata)
    frame:SetFrameLevel(config.frameLevel)
    
    -- Создаем текстуру для иконки
    frame.texture = frame:CreateTexture(nil, "BACKGROUND")
    frame.texture:SetAllPoints(frame)
    
    -- Применяем настройки зума
    if config.iconZoomed then
        frame.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    else
        frame.texture:SetTexCoord(0, 1, 0, 1)
    end
    
    -- Создаем бэкдроп только если указано
    if config.hasBackdrop then
        frame:SetBackdrop({
            bgFile = config.backdropTexture,
        })
        frame:SetBackdropColor(0, 0, 0, 0)
    end
    
    -- Создаем фрейм кулдауна
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints(frame)
    frame.cooldown.noCooldownCount = true
    frame.cooldown:SetFrameStrata(config.frameStrata)
    frame.cooldown:SetFrameLevel(config.frameLevel + 1)
    frame.cooldown:SetDrawEdge(true)
    frame.cooldown:SetAlpha(config.cooldownAlpha)
    frame.cooldown:SetScript("OnShow", function() frame.active = true end)
    frame.cooldown:SetScript("OnHide", function() frame.active = false end)
    
    -- Создаем фрейм для текста кулдауна
    frame.cooldownFrame = CreateFrame("Frame", nil, frame)
    frame.cooldownFrame:SetAllPoints(frame)
    frame.cooldownFrame:SetFrameStrata(config.frameStrata)
    frame.cooldownFrame:SetFrameLevel(config.frameLevel + 2)
    
    -- Создаем текст кулдауна
    frame.cooldownFont = frame.cooldownFrame:CreateFontString(nil, "OVERLAY")
    frame.cooldownFont:SetFont(self:SMFetch("font", config.fontOption), 20, "OUTLINE")
    frame.cooldownFont:SetJustifyH("CENTER")
    frame.cooldownFont:SetPoint("CENTER")
    frame.cooldownFont:SetAlpha(config.fontAlpha)
    
    -- Создаем рамку
    frame.borderFrame = CreateFrame("Frame", nil, frame)
    frame.borderFrame:SetAllPoints(frame)
    frame.borderFrame:SetFrameStrata(config.frameStrata)
    frame.borderFrame:SetFrameLevel(config.frameLevel + 3)
    
    -- Создаем текстуру рамки
    frame.texture.overlay = frame.borderFrame:CreateTexture(nil, "OVERLAY")
    frame.texture.overlay:SetAllPoints(frame)
    frame.texture.overlay:Hide()
    
    -- Устанавливаем рамку если указана
    if config.borderStyle and config.borderStyle ~= "None" then
        frame.texture.overlay:SetTexture(config.borderStyle)
        if config.borderColor then
            local r, g, b, a = self:SetColor(config.borderColor)
            frame.texture.overlay:SetVertexColor(r, g, b, a)
        end
        frame.texture.overlay:Show()
    end
    
    -- Добавляем стандартный таймер обновления
    frame:SetScript("OnUpdate", function(self, elapsed)
        if not self.active then return end
        
        if self and self.timeLeft and self.timeLeft <= 0 then
            self.active = false
            self:StopCooldown()

            if self.cooldownFont then
                self.cooldownFont:SetText("")
            end
            -- Сбрасываем бэкдроп при окончании кулдауна
            if config.hasBackdrop then
                Gladdy:SendMessage("TRINKET_READY", self.unit)
                if config.trinketColored then
                    self:SetBackdropColor(Gladdy:SetColor(config.trinketColoredNoCd))
                else
                    self:SetBackdropColor(0, 0, 0, 0)
                end
            end
        else
            self.timeLeft = self.timeLeft - elapsed
        end

        if not self.cooldownFont or not config.fontEnabled then return end
        
        local timeLeft = self.timeLeft
        local width = self:GetWidth()
        
        -- Специальная обработка для минут
        if timeLeft > 60 then
            self.cooldownFont:SetTextColor(1, 1, 0, config.fontAlpha)
            self.cooldownFont:SetFont(Gladdy:SMFetch("font", config.fontOption), 
                (width/2 - 0.15*width) * (config.fontScale), "OUTLINE")
        elseif timeLeft >= 30 then
            self.cooldownFont:SetTextColor(1, 1, 0, config.fontAlpha)
            self.cooldownFont:SetFont(Gladdy:SMFetch("font", config.fontOption), 
                (width/2 - 1) * (config.fontScale), "OUTLINE")
        elseif timeLeft >= 11 then
            self.cooldownFont:SetTextColor(1, 0.7, 0, config.fontAlpha)
            self.cooldownFont:SetFont(Gladdy:SMFetch("font", config.fontOption), 
                (width/2 - 1) * (config.fontScale), "OUTLINE")
        elseif timeLeft >= 5 then
            self.cooldownFont:SetTextColor(1, 0.7, 0, config.fontAlpha)
            self.cooldownFont:SetFont(Gladdy:SMFetch("font", config.fontOption), 
                (width/2 - 1) * (config.fontScale), "OUTLINE")
        else
            self.cooldownFont:SetTextColor(1, 0, 0, config.fontAlpha)
            self.cooldownFont:SetFont(Gladdy:SMFetch("font", config.fontOption), 
                (width/2 - 1) * (config.fontScale), "OUTLINE")
        end
        
        Gladdy:FormatTimer(self.cooldownFont, timeLeft, timeLeft < 10, true)
    end)
    
    -- Добавляем метод обновления конфига
    function frame:UpdateConfig(newConfig)
        -- Обновляем настройки фрейма
        self:SetFrameStrata(newConfig.frameStrata)
        self:SetFrameLevel(newConfig.frameLevel)
        
        -- Обновляем кулдаун
        self.cooldown:SetFrameStrata(newConfig.frameStrata)
        self.cooldown:SetFrameLevel((newConfig.frameLevel) + 1)
        
        -- Обрабатываем опцию отключения круга
        if self.active then
            if newConfig.disableCircle then
                self.cooldown:SetAlpha(0)
            else
                self.cooldown:SetAlpha(newConfig.cooldownAlpha)
            end
        end
        
        -- Обновляем фрейм текста кулдауна
        self.cooldownFrame:SetFrameStrata(newConfig.frameStrata or "MEDIUM")
        self.cooldownFrame:SetFrameLevel((newConfig.frameLevel or 5) + 2)
        
        -- Обрабатываем опцию включения шрифта
        if newConfig.fontEnabled then
            self.cooldownFont:SetAlpha(newConfig.fontAlpha or 1)
        else
            self.cooldownFont:SetAlpha(0)
            self.cooldownFont:SetText("")
        end
        
        -- Обновляем рамку
        self.borderFrame:SetFrameStrata(newConfig.frameStrata or "MEDIUM")
        self.borderFrame:SetFrameLevel((newConfig.frameLevel or 5) + 3)
        
        -- Обновляем текстуру
        if newConfig.iconZoomed then
            self.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        else
            self.texture:SetTexCoord(0, 1, 0, 1)
        end
        
        -- Обновляем рамку
        self:UpdateBorder(newConfig.borderStyle, newConfig.borderColor)
        
        -- Сохраняем новый конфиг для использования в OnUpdate
        config = newConfig
    end
    
    function frame:StopCooldown()
        if self.cooldown then
            self.cooldown:SetCooldown(0, 0)
            self.cooldown:Hide()
        end
    
        if self.cooldownFont then
            self.cooldownFont:SetText("")
        end
    end
    
    function frame:SetIcon(texture)
        if texture then
            self.texture:SetTexture(texture)
        else
            self.texture:SetTexture("")
        end
    end
    
    function frame:UpdateBorder(borderStyle, borderColor)
        if not borderStyle or borderStyle == "None" then
            self.texture.overlay:Hide()
        else
            self.texture.overlay:SetTexture(borderStyle)
            if borderColor then
                local r, g, b, a = Gladdy:SetColor(borderColor)
                self.texture.overlay:SetVertexColor(r, g, b, a)
            end
            self.texture.overlay:Show()
        end
    end
    
    return frame
end

function Gladdy:CreateSomeFrame(parent, name, config)
    local frame = CreateFrame("Frame", name, parent)
    frame:EnableMouse(false)
    frame:SetFrameStrata(config.frameStrata)
    frame:SetFrameLevel(config.frameLevel)
    
    -- Создаем внутренний фрейм
    frame.frame = CreateFrame("Frame", nil, frame)
    frame.frame:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.frame:EnableMouse(false)
    frame.frame:SetFrameStrata(config.frameStrata)
    frame.frame:SetFrameLevel(config.frameLevel)
    
    -- Создаем фрейм кулдауна
    frame.cooldown = CreateFrame("Cooldown", nil, frame.frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints(frame.frame)
    frame.cooldown.noCooldownCount = true
    frame.cooldown:SetFrameStrata(config.frameStrata)
    frame.cooldown:SetFrameLevel(config.frameLevel + 1)
    frame.cooldown:SetReverse(true)
    frame.cooldown:SetDrawEdge(true)
    frame.cooldown:SetAlpha(config.cooldownAlpha)
    frame.cooldown:SetScript("OnShow", function() frame.active = true end)
    frame.cooldown:SetScript("OnHide", function() frame.active = false end)
    
    -- Создаем фрейм для текста кулдауна
    frame.cooldownFrame = CreateFrame("Frame", nil, frame.frame)
    frame.cooldownFrame:SetAllPoints(frame.frame)
    frame.cooldownFrame:SetFrameStrata(config.frameStrata)
    frame.cooldownFrame:SetFrameLevel(config.frameLevel + 2)

    -- Создаем текстуру для иконки
    frame.icon = frame.frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:SetAllPoints(frame.frame)
        
    -- Применяем настройки зума
    if config.iconZoomed then
        frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    else
        frame.icon:SetTexCoord(0, 1, 0, 1)
    end

    -- Создаем текстуру рамки
    frame.icon.overlay = frame.cooldownFrame:CreateTexture(nil, "OVERLAY")
    frame.icon.overlay:SetAllPoints(frame)
    frame.icon.overlay:Hide()

    -- Устанавливаем рамку если указана
    if config.borderStyle and config.borderStyle ~= "None" then
        frame.icon.overlay:SetTexture(config.borderStyle)
        if config.borderColor then
            local r, g, b, a = Gladdy:SetColor(config.borderColor)
            frame.icon.overlay:SetVertexColor(r, g, b, a)
        end
        frame.icon.overlay:Show()
    end
    
    -- Создаем текст кулдауна
    frame.text = frame.cooldownFrame:CreateFontString(nil, "OVERLAY")
    frame.text:SetFont(self:SMFetch("font", config.fontOption), 10, "OUTLINE")
    frame.text:SetJustifyH("CENTER")
    frame.text:SetPoint("CENTER")
    frame.text:SetAlpha(config.fontAlpha)
    frame.unit = config.unit
    
    -- Добавляем стандартный таймер обновления
    if config.type == "aura" then
        local specialSpells = config.specialSpells or {}
        frame:SetScript("OnUpdate", function(self, elapsed)
            if (self.active) then 
                if (not config.interruptDetached and not config.detached and self.interruptFrame.priority and self.priority < self.interruptFrame.priority) then
                    self.frame:SetAlpha(0.001)
                else
                    self.frame:SetAlpha(1)
                end
                
                if self.timeLeft <= 0 then
                    Gladdy.modules["Auras"]:AURA_FADE(self.unit, self.track, true)
                else
                    if specialSpells[self:GetSpellID()] then
                        self.text:SetText("")
                    else
                        Gladdy:FormatTimer(self.text, self.timeLeft, self.timeLeft < 10)
                    end
                    self.timeLeft = self.timeLeft - elapsed
                end
            else
                self.frame:SetAlpha(0.001)
            end
        end)
    elseif config.type == "interrupt" then
        frame:SetScript("OnUpdate", function(self, elapsed)
            if (self.active) then
                if (not config.interruptDetached and Gladdy.modules["Auras"].frames[self.unit].priority and self.priority <= Gladdy.modules["Auras"].frames[self.unit].priority) then
                    self.frame:SetAlpha(0.001)
                else
                    self.frame:SetAlpha(1)
                end
                if (self.timeLeft <= 0) then
                    self.active = false
                    self.priority = nil
                    self.spellSchool = nil
                    self:StopCooldown()
                    self.frame:SetAlpha(0.001)
                else
                    self.timeLeft = self.timeLeft - elapsed
                    Gladdy:FormatTimer(self.text, self.timeLeft, self.timeLeft < 10)
                end
            else
                self.priority = nil
                self.spellSchool = nil
                self.frame:SetAlpha(0.001)
            end
        end)
    end
    
    -- Добавляем метод получения spellID
    function frame:GetSpellID()
        return self.spellID
    end
    
    -- Добавляем метод обновления конфига
    function frame:UpdateConfig(newConfig)

        if newConfig.detached then
            -- Обновляем настройки фрейма
            self:SetFrameStrata(newConfig.frameStrata)
            self:SetFrameLevel(newConfig.frameLevel)
            -- Обновляем внутренний фрейм
            self.frame:SetFrameStrata(newConfig.frameStrata)
            self.frame:SetFrameLevel(newConfig.frameLevel)
            -- Обновляем кулдаун
            self.cooldown:SetFrameStrata(newConfig.frameStrata)
            self.cooldown:SetFrameLevel(newConfig.frameLevel + 1)
            self.cooldownFrame:SetFrameStrata(newConfig.frameStrata)
            self.cooldownFrame:SetFrameLevel(newConfig.frameLevel + 2)
        else
            self:SetFrameStrata(Gladdy.db.auraFrameStrata)
            self:SetFrameLevel(Gladdy.db.auraFrameLevel + 1)
            self.frame:SetFrameStrata(Gladdy.db.auraFrameStrata)
            self.frame:SetFrameLevel(Gladdy.db.auraFrameLevel + 1)
            self.cooldown:SetFrameStrata(Gladdy.db.auraFrameStrata)
            self.cooldown:SetFrameLevel(Gladdy.db.auraFrameLevel + 2)
            self.cooldownFrame:SetFrameStrata(Gladdy.db.auraFrameStrata)
            self.cooldownFrame:SetFrameLevel(Gladdy.db.auraFrameLevel + 3)
        end
        
        -- Обрабатываем опцию отключения круга
        if self.active then
            if newConfig.disableCircle then
                self.cooldown:SetAlpha(0)
            else
                self.cooldown:SetAlpha(newConfig.cooldownAlpha)
            end
        end
        
        -- Обрабатываем опцию включения шрифта
        if newConfig.fontEnabled then
            self.text:SetAlpha(newConfig.fontAlpha)
        else
            self.text:SetAlpha(0)
            self.text:SetText("")
        end
        
        -- Обновляем текстуру
        if newConfig.iconZoomed then
            self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        else
            self.icon:SetTexCoord(0, 1, 0, 1)
        end
        
        -- Обновляем рамку
        self:UpdateBorder(newConfig.borderStyle, newConfig.borderColor)
        
        -- Сохраняем новый конфиг для использования в OnUpdate
        config = newConfig
    end
    
    function frame:StopCooldown()
        if self.cooldown then
            self.cooldown:SetCooldown(0, 0)
            self.cooldown:Hide()
        end

        if self.cooldownFont then
            self.cooldownFont:SetText("")
        end
    end
    
    function frame:SetIcon(texture)
        if texture then
            self.icon:SetTexture(texture)
        else
            self.icon:SetTexture("")
        end
    end
    
    function frame:UpdateBorder(borderStyle, borderColor)
        if not borderStyle or borderStyle == "None" then
            self.icon.overlay:Hide()
        else
            self.icon.overlay:SetTexture(borderStyle)
            if borderColor then
                local r, g, b, a = Gladdy:SetColor(borderColor)
                self.icon.overlay:SetVertexColor(r, g, b, a)
            end
            self.icon.overlay:Show()
        end
    end
    
    return frame
end