ConsiderDB = ConsiderDB or {}

local function GetDifficultyColor(targetLevel, playerLevel)
    local levelDiff = targetLevel - playerLevel
    
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
    else
        return "|cff808080", " poses no challenge and offers no reward."
    end
end


local function GetDifficultyDescription(colorName)
    if colorName == "Red" then
        return "Impossible"
    elseif colorName == "Orange" then
        return "Very Hard"
    elseif colorName == "Yellow" then
        return "Harder"
    elseif colorName == "White" then
        return "Even Match"
    elseif colorName == "Blue" then
        return "Easier"
    elseif colorName == "Green" then
        return "Much Easier"
    elseif colorName == "Gray" then
        return "No Reward"
    end
    return ""
end

local function ConsiderTarget()
    local unit = "target"
    if not UnitExists(unit) then
        print("No target selected.")
        return
    end
    
    local name = UnitName(unit)
    local level = UnitLevel(unit)
    local playerLevel = UnitLevel("player")
    local classif = UnitClassification(unit)
    local classifText = ""
    
    -- Check if target is dead
    if UnitIsDead(unit) then
        local creatureType = UnitCreatureType(unit)
        
        -- Special message for dead beasts
        if creatureType == "Beast" then
            local sleepMessages = {
                " is asleep.",
                " is just sleeping.",
                " is not dead, just taking a nap.",
                " is sleeping.",
                " is snoring peacefully.",
                " forgot to set an alarm.",
                " is having the best nap ever."
            }
            local randomSleep = sleepMessages[math.random(#sleepMessages)]
            print("[Consider] |cff808080" .. name .. randomSleep .. "|r")
            return
        end
        
        -- Special messages for dead critters
        if creatureType == "Critter" then
            local critterMessages = {
                " was just trying to live peacefully.",
                " didn't deserve this fate.",
                " was minding its own business.",
                " lived a simple life.",
                " is roadkill.",
                " never hurt anyone."
            }
            local randomCritter = critterMessages[math.random(#critterMessages)]
            print("[Consider] |cff808080" .. name .. randomCritter .. "|r")
            return
        end
        
        -- Regular jokes for other creatures
        local jokes = {
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
        local randomJoke = jokes[math.random(#jokes)]
        print("[Consider] |cff808080" .. name .. randomJoke .. "|r")
        return
    end
    
    -- Special handling for alive critters
    local creatureType = UnitCreatureType(unit)
    if creatureType == "Critter" then
        local critterAliveMessages = {
            " is just trying to live peacefully.",
            " doesn't want any trouble.",
            " poses no threat to anyone.",
            " just wants to be left alone.",
            " is innocent and harmless."
        }
        local randomMessage = critterAliveMessages[math.random(#critterAliveMessages)]
        print("[Consider] |cff00ff00" .. name .. randomMessage .. "|r")
        return
    end
    
    if classif == "elite" then
        classifText = " (Elite)"
    elseif classif == "rareelite" then
        classifText = " (Rare Elite)"
    elseif classif == "rare" then
        classifText = " (Rare)"
    end
    
    local colorCode, description = GetDifficultyColor(level, playerLevel)
    
    print("[Consider] " .. colorCode .. name .. classifText .. description .. "|r")
end

local function SetKeybind(key)
    if not key or key == "" then
        return false
    end

    local macroName = "Consider"
    local macroText = "/con"
    local macroIndex = GetMacroIndexByName(macroName)
    if macroIndex == 0 then
        CreateMacro(macroName, "INV_Misc_QuestionMark", macroText, nil, 1)
    else
        EditMacro(macroIndex, macroName, "INV_Misc_QuestionMark", macroText)
    end

    return SetBinding(key, "MACRO " .. macroName)
end

-- Create settings frame
local settingsFrame = CreateFrame("Frame", "ConsiderSettings", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(320, 320)
settingsFrame:SetPoint("CENTER")
settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("TOP", 0, -5)
settingsFrame.title:SetText("Consider Settings")
settingsFrame:SetScript("OnDragStart", function(self)
    if self:IsMovable() then
        self:StartMoving()
    end
end)
settingsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

local descriptionText = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
descriptionText:SetPoint("TOPLEFT", 16, -32)
descriptionText:SetPoint("RIGHT", -16, 0)
descriptionText:SetJustifyH("LEFT")
descriptionText:SetText("Consider compares your level to your target and explains how tough the fight will be when you press your keybind or use /con.")

local colorHeader = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
colorHeader:SetPoint("TOPLEFT", descriptionText, "BOTTOMLEFT", 0, -12)
colorHeader:SetText("Difficulty Colors")

local colorLegend = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
colorLegend:SetPoint("TOPLEFT", colorHeader, "BOTTOMLEFT", 0, -8)
colorLegend:SetPoint("RIGHT", descriptionText, "RIGHT", 0, 0)
colorLegend:SetJustifyH("LEFT")
colorLegend:SetText("|cffff0000Red|r – Impossible\n|cffff8000Orange|r – Extremely Dangerous\n|cffffff00Yellow|r – Harder\n|cffffffffWhite|r – Even Match\n|cff0080ffBlue|r – Easier\n|cff00ff00Green|r – Much Easier\n|cff808080Gray|r – No Reward")

local divider = settingsFrame:CreateTexture(nil, "ARTWORK")
divider:SetColorTexture(1, 1, 1, 0.15)
divider:SetPoint("TOPLEFT", colorLegend, "BOTTOMLEFT", -4, -10)
divider:SetPoint("TOPRIGHT", colorLegend, "BOTTOMRIGHT", 4, -10)
divider:SetHeight(1)

local keyInput = CreateFrame("EditBox", nil, settingsFrame)
keyInput:SetSize(1, 1)
keyInput:SetPoint("TOPLEFT")
keyInput:SetAutoFocus(false)
keyInput:SetAlpha(0)
keyInput:EnableMouse(false)
keyInput:Hide()

local setKeybindButton
local keybindLabel
local manualInput

local function NormalizeKey(key)
    if not key then
        return ""
    end

    key = key:upper()
    key = key:gsub("%s+", "")
    key = key:gsub("%+", "-")

    return key
end

local function GetBindingSet()
    if type(GetCurrentBindingSet) == "function" then
        return GetCurrentBindingSet()
    end
    return 2
end

local function UpdateKeybindDisplay()
    local keyText = ConsiderDB.keybind or "None"
    if keybindLabel then
        keybindLabel:SetText("Current Keybind: " .. keyText)
    end
    if setKeybindButton then
        if settingsFrame.waitingForKey then
            setKeybindButton:SetText("Press a key...")
        else
            setKeybindButton:SetText("Capture Key")
        end
    end
end

local function RefreshManualInput()
    if manualInput then
        manualInput:SetText(ConsiderDB.keybind or "")
        manualInput:SetCursorPosition(0)
    end
end

local function CommitKeybind(rawKey)
    local normalizedKey = NormalizeKey(rawKey)
    local previousKey = ConsiderDB.keybind
    local changed = false

    if normalizedKey == "" then
        if previousKey and previousKey ~= "" then
            SetBinding(previousKey)
            ConsiderDB.keybind = nil
            print("Consider keybind cleared.")
            changed = true
        end
    else
        if previousKey and previousKey ~= "" and previousKey ~= normalizedKey then
            SetBinding(previousKey)
            changed = true
        end

        ConsiderDB.keybind = normalizedKey
        if SetKeybind(normalizedKey) then
            print("Keybind set to " .. normalizedKey)
            changed = true
        else
            print("Unable to bind key: " .. normalizedKey)
        end
    end

    if changed then
        SaveBindings(GetBindingSet())
    end

    RefreshManualInput()
    UpdateKeybindDisplay()
end

keybindLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
keybindLabel:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 4, -16)
keybindLabel:SetText("Current Keybind: None")

setKeybindButton = CreateFrame("Button", nil, settingsFrame, "GameMenuButtonTemplate")
setKeybindButton:SetSize(140, 26)
setKeybindButton:SetPoint("TOPLEFT", keybindLabel, "BOTTOMLEFT", -4, -12)
setKeybindButton:SetText("Capture Key")
setKeybindButton:SetScript("OnClick", function()
    settingsFrame.waitingForKey = true
    keyInput:Show()
    keyInput:SetFocus()
    manualInput:ClearFocus()
    UpdateKeybindDisplay()
end)

manualInput = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
manualInput:SetHeight(28)
manualInput:SetPoint("TOPLEFT", setKeybindButton, "TOPRIGHT", 12, 0)
manualInput:SetPoint("RIGHT", descriptionText, "RIGHT", 0, 0)
manualInput:SetAutoFocus(false)
manualInput:SetMaxLetters(32)
manualInput:SetTextInsets(6, 6, 0, 0)
manualInput:SetScript("OnEnterPressed", function(self)
    CommitKeybind(self:GetText())
    self:ClearFocus()
end)
manualInput:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    RefreshManualInput()
    UpdateKeybindDisplay()
end)
manualInput:SetScript("OnEditFocusGained", function(self)
    settingsFrame.waitingForKey = false
    keyInput:Hide()
    UpdateKeybindDisplay()
end)

local manualHint = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
manualHint:SetPoint("TOPLEFT", setKeybindButton, "BOTTOMLEFT", 4, -10)
manualHint:SetPoint("RIGHT", descriptionText, "RIGHT", 0, 0)
manualHint:SetJustifyH("LEFT")
manualHint:SetText("Type a key combination (e.g., SHIFT-G) and press Enter to bind. Leave blank and press Enter to clear.")

keyInput:SetScript("OnKeyDown", function(self, key)
    if settingsFrame.waitingForKey then
        settingsFrame.waitingForKey = false
        self:Hide()
        self:ClearFocus()
        if key ~= "ESCAPE" then
            CommitKeybind(key)
        else
            RefreshManualInput()
            UpdateKeybindDisplay()
        end
    end
end)

settingsFrame:SetScript("OnShow", function()
    settingsFrame.waitingForKey = false
    RefreshManualInput()
    UpdateKeybindDisplay()
end)

settingsFrame:Hide()

-- Load saved keybind
if ConsiderDB.keybind then
    SetKeybind(ConsiderDB.keybind)
end
RefreshManualInput()
UpdateKeybindDisplay()

-- Print addon loaded message
print("|cff00ff00Consider|r addon loaded. Use |cfffff200/consider|r to set keybind to consider your target.")

-- Slash commands
SLASH_CONSIDERSETTINGS1 = '/consider'
SlashCmdList['CONSIDERSETTINGS'] = function() settingsFrame:Show() end

SLASH_CONSIDERTARGET1 = '/con'
SlashCmdList['CONSIDERTARGET'] = ConsiderTarget
