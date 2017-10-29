local DEBUG = false
--@debug@
DEBUG = false
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:NewModule("RCEPGP", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")
local LibDialog = LibStub("LibDialog-1.0")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")

-- Set the addon name for self:Print()
local RCEPGPMetaTable = getmetatable(RCEPGP)
RCEPGPMetaTable.__tostring = function() return "RCLootCouncil-EPGP" end
setmetatable(RCEPGP, RCEPGPMetaTable)

-- MAKESURE: Edit the following versions every update, and should also update the version in TOC file.
RCEPGP.version = "2.1.1"
RCEPGP.testVersion = "Release"
							   -- format: Release/Beta/Alpha.num
							   -- testVersion compares only by number. eg. "Alpha.2" > "Beta.1"
RCEPGP.tocVersion = GetAddOnMetadata("RCLootCouncil_EPGP", "Version")
RCEPGP.testTocVersion = GetAddOnMetadata("RCLootCouncil_EPGP", "X-TestVersion")

RCEPGP.lastVersionNeedingRestart = "2.0.0"
RCEPGP.lastVersionResetSetting = "2.0.0"
RCEPGP.minRCVersion = "2.6.0"

RCEPGP.isNewInstall = nil

RCEPGP.debug = DEBUG

local ExtraUtilities = addon:GetModule("RCExtraUtilities", true) -- nil if ExtraUtilites not enabled.
local RCVotingFrame = addon:GetModule("RCVotingFrame")

local newestVersionDetected = RCEPGP.version
local newestTestVersionDetected = RCEPGP.testVersion

local currentAwardingGP = 0

local session = 1

function RCEPGP:GetEPGPdb()
    if not addon:Getdb().epgp then
        addon:Getdb().epgp = {}
        if self.isNewInstall == nil then self.isNewInstall = true end
    else
        if self.isNewInstall == nil then self.isNewInstall = false end
    end
    return addon:Getdb().epgp
end

function RCEPGP:OnInitialize()
    if addon:VersionCompare(addon.version, self.minRCVersion) then
        self:ShowRCVersionBelowMinNotification()
    end
    -- Added in v2.0
    local lastVersion = self:GetEPGPdb().version
    if not lastVersion then lastVersion = "1.9.2" end
    if (not self.isNewInstall) and addon:VersionCompare(self.tocVersion, self.lastVersionNeedingRestart) then
        self:ShowNeedRestartNotification()
    end

    self:GetEPGPdb().version = self.version
    self:GetEPGPdb().tocVersion = self.tocVersion
    self:GetEPGPdb().testVersion = self.testVersion
    self:GetEPGPdb().testTocVersion = self.testTocVersion

    if (not self.isNewInstall) and addon:VersionCompare(lastVersion, "2.0.0") then
        self:UpdateAnnounceKeyword_v2_0_0()
    end
    if (not self.isNewInstall) and addon:VersionCompare(lastVersion, self.lastVersionResetSetting) then
        self:ShowSettingResetNotification()
    end

    self.generalDefaults = {
        sendEPGPSettings = true,
        biddingEnabled = false,
        screenshotOnAward = false,
        screenshotOnTestAward = false,
        screenshotOnlyWithGP = false,
        screenshotOnAwardLater = false,
    }
    self:SetdbDefaults(self:GetGeneraldb(), self.generalDefaults, false)

    self:RegisterMessage("RCCustomGPRuleChanged", "OnMessageReceived")
    self:RegisterMessage("RCMLAwardSuccess", "OnMessageReceived")
    self:RegisterMessage("RCMLAwardFailed", "OnMessageReceived")
    self:RegisterMessage("RCSessionChangedPre", "OnMessageReceived")
    self:RegisterMessage("RCUpdateDB", "OnMessageReceived")

    self:RegisterComm("RCLootCouncil", "OnCommReceived")

    self:RegisterEvent("PLAYER_LOGIN", "OnEvent")
    self:RegisterEvent("GROUP_JOINED", "OnEvent")
    self:RegisterEvent("SCREENSHOT_SUCCEEDED", "OnEvent")
    self:RegisterEvent("SCREENSHOT_FAILED", "OnEvent")

    EPGP.RegisterCallback(self, "StandingsChanged", self.UpdateVotingFrame)

    self:SecureHook(RCVotingFrame, "OnEnable", "AddWidgetsIntoVotingFrame")
    self:AddRightClickMenu(_G["RCLootCouncil_VotingFrame_RightclickMenu"], RCVotingFrame.rightClickEntries, self.rightClickEntries)
    if ExtraUtilities then
        self:SecureHook(ExtraUtilities, "SetupColumns", function() self:SetupColumns() end)
        self:SecureHook(ExtraUtilities, "UpdateColumn", function() self:SetupColumns() end)
    end
    self:DisableGPPopup()
    self:EnableGPTooltip()
    self:DisablezhCNProfanityFilter()

    self:AddOptions()
    self:RefreshOptionsTable()

    self:AddGPOptions()
    self:AddSlashCmds()
    self:AddAnnouncement()
    self:SetupColumns()

    self:EPGPDkpReloadedSettingToRC()

    self:Add0GPSuffixToRCAwardButtons()
    self.initialize = true
end

-- MAKESURE all messages are registered
-- MAKESURE all empty settings reseted to default when RCUpdateDB
-- MAKESURE statement are executed after the OnMessageReceived of RCLootCouncil if needed.
function RCEPGP:OnMessageReceived(msg, ...)
    self:DebugPrint("ReceiveMessage", msg)
    if msg == "RCCustomGPRuleChanged" then
        self:DebugPrint("Refresh menu due to GP rule changed.")
        self:UpdateGPEditbox()
        self:RefreshMenu(level)
    elseif msg == "RCMLAwardSuccess" then
        local session, winner, status = unpack({...})
        if (not RCVotingFrame:GetLootTable()) or (not RCVotingFrame:GetLootTable()[session]) then
            return
        end
        if self:GetGeneraldb().screenshotOnAward and ((not self:GetGeneraldb().screenshotOnlyWithGP) or (self:GetCurrentAwardingGP() and self:GetCurrentAwardingGP() > 0))then
            if status == "normal" or (status == "test_mode" and self:GetGeneraldb().screenshotOnTestAward) then
                RCVotingFrame:GetLootTable()[session].awarded = winner
                RCVotingFrame:Update() -- Force to update the string thats shows the winner immediately. Should use a better way if RCLootCouncil changes API.
                RCVotingFrame:GetLootTable()[session].gpAwarded = self:GetCurrentAwardingGP() -- duplicate, reason is the same as above. Should try to find a better way...
                self:UpdateGPAwardString()
                Screenshot()
            end
        end

        if winner then
            local gp = self:GetCurrentAwardingGP()
            local item = RCVotingFrame:GetLootTable() and RCVotingFrame:GetLootTable()[session] and RCVotingFrame:GetLootTable()[session].link
            if item and gp and gp ~= 0 then
                EPGP:IncGPBy(self:GetEPGPName(winner), item, gp) -- Fix GP not awarded for Russian name.
                self:Debug("Awarded GP: ", self:GetEPGPName(winner), item, gp)
            end
            addon:SendCommand("group", "RCEPGP_awarded", {session=session, winner=winner, gpAwarded=gp})
        end
    elseif msg == "RCMLAwardFailed" then
        local session, winner, status = unpack({...})
        if status == "bagged" and self:GetGeneraldb().screenshotOnAward and self:GetGeneraldb().screenshotOnAwardLater then
            Screenshot()
        end
    elseif msg == "RCSessionChangedPre" then
        local s = unpack({...})
        session = s
        self:UpdateGPEditbox()
        self:UpdateGPAwardString()
    elseif msg == "RCUpdateDB" then
        self:GetEPGPdb().version = self.version
        self:GetEPGPdb().tocVersion = self.tocVersion
        self:GetEPGPdb().testVersion = self.testVersion
        self:GetEPGPdb().testTocVersion = self.testTocVersion
        self:RCToEPGPDkpReloadedSetting()
        self:SetdbDefaults(self:GetGeneraldb(), self.generalDefaults, false) -- should after self:RCToEPGPDkpReloadedSetting()
    end
end

function RCEPGP:OnCommReceived(prefix, serializedMsg, distri, sender)
    local test, command, data = self:Deserialize(serializedMsg)
    if prefix == "RCLootCouncil" then
        -- data is always a table to be unpacked
        local test, command, data = addon:Deserialize(serializedMsg)
        if addon:HandleXRealmComms(RCVotingFrame, command, data, sender) then return end

        if test then
            if command == "change_response" or command == "response" then
                self:DebugPrint("ReceiveComm", command, unpack(data))
                C_Timer.After(0, function() self:RefreshMenu(1) end) -- to ensure this is run after RCVotingFrame:OnCommReceived of "change_response"
            elseif command == "RCEPGP_awarded" then
                -- Dont award GP here.
                self:DebugPrint("ReceiveComm", command, unpack(data))
                local data = unpack(data)
                local session, winner, gpAwarded = data.session, data.winner, data.gpAwarded
                if (not RCVotingFrame:GetLootTable()) or (not RCVotingFrame:GetLootTable()[session]) then
                    return
                end
                RCVotingFrame:GetLootTable()[session].gpAwarded = gpAwarded
                self:UpdateGPAwardString()
            elseif command == "RCEPGP_VersionBroadcast" or command == "RCEPGP_VersionReply" then
                local otherVersion, otherTestVersion = unpack(data)

                -- Only report test version updates if a test version is installed.
                if self:IsTestVersion(self.testVersion) or (not self:IsTestVersion(otherTestVersion)) then
                    if addon:VersionCompare(newestVersionDetected, otherVersion) then
                        self:Print(format(LEP["new_version_detected"], self.version.."-"..self.testVersion, otherVersion.."-"..otherTestVersion))
                        newestVersionDetected = otherVersion
                        newestTestVersionDetected = otherTestVersion
                    elseif newestVersionDetected == otherVersion and self:TestVersionCompare(newestTestVersionDetected, otherTestVersion) then
                        self:Print(format(LEP["new_version_detected"], self.version.."-"..self.testVersion, otherVersion.."-"..otherTestVersion))
                        newestTestVersionDetected = otherTestVersion
                    end
                end
                self:DebugPrint("ReceiveComm", command, unpack(data))
                if command == "RCEPGP_VersionBroadcast" and (not UnitIsUnit("player", Ambiguate(sender, "short"))) then
                    self:ReplyVersion(sender)
                end
            end
        end
    end
end

function RCEPGP:OnEvent(event, ...)
    self:DebugPrint("OnEvent", event, ...)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(5, function() self:BroadcastVersion("guild") end)
    elseif event == "GROUP_JOINED" then
        C_Timer.After(2, function() self:BroadcastVersion("group") end)
    elseif event == "SCREENSHOT_SUCCEEDED" then
        if RCVotingFrame:GetFrame() and RCVotingFrame:GetFrame():IsShown() then
            self:Print(_G.SCREENSHOT_SUCCESS)
        end
    elseif event == "SCREENSHOT_FAILED" then
        if RCVotingFrame:GetFrame() and RCVotingFrame:GetFrame():IsShown() then
            self:Print("|cffff0000".._G.SCREENSHOT_FAILURE.."|r")
        end
    end
end

-- Return true if test version 1 is older than test version 2
-- testVersion looks like: Beta.1, and we only compare the number after the dot.
function RCEPGP:TestVersionCompare(v1, v2)
    if v1:lower():find("release") then
        return false
    end
    if v2:lower():find("release") then
        return true
    end
    local testName1, testVer1 = strsplit(".", v1)
    local testName2, testVer2 = strsplit(".", v2)
    return tonumber(testVer1) < tonumber(testVer2)
end

function RCEPGP:IsTestVersion(v)
    return v and (v:lower():find("alpha") or v:lower():find("beta"))
end

function RCEPGP.UpdateVotingFrame()
    -- Dont try to use RCVotingFrame:GetFrame() here, it causes lag on login.w
    RCVotingFrame:Update()
end

function RCEPGP:UpdateGPEditbox()
    local lootTable = RCVotingFrame:GetLootTable()
    if lootTable then
        local t = lootTable[session]
        if t then
            local gp = GP:GetValue(t.link) or 0
            RCVotingFrame:GetFrame().gpEditbox:SetNumber(gp)
        end
    end
end

function RCEPGP:UpdateGPAwardString()
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

function RCEPGP:DisablezhCNProfanityFilter()
    if GetLocale() == "zhCN" then
        SetCVar("profanityFilter", "0")
        self:DebugPrint("Diable profanity filter of zhCN client.")
    end
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

    if self:GetGeneraldb().biddingEnabled then
        ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, bid)
    else
        RemoveColumn(RCVotingFrame.scrollCols, bid)
    end

    self:ResponseSortPRNext()

    if RCVotingFrame:GetFrame() then
        RCVotingFrame:GetFrame().UpdateSt()
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
        if not realmName then
            realmName = ourRealmName
        end
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
        frame.text:SetText(format("%.4g", pr))
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
function RCEPGP:AddWidgetsIntoVotingFrame()
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
    self:DebugPrint("RCEPGP:GetResponseGP returns ", responseGP, "arguments: ", response, isTier, isRelic)
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

function RCEPGP:GetCurrentAwardingGP()
    return currentAwardingGP
end

function RCEPGP:AddAnnouncement()
    if RCLootCouncilML.awardStrings then -- Requires RCLootCouncil v2.5
        local function GetEPGPInfo(name)
            name = self:GetEPGPName(name)
            local ep = "?"
            local gp = "?"
            local pr = "?"
            local newgp = "?"
            local newpr = "?"
            ep, gp = EPGP:GetEPGP(name)
            if ep and gp then
                pr = format("%.4g", ep / gp)
            end

            if ep and gp then
                newgp = math.floor(gp + self:GetCurrentAwardingGP() + 0.5)
                newpr = format("%.4g", ep / newgp)
            end

            if not ep then ep = "?" end
            if not gp then gp = "?" end

            return ep, gp, pr, newgp, newpr
        end

        RCLootCouncilML.awardStrings['#diffgp#'] = function(name) return self:GetCurrentAwardingGP() end
        RCLootCouncilML.awardStrings['#ep#'] = function(name) return select(1, GetEPGPInfo(name)) end
        RCLootCouncilML.awardStrings['#gp#'] = function(name) return select(2, GetEPGPInfo(name)) end
        RCLootCouncilML.awardStrings['#pr#'] = function(name) return select(3, GetEPGPInfo(name)) end
        RCLootCouncilML.awardStrings['#newgp#'] = function(name) return select(4, GetEPGPInfo(name)) end
        RCLootCouncilML.awardStrings['#newpr#'] = function(name) return select(5, GetEPGPInfo(name)) end

        L["announce_awards_desc2"] = L["announce_awards_desc2"].." "..LEP["announce_awards_desc2"]
        addon.options.args.mlSettings.args.announcementsTab.args.awardAnnouncement.args.outputDesc.name = L["announce_awards_desc2"]
    end
    self:Debug("Added EPGP award text keyword.")
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
    self:Debug("Updated award text keyword to v2.0.0.")
end

function RCEPGP:BroadcastVersion(target)
    addon:SendCommand(target, "RCEPGP_VersionBroadcast", self.version, self.testVersion)
    self:DebugPrint("SendComm", "RCEPGP_VersionBroadcast", self.version, self.testVersion)
end

function RCEPGP:ReplyVersion(target)
    addon:SendCommand(target, "RCEPGP_VersionReply", self.version, self.testVersion)
    self:DebugPrint("SendComm", "RCEPGP_VersionReply", self.version, self.testVersion)
end

function RCEPGP:ShowSettingResetNotification()
    StaticPopupDialogs["RCEPGP_SETTING_RESET"] = {
        text = LEP["setting_reset_notification"],
        button1 = OKAY,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show ("RCEPGP_SETTING_RESET", self.version.."-"..self.testVersion)
    self:Print(format(LEP["setting_reset_notification"], self.version..self.testVersion))
end

function RCEPGP:ShowNeedRestartNotification()
    StaticPopupDialogs["RCEPGP_NEED_RESTART"] = {
        text = LEP["need_restart_notification"],
        button1 = OKAY,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show ("RCEPGP_NEED_RESTART", self.version.."-"..self.testVersion)
    self:Print(format(LEP["need_restart_notification"], self.version.."-"..self.testVersion))
end

function RCEPGP:ShowRCVersionBelowMinNotification()
    StaticPopupDialogs["RCEPGP_RC_VERSION_BELOW_MIN"] = {
        text = LEP["rc_version_below_min_notification"],
        button1 = OKAY,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show ("RCEPGP_RC_VERSION_BELOW_MIN", self.minRCVersion, addon.version)
    self:Print(format(LEP["rc_version_below_min_notification"], self.minRCVersion, addon.version))
end

-- Link table in RCEPGP's saved variable with EPGP's saved variable together.
-- Used to send EPGP(dkp reloaded) settings with RC sync
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
    self:Debug("Save EPGP(dkp reloaded) settings to RCLootCouncil Saved Variables.")
end

local function deepcopy(dest, src)
    if type(src) ~= "table" then return end
    if type(dest) ~= "table" then return end
    for key, value in pairs(src) do
        if type(value) == "table" and type(dest[key]) == "table" then
            deepcopy(dest[key], src[key])
        else
            dest[key] = value
        end
    end
end

-- Restore settings stored in RC to EPGP(dkp reloaded)
function RCEPGP:RCToEPGPDkpReloadedSetting()
    if not self:GetGeneraldb().sendEPGPSettings then return end

    local syncHappened = false
    if self:GetEPGPdb().EPGPDkpReloadedDB and self:GetEPGPdb().EPGPDkpReloadedDB.children then
        for module, entry in pairs(self:GetEPGPdb().EPGPDkpReloadedDB.children) do
            if module ~= "log" then -- Not gonna sync "log" module because it is too big. Probably will sync it with RCHistory Later.

                if EPGP.db.children[module].profile and self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile and
                    EPGP.db.children[module].profile ~= self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile then
                    syncHappened = true
                end

                local mod = EPGP:GetModule(module)
                -- Copy settings
                deepcopy(EPGP.db.children[module].profile, self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile)

                if mod then -- Enable module if needed
                    if self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile.enabled then
                        mod:Enable()
                    else
                        mod:Disable()
                    end
                end
            end
        end
    end

    if not syncHappened then return end -- No actual sync happened. (This can happen when sync from a user without RCLootCoucil-EPGP installed).

    self:Debug("Restore EPGP(dkp reloaded) settings from RCLootCouncil Saved Variables.")
    self:EPGPDkpReloadedSettingToRC() -- Link table in RCEPGP's saved variable with EPGP's saved variable together.
    self:Print(LEP["EPGP_DKP_Reloaded_settings_received"])
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
    if self.debug then
        self:DebugPrint(msg, ...)
    end
    addon:DebugLog("EPGP: ", msg, ...)
end

function RCEPGP:DebugPrint(msg, ...)
	if self.debug then
		if select("#", ...) > 0 then
			print("|cffcb6700rcepgpdebug:|r "..tostring(msg).."|cffff6767", ...)
		else
			print("|cffcb6700rcepgpdebug:|r "..tostring(msg).."|r")
		end
	end
end

function RCEPGP:SetdbDefaults(db, defaults, restoreDefaults)
    for info, value in pairs(defaults) do
        if restoreDefaults or db[info] == nil or db[info] == "" then
            db[info] = value
        end
    end
end


function RCEPGP:GetGeneraldb()
    if not self:GetEPGPdb().general then
        self:GetEPGPdb().general = {}
    end
    return self:GetEPGPdb().general
end

function RCEPGP.GeneralOptionGetter(info)
    return RCEPGP:GetGeneraldb()[info[#info]]
end

function RCEPGP.GeneralOptionSetter(info, value)
    RCEPGP:GetGeneraldb()[info[#info]] = value
end

function RCEPGP:GeneralRestoreToDefault()
    self:SetdbDefaults(self:GetGeneraldb(), self.generalDefaults, true)
    self:SendMessage("RCEPGPGeneralOptionRestoreToDefault")
end

-- Get the amount of last GP operations with given name and reason.
-- Reason can be not specified.
function RCEPGP:GetLastGPAmount(name, reason)
    local logMod = EPGP:GetModule("log")
    if logMod and logMod.db and logMod.db.profile and logMod.db.profile.log then
        for i = #logMod.db.profile.log, 1, - 1 do

            local entry = logMod.db.profile.log[i]
            local timestamp, kind, name2, reason2, amount = unpack(entry)
            if kind == 'GP' and name2 == name  then
                if not reason then
                    return amount, reason2
                elseif reason == reason2 then
                    return amount, reason2
                else
                    local _, link = GetItemInfo(reason)
                    local _, link2 = GetItemInfo(reason2)
                    if link and link == link2 then
                        return amount, reason2
                    end
                end
            end
        end
    end
    return 0
end

-- /rc gp name reason [amount]
function RCEPGP:IncGPBy(name, reason, amount)
    if name == "help" then
        self:Print(LEP["slash_rc_gp_help_detailed"])
        return
    end
    if not CanEditOfficerNote() then
        self:Print(LEP["no_permission_to_edit_officer_note"])
        return
    end
    if name == "%p" then
        name = self:GetEPGPName("player")
    elseif name == "%t" then
        if not UnitExists("target") then
            self:Print(L["You must select a target"])
            return
        end
        name = self:GetEPGPName("target")
    end

    if not amount then
        amount = LibStub:GetLibrary("LibGearPoints-1.2"):GetValue(reason)
    else
        amount = tonumber(amount)
    end

    if EPGP:CanIncGPBy(reason, amount) then
        EPGP:IncGPBy(name, reason, amount)
    else
        self:Print(LEP["slash_rc_command_failed"])
    end
end

-- /rc undogp name reason
-- Undo the previous GP operations to 'name' with 'reason'
-- Reason by be nil to match the most recent GP operation to 'name'
function RCEPGP:UndoGP(name, reason)
    if name == "help" then
        self:Print(LEP["slash_rc_undogp_help_detailed"])
        return
    end
    if not CanEditOfficerNote() then
        self:Print(LEP["no_permission_to_edit_officer_note"])
        return
    end
    if name == "%p" then
        name = RCEPGP:GetEPGPName("player")
    elseif name == "%t" then
        if not UnitExists("target") then
            RCEPGP:Print(LEP["error_no_target"])
            return
        end
        name = self:GetEPGPName("target")
    end

    -- TODO: More error checking?
    local amount, reason2  = self:GetLastGPAmount(name, reason)
    if EPGP:CanIncGPBy(reason, amount) then
        EPGP:IncGPBy(name, reason2, -amount)
    else
        self:Print(LEP["slash_rc_command_failed"])
    end
end
