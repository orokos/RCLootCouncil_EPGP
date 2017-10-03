local version = "2.0.0"
local tocVersion = GetAddOnMetadata("RCLootCouncil_EPGP", "Version")
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:NewModule("RCEPGP", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")
local LibDialog = LibStub("LibDialog-1.0")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")
RCEPGP.version = version
RCEPGP.debug = false

local ExtraUtilities = addon:GetModule("RCExtraUtilities", true) -- nil if ExtraUtilites not enabled.
local RCVotingFrame = addon:GetModule("RCVotingFrame")
local originalCols = {unpack(RCVotingFrame.scrollCols)}

local newestVersionDetected = RCEPGP.version
local currentAwardingGPs = {}

local session = 1

function RCEPGP:GetEPGPdb()
    if not addon:Getdb().epgp then
        addon:Getdb().epgp = {}
        self:SetDefaults()
    end
    return addon:Getdb().epgp
end

function RCEPGP:OnInitialize()
    self:RegisterMessage("RCCustomGPRuleChanged", "OnMessageReceived")
    self:RegisterMessage("RCMLAwardSuccess", "OnMessageReceived")
    self:RegisterMessage("RCSessionChangedPre", "OnMessageReceived")

    self:RegisterComm("RCLC_EPGP", "OnCommReceived")
    self:RegisterComm("RCLootCouncil", "OnCommReceived")

    self:RegisterEvent("PLAYER_LOGIN", "OnEvent")
    self:RegisterEvent("GROUP_JOINED", "OnEvent")

    EPGP.RegisterCallback(self, "StandingsChanged", self.UpdateVotingFrame)

    self:SecureHook(RCVotingFrame, "OnEnable", "AddGPEditBox")
    self:AddRightClickMenu(_G["RCLootCouncil_VotingFrame_RightclickMenu"], RCVotingFrame.rightClickEntries, self.rightClickEntries)
    if ExtraUtilities then
        self:SecureHook(ExtraUtilities, "SetupColumns", function() self:SetupColumns() end)
        self:SecureHook(ExtraUtilities, "UpdateColumn", function() self:SetupColumns() end)
    end
    self:DisableGPPopup()
    self:EnableGPTooltip()
    self:DisablezhCNProfanityFilter()
    self:OptionsTable()
    self:AddGPOptions()
    self:AddChatCommand()
    self:AddAnnouncement()
    self:SetupColumns()

    -- Added in v2.0
    local lastVersion = self:GetEPGPdb().version
    if not lastVersion then lastVersion = "1.9.2" end
    self:SecureHook(RCLootCouncil, "UpdateDB", function() self:GetEPGPdb().version = version end)

    if self:CompareVersion(lastVersion, "2.0.0") == -1 then
        self:UpdateAnnounceKeyword_v2_0_0()
    end
    if self:CompareVersion(tocVersion, "2.0.0") == -1 then
        self:ShowNeedRestartDialog(version)
    end
    self:GetEPGPdb().version = version

    self:EPGPDkpReloadedSettingToRC()
    self:RCToEPGPDkpReloadedSetting()
    self:Add0GPSuffixToRCAwardButtons()

    self.initialize = true
end

function RCEPGP:OnMessageReceived(msg, ...)
    self:DebugPrint("RCEPGP_OnMessageReceived", msg)
    if msg == "RCCustomGPRuleChanged" then
        self:DebugPrint("Refresh menu due to GP rule changed.")
        self:UpdateGPEditbox()
        self:RefreshMenu(level)
    elseif msg == "RCMLAwardSuccess" then
        local session, winner, status = unpack({...})
        if winner then
            local gp = self:GetCurrentAwardingGP(session)
            local item = RCVotingFrame:GetLootTable() and RCVotingFrame:GetLootTable()[session] and RCVotingFrame:GetLootTable()[session].link
            if item and gp and gp ~= 0 then
                EPGP:IncGPBy(winner, item, gp)
                self:Debug("Awarded GP: ", winner, item, gp)
            end
        end
    elseif msg == "RCSessionChangedPre" then
        local s = unpack({...})
        session = s
        self:UpdateGPEditbox()
    end
end

function RCEPGP:OnCommReceived(prefix, serializedMsg, distri, sender)
    local test, command, data = self:Deserialize(serializedMsg)
    if prefix == "RCLootCouncil" then
        -- data is always a table to be unpacked
        local test, command, data = addon:Deserialize(serializedMsg)
        if addon:HandleXRealmComms(RCVotingFrame, command, data, sender) then return end

        if test then
            if command == "change_response" then
                self:DebugPrint("Refresh menu due to change response.")
                self:RefreshMenu(1)
            end
        end
    elseif prefix == "RCLC_EPGP" then
        self:DebugPrint("RCEPGP_OnCommReceived_RCLC_EPGP", serializedMsg, distri, sender)
        if test then
            if command == "version" then
                local otherVersion = data
                if self:CompareVersion(newestVersionDetected, otherVersion) == -1 then
                    self:Print(string.format("New Version %s detected. Please update the addon.", otherVersion))
                    newestVersionDetected = otherVersion
                end
                self:DebugPrint("Other version received by comm: ", otherVersion)
            end
        end
    end
end

function RCEPGP:OnEvent(event, ...)
    self:DebugPrint("RCEPGP_OnEvent", event, ...)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(5, function() self:SendVersion("GUILD") end)
    elseif event == "GROUP_JOINED" then
        C_Timer.After(5, function() self:SendVersion("RAID") end)
    end
end

function RCEPGP.UpdateVotingFrame()
    RCVotingFrame:Update()
end

function RCEPGP:CompareVersion(v1, v2)
    local a1, b1, c1 = strsplit(".", v1)
    a1 = tonumber(a1 or 0); b1 = tonumber(b1 or 0); c1 = tonumber(c1 or 0)
    local a2, b2, c2 = strsplit(".", v2)
    a2 = tonumber(a2 or 0); b2 = tonumber(b2 or 0); c2 = tonumber(c2 or 0)
    if a1 < a2 then return -1 end
    if a1 > a2 then return 1 end
    if b1 < b2 then return -1 end
    if b1 > b2 then return 1 end
    if c1 < c2 then return -1 end
    if c1 > c2 then return 1 end
    return 0
end

function RCEPGP:UpdateGPEditbox()
    local lootTable = RCVotingFrame:GetLootTable()
    if lootTable then
        local t = lootTable[session]
        if t then
            local gp = GP:GetValue(t.link) or 0
            RCVotingFrame.frame.gpEditbox:SetNumber(gp)
        end
    end
end

function RCEPGP:DisablezhCNProfanityFilter()
    if GetLocale() == "zhCN" then
        SetCVar("profanityFilter", "0")
    end
    self:DebugPrint("Diable profanity filter of zhCN client.")
end

-- We only want to disable GP popup of EPGP(dkp reloaded) when RCLootCouncil Voting Frame is opening.
-- Restore to previous setting of EPGP loot popup when Voting Frame closes.
local isDisablingEPGPPopup = false
local isEPGPPopupEnabled = false
function RCEPGP:DisableGPPopup()
    if EPGP and EPGP.GetModule then
        local loot = EPGP:GetModule("loot")
        if loot then
            self:SecureHook(RCVotingFrame, "Show", function()
                local loot = EPGP:GetModule("loot")
                if not isDisablingEPGPPopup then
                    isEPGPPopupEnabled = loot.db.profile.enabled
                end
                loot.db.profile.enabled = false
                loot:Disable()
                isDisablingEPGPPopup = true
                self:DebugPrint("GP Popup of EPGP(dkp reloaded) disabled")
            end)

            self:SecureHook(RCVotingFrame, "Hide", function()
                C_Timer.After(5, function() -- Delay it because loot event may be triggered slight after Session ends.
                    local loot = EPGP:GetModule("loot")
                    loot.db.profile.enabled = isEPGPPopupEnabled
                    if isEPGPPopupEnabled then
                        loot:Enable()
                        self:DebugPrint("GP Popup of EPGP(dkp reloaded) enabled")
                    else
                        loot:Disable()
                        self:DebugPrint("GP Popup of EPGP(dkp reloaded) disabled")
                    end
                    isDisablingEPGPPopup = false
                end)
            end)
        end
    end
end

function RCEPGP:EnableGPTooltip()
    if EPGP and EPGP.GetModule then
        local gptooltip = EPGP:GetModule("gptooltip")
        if gptooltip and gptooltip.db then
            gptooltip.db.profile.enabled = true
        end
        if gptooltip and gptooltip.Enable then
            gptooltip:Enable()
        end
    end
end

local function RemoveColumn(t, column)
    for i = 1, #t do
        if t[i] and t[i].colName == column.colName then
            table.remove(t, i)
        end
    end
end

local function ReinsertColumnAtTheEnd(t, column)
    RemoveColumn(t, column)
    table.insert(t, column)
end

function RCEPGP:SetupColumns()
    local ep =
    { name = "EP", DoCellUpdate = self.SetCellEP, colName = "ep", sortnext = self:GetScrollColIndexFromName("response"), width = 60, align = "CENTER", defaultsort = "dsc" }
    local gp =
    { name = "GP", DoCellUpdate = self.SetCellGP, colName = "gp", sortnext = self:GetScrollColIndexFromName("response"), width = 50, align = "CENTER", defaultsort = "dsc" }
    local pr =
    { name = "PR", DoCellUpdate = self.SetCellPR, colName = "pr", width = 50, align = "CENTER", comparesort = self.PRSort, defaultsort = "dsc" }
    local bid =
    { name = "Bid", DoCellUpdate = self.SetCellBid, colName = "bid", sortnext = self:GetScrollColIndexFromName("response"), width = 50, align = "CENTER",
    defaultsort = "dsc" }

    ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, ep)
    ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, gp)
    ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, pr)

    if self:GetEPGPdb().biddingEnabled then
        ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, bid)
    else
        RemoveColumn(RCVotingFrame.scrollCols, bid)
    end

    self:ResponseSortPRNext()

    if RCVotingFrame.frame then
        RCVotingFrame.frame.UpdateSt()
    end
end

function RCEPGP:GetScrollColIndexFromName(colName)
    for i, v in ipairs(RCVotingFrame.scrollCols) do
        if v.colName == colName then
            return i
        end
    end
end

function RCEPGP:ResponseSortPRNext()
    local responseIdx = self:GetScrollColIndexFromName("response")
    local prIdx = self:GetScrollColIndexFromName("pr")
    if responseIdx then
        RCVotingFrame.scrollCols[responseIdx].sortnext = prIdx
    end
end

---------------------------------------------
-- Lib-st UI functions
---------------------------------------------

-- Uppercase the first character of the string and lowercase the rest of characters.
-- Str can contain unicode characters.
local function UpperFirstLowerRest(str)
    local isFirstChar = true
    local result = ""

    for c in str:gmatch(".[\128-\191]*") do -- string can contains unicode characters.
        --https://stackoverflow.com/questions/22129516/string-sub-issue-with-non-english-characters
        if isFirstChar then
            isFirstChar = false
            result = result..c:upper()
        else
            result = result..c:lower()
        end
    end
    return result
end

-- Trying to fix some issue where RCLootCouncil handles some names differently with EPGP
-- EPGP requires fullname (name-realm) with the correct capitialization,
-- and realm name cannot contain space.
function RCEPGP:GetEPGPName(inputName)
    if not inputName then return nil end

    --------- First try to find name in the raid ------------------------------
    local name = Ambiguate(inputName, "short") -- Convert to short name to be used as the argument to UnitFullName
    local _, ourRealmName = UnitFullName("player") -- Get the name of our realm WITHOUT SPACE.

    local name, realm = UnitFullName(name) -- In order to return a name with correct capitialization, and the realm name WITHOUT SPACE.
    if name then -- Found the name in the raid
        if realm and realm ~= "" then
            return name.."-"..realm
        else
            return name.."-"..ourRealmName
        end
    else -- Name not found in raid, fix capitialiation and space in realm name manually.
        local shortName, realmName = strsplit("-", inputName)
        local shortName = UpperFirstLowerRest(shortName)
        realmName = realmName:gsub(" ", "") -- Eliminate space in the name
        return shortName.."-"..realmName
    end
end

local COLOR_RED = "|cFFFF0000"
local COLOR_GREY = "|cFF808080"

function RCEPGP.SetCellEP(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
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

function RCEPGP.SetCellGP(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
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

function RCEPGP.SetCellPR(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
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
        frame.text:SetText(string.format("%.4g", pr))
    end

    data[realrow].cols[column].value = pr or 0
end

function RCEPGP:GetBid(name)
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

function RCEPGP.SetCellBid(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
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

function RCEPGP.PRSort(table, rowa, rowb, sortbycol)
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
function RCEPGP:AddGPEditBox()
    if not RCVotingFrame.frame.gpString then
        local gpstr = RCVotingFrame.frame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        gpstr:SetPoint("CENTER", RCVotingFrame.frame.content, "TOPLEFT", 300, - 60)
        gpstr:SetText("GP: ")
        gpstr:Show()
        gpstr:SetTextColor(1, 1, 0, 1) -- Yellow
        RCVotingFrame.frame.gpString = gpstr
    end


    local editbox_name = "RCLootCouncil_GP_EditBox"
    if not RCVotingFrame.frame.gpEditbox then
        local editbox = _G.CreateFrame("EditBox", editbox_name, RCVotingFrame.frame.content, "AutoCompleteEditBoxTemplate")
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

        editbox:SetPoint("LEFT", RCVotingFrame.frame.gpString, "RIGHT", 10, 0)
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
        end)

        -- Clear focus when rightclick menu opens.
        if not self:IsHooked(_G["Lib_DropDownList1"], "OnShow") then
            self:SecureHookScript(_G["Lib_DropDownList1"], "OnShow", function()
                if RCVotingFrame.frame and RCVotingFrame.frame.gpEditbox then
                    RCVotingFrame.frame.gpEditbox:ClearFocus()
                end
            end)
        end
        RCVotingFrame.frame.gpEditbox = editbox
    end
end

-- "response" needs to be the response id(Number), or the button name(not response name)
function RCEPGP:GetResponseGP(response, isTier, isRelic)
    if response == "PASS" or response == "AUTOPASS" then
        return "0%"
    end
    local responseGP = "100%"

    if isRelic and addon.db.profile.relicButtons then
        for k, v in pairs(addon.db.profile.relicButtons) do
            if v.text == response then
                responseGP = v.gp or responseGP
                break
            elseif k == response then
                responseGP = v.gp or responseGP
                break
            end
        end
    elseif isTier then
        for k, v in pairs(addon.db.profile.tierButtons) do
            if v.text == response then
                responseGP = v.gp or responseGP
                break
            elseif k == response then
                responseGP = v.gp or responseGP
                break
            end
        end
    else
        for k, v in pairs(addon.db.profile.responses) do
            if v.text == response then
                responseGP = v.gp or responseGP
                break
            elseif k == response then
                responseGP = v.gp or responseGP
                break
            end
        end
    end
    self:DebugPrint("GetResponseGP returns ", responseGP, "arguments: ", response, isTier, isRelic)
    return responseGP
end

-- responseGP: string. example: "100%", "1524"
-- itemGP: Integer. The gear point of the item
-- Return: return type is always integer
-- If responseGP is percentage, return responseGP*itemGP, else return responseGP
function RCEPGP:GetFinalGP(responseGP, itemGP)
    local gp
    if string.match(responseGP, "^%d+$") then
        gp = tonumber(responseGP)
    else -- responseGP is percentage like 55%
        local coeff = tonumber(string.match(responseGP, "%d+"))/100
        gp = math.floor(coeff * itemGP)
    end
    return gp
end

function RCEPGP:AddRightClickMenu(menu, RCEntries, myEntries)
    menu.RCEPGPMenu = true
    for level, entries in ipairs(myEntries) do
        table.sort(entries, function(i, j) return i.pos < j.pos end)
        for id=1, #entries do
            local entry = entries[id]
            table.insert(RCEntries[level], entry.pos, entry)
        end
    end
end

-- Refresh the current menu if it is a RCEPGP menu.
function RCEPGP:RefreshMenu(level)
    local menu = Lib_UIDropDownMenu_GetCurrentDropDown()
    if not menu then return end
    if not menu.RCEPGPMenu then return end
    if not Lib_DropDownList1:IsShown() then return end
    if menu.initialize then
        Lib_DropDownList1.numButtons = 0
        menu.initialize(menu, level, menu.menuList)
    end
end

function RCEPGP:GetGPAndResponseGPText(gp, responseGP)
    local text =  "("..gp.." GP)"
    if string.match(responseGP, "^%d+%%") then
        text = "("..gp.." GP, "..responseGP..")"
    end
    return text
end

local function GetGPInfo(name)
    local lootTable = RCVotingFrame:GetLootTable()
    if lootTable and lootTable[session] and lootTable[session].candidates
    and name and lootTable[session].candidates[name] then
        local data = lootTable[session].candidates[name]
        local responseGP = RCEPGP:GetResponseGP(data.response, data.isTier, data.isRelic)
        local editboxGP = RCVotingFrame.frame.gpEditbox:GetNumber()
        local gp = RCEPGP:GetFinalGP(responseGP, editboxGP)
        local item = lootTable[session].link
        local bid = RCEPGP:GetBid(name)
        return data, name, item, responseGP, gp, bid
    else -- Error occurs
        return nil, "UNKNOWN", "UNKNOWN", "UNKNOWN", 0, 0 -- nil protection
    end
end

RCEPGP.rightClickEntries = {
    { -- Level 1
        { -- Button 1
            pos = 2,
            hidden = function() return not RCEPGP:GetEPGPdb().biddingEnabled end,
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

function RCEPGP:GetCurrentAwardingGP(session)
    return currentAwardingGPs[session] or 0
end

-- Dialog input is the same as RCLOOTCOUNCIL_CONFIRM_AWARD, plus "gp" and "resonseGP".
LibDialog:Register("RCEPGP_CONFIRM_AWARD", {
    text = "something_went_wrong",
    icon = "",
    on_show = function(self, data)
        RCLootCouncilML.AwardPopupOnShow(self, data)
        if data.gp then
            local text = self.text:GetText().." "..RCEPGP:GetGPAndResponseGPText(data.gp, data.responseGP)
            self.text:SetText(text)
        end
    end,
    buttons = {
        { text = L["Yes"],
            on_click = function(self, data)
                currentAwardingGPs[data.session] = data and data.gp or 0
                RCLootCouncilML.AwardPopupOnClickYes(self, data) -- GP Award is handled in RCEPGP:OnMessageReceived()
                currentAwardingGPs[data.session] = 0
            end,
        },
        { text = L["No"],
            on_click = function(self, data)
                RCLootCouncilML.AwardPopupOnClickNo(self, data)
            end,
        },
    },
    hide_on_escape = true,
    show_while_dead = true,
})

function RCEPGP:AddChatCommand()
    addon:CustomChatCmd(self, "OpenOptions", LEP["chat_commands"], "EPGP", "epgp")
end

function RCEPGP:AddAnnouncement()
    if RCLootCouncilML.awardStrings then -- Requires RCLootCouncil v2.5
        local function GetEPGPInfo(name, session)
            name = self:GetEPGPName(name)
            local ep = "?"
            local gp = "?"
            local pr = "?"
            local newgp = "?"
            local newpr = "?"
            ep, gp = EPGP:GetEPGP(name)
            if ep and gp then
                pr = string.format("%.4g", ep / gp)
            end

            if ep and gp then
                newgp = math.floor(gp + self:GetCurrentAwardingGP(session) + 0.5)
                newpr = string.format("%.4g", ep / newgp)
            end

            if not ep then ep = "?" end
            if not gp then gp = "?" end

            return ep, gp, pr, newgp, newpr
        end

        RCLootCouncilML.awardStrings['#diffgp#'] = function(name, _, _, _, session) return self:GetCurrentAwardingGP(session) end
        RCLootCouncilML.awardStrings['#ep#'] = function(name, _, _, _, session) return select(1, GetEPGPInfo(name, session)) end
        RCLootCouncilML.awardStrings['#gp#'] = function(name, _, _, _, session) return select(2, GetEPGPInfo(name, session)) end
        RCLootCouncilML.awardStrings['#pr#'] = function(name, _, _, _, session) return select(3, GetEPGPInfo(name, session)) end
        RCLootCouncilML.awardStrings['#newgp#'] = function(name, _, _, _, session) return select(4, GetEPGPInfo(name, session)) end
        RCLootCouncilML.awardStrings['#newpr#'] = function(name, _, _, _, session) return select(5, GetEPGPInfo(name, session)) end

        L["announce_awards_desc2"] = L["announce_awards_desc2"].." "..LEP["announce_awards_desc2"]
        addon.options.args.mlSettings.args.announcementsTab.args.awardAnnouncement.args.outputDesc.name = L["announce_awards_desc2"]
    end
    RCEPGP:Debug("Added EPGP award text keyword.")
end

function RCEPGP:UpdateAnnounceKeyword_v2_0_0()
    for i=1, #addon:Getdb().awardText do
        local text = addon:Getdb().awardText[i].text
        if text then
            if not text:find('#diffgp#') then text = text:gsub('#diffgp', '#diffgp#') end
            if not text:find('#ep#') then text = text:gsub('#ep', '#ep#') end
            if not text:find('#gp#') then text = text:gsub('#gp', '#gp#') end
            if not text:find('#pr#') then text = text:gsub('#pr', '#pr#') end
            if not text:find('#newgp#') then text = text:gsub('#newgp', '#newgp#') end
            if not text:find('#newpr#') then text = text:gsub('#newpr', '#newpr#') end
            addon:Getdb().awardText[i].text = text
        end
    end
    RCEPGP:Debug("Updated award text keyword to v2.0.0.")
end

function RCEPGP:SendVersion(channel)
    if not IsInGuild() and channel == "GUILD" then return end
    if not IsInGroup() and (channel == "RAID" or channel == "PARTY") then return end
    local serializedMsg = self:Serialize("version", RCEPGP.version)
    local _, a, b = self:Deserialize(serializedMsg)
    self:SendCommMessage("RCLC_EPGP", serializedMsg, channel)
    RCEPGP:Debug("Sent version ", serializedMsg, channel)
end

function RCEPGP:ShowNeedRestartDialog()
    StaticPopupDialogs["RCEPGP_NEED_RESTART"] = {
        text = "RCLootCouncil-EPGP v%s update requires full restart of the client. Some features of the addon don't work until client restarts.",
        button1 = "I'll restart the client.",
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show ("RCEPGP_NEED_RESTART", version)
end

function RCEPGP:EPGPDkpReloadedSettingToRC()
    self:GetEPGPdb().EPGPDkpReloadedDB = {}
    self:GetEPGPdb().EPGPDkpReloadedDB.children = {}
    if EPGP.db and EPGP.db.children then
        for module, entry in pairs(EPGP.db.children) do
            if module ~= "log" then -- Not gonna sync "log" module because it is too big. Probably will sync it with RCHistory Later.
                self:GetEPGPdb().EPGPDkpReloadedDB.children[module] = {}
                -- link the table to the table of EPGP settings.
                self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile = EPGP.db.children[module].profile
            end
        end
    end
    RCEPGP:Debug("Save EPGP(dkp reloaded) settings to RCLootCouncil Saved Variables.")
end

function RCEPGP:RCToEPGPDkpReloadedSetting()
    if self:GetEPGPdb().EPGPDkpReloadedDB and self:GetEPGPdb().EPGPDkpReloadedDB.children then
        for module, entry in pairs(self:GetEPGPdb().EPGPDkpReloadedDB.children) do
            if self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile then
                for key, value in pairs(self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile) do
                    EPGP.db.children[module].profile[key] = value
                end
            end
        end
    end
    self:EPGPDkpReloadedSettingToRC()
    self:Debug("Restore EPGP(dkp reloaded) settings from RCLootCouncil Saved Variables.")
end

function RCEPGP:Add0GPSuffixToRCAwardButtons()
    for _, entry in ipairs(RCVotingFrame.rightClickEntries[1]) do
        if entry.text == L["Award"] then
            entry.text = L["Award"].." (0 GP)"
        end
        if entry.text == L["Award for ..."] then
            entry.text = L["Award for ..."].." (0 GP)"
        end
    end
    self:DebugPrint("Added 0GP suffix to RC Award Buttons.")
end

-- debug print and log
function RCEPGP:Debug(msg, ...)
    if RCEPGP.debug then
        RCEPGP:DebugPrint(msg, ...)
    end
    addon:DebugLog("EPGP: ", msg, ...)
end

function RCEPGP:DebugPrint(msg, ...)
	if RCEPGP.debug then
		if select("#", ...) > 0 then
			print("|cffcb6700rcepgpdebug:|r "..tostring(msg).."|cffff6767", ...)
		else
			print("|cffcb6700rcepgpdebug:|r "..tostring(msg).."|r")
		end
	end
end
