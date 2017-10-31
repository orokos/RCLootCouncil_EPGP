local DEBUG = false
--@debug@
DEBUG = true
--@end-debug@
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:NewModule("RCEPGP", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceBucket-3.0")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local RCVotingFrame = addon:GetModule("RCVotingFrame")

local currentAwardingGP = 0
local db

function RCEPGP:OnInitialize()
	-- MAKESURE: Edit the following versions every update, and should also update the version in TOC file.
	self.version = "2.1.1"
	self.testVersion = "Release" -- format: Release/Beta/Alpha.num, testVersion compares only by number. eg. "Alpha.2" > "Beta.1"
	self.tocVersion = GetAddOnMetadata("RCLootCouncil_EPGP", "Version")
	self.testTocVersion = GetAddOnMetadata("RCLootCouncil_EPGP", "X-TestVersion")
	self.lastVersionNeedingRestart = "2.0.0"
	self.lastVersionResetSetting = "2.0.0"
	self.minRCVersion = "2.6.0"

	self.debug = DEBUG
	self.newestVersionDetected = self.version
	self.newestTestVersionDetected = self.testVersion
	self.isNewInstall = (addon:Getdb().epgp == nil)
	db = self:GetEPGPdb()
	local meta = getmetatable(self) 	-- Set the addon name for self:Print()
	meta.__tostring = function() return "RCLootCouncil-EPGP" end
	setmetatable(self, meta)

	self.defaults = {
		sendEPGPSettings = true,
		biddingEnabled = false,
		customGP = {
			customGPEnabled = false,
			RelicSlot     = "0.667",
			TrinketSlot   = "1.25",
			HeadSlot      = "1",
			ChestSlot     = "1",
			LegsSlot      = "1",
			ShoulderSlot  = "0.75",
			HandsSlot     = "0.75",
			WaistSlot     = "0.75",
			FeetSlot      = "0.75",
			NeckSlot      = "0.56",
			FingerSlot    = "0.56",
			BackSlot      = "0.56",
			WristSlot     = "0.56",
			formula = "1000 * 2 ^ (-915/30) * 2 ^ (ilvl/30) * slotWeights + hasSpeed * 25 + numSocket * 200",
		},
	}
	addon.defaults.profile.epgp = self.defaults
	addon.db:RegisterDefaults(addon.defaults)

    if addon:VersionCompare(addon.version, self.minRCVersion) then
		self:ShowNotification(format(LEP["rc_version_below_min_notification"], self.minRCVersion, addon.version))
    end
    -- Added in v2.0
    local lastVersion = db.version
    if not lastVersion then lastVersion = "1.9.2" end
    if (not self.isNewInstall) and addon:VersionCompare(self.tocVersion, self.lastVersionNeedingRestart) then
		self:ShowNotification(format(LEP["need_restart_notification"], self.version.."-"..self.testVersion))
    end

    db.version = self.version
    db.tocVersion = self.tocVersion
    db.testVersion = self.testVersion
    db.testTocVersion = self.testTocVersion

    if (not self.isNewInstall) and addon:VersionCompare(lastVersion, "2.0.0") then
        self:UpdateAnnounceKeyword_v2_0_0()
    end
    if (not self.isNewInstall) and addon:VersionCompare(lastVersion, self.lastVersionResetSetting) then
		self:ShowNotification(format(LEP["setting_reset_notification"], self.version.."-"..self.testVersion))
    end

    self:RegisterMessage("RCMLAwardSuccess", "OnMessageReceived")
    self:RegisterMessage("RCUpdateDB", "OnMessageReceived")

    self:RegisterComm("RCLootCouncil", "OnCommReceived")

    self:RegisterEvent("PLAYER_LOGIN", "OnEvent")
    self:RegisterEvent("GROUP_JOINED", "OnEvent")

    self:AddGPOptions()
    self:AddOptions()

    self:AddSlashCmds()
    self:AddAnnouncement()

    self:EPGPDkpReloadedSettingToRC()

	if GetLocale() == "zhCN" then
		SetCVar("profanityFilter", "0")
		self:DebugPrint("Diable profanity filter of zhCN client.")
	end
    self.initialize = true
end

-- MAKESURE all messages are registered
-- MAKESURE all empty settings reseted to default when RCUpdateDB
-- MAKESURE statement are executed after the OnMessageReceived of RCLootCouncil if needed.
function RCEPGP:OnMessageReceived(msg, ...)
    self:DebugPrint("RCEPGP:OnMessageReceived", msg, ...)
	if msg == "RCMLAwardSuccess" then
        local session, winner, status = unpack({...})
        if (not RCVotingFrame:GetLootTable()) or (not RCVotingFrame:GetLootTable()[session]) then
            return
        end

        if winner then
            local gp = self:GetCurrentAwardingGP()
			RCVotingFrame:GetLootTable()[session].gpAwarded = gp -- This line exists because of undo button in rightclick menu
			addon:SendCommand("group", "RCEPGP_awarded", {session=session, winner=winner, gpAwarded=gp})

			local item = RCVotingFrame:GetLootTable() and RCVotingFrame:GetLootTable()[session] and RCVotingFrame:GetLootTable()[session].link
			if item and gp and gp ~= 0 then
				EPGP:IncGPBy(RCEPGP:GetEPGPName(winner), item, gp) -- Fix GP not awarded for Russian name.
				self:Debug("Awarded GP: ", self:GetEPGPName(winner), item, gp)
			end
        end
    elseif msg == "RCUpdateDB" then
		db = self:GetEPGPdb()
        db.version = self.version
        db.tocVersion = self.tocVersion
        db.testVersion = self.testVersion
        db.testTocVersion = self.testTocVersion
        self:RCToEPGPDkpReloadedSetting()
    end
end

function RCEPGP:OnCommReceived(prefix, serializedMsg, distri, sender)
    local test, command, data = self:Deserialize(serializedMsg)
    if prefix == "RCLootCouncil" then
        -- data is always a table to be unpacked
        local test, command, data = addon:Deserialize(serializedMsg)
        if addon:HandleXRealmComms(self, command, data, sender) then return end

        if test then
            if command == "RCEPGP_VersionBroadcast" or command == "RCEPGP_VersionReply" then
                local otherVersion, otherTestVersion = unpack(data)

                -- Only report test version updates if a test version is installed.
                if self:IsTestVersion(self.testVersion) or (not self:IsTestVersion(otherTestVersion)) then
                    if addon:VersionCompare(self.newestVersionDetected, otherVersion) then
                        self:Print(format(LEP["new_version_detected"], self.version.."-"..self.testVersion, otherVersion.."-"..otherTestVersion))
                        self.newestVersionDetected = otherVersion
                        self.newestTestVersionDetected = otherTestVersion
                    elseif self.newestVersionDetected == otherVersion and self:TestVersionCompare(self.newestTestVersionDetected, otherTestVersion) then
                        self:Print(format(LEP["new_version_detected"], self.version.."-"..self.testVersion, otherVersion.."-"..otherTestVersion))
                        self.newestTestVersionDetected = otherTestVersion
                    end
                end
                self:DebugPrint("RCEPGP:OnCommReceived", command, unpack(data))
                if command == "RCEPGP_VersionBroadcast" and (not UnitIsUnit("player", Ambiguate(sender, "short"))) then
                    addon:SendCommand(sender, "RCEPGP_VersionReply", self.version, self.testVersion)
                end
            end
        end
    end
end

function RCEPGP:OnEvent(event, ...)
    self:DebugPrint("RCEPGP:OnEvent", event, ...)
    if event == "PLAYER_LOGIN" then
        self:ScheduleTimer(function() addon:SendCommand("guild", "RCEPGP_VersionBroadcast", self.version, self.testVersion) end, 5)
    elseif event == "GROUP_JOINED" then
        self:ScheduleTimer(function() addon:SendCommand("group", "RCEPGP_VersionBroadcast", self.version, self.testVersion) end, 2)
    end
end

function RCEPGP:GetEPGPdb()
    if not addon:Getdb().epgp then
        addon:Getdb().epgp = {}
    end
    return addon:Getdb().epgp
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

---------------------------------------------
-- Name functions
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

---------------------------------------------
-- GP functions
---------------------------------------------

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

---------------------------------------------
-- Debug functions
---------------------------------------------

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

---------------------------------------------
-- UI functions
---------------------------------------------

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

function RCEPGP:DeepCopy(dest, src, cleanCopy)
	if cleanCopy and type(dest) == "table" then
		wipe(dest)
	end
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
