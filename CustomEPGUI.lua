local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomEP = RCEPGP:GetModule("RCCustomEP")
local RCCustomEPGUI = RCEPGP:NewModule("RCCustomEPGUI", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")

function RCCustomEPGUI:OnInitialize()
    addon:CustomChatCmd(self, "ShowFrame","Show GUI", "epgui")

    --TODO delete next line
    self:GetFrame():Show()
    self:RegisterMessage("RCCustomEPQueueRemoved", "EPQueueChanged")
    self:RegisterMessage("RCCustomEPQueueAdded", "EPQueueChanged")
end

function RCCustomEPGUI:ShowFrame()
    self:GetFrame():Show()
end

function RCCustomEPGUI:EPQueueChanged()
    print("EP queue changed")
    self:BuildST()
end

function RCCustomEPGUI:GetFrame()
    if self.frame then
        return self.frame
    end
    local f = addon:CreateFrame("RCEPGPCustomEPFrame", "RCCustomEP", "RCLootCouncil Custom EP GUI", 250,600)
    self.frame = f

    local b1 = CreateFrame("Button", nil, f.content, "UIPanelCloseButton")
    b1:SetSize(40, 40)
	b1:SetPoint("TOPRIGHT", f, "TOPRIGHT", 6, 6)
	b1:SetScript("OnClick", function()
		f:Hide()
	end)
	f.closeBtn = b1

	local awardReasonStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	awardReasonStr:SetPoint("TOPLEFT", f.content, "TOPLEFT", 20, -20)
	awardReasonStr:SetText("Reason")
	f.awardReasonStr = awardReasonStr

    local e1 = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    e1:SetSize(150, 32)
    e1:SetText("123213213")
    e1:SetFontObject("GameFontHighlight")
    e1:SetAutoFocus(false)
    e1:SetPoint("TOPLEFT", awardReasonStr, "BOTTOMLEFT", 0, -4)
    e1:Show()
    e1:SetScript("OnEnter", function()
    	GameTooltip:SetOwner(e1, "ANCHOR_TOPRIGHT")
    	GameTooltip:AddLine("Award Reason",1,1,1) -- TODO
    	GameTooltip:Show()
    end)
    e1:SetScript("OnLeave", function()
    	addon:HideTooltip()
    end)
    f.reasonEditbox = e1

    local awardAmountStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    awardAmountStr:SetPoint("TOPLEFT", e1, "BOTTOMLEFT", 0, -4)
    awardAmountStr:SetText("Amount")
    f.awardAmountStr = awardAmountStr

    local e2 = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    e2:SetSize(150, 32)
    e2:SetText("123213213")
    e2:SetFontObject("GameFontHighlight")
    e2:SetAutoFocus(false)
    e2:SetPoint("TOPLEFT", awardAmountStr, "BOTTOMLEFT", 0, -4)
    e2:Show()
    e2:SetScript("OnEnter", function()
    	GameTooltip:SetOwner(e2, "ANCHOR_TOPRIGHT")
    	GameTooltip:AddLine("Award Amount123213\n2132142141242134213",1,1,1) -- TODO
    	GameTooltip:Show()
    end)
    e2:SetScript("OnLeave", function()
    	addon:HideTooltip()
    end)

    local inputNameStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    inputNameStr:SetPoint("TOPLEFT", e2, "BOTTOMLEFT", 0, -4)
    inputNameStr:SetText("Input Name")
    f.targetNameStr = targetNameStr

    local e3 = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    e3:SetSize(150, 32)
    e3:SetText("123213213")
    e3:SetFontObject("GameFontHighlight")
    e3:SetAutoFocus(false)
    e3:SetPoint("TOPLEFT", inputNameStr, "BOTTOMLEFT", 0, -4)
    e3:Show()
    e3:SetScript("OnEnter", function()
    	GameTooltip:SetOwner(e3, "ANCHOR_TOPRIGHT")
    	GameTooltip:AddLine("Award Amount123213\n2132142141242134213",1,1,1) -- TODO
    	GameTooltip:Show()
    end)
    e3:SetScript("OnLeave", function()
    	addon:HideTooltip()
    end)
    f.targetNameEditbox = e3

    local recurIntervalStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    recurIntervalStr:SetPoint("TOPLEFT", e3, "BOTTOMLEFT", 0, -4)
    recurIntervalStr:SetText("Recur Interval")
    f.recurIntervalStr = recurIntervalStr

    local e4 = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    e4:SetSize(150, 32)
    e4:SetText("123213213")
    e4:SetFontObject("GameFontHighlight")
    e4:SetAutoFocus(false)
    e4:SetPoint("TOPLEFT", recurIntervalStr, "BOTTOMLEFT", 0, -4)
    e4:Show()
    e4:SetScript("OnEnter", function()
        GameTooltip:SetOwner(e4, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine("Recur Interval",1,1,1, true) -- TODO
        GameTooltip:Show()
    end)
    e4:SetScript("OnLeave", function()
        addon:HideTooltip()
    end)
    f.recurIntervalEditbox = e4

    local recurIntervalStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    recurIntervalStr:SetPoint("TOPLEFT", e3, "BOTTOMLEFT", 0, -4)
    recurIntervalStr:SetText("Recur Interval")
    f.recurIntervalStr = recurIntervalStr

    local e4 = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    e4:SetSize(150, 32)
    e4:SetText("123213213")
    e4:SetFontObject("GameFontHighlight")
    e4:SetAutoFocus(false)
    e4:SetPoint("TOPLEFT", recurIntervalStr, "BOTTOMLEFT", 0, -4)
    e4:Show()
    e4:SetScript("OnEnter", function()
        GameTooltip:SetOwner(e4, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine("Recur Interval",1,1,1, true) -- TODO
        GameTooltip:Show()
    end)
    e4:SetScript("OnLeave", function()
        addon:HideTooltip()
    end)
    f.recurIntervalEditbox = e4

    local scheduleTimeStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scheduleTimeStr:SetPoint("TOPLEFT", e4, "BOTTOMLEFT", 0, -4)
    scheduleTimeStr:SetText("Schedule Time")
    f.recurIntervalStr = scheduleTimeStr

    local e5 = CreateFrame("EditBox", nil, f.content, "InputBoxTemplate")
    e5:SetSize(150, 32)
    e5:SetText("123213213")
    e5:SetFontObject("GameFontHighlight")
    e5:SetAutoFocus(false)
    e5:SetPoint("TOPLEFT", scheduleTimeStr, "BOTTOMLEFT", 0, -4)
    e5:Show()
    e5:SetScript("OnEnter", function()
        GameTooltip:SetOwner(e5, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine("Schedule Time",1,1,1, true) -- TODO
        GameTooltip:Show()
    end)
    e5:SetScript("OnLeave", function()
        addon:HideTooltip()
    end)
    f.scheduleTimeEditbox = e5

    local favoriteNumber = 42 -- A user-configurable setting

    local formulaStr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    formulaStr:SetPoint("TOPLEFT", e5, "BOTTOMLEFT", 0, -4)
    formulaStr:SetText("Formula")
    f.recurIntervalStr = formulaStr

    -- Create the dropdown, and configure its appearance
    local dropDown = CreateFrame("FRAME", "WPDemoDropDown", f.content, "Lib_UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", formulaStr, "BOTTOMLEFT", -23, -4)
    Lib_UIDropDownMenu_SetWidth(dropDown, 200)
    dropDown.selected = 0 -- The index of selected formula. Default 0: The default Mass EP Rule
    Lib_UIDropDownMenu_SetText(dropDown, "Default MassEP Formula")

    -- Create and bind the initialization function to the dropdown menu
    Lib_UIDropDownMenu_Initialize(dropDown, function(menu, level)
        local info = Lib_UIDropDownMenu_CreateInfo()
        if (level or 1) == 1 then
        -- Display the 0-9, 10-19, ... groups
            info.text = "Default MassEP Formula"
            info.checked = function() return menu.selected == 0 end
            info.hasArrow = false
            info.tooltipTitle = "Default MassEP Formula"
            info.tooltipText = "TODO desc"
            info.tooltipOnButton = true
            info.func = function()
                Lib_UIDropDownMenu_SetText(menu, "Default MassEP Formula")
                menu.selected = 0
                Lib_CloseDropDownMenus()
            end
            Lib_UIDropDownMenu_AddButton(info)

            for i=1, #RCEPGP:GetEPGPdb().EPFormulas do
                if RCCustomEP:GetEPFormulaFunc(i) then
                    info.text = i..". "..RCEPGP:GetEPGPdb().EPFormulas[i].name
                    info.checked = function() return menu.selected == i end
                    info.hasArrow = false
                    info.tooltipTitle = "|cFFFFFF00"..i..". "..RCEPGP:GetEPGPdb().EPFormulas[i].name.."|r"
                    info.tooltipText = "|cFFFFFFFFDescription:\n"..RCEPGP:GetEPGPdb().EPFormulas[i].desc.."\n\nFormula:\n"..RCEPGP:GetEPGPdb().EPFormulas[i].formula.."|r"
                    info.tooltipOnButton = true
                    info.func = function()
                        Lib_UIDropDownMenu_SetText(menu, i..". "..RCEPGP:GetEPGPdb().EPFormulas[i].name)
                        menu.selected = i
                        Lib_CloseDropDownMenus()
                    end
                    Lib_UIDropDownMenu_AddButton(info)
                end
            end

            info.text = "Modify Formulas..."
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

    RCCustomEPGUI.guiCols = {
        { name = "Formula Index", colName = "index", width = 50, DoCellUpdate = RCCustomEPGUI.SetCellFormulaIndex, },
        { name = "Formula Name", colName = "name", width = 50, DoCellUpdate = RCCustomEPGUI.SetCellFormulaName, },
        { name = "Countdown(s)", colName = "countdown", width = 50, DoCellUpdate = RCCustomEPGUI.SetCellCountdown, },
        { name = "End Time (Realm Time)", colName = "endtime", width = 100, DoCellUpdate = RCCustomEPGUI.SetCellEndTime, },
        { name = "Cancel", colName = "cancel", width = 100, DoCellUpdate = RCCustomEPGUI.SetCellCancel, },
    }

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
