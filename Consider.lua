-- Consider Addon
-- Copyright (c) 2025 Matthew Paul Centonze ("seathasky")
-- Licensed under the MIT License (see LICENSE file for details)

local ADDON_NAME = "Consider"
local KEYBIND_ACTION = "CONSIDER_KEYBIND"
local DEFAULT_BINDING = "SHIFT-G"

local random = math.random

local DEAD_BEAST_MESSAGES = {
    " is asleep.",
    " is just sleeping.",
    " is not dead, just taking a nap.",
    " is sleeping.",
    " is snoring peacefully.",
    " forgot to set an alarm.",
    " is having the best nap ever."
}

local DEAD_CRITTER_MESSAGES = {
    " was just trying to live peacefully.",
    " didn't deserve this fate.",
    " was minding its own business.",
    " lived a simple life.",
    " is roadkill.",
    " never hurt anyone."
}

local DEAD_GENERAL_MESSAGES = {
    " is pushing up daisies.",
    " has shuffled off this mortal coil.",
    " is taking a dirt nap.",
    " has joined the choir invisible.",
    " is definitely not getting back up.",
    " is sleeping with the fishes.",
    " has gone to the great beyond.",
    " is deadge.",
    " is deader than a doornail."
}

local ALIVE_CRITTER_MESSAGES = {
    " is just trying to live peacefully.",
    " doesn't want any trouble.",
    " poses no threat to anyone.",
    " just wants to be left alone.",
    " is innocent and harmless."
}

local CLASSIFICATION_LABEL = {
    elite = " (Elite)",
    rare = " (Rare)",
    rareelite = " (Rare Elite)",
}

local function GetDifficultyColor(targetLevel, playerLevel)
    local levelDiff = (targetLevel or 0) - (playerLevel or 0)

    if levelDiff >= 5 then
        return "|cffff0000", " looks like it would wipe the floor with you."
    elseif levelDiff >= 3 then
        return "|cffff8000", " looks extremely dangerous."
    elseif levelDiff >= 1 then
        return "|cffffff00", " looks like quite a challenge."
    elseif levelDiff == 0 then
        return "|cffffffff", " looks like an even match."
    elseif levelDiff >= -2 then
        return "|cff0080ff", " looks weak."
    elseif levelDiff >= -7 then
        return "|cff00ff00", " is no threat."
    end

    return "|cff808080", " poses no challenge and offers no reward."
end

local function PrintColoredMessage(colorCode, message)
    print(string.format("[Consider] %s%s|r", colorCode, message))
end

local function ConsiderTarget()
    local unit = "target"
    if not UnitExists(unit) then
        print("[Consider] No target selected.")
        return
    end

    local name = UnitName(unit) or "Unknown"

    if UnitIsDead(unit) then
        local creatureType = UnitCreatureType(unit)
        if creatureType == "Beast" then
            PrintColoredMessage("|cff808080", name .. DEAD_BEAST_MESSAGES[random(#DEAD_BEAST_MESSAGES)])
            return
        elseif creatureType == "Critter" then
            PrintColoredMessage("|cff808080", name .. DEAD_CRITTER_MESSAGES[random(#DEAD_CRITTER_MESSAGES)])
            return
        end

        PrintColoredMessage("|cff808080", name .. DEAD_GENERAL_MESSAGES[random(#DEAD_GENERAL_MESSAGES)])
        return
    end

    local creatureType = UnitCreatureType(unit)
    if creatureType == "Critter" then
        PrintColoredMessage("|cff00ff00", name .. ALIVE_CRITTER_MESSAGES[random(#ALIVE_CRITTER_MESSAGES)])
        return
    end

    local classifText = CLASSIFICATION_LABEL[UnitClassification(unit) or ""] or ""
    local colorCode, description = GetDifficultyColor(UnitLevel(unit), UnitLevel("player"))

    PrintColoredMessage(colorCode, name .. classifText .. description)
end

function Consider_OnKeybind()
    ConsiderTarget()
end

local settingsFrame

local function GetKeybindSummary()
    local primary, secondary = GetBindingKey(KEYBIND_ACTION)

    local function formatKey(key)
        if not key then
            return nil
        end
        return GetBindingText(key, "KEY_")
    end

    local formattedPrimary = formatKey(primary)
    local formattedSecondary = formatKey(secondary)

    if formattedPrimary and formattedSecondary then
        return formattedPrimary .. " / " .. formattedSecondary
    end

    return formattedPrimary or formattedSecondary or "Not Bound"
end

local function UpdateKeybindDisplay()
    if not settingsFrame or not settingsFrame.keybindLabel then
        return
    end

    settingsFrame.keybindLabel:SetText("Current Keybind: " .. GetKeybindSummary())
end

local function EnsureDefaultBinding()
    local primary, secondary = GetBindingKey(KEYBIND_ACTION)
    if primary or secondary then
        return
    end

    if SetBinding(DEFAULT_BINDING, KEYBIND_ACTION) then
        local bindingSet = type(GetCurrentBindingSet) == "function" and GetCurrentBindingSet() or 2
        -- Ensure bindingSet is valid (1 = account-wide, 2 = character-specific)
        if bindingSet ~= 1 and bindingSet ~= 2 then
            bindingSet = 2  -- Default to character-specific bindings
        end
        if type(SaveBindings) == "function" then
            SaveBindings(bindingSet)
        end
    end
end

local function EnsureSettingsFrame()
    if settingsFrame then
        return settingsFrame
    end

    local frame = CreateFrame("Frame", "ConsiderSettings", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(320, 320)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText("Consider Settings")

    local descriptionText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    descriptionText:SetPoint("TOPLEFT", 16, -32)
    descriptionText:SetPoint("RIGHT", -16, 0)
    descriptionText:SetJustifyH("LEFT")
    descriptionText:SetText("Consider compares your level to your target and explains how tough the fight will be when you press your keybind or use /con.")

    local colorHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorHeader:SetPoint("TOPLEFT", descriptionText, "BOTTOMLEFT", 0, -12)
    colorHeader:SetText("Difficulty Colors")

    local colorLegend = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    colorLegend:SetPoint("TOPLEFT", colorHeader, "BOTTOMLEFT", 0, -8)
    colorLegend:SetPoint("RIGHT", descriptionText, "RIGHT", 0, 0)
    colorLegend:SetJustifyH("LEFT")
    colorLegend:SetText("|cffff0000Red|r – Impossible\n|cffff8000Orange|r – Extremely Dangerous\n|cffffff00Yellow|r – Harder\n|cffffffffWhite|r – Even Match\n|cff0080ffBlue|r – Easier\n|cff00ff00Green|r – Much Easier\n|cff808080Gray|r – No Reward")

    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 1, 1, 0.15)
    divider:SetPoint("TOPLEFT", colorLegend, "BOTTOMLEFT", -4, -10)
    divider:SetPoint("TOPRIGHT", colorLegend, "BOTTOMRIGHT", 4, -10)
    divider:SetHeight(1)

    frame.keybindLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.keybindLabel:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 4, -16)
    frame.keybindLabel:SetText("Current Keybind: " .. DEFAULT_BINDING)

    local rebindHint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rebindHint:SetPoint("TOPLEFT", frame.keybindLabel, "BOTTOMLEFT", 0, -10)
    rebindHint:SetPoint("RIGHT", descriptionText, "RIGHT", 0, 0)
    rebindHint:SetJustifyH("LEFT")
    rebindHint:SetText(string.format("Default keybind: %s\nYou can rebind it from Options > Keybindings > Consider.", DEFAULT_BINDING))

    frame:SetScript("OnShow", UpdateKeybindDisplay)
    frame:Hide()

    settingsFrame = frame
    UpdateKeybindDisplay()

    return frame
end

local function ShowSettings()
    EnsureSettingsFrame():Show()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UPDATE_BINDINGS")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        EnsureDefaultBinding()
    print(string.format("|cff00ff00%s|r addon loaded. Use |cfffff200/consider|r for addon info or rebind under Options > Keybindings > Consider.", ADDON_NAME))
    end

    UpdateKeybindDisplay()
end)

SLASH_CONSIDERSETTINGS1 = "/consider"
SlashCmdList.CONSIDERSETTINGS = ShowSettings

SLASH_CONSIDERTARGET1 = "/con"
SlashCmdList.CONSIDERTARGET = ConsiderTarget

