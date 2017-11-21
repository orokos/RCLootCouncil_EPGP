local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomEP = RCEPGP:GetModule("RCCustomEP")
local RCCustomEPGUI = RCEPGP:NewModule("RCCustomEPGUI", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")

function RCCustomEPGUI:OnInitialize()
    addon:CustomChatCmd(self, "ShowFrame", LEP["slash_rc_epgui_help"], "epgui")
    self:RegisterMessage("RCCustomEPQueueRemoved", "EPQueueChanged")
    self:RegisterMessage("RCCustomEPQueueAdded", "EPQueueChanged")
end

function RCCustomEPGUI:ShowFrame()
    self:GetFrame():Show()
end

function RCCustomEPGUI:EPQueueChanged()
    RCEPGP:DebugPrint("GUI: EP queue changed")
    self:BuildST()
end

function RCCustomEPGUI:GetFrame()
    if self.frame then
        return self.frame
    end
    local f = addon:CreateFrame("RCEPGPCustomEPFrame", "RCCustomEPGUI", LEP["RCLootCouncil-EPGP Custom EP GUI"], 250, 510)
    self.frame = f

    local closeBtn = CreateFrame("Button", nil, f.content, "UIPanelCloseButton")
    closeBtn:SetSize(40, 40)
	closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", 6, 6)
	closeBtn:SetScript("OnClick", function()
		f:Hide()
	end)
	f.closeBtn = closeBtn

	local awardReasonStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	awardReasonStr:SetPoint("TOPLEFT", f.content, "TOPLEFT", 20, -30)
	awardReasonStr:SetText(LEP["Award Reason"])
    awardReasonStr:SetTextColor(1, 0, 0)
	f.awardReasonStr = awardReasonStr

    local awardReasonEditbox = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    awardReasonEditbox:SetSize(175, 32)
    awardReasonEditbox:SetText("")
    awardReasonEditbox:SetFontObject("GameFontHighlight")
    awardReasonEditbox:SetAutoFocus(false)
    awardReasonEditbox:SetPoint("TOPLEFT", awardReasonStr, "BOTTOMLEFT", 0, -4)
    awardReasonEditbox:Show()
    awardReasonEditbox:SetScript("OnEnter", function(self)
    	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
    	GameTooltip:AddLine(LEP["gui_award_reason_tooltip1"], 1, 1, 1)
        GameTooltip:AddLine(LEP["gui_award_reason_tooltip2"], 1, 1, 1)
    	GameTooltip:Show()
    end)
    awardReasonEditbox:SetScript("OnLeave", function()
    	addon:HideTooltip()
    end)

    awardReasonEditbox:SetScript("OnTextChanged", function(self)
        if self:GetText() == "" then
            GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            GameTooltip:AddLine(LEP["gui_award_reason_tooltip1"], 1, 1, 1)
            GameTooltip:AddLine(LEP["gui_award_reason_tooltip2"], 1, 1, 1)
            GameTooltip:Show()
            awardReasonStr:SetTextColor(1, 0, 0)
        else
            awardReasonStr:SetTextColor(1, 0.82, 0)
        end
    end)
    f.awardReasonEditbox = awardReasonEditbox

    local awardAmountStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    awardAmountStr:SetPoint("LEFT", awardReasonStr, "LEFT", 225, 0)
    awardAmountStr:SetText(LEP["EP Award Amount"])
    awardAmountStr:SetTextColor(1, 0, 0)
    f.awardAmountStr = awardAmountStr

    local awardAmountEditbox = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    awardAmountEditbox:SetSize(175, 32)
    awardAmountEditbox:SetText("")
    awardAmountEditbox:SetFontObject("GameFontHighlight")
    awardAmountEditbox:SetAutoFocus(false)
    awardAmountEditbox:SetPoint("TOPLEFT", awardAmountStr, "BOTTOMLEFT", 0, -4)
    awardAmountEditbox:Show()
    awardAmountEditbox:SetScript("OnEnter", function(self)
    	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
    	GameTooltip:AddLine(LEP["gui_award_amount_tooltip1"], 1, 1, 1)
        GameTooltip:AddLine(LEP["gui_award_amount_tooltip2"], 1, 1, 1)
    	GameTooltip:Show()
    end)
    awardAmountEditbox:SetScript("OnLeave", function()
    	addon:HideTooltip()
    end)
    awardAmountEditbox.lastText = ""
    awardAmountEditbox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            if self:GetText() ~= "" and ((not tonumber(self:GetText())) or tonumber(self:GetText()) ~= math.floor(tonumber(self:GetText())+0.5)) then -- Only allows number input.
                self:SetText(self.lastText)
                GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            	GameTooltip:AddLine(LEP["gui_award_amount_tooltip1"], 1, 1, 1)
                GameTooltip:AddLine(LEP["gui_award_amount_tooltip2"], 1, 1, 1)
            	GameTooltip:Show()
            else
                self.lastText = self:GetText()
            end
        else
            self.lastText = self:GetText()
        end
        if self:GetText() == "" then
            awardAmountStr:SetTextColor(1, 0, 0)
        else
            awardAmountStr:SetTextColor(1, 0.82, 0)
        end
    end)
    f.awardAmountEditbox = awardAmountEditbox

    local recurPeriodStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    recurPeriodStr:SetPoint("TOPLEFT", awardReasonEditbox, "BOTTOMLEFT", 0, -4)
    recurPeriodStr:SetText(LEP["Recurring Award Period"])
    f.recurPeriodStr = recurPeriodStr

    local recurPeriodEditbox = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    recurPeriodEditbox:SetSize(175, 32)
    recurPeriodEditbox:SetText("")
    recurPeriodEditbox:SetFontObject("GameFontHighlight")
    recurPeriodEditbox:SetAutoFocus(false)
    recurPeriodEditbox:SetPoint("TOPLEFT", recurPeriodStr, "BOTTOMLEFT", 0, -4)
    recurPeriodEditbox:Show()
    recurPeriodEditbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine(LEP["gui_recurring_period_tooltip1"], 1, 1, 1, true)
        GameTooltip:AddLine(LEP["gui_recurring_period_tooltip2"], 1, 1, 1, true)
        GameTooltip:AddLine(LEP["gui_recurring_period_tooltip3"], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    recurPeriodEditbox:SetScript("OnLeave", function()
        addon:HideTooltip()
    end)
    recurPeriodEditbox.lastText = ""
    recurPeriodEditbox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            if self:GetText() ~= "" and ((not tonumber(self:GetText())) or tonumber(self:GetText()) < 0) then -- Only allows number input.
                self:SetText(self.lastText)
                GameTooltip:AddLine(LEP["gui_recurring_period_tooltip1"], 1, 1, 1, true)
                GameTooltip:AddLine(LEP["gui_recurring_period_tooltip2"], 1, 1, 1, true)
                GameTooltip:AddLine(LEP["gui_recurring_period_tooltip3"], 1, 1, 1, true)
            else
                self.lastText = self:GetText()
            end
        else
            self.lastText = self:GetText()
        end
    end)
    f.recurPeriodEditbox = recurPeriodEditbox

    local scheduleTimeStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scheduleTimeStr:SetPoint("TOPLEFT", awardAmountEditbox, "BOTTOMLEFT", 0, -4)
    scheduleTimeStr:SetText(LEP["Scheduled Award Time"])
    f.recurPeriodStr = scheduleTimeStr

    local scheduleTimeEditbox = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    scheduleTimeEditbox:SetSize(175, 32)
    scheduleTimeEditbox:SetText("")
    scheduleTimeEditbox:SetFontObject("GameFontHighlight")
    scheduleTimeEditbox:SetAutoFocus(false)
    scheduleTimeEditbox:SetPoint("TOPLEFT", scheduleTimeStr, "BOTTOMLEFT", 0, -4)
    scheduleTimeEditbox:Show()
    scheduleTimeEditbox:SetScript("OnEnter", function()
        GameTooltip:SetOwner(scheduleTimeEditbox, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine(LEP["gui_scheduled_time_tooltip1"], 1, 1, 1, true)
        GameTooltip:AddLine(LEP["gui_scheduled_time_tooltip2"], 1, 1, 1, true)
        GameTooltip:AddLine(LEP["gui_scheduled_time_tooltip3"], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    scheduleTimeEditbox:SetScript("OnLeave", function()
        addon:HideTooltip()
    end)
    scheduleTimeEditbox.lastText = ""
    scheduleTimeEditbox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            if self:GetText() ~= "" and (not RCCustomEP:GetUTCEndTime(self:GetText())) then -- Only allows time format.
                self:SetText(self.lastText)
                GameTooltip:SetOwner(scheduleTimeEditbox, "ANCHOR_TOPRIGHT")
                GameTooltip:AddLine(LEP["gui_scheduled_time_tooltip1"], 1, 1, 1, true)
                GameTooltip:AddLine(LEP["gui_scheduled_time_tooltip2"], 1, 1, 1, true)
                GameTooltip:AddLine(LEP["gui_scheduled_time_tooltip3"], 1, 1, 1, true)
                GameTooltip:Show()
            else
                self.lastText = self:GetText()
            end
        else
            self.lastText = self:GetText()
        end
    end)
    f.scheduleTimeEditbox = scheduleTimeEditbox

    local formulaStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    formulaStr:SetPoint("TOPLEFT", recurPeriodEditbox, "BOTTOMLEFT", 0, -4)
    formulaStr:SetText(LEP["EP Award Formula"])
    f.recurPeriodStr = formulaStr

    -- Create the dropdown, and configure its appearance
    local formulaDropDown = CreateFrame("FRAME", "RCCustomEPGUIFormulaDropdown", f.content, "Lib_UIDropDownMenuTemplate")
    formulaDropDown:SetPoint("TOPLEFT", formulaStr, "BOTTOMLEFT", -23, -4)
    Lib_UIDropDownMenu_SetWidth(formulaDropDown, 175)
    formulaDropDown.selected = 0 -- The index of selected formula. Default 0: The default Mass EP Rule
    Lib_UIDropDownMenu_SetText(formulaDropDown, LEP["Default Mass EP Formula"])

    -- Create and bind the initialization function to the dropdown menu
    Lib_UIDropDownMenu_Initialize(formulaDropDown, function(menu, level)
        if (level or 1) == 1 then
        -- Display the 0-9, 10-19, ... groups
            local info = Lib_UIDropDownMenu_CreateInfo()
            info.text = LEP["Default Mass EP Formula"]
            info.checked = function() return menu.selected == 0 end
            info.hasArrow = false
            info.tooltipTitle = "|cFFFFFF00"..LEP["Default Mass EP Formula"].."|r"
            info.tooltipText = "\n|cFFFFFFFF"..LEP["Description"]..":\n"..LEP["default_mass_ep_formula_desc"].."\n\n"..LEP["Formula"]..":\nN/A|r"
            info.tooltipOnButton = true
            info.func = function()
                Lib_UIDropDownMenu_SetText(menu, LEP["Default Mass EP Formula"])
                menu.selected = 0
                Lib_CloseDropDownMenus()
            end
            Lib_UIDropDownMenu_AddButton(info)

            for i=1, #RCEPGP:GetEPGPdb().EPFormulas do
                if RCCustomEP:GetEPFormulaFunc(i) then
                    info = Lib_UIDropDownMenu_CreateInfo()
                    info.text = i..". "..RCEPGP:GetEPGPdb().EPFormulas[i].name
                    info.checked = function() return menu.selected == i end
                    info.hasArrow = false
                    info.tooltipTitle = "|cFFFFFF00"..i..". "..RCEPGP:GetEPGPdb().EPFormulas[i].name.."|r"
                    info.tooltipText =  "\n|cFFFFFFFF"..LEP["Description"]..":\n"..RCEPGP:GetEPGPdb().EPFormulas[i].desc.."\n\n"..LEP["Formula"]..":\n"..RCEPGP:GetEPGPdb().EPFormulas[i].formula.."|r"
                    info.tooltipOnButton = true
                    info.func = function()
                        Lib_UIDropDownMenu_SetText(menu, i..". "..RCEPGP:GetEPGPdb().EPFormulas[i].name)
                        menu.selected = i
                        Lib_CloseDropDownMenus()
                    end
                    Lib_UIDropDownMenu_AddButton(info)
                end
            end

            info = Lib_UIDropDownMenu_CreateInfo()
            info.text = LEP["Modify Formulas..."]
            info.notCheckable = true
            info.hasArrow = false
            info.func = function()
                InterfaceOptionsFrame_OpenToCategory(RCEPGP.optionsFrame)
                InterfaceOptionsFrame_OpenToCategory(RCEPGP.optionsFrame)
                LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil - EPGP", "epTab")
            end
            Lib_UIDropDownMenu_AddButton(info)
        end
    end)
    f.formulaDropDown = formulaDropDown

    local targetNameStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetNameStr:SetPoint("LEFT", formulaStr, "LEFT", 225, 0)
    targetNameStr:SetText(LEP["Formula Target Name"])
    f.targetNameStr = targetNameStr

    local targetNameEditbox = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    targetNameEditbox:SetSize(175, 32)
    targetNameEditbox:SetText("")
    targetNameEditbox:SetFontObject("GameFontHighlight")
    targetNameEditbox:SetAutoFocus(false)
    targetNameEditbox:SetPoint("TOPLEFT", targetNameStr, "BOTTOMLEFT", 0, 0)
    targetNameEditbox:Show()
    targetNameEditbox:SetScript("OnEnter", function()
    	GameTooltip:SetOwner(targetNameEditbox, "ANCHOR_TOPRIGHT")
    	GameTooltip:AddLine(LEP["gui_target_name_tooltip1"], 1, 1, 1)
    	GameTooltip:AddLine(LEP["gui_target_name_tooltip2"], 1, 1, 1)
    	GameTooltip:AddLine(LEP["gui_target_name_tooltip3"], 1, 1, 1)
    	GameTooltip:Show()
    end)
    targetNameEditbox:SetScript("OnLeave", function()
    	addon:HideTooltip()
    end)
    targetNameEditbox:SetScript("OnUpdate", function(self)
        if formulaDropDown.selected == 0 then
            self:Disable()
            self:SetText("")
            targetNameStr:SetText("|cff808080"..LEP["Formula Target Name"].."|r")
        else
            targetNameStr:SetText(LEP["Formula Target Name"])
            self:Enable()
        end
    end)
    targetNameEditbox.lastText = ""
    targetNameEditbox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            if self:GetText():find(" ") then -- Only allows number input.
                self:SetText(self.lastText)
                GameTooltip:SetOwner(targetNameEditbox, "ANCHOR_TOPRIGHT")
                GameTooltip:AddLine(LEP["gui_target_name_tooltip1"], 1, 1, 1)
            	GameTooltip:AddLine(LEP["gui_target_name_tooltip2"], 1, 1, 1)
            	GameTooltip:AddLine(LEP["gui_target_name_tooltip3"], 1, 1, 1)
                GameTooltip:Show()
            else
                self.lastText = self:GetText()
            end
        else
            self.lastText = self:GetText()
        end
    end)
    f.targetNameEditbox = targetNameEditbox

    local epAwardBtn = CreateFrame("Button", nil, f.content, "UIPanelButtonTemplate")
	epAwardBtn:SetText(LEP["Mass EP Award"])
    epAwardBtn:SetPoint("TOPLEFT", formulaDropDown, "BOTTOMLEFT", 75, -10)
	epAwardBtn:SetSize(300,30)
    epAwardBtn:Show()
    epAwardBtn:SetScript("OnUpdate", function(self)
        local isScheduling = true
        if scheduleTimeEditbox:GetText() == "" or tonumber(scheduleTimeEditbox:GetText()) == 0 then
            isScheduling = false
        end
        local isRecurring = true
        if recurPeriodEditbox:GetText() == "" or tonumber(recurPeriodEditbox:GetText()) == 0 then
            isRecurring = false
        end
        if isScheduling and isRecurring then
            self:SetText(LEP["Schedule to Start Recurring Mass EP Award"])
        elseif not isScheduling and isRecurring then
            self:SetText(LEP["Start Recurring Mass EP Award"])
        elseif isScheduling and not isRecurring then
            self:SetText(LEP["Schedule Mass EP Award"])
        else
            self:SetText(LEP["Mass EP Award"])
        end

        local reason = awardReasonEditbox:GetText()
        local amount = tonumber(awardAmountEditbox:GetText())

        local shouldDisable = false
        if reason == "" then
            shouldDisable = true
        elseif amount == nil then
            shouldDisable = true
        elseif formulaDropDown.selected == 0 and (not EPGP:CanIncEPBy(reason, amount)) then
            shouldDisable = true
        elseif (not EPGP:CanIncEPBy(reason, 1)) then -- For custom EP formula, 0 amount is allowed.
            shouldDisable = true
        end

        if shouldDisable then
            self:Disable()
        else
            self:Enable()
        end
    end)
    epAwardBtn:SetScript("OnClick", function(self)
        local periodMin = recurPeriodEditbox:GetText()
        local reason = awardReasonEditbox:GetText()
        local amount = awardAmountEditbox:GetText(0)
        local formulaIndexOrName = formulaDropDown.selected
        if formulaDropDown.selected == 0 then
            formulaIndexOrName = nil
        end
        local targetName = targetNameEditbox:GetText()
        local scheduleTime = scheduleTimeEditbox:GetText()

        if periodMin == "0" or periodMin == "" then
            RCCustomEP:Massep(reason, amount, formulaIndexOrName, targetName, scheduleTime)
        else
            RCCustomEP:Recurep(periodMin, reason, amount, formulaIndexOrName, targetName, scheduleTime)
        end
    end)
    f.epAwardBtn = epAwardBtn

    RCCustomEPGUI.guiCols = {
        { name = LEP["Index"], colName = "index", width = 50, DoCellUpdate = RCCustomEPGUI.SetCellFormulaIndex, align = "CENTER"},
        { name = LEP["Name"], colName = "name", width = 100, DoCellUpdate = RCCustomEPGUI.SetCellFormulaName, align = "CENTER"},
        { name = LEP["Award Period"], colName = "type", width = 50, DoCellUpdate = RCCustomEPGUI.SellCellAwardPeriod, align = "CENTER", },
        { name = LEP["Countdown(s)"], colName = "countdown", width = 75, DoCellUpdate = RCCustomEPGUI.SetCellCountdown, align = "CENTER"},
        { name = LEP["End Time\n(Realm Time)"], colName = "endtime", width = 75, DoCellUpdate = RCCustomEPGUI.SetCellEndTime, align = "CENTER"},
        { name = LEP["Cancel"], colName = "cancel", width = 50, DoCellUpdate = RCCustomEPGUI.SetCellCancel, align = "CENTER"},
    }

    local scheduledAwardStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scheduledAwardStr:SetPoint("CENTER", f.content, "CENTER", 0, -3)
    scheduledAwardStr:SetTextColor(1, 0.82, 0)
    scheduledAwardStr:SetText(LEP["Scheduled EP Award"])
    f.scheduledAwardStr = scheduledAwardStr

    local st = LibStub("ScrollingTable"):CreateST(RCCustomEPGUI.guiCols, 6, 30, { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 }, f.content)
    st.frame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
    st.frame:Show()
    st:EnableSelection(true)
    f.st = st
    self:BuildST()
    st:Refresh()
    st.frame.lastUpdateTime = GetTime()
    st.frame:SetScript("OnUpdate", function(self) if GetTime() > self.lastUpdateTime + 1 then self.lastUpdateTime = GetTime(); st:Refresh() end end) -- Update every second

    return self.frame
end

function RCCustomEPGUI:BuildST()
    local rows = {}
	local i = 1

	for i, entry in ipairs(RCCustomEP:GetMassEPQueue()) do
		local data = {}
		for num, col in ipairs(self.guiCols) do
			data[num] = {value = "", colName = col.colName}
		end
		rows[i] = {
			index = index,
            entry = entry,
			cols = data,
		}
	end

	self.frame.st:SetData(rows)
end

function RCCustomEPGUI.SetCellFormulaIndex(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local entry = data[realrow].entry
    if entry then
        local formulaIndexOrName = entry.formulaIndexOrName
        local index = ""
        for i, entry in ipairs(RCEPGP:GetEPGPdb().EPFormulas) do
            if i == tonumber(formulaIndexOrName) or entry.name == formulaIndexOrName then
                index = i
                break
            end
        end
        frame.text:SetText(index)
        data[realrow].cols[column].value = index
    end
end

function RCCustomEPGUI.SetCellFormulaName(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local entry = data[realrow].entry
    if entry then
        local formulaIndexOrName = entry.formulaIndexOrName
        local name = ""
        for i, entry in ipairs(RCEPGP:GetEPGPdb().EPFormulas) do
            if i == tonumber(formulaIndexOrName) or entry.name == formulaIndexOrName then
                name = entry.name
                break
            end
        end
        frame.text:SetText(name)
        data[realrow].cols[column].value = name
    end
end

function RCCustomEPGUI.SetCellAwardPeriod(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local entry = data[realrow].entry
    if entry then
        local periodMin = 0
        local formulaIndexOrName = entry.formulaIndexOrName
        local name = ""
        for i, entry in ipairs(RCEPGP:GetEPGPdb().EPFormulas) do
            if i == tonumber(formulaIndexOrName) or entry.name == formulaIndexOrName then
                if entry.type == "recurep" then
                    periodMin = entry.periodMin
                end
                break
            end
        end
        if periodMin ~= 0 then
            frame.text:SetText(periodMin)
        end
        data[realrow].cols[column].value = periodMin
    end
end

function RCCustomEPGUI.SetCellCountdown(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local entry = data[realrow].entry
    if entry then
        local UTCEndTime = entry.UTCEndTime
        local now = time(date("!*t"))
        local countdown = math.floor(UTCEndTime-now+0.5)
        if countdown < 0 then countdown = 0 end
        frame.text:SetText(countdown)
        data[realrow].cols[column].value = countdown
    end
end

function RCCustomEPGUI.SetCellEndTime(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local entry = data[realrow].entry
    if entry then
        local UTCEndTime = entry.UTCEndTime
        local displayTime = UTCEndTime + RCCustomEP.realmTimeDiff
        if date("*t").isdst then displayTime = displayTime - 3600 end
        local t = date("%H:%M:%S", displayTime)
        frame.text:SetText(t)
        data[realrow].cols[column].value = t
    end
end

function RCCustomEPGUI.SetCellCancel(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local entry = data[realrow].entry
    if entry then
        local f = frame.cancelBtn or CreateFrame("Button", nil, frame)
        f:SetSize(32, 32)
        f:SetPoint("CENTER", frame, "CENTER")
        f:SetNormalTexture("Interface/BUTTONS/UI-GroupLoot-Pass-Up")
        f:SetHighlightTexture("Interface/BUTTONS/UI-GROUPLOOT-PASS-HIGHLIGHT")
        f:SetPushedTexture("Interface/BUTTONS/UI-GroupLoot-Pass-Down")
        frame.cancelBtn = f
        f:SetScript("OnClick", function()
            if RCCustomEP:GetMassEPQueue()[realrow] == entry then -- We need to confirm that the entry actually exists due to update latency.
                _G.table.remove(RCCustomEP:GetMassEPQueue(), realrow)
                addon:SendMessage("RCCustomEPQueueRemoved", entry)
            end
        end)
    end
end

-- TODO: type in dropdown
-- TODO: queue
