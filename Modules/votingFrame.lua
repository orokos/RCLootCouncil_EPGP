local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")
local LibDialog = LibStub("LibDialog-1.0")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")
local ExtraUtilities = addon:GetModule("RCExtraUtilities", true) -- nil if ExtraUtilites not enabled.
local RCVotingFrame = addon:GetModule("RCVotingFrame")
local RCVF = RCEPGP:NewModule("RCEPGPVotingFrame", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")

local session = 1

function RCVF:OnInitialize()
	self:SecureHook(RCVotingFrame, "OnEnable", "AddWidgetsIntoVotingFrame")
	self:RegisterMessage("RCCustomGPRuleChanged", "OnMessageReceived")
	self:RegisterMessage("RCSessionChangedPre", "OnMessageReceived")
	EPGP.RegisterCallback(self, "StandingsChanged", self.UpdateVotingFrame)
    self:SetupColumns()
	RCEPGP:AddRightClickMenu(_G["RCLootCouncil_VotingFrame_RightclickMenu"], RCVotingFrame.rightClickEntries, self.rightClickEntries)
	self:Add0GPSuffixToRCAwardButtons()
	self.initialize = true
end

function RCVF:OnMessageReceived(msg, ...)
    RCEPGP:DebugPrint("RCVF", "ReceiveMessage", msg)
    if msg == "RCCustomGPRuleChanged" then
        RCEPGP:DebugPrint("Refresh menu due to GP rule changed.")
        self:UpdateGPEditbox()
        RCEPGP:RefreshMenu(level)
	elseif msg == "RCSessionChangedPre" then
		local s = unpack({...})
		session = s
		self:UpdateGPEditbox()
		self:UpdateGPAwardString()
	end
end
function RCVF.UpdateVotingFrame()
    -- Dont try to use RCVotingFrame:GetFrame() here, it causes lag on login.
	if RCVotingFrame.frame and session and RCVotingFrame:GetLootTable()[session] then
    	RCVotingFrame:Update()
	end
end

function RCVF:UpdateGPEditbox()
    local lootTable = RCVotingFrame:GetLootTable()
    if lootTable then
        local t = lootTable[session]
        if t then
            local gp = GP:GetValue(t.link) or 0
            RCVotingFrame:GetFrame().gpEditbox:SetNumber(gp)
        end
    end
end

function RCVF:UpdateGPAwardString()
    if RCVotingFrame.frame and RCVotingFrame.frame.awdGPstr then
        if (not RCVotingFrame:GetLootTable()) or (not RCVotingFrame:GetLootTable()[session]) then
            return
        end
        local gpAwarded = RCVotingFrame:GetLootTable()[session].gpAwarded
        if not gpAwarded then
            RCVotingFrame.frame.awdGPstr:SetText("")
            RCVotingFrame.frame.awdGPstr:Hide()
        else
            local text = ""
            if gpAwarded >= 0 then
                text = "GP   +"..gpAwarded
            elseif gpAwarded < 0 then
                text = "GP   "..gpAwarded
            end
            RCVotingFrame.frame.awdGPstr:SetText(text)
            RCVotingFrame.frame.awdGPstr:Show()
        end
    end
end

function RCVF:GetScrollColIndexFromName(colName)
    for i, v in ipairs(RCVotingFrame.scrollCols) do
        if v.colName == colName then
            return i
        end
    end
end

function RCVF:SetupColumns()
    local ep =
    { name = "EP", DoCellUpdate = self.SetCellEP, colName = "ep", sortnext = self:GetScrollColIndexFromName("response"), width = 60, align = "CENTER", defaultsort = "dsc" }
    local gp =
    { name = "GP", DoCellUpdate = self.SetCellGP, colName = "gp", sortnext = self:GetScrollColIndexFromName("response"), width = 50, align = "CENTER", defaultsort = "dsc" }
    local pr =
    { name = "PR", DoCellUpdate = self.SetCellPR, colName = "pr", width = 50, align = "CENTER", comparesort = self.PRSort, defaultsort = "dsc" }
    local bid =
    { name = "Bid", DoCellUpdate = self.SetCellBid, colName = "bid", sortnext = self:GetScrollColIndexFromName("response"), width = 50, align = "CENTER",
    defaultsort = "dsc" }

    RCEPGP:ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, ep)
    RCEPGP:ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, gp)
    RCEPGP:ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, pr)

    if RCEPGP:GetGeneraldb().biddingEnabled then
        RCEPGP:ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, bid)
    else
        RCEPGP:RemoveColumn(RCVotingFrame.scrollCols, bid)
    end

    self:ResponseSortPRNext()

    if RCVotingFrame:GetFrame() then
        RCVotingFrame:GetFrame().UpdateSt()
    end
end

function RCVF:ResponseSortPRNext()
    local responseIdx = self:GetScrollColIndexFromName("response")
    local prIdx = self:GetScrollColIndexFromName("pr")
    if responseIdx then
        RCVotingFrame.scrollCols[responseIdx].sortnext = prIdx
    end
end

local COLOR_RED = "|cFFFF0000"
local COLOR_GREY = "|cFF808080"

function RCVF.SetCellEP(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local name = data[realrow].name
    name = RCEPGP:GetEPGPName(name)
    local ep, gp, main = EPGP:GetEPGP(name)
    if not ep then
        frame.text:SetText(COLOR_RED.."?")
    elseif ep >= EPGP.db.profile.min_ep then
        frame.text:SetText(COLOR_GREY..ep)
    else
        frame.text:SetText(COLOR_RED..ep)
    end
    data[realrow].cols[column].value = ep or 0
end

function RCVF.SetCellGP(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local name = data[realrow].name
    name = RCEPGP:GetEPGPName(name)
    local ep, gp, main = EPGP:GetEPGP(name)
    if not gp then
        frame.text:SetText(COLOR_GREY.."?")
    else
        frame.text:SetText(COLOR_GREY..gp)
    end
    data[realrow].cols[column].value = gp or 0
end

function RCVF.SetCellPR(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local name = data[realrow].name
    name = RCEPGP:GetEPGPName(name)
    local ep, gp, main = EPGP:GetEPGP(name)
    local pr
    if ep and gp then
        pr = ep / gp
    end

    if not pr then
        frame.text:SetText("?")
    else
        frame.text:SetText(format("%.4g", pr))
    end

    data[realrow].cols[column].value = pr or 0
end

function RCVF:GetBid(name)
    local lootTable = RCVotingFrame:GetLootTable()

    -- nil protection
    if session and name and lootTable and lootTable[session]
    and lootTable[session].candidates and lootTable[session].candidates[name] then
        local note = lootTable[session].candidates[name].note
        if note then
            local bid = tonumber(string.match(note, "[0-9]+"))
            return bid
        end
    end
end

function RCVF.SetCellBid(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local name = data[realrow].name
    local bid = RCEPGP:GetBid(name)
    if bid then
        frame.text:SetText(tostring(bid))
        data[realrow].cols[column].value = bid
    else
        data[realrow].cols[column].value = 0
        frame.text:SetText("")
    end
end

function RCVF.PRSort(table, rowa, rowb, sortbycol)
    local column = table.cols[sortbycol]
    local a, b = table:GetRow(rowa), table:GetRow(rowb);
    -- Extract the rank index from the name, fallback to 100 if not found

    local nameA = RCEPGP:GetEPGPName(a.name)
    local nameB = RCEPGP:GetEPGPName(b.name)

    local a_ep, a_gp = EPGP:GetEPGP(nameA)
    local b_ep, b_gp = EPGP:GetEPGP(nameB)

    if (not a_ep) or (not a_gp) then
        return false
    elseif (not b_ep) or (not b_gp) then
        return true
    end

    local a_pr = a_ep / a_gp
    local b_pr = b_ep / b_gp

    local a_qualifies = a_ep >= EPGP.db.profile.min_ep
    local b_qualifies = b_ep >= EPGP.db.profile.min_ep

    if a_qualifies == b_qualifies and a_pr == b_pr then
        if column.sortnext then
            local nextcol = table.cols[column.sortnext];
            if nextcol and not(nextcol.sort) then
                if nextcol.comparesort then
                    return nextcol.comparesort(table, rowa, rowb, column.sortnext);
                else
                    return table:CompareSort(rowa, rowb, column.sortnext);
                end
            end
        end
        return false
    else
        local direction = column.sort or column.defaultsort or "dsc";
        if direction:lower() == "asc" then
            if a_qualifies == b_qualifies then
                return a_pr < b_pr
            else
                return b_qualifies
            end
        else
            if a_qualifies == b_qualifies then
                return a_pr > b_pr
            else
                return a_qualifies
            end
        end
    end
end

----------------------------------------------------------------
function RCVF:AddWidgetsIntoVotingFrame()
    local f = RCVotingFrame:GetFrame()

    if not f.gpString then
        local gpstr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        gpstr:SetPoint("CENTER", f.content, "TOPLEFT", 300, - 60)
        gpstr:SetText("GP: ")
        gpstr:Show()
        gpstr:SetTextColor(1, 1, 0, 1) -- Yellow
        f.gpString = gpstr
    end


    local editbox_name = "RCLootCouncil_GP_EditBox"
    if not f.gpEditbox then
        local editbox = _G.CreateFrame("EditBox", editbox_name, f.content, "AutoCompleteEditBoxTemplate")
        editbox:SetWidth(40)
        editbox:SetHeight(32)
        editbox:SetFontObject("ChatFontNormal")
        editbox:SetNumeric(true)
        editbox:SetMaxLetters(5)
        editbox:SetAutoFocus(false)

        local left = editbox:CreateTexture(("%sLeft"):format(editbox_name), "BACKGROUND")
        left:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Left2]])
        left:SetWidth(8)
        left:SetHeight(32)
        left:SetPoint("LEFT", -5, 0)

        local right = editbox:CreateTexture(("%sRight"):format(editbox_name), "BACKGROUND")
        right:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Right2]])
        right:SetWidth(8)
        right:SetHeight(32)
        right:SetPoint("RIGHT", 5, 0)

        local mid = editbox:CreateTexture(("%sMid"):format(editbox_name), "BACKGROUND")
        mid:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Mid2]])
        mid:SetHeight(32)
        mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
        mid:SetPoint("TOPRIGHT", right, "TOPLEFT", 0, 0)

        --local label = editbox:CreateFontString(editbox_name, "ARTWORK", "GameFontNormalSmall")
        --label:SetPoint("RIGHT", editbox, "LEFT", - 15, 0)
        --label:Show()
        editbox.left = left
        editbox.right = right
        editbox.mid = mid
        --editbox.label = label

        editbox:SetPoint("LEFT", f.gpString, "RIGHT", 10, 0)
        editbox:Show()

        -- Auto release Focus after 3s editbox is not used
        local loseFocusTime = 3
        editbox:SetScript("OnEditFocusGained", function(self, userInput) self.lastUsedTime = GetTime() end)
        editbox:SetScript("OnTextChanged", function(self, userInput)
            RCVotingFrame:Update()
            self.lastUsedTime = GetTime()
            RCEPGP:RefreshMenu(1)
         end)
        editbox:SetScript("OnUpdate", function(self, elapsed)
            if self.lastUsedTime and GetTime() - self.lastUsedTime > loseFocusTime then
                self.lastUsedTime = nil
                if editbox:HasFocus() then
                    editbox:ClearFocus()
                end
            end
            if addon.isMasterLooter then -- Cant enter text if not master looter.
                self:Enable()
            else
                self:Disable()
            end
        end)

        -- Clear focus when rightclick menu opens.
        if not self:IsHooked(_G["Lib_DropDownList1"], "OnShow") then
            self:SecureHookScript(_G["Lib_DropDownList1"], "OnShow", function()
                if f and f.gpEditbox then
                    f.gpEditbox:ClearFocus()
                end
            end)
        end
        f.gpEditbox = editbox
    end

    if not f.awdGPstr then
        local awdGPstr = f.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        awdGPstr:SetPoint("BOTTOM", f.awardString, "TOP", 0, 1)
        awdGPstr:SetText("GP   +1000")
        awdGPstr:SetTextColor(1, 1, 0, 1) -- Yellow
        awdGPstr:Hide()
        f.awdGPstr = awdGPstr
    end
end

-- v2.1.1: We don't use RCEPGP:GetEPGPName() here because we need to use RC name for fetch RC data
local function GetGPInfo(name)
    local lootTable = RCVotingFrame:GetLootTable()
    if lootTable and lootTable[session] and lootTable[session].candidates
    and name and lootTable[session].candidates[name] then
        local data = lootTable[session].candidates[name]
        local responseGP = RCEPGP:GetResponseGP(data.response, data.isTier, data.isRelic)
        local editboxGP = RCVotingFrame:GetFrame().gpEditbox:GetNumber()
        local gp = RCEPGP:GetFinalGP(responseGP, editboxGP)
        local item = lootTable[session].link
        local bid = RCVF:GetBid(name)
        return data, name, item, responseGP, gp, bid
    else -- Error occurs
        return nil, "UNKNOWN", "UNKNOWN", "UNKNOWN", 0, 0 -- nil protection
    end
end

RCVF.rightClickEntries = {
    { -- Level 1
        { -- Button 1
            pos = 2,
            hidden = function() return not RCEPGP:GetGeneraldb().biddingEnabled end,
            notCheckable = true,
            func = function(name)
                local data, name, item, responseGP, gp, bid = GetGPInfo(name)
                if not data then return end
                local args = RCVotingFrame:GetAwardPopupData(session, name, data)
                args.gp = bid
                args.responseGP = responseGP
                LibDialog:Spawn("RCEPGP_CONFIRM_AWARD", args)
            end,
            text = function(name)
                local data, name, item, responseGP, gp, bid = GetGPInfo(name)
                if not bid then bid = "?" end
                return L["Award"].." ("..bid.." "..LEP["GP Bid"]..")"
            end,
            disabled = function(name)
                local data, name, item, responseGP, gp, bid = GetGPInfo(name)
                return (not bid) or ((not EPGP:CanIncGPBy(item, bid)) and bid and (bid ~= 0))
            end,
        },
        { -- Button 2
        pos = 3,
        notCheckable = true,
        func = function(name)
            local data, name, item, responseGP, gp, bid = GetGPInfo(name)
            if not data then return end
            local args = RCVotingFrame:GetAwardPopupData(session, name, data)
            args.gp = gp
            args.responseGP = responseGP
            LibDialog:Spawn("RCEPGP_CONFIRM_AWARD", args)
        end,
        text = function(name)
            local data, name, item, responseGP, gp, bid = GetGPInfo(name)
            return L["Award"].." "..RCEPGP:GetGPAndResponseGPText(gp, responseGP)
        end,
        disabled = function(name)
            local data, name, item, responseGP, gp, bid = GetGPInfo(name)
            return (not EPGP:CanIncGPBy(item, gp)) and gp and (gp ~= 0)
        end,
        },
    },
}

function RCVF:Add0GPSuffixToRCAwardButtons()
    for _, entry in ipairs(RCVotingFrame.rightClickEntries[1]) do
        if entry.text == L["Award"] then
            entry.text = L["Award"].." (0 GP)"
        end
        if entry.text == L["Award for ..."] then
            entry.text = L["Award for ..."].." (0 GP)"
        end
    end
    RCEPGP:DebugPrint("Added 0GP suffix to RC Award Buttons.")
end
