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
		self:ShowNotification(format(LEP["rc_version_below_min_notification"], self.minRCVersion, addon.version))
    end
    -- Added in v2.0
    local lastVersion = self:GetEPGPdb().version
    if not lastVersion then lastVersion = "1.9.2" end
    if (not self.isNewInstall) and addon:VersionCompare(self.tocVersion, self.lastVersionNeedingRestart) then
		self:ShowNotification(format(LEP["need_restart_notification"], self.version.."-"..self.testVersion))
    end

    self:GetEPGPdb().version = self.version
    self:GetEPGPdb().tocVersion = self.tocVersion
    self:GetEPGPdb().testVersion = self.testVersion
    self:GetEPGPdb().testTocVersion = self.testTocVersion

    if (not self.isNewInstall) and addon:VersionCompare(lastVersion, "2.0.0") then
        self:UpdateAnnounceKeyword_v2_0_0()
    end
    if (not self.isNewInstall) and addon:VersionCompare(lastVersion, self.lastVersionResetSetting) then
		self:ShowNotification(format(LEP["setting_reset_notification"], self.version.."-"..self.testVersion))
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

    self:RegisterMessage("RCMLAwardSuccess", "OnMessageReceived")
    self:RegisterMessage("RCMLAwardFailed", "OnMessageReceived")
    self:RegisterMessage("RCSessionChangedPre", "OnMessageReceived")
    self:RegisterMessage("RCUpdateDB", "OnMessageReceived")

    self:RegisterComm("RCLootCouncil", "OnCommReceived")

    self:RegisterEvent("PLAYER_LOGIN", "OnEvent")
    self:RegisterEvent("GROUP_JOINED", "OnEvent")
    self:RegisterEvent("SCREENSHOT_SUCCEEDED", "OnEvent")
    self:RegisterEvent("SCREENSHOT_FAILED", "OnEvent")

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


    self:EPGPDkpReloadedSettingToRC()
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
                    addon:SendCommand(sender, "RCEPGP_VersionReply", self.version, self.testVersion)
                end
            end
        end
    end
end

function RCEPGP:OnEvent(event, ...)
    self:DebugPrint("OnEvent", event, ...)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(5, function() addon:SendCommand("guild", "RCEPGP_VersionBroadcast", self.version, self.testVersion) end)
    elseif event == "GROUP_JOINED" then
        C_Timer.After(2, function() addon:SendCommand("group", "RCEPGP_VersionBroadcast", self.version, self.testVersion) end)
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

function RCEPGP:SetCurrentAwardingGP(gp)
	currentAwardingGP = gp
end

function RCEPGP:GetCurrentAwardingGP()
    return currentAwardingGP
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



function RCEPGP:RemoveColumn(t, column)
    for i = 1, #t do
        if t[i] and t[i].colName == column.colName then
            table.remove(t, i)
        end
    end
end

function RCEPGP:ReinsertColumnAtTheEnd(t, column)
    self:RemoveColumn(t, column)
    table.insert(t, column)
end
