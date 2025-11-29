local select, str_gsub = select, string.gsub

local Gladdy = LibStub("Gladdy")
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local L = Gladdy.L
local Classicon = Gladdy:NewModule("Class Icon", 81, {
    classIconEnabled = true,
    classIconSize = 60 + 20 + 1,
    classIconWidthFactor = 0.9,
    classIconZoomed = false, -- Use zoomed approach which works more reliably
    classIconBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    classIconBorderColor = { r = 0, g = 0, b = 0, a = 1 },  -- Changed to white for better visibility
    classIconSpecIcon = false,
    classIconXOffset = 0,
    classIconYOffset = 0,
    classIconFrameStrata = "MEDIUM",
    classIconFrameLevel = 5,
    classIconGroup = false,
    classIconGroupDirection = "DOWN"
})

local classIconPath = "Interface\\Addons\\Gladdy\\Images\\Classes\\"
local classIcons = {
    ["DRUID"] = classIconPath .. "inv_misc_monsterclaw_04",
    ["DEATHKNIGHT"] = select(3, GetSpellInfo(49023)), --Might of Mograine
    ["HUNTER"] = classIconPath .. "inv_weapon_bow_07",
    ["MAGE"] = classIconPath .. "inv_staff_13",
    ["PALADIN"] = classIconPath .. "inv_hammer_01",
    ["PRIEST"] = classIconPath .. "inv_staff_30",
    ["ROGUE"] = classIconPath .. "inv_throwingknife_04",
    ["SHAMAN"] = classIconPath .. "inv_jewelry_talisman_04",
    ["WARLOCK"] = classIconPath .. "spell_nature_drowsy",
    ["WARRIOR"] = classIconPath .. "inv_sword_27",
}

local specIcons = {
    --DRUID
    ["DRUID"] = {
        [L["Balance"]] = select(3, GetSpellInfo(8921)), -- Moonfire
        [L["Feral"]] = select(3, GetSpellInfo(27545)), -- Cat Form
        [L["Restoration"]] = select(3, GetSpellInfo(5185)), -- Healing Touch
    },
    ["DEATHKNIGHT"] = {
        [L["Unholy"]] = select(3, GetSpellInfo(48265)), -- Unholy Presence
        [L["Blood"]] = select(3, GetSpellInfo(48266)), -- Blood Presence
        [L["Frost"]] = select(3, GetSpellInfo(48263)), -- Frost Presence
    },
    ["HUNTER"] = {
        [L["Beast Mastery"]] = select(3, GetSpellInfo(1515)), -- Tame Beast
        [L["Marksmanship"]] = select(3, GetSpellInfo(42243)), -- Volley
        [L["Survival"]] = select(3, GetSpellInfo(1495)), -- Mongoose Bite
    },
    ["MAGE"] = {
        [L["Arcane"]] = select(3, GetSpellInfo(1459)), -- Arcane Intellect
        [L["Fire"]] = select(3, GetSpellInfo(133)), -- Fireball
        [L["Frost"]] = select(3, GetSpellInfo(116)), -- Frostbolt
    },
    ["PALADIN"] = {
        [L["Holy"]] = select(3, GetSpellInfo(635)), -- Holy Light
        [L["Retribution"]] = select(3, GetSpellInfo(7294)), -- Retribution Aura
        [L["Protection"]] = select(3, GetSpellInfo(32828)), -- Protection Aura
    },
    ["PRIEST"] = {
        [L["Discipline"]] = select(3, GetSpellInfo(1243)), -- Power Word: Fortitude
        [L["Shadow"]] = select(3, GetSpellInfo(589)), -- Shadow Word: Pain
        [L["Holy"]] = select(3, GetSpellInfo(635)), -- Holy Light
    },
    ["ROGUE"] = {
        [L["Assassination"]] = select(3, GetSpellInfo(1329)), -- Mutilate (Eviscerate? 2098)
        [L["Combat"]] = select(3, GetSpellInfo(53)), -- Backstab
        [L["Subtlety"]] = select(3, GetSpellInfo(1784)), -- Stealth
    },
    ["SHAMAN"] = {
        [L["Elemental"]] = select(3, GetSpellInfo(403)), -- Lightning Bolt
        [L["Enhancement"]] = select(3, GetSpellInfo(324)), -- Lightning Shield
        [L["Restoration"]] = select(3, GetSpellInfo(331)), -- Healing Wave
    },
    ["WARLOCK"] = {
        [L["Affliction"]] = select(3, GetSpellInfo(6789)), -- Affliction
        [L["Demonology"]] = select(3, GetSpellInfo(5500)), -- Sense Demons
        [L["Destruction"]] = select(3, GetSpellInfo(5740)), -- Rain of Fire
    },
    ["WARRIOR"] = {
        [L["Arms"]] = select(3, GetSpellInfo(12294)), -- Mortal Strike
        [L["Fury"]] = select(3, GetSpellInfo(12325)), -- Inner Rage
        [L["Protection"]] = select(3, GetSpellInfo(71)), -- Defensive Stance
    },
}

function Classicon:Initialize()
    self.frames = {}

    if Gladdy.db.classIconEnabled then
        self:RegisterMessage("ENEMY_SPOTTED")
        self:RegisterMessage("UNIT_DEATH")
        self:RegisterMessage("UNIT_SPEC")
    end
end

function Classicon:UpdateFrameOnce()
    if Gladdy.db.classIconEnabled then
        self:RegisterMessage("ENEMY_SPOTTED")
        self:RegisterMessage("UNIT_DEATH")
        self:RegisterMessage("UNIT_SPEC")
    else
        self:UnregisterAllMessages()
    end
end

function Classicon:ResetUnit(unit)
    local classIcon = self.frames[unit]
    if (not classIcon) then
        return
    end

    classIcon.texture:SetTexture("")
end

function Classicon:CreateFrame(unit)
    local classIcon = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    classIcon:EnableMouse(false)
    classIcon:SetFrameStrata(Gladdy.db.classIconFrameStrata)
    classIcon:SetFrameLevel(Gladdy.db.classIconFrameLevel)

    classIcon.texture = classIcon:CreateTexture(nil, "BACKGROUND")
    classIcon.texture:SetAllPoints(classIcon)

    classIcon.texture.overlay = classIcon:CreateTexture(nil, "BORDER")
    classIcon.texture.overlay:SetAllPoints(classIcon)
    classIcon.texture.overlay:SetTexture(Gladdy.db.classIconBorderStyle)

    Gladdy.buttons[unit].classIcon = classIcon
    self.frames[unit] = classIcon
end

function Classicon:UpdateFrame(unit)
    local classIcon = self.frames[unit]
    if not classIcon then return end

    classIcon:SetFrameStrata(Gladdy.db.classIconFrameStrata)
    classIcon:SetFrameLevel(Gladdy.db.classIconFrameLevel)

    -- Обновляем размеры
    local width, height = Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor, Gladdy.db.classIconSize
    classIcon:SetWidth(width)
    classIcon:SetHeight(height)

    -- Применяем текстурные координаты
    if Gladdy.db.classIconZoomed then
        classIcon.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    else
        classIcon.texture:SetTexCoord(0, 1, 0, 1)
    end

    -- Обновляем позицию
    if not Gladdy.db.classIconGroup or unit == "arena1" then
        Gladdy:SetPosition(classIcon, unit, "classIconXOffset", "classIconYOffset", Classicon)
    end

    -- Обновляем группировку
    if Gladdy.db.classIconGroup then
        if unit ~= "arena1" then
            local previousUnit = "arena" .. str_gsub(unit, "arena", "") - 1
            classIcon:ClearAllPoints()
            if Gladdy.db.classIconGroupDirection == "RIGHT" then
                classIcon:SetPoint("LEFT", self.frames[previousUnit], "RIGHT", 0, 0)
            elseif Gladdy.db.classIconGroupDirection == "LEFT" then
                classIcon:SetPoint("RIGHT", self.frames[previousUnit], "LEFT", 0, 0)
            elseif Gladdy.db.classIconGroupDirection == "UP" then
                classIcon:SetPoint("BOTTOM", self.frames[previousUnit], "TOP", 0, 0)
            elseif Gladdy.db.classIconGroupDirection == "DOWN" then
                classIcon:SetPoint("TOP", self.frames[previousUnit], "BOTTOM", 0, 0)
            end
        end
    end

    -- Создаем мувер для первой арены
    if unit == "arena1" then
        Gladdy:CreateMover(classIcon, "classIconXOffset", "classIconYOffset", L["Class Icon"],
            {"TOPLEFT", "TOPLEFT"},
            width, height,
            0, 0, "classIconEnabled")
    end

    -- Обновляем рамку
    if Gladdy.db.classIconBorderStyle ~= "None" then
        classIcon.texture.overlay:SetTexture(Gladdy.db.classIconBorderStyle)
        classIcon.texture.overlay:SetVertexColor(Gladdy:SetColor(Gladdy.db.classIconBorderColor))
    else
        classIcon.texture.overlay:SetTexture("")
    end

    -- Показываем/скрываем в зависимости от настроек
    if Gladdy.db.classIconEnabled then
        classIcon:Show()
    else
        classIcon:Hide()
    end
end

function Classicon:ENEMY_SPOTTED(unit)
    if (not Gladdy.db.classIconEnabled) then return end
    
    local classIcon = self.frames[unit]
    if (not classIcon) then return end

    classIcon.texture:SetTexture(classIcons[Gladdy.buttons[unit].class])
    classIcon.texture:SetAllPoints(classIcon)
end

function Classicon:UNIT_SPEC(unit, spec)
    if (not Gladdy.db.classIconEnabled) then return end
    
    local classIcon = self.frames[unit]
    if (not Gladdy.db.classIconSpecIcon or not classIcon) then
        return
    end
    classIcon.texture:SetTexture(specIcons[Gladdy.buttons[unit].class][spec])
end

function Classicon:GetOptions()
    return {
        headerClassicon = {
            type = "header",
            name = L["Class Icon"],
            order = 2,
        },
        classIconEnabled = Gladdy:option({
            type = "toggle",
            name = L["Class Icon Enabled"],
            order = 3,
        }),
        classIconSpecIcon = {
            type = "toggle",
            name = L["Show Spec Icon"],
            desc = L["Shows Spec Icon once spec is detected"],
            order = 4,
            disabled = function() return not Gladdy.db.classIconEnabled end,
            get = function() return Gladdy.db.classIconSpecIcon end,
            set = function(_, value)
                Gladdy.db.classIconSpecIcon = value
                if Gladdy.curBracket and Gladdy.curBracket > 0 then
                    for i=1,Gladdy.curBracket do
                        local unit = "arena" .. i
                        if (Gladdy.buttons[unit] and Gladdy.buttons[unit].spec) then
                            self:ENEMY_SPOTTED(unit)
                            self:UNIT_SPEC(unit, Gladdy.buttons[unit].spec)
                        end
                    end
                end
            end
        },
        classIconGroup = Gladdy:option({
            type = "toggle",
            name = L["Group Class Icon"],
            order = 5,
            disabled = function() return not Gladdy.db.classIconEnabled end,
        }),
        classIconGroupDirection = Gladdy:option({
            type = "select",
            name = L["Group direction"],
            order = 6,
            values = {
                ["RIGHT"] = L["Right"],
                ["LEFT"] = L["Left"],
                ["UP"] = L["Up"],
                ["DOWN"] = L["Down"],
            },
            disabled = function()
                return not Gladdy.db.classIconGroup or not Gladdy.db.classIconEnabled
            end,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 7,
            disabled = function() return not Gladdy.db.classIconEnabled end,
            args = {
                size = {
                    type = "group",
                    name = L["Icon"],
                    order = 1,
                    args = {
                        header = {
                            type = "header",
                            name = L["Icon"],
                            order = 1,
                        },
                        classIconZoomed = Gladdy:option({
                            type = "toggle",
                            name = L["Zoomed Icon"],
                            desc = L["Zooms the icon to remove borders"],
                            order = 2,
                            width = "full",
                        }),
                        classIconSize = Gladdy:option({
                            type = "range",
                            name = L["Size"],
                            min = 3,
                            max = 100,
                            step = .1,
                            order = 3,
                            width = "full",
                        }),
                        classIconWidthFactor = Gladdy:option({
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
                position = {
                    type = "group",
                    name = L["Position"],
                    order = 3,
                    args = {
                        headerPosition = {
                            type = "header",
                            name = L["Position"],
                            order = 5,
                        },
                        classIconXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 11,
                            min = -800,
                            max = 800,
                            step = 0.1,
                            width = "full",
                        }),
                        classIconYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 12,
                            min = -800,
                            max = 800,
                            step = 0.1,
                            width = "full",
                        }),
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 2,
                    args = {
                        headerBorder = {
                            type = "header",
                            name = L["Border"],
                            order = 10,
                        },
                        classIconBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 11,
                            values = Gladdy:GetIconStyles()
                        }),
                        classIconBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 12,
                            hasAlpha = true,
                        }),
                    },
                },
                frameStrata = {
                    type = "group",
                    name = L["Frame Strata and Level"],
                    order = 4,
                    args = {
                        headerAuraLevel = {
                            type = "header",
                            name = L["Frame Strata and Level"],
                            order = 1,
                        },
                        classIconFrameStrata = Gladdy:option({
                            type = "select",
                            name = L["Frame Strata"],
                            order = 2,
                            values = Gladdy.frameStrata,
                            sorting = Gladdy.frameStrataSorting,
                            width = "full",
                        }),
                        classIconFrameLevel = Gladdy:option({
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