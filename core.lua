--@debug@
if LibDebug then LibDebug() end
--@end-debug@

-- Upvalue for better performance
local Ambiguate = Ambiguate
local CopyTable = CopyTable
local GetAddOnMetadata = GetAddOnMetadata
local GetItemInfo = GetItemInfo
local GetLocale = GetLocale
local Lib_DropDownList1 = Lib_DropDownList1
local Lib_UIDropDownMenu_GetCurrentDropDown = Lib_UIDropDownMenu_GetCurrentDropDown
local SetCVar = SetCVar
local UnitFullName = UnitFullName
local format = format
local getmetatable = getmetatable
local ipairs = ipairs
local math = math
local pairs = pairs
local select = select
local setmetatable = setmetatable
local string = string
local strsplit = strsplit
local table = table
local tonumber = tonumber
local tostring = tostring
local type = type
local unpack = unpack

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:NewModule("RCEPGP", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceBucket-3.0")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")
local GP = LibStub("LibGearPoints-1.2")
local GS = LibStub("LibGuildStorage-1.2")

local currentAwardingGP = 0

function RCEPGP:OnInitialize()
	-- MAKESURE: Edit the following versions every update, and should also update the version in TOC file.
	self.version = "2.2.2"
	self.tVersion = nil -- format: nil/Beta.num/Alpha.num, testVersion compares only by number. eg. "Alpha.2" > "Beta.1"
	self.tocVersion = GetAddOnMetadata("RCLootCouncil_EPGP", "Version")
	self.testTocVersion = GetAddOnMetadata("RCLootCouncil_EPGP", "X-TestVersion") -- "" (emtyp string)/Beta.num/Alpha.num
	self.lastVersionNeedingRestart = "2.2.0"
	self.lastVersionResetSetting = "2.2.0"
	self.minRCVersion = "2.7.6"

	self.debug = false
	local meta = getmetatable(self) 	-- Set the addon name for self:Print()
	meta.__tostring = function() return "RCLootCouncil-EPGP" end
	setmetatable(self, meta)

	self.defaults = {
		profile = {
			gp = {
				responses = {
					['*'] = "100%",
				},
				tierButtons = {
					['*'] = "100%",
				},
				relicButtons = {
					['*'] = "100%",
				}
			},
			columns = {
				ep = true,
				gp = true,
				pr = true,
				bid = true,
				bidTimesPR = true,
			},
			dkpMode = false,
			bid = {
				bidEnabled = false,
				bidMode = "prRelative",
				defaultBid = "",
				minBid = "0",
				maxBid = "10000",
				minNewPR = "1",
			},
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
			customEP = {
				EPFormulas = {
					count = 1,
					[1] = {
						name = "Default",
					},
					['**'] = {
						name = "EPGP_Default",
						reason = "reason",
						amount = "100",
						period = "15",

						online = 1,
						offline = 1,
						inGroup = 1,
						standby = 1,
						calendarSignedUp = 0,
						completelyNotInGroup = 0,
						isRank0 = 1,
						isRank1 = 1,
						isRank2 = 1,
						isRank3 = 1,
						isRank4 = 1,
						isRank5 = 1,
						isRank6 = 1,
						isRank7 = 1,
						isRank8 = 1,
						isRank9 = 1,
						notInGuild = 1,
						inZones = 1,
						notInZones = 1,
						zones = "",
					},
				}
			}
		}
	}

	-- Clean garbage in SV
	addon.db.profile.epgp = nil -- No longer used
	for _, v in pairs(addon.db.profile.relicButtons) do v.gp = nil end
	for _, v in pairs(addon.db.profile.tierButtons) do v.gp = nil end
    for _, v in pairs(addon.db.profile.responses) do v.gp = nil end

	addon.db:RegisterNamespace("EPGP", self.defaults)

	self.db = addon.db:GetNamespace("EPGP").profile
	addon.db:GetNamespace("EPGP").RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	addon.db:GetNamespace("EPGP").RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	addon.db:GetNamespace("EPGP").RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	self.globalDB = addon.db:GetNamespace("EPGP").global


    if addon:VersionCompare(addon.version, self.minRCVersion) then
		self:ShowNotification(format(LEP["rc_version_below_min_notification"], self.minRCVersion, addon.version))
    end
    if addon:VersionCompare(self.tocVersion, self.lastVersionNeedingRestart) then
		self:ShowNotification(format(LEP["need_restart_notification"], self.version..(self.tVersion and ("-"..self.tVersion) or "")))
    end

    local lastVersion = self.globalDB.version
    self.globalDB.version = self.version
    self.globalDB.tocVersion = self.tocVersion
    self.globalDB.tVersion = self.tVersion
    self.globalDB.testTocVersion = self.testTocVersion

    if lastVersion and addon:VersionCompare(lastVersion, self.lastVersionResetSetting) then
		self:ShowNotification(format(LEP["setting_reset_notification"], self.version..(self.tVersion and ("-"..self.tVersion) or "")))
    end

	self:RegisterMessage("RCMLAddItem", "OnMessageReceived")
	self:RegisterMessage("RCMLBuildMLdb", "OnMessageReceived")
	self:RegisterBucketMessage("RCEPGPConfigTableChanged", 2, "EPGPConfigTableChanged")

    self:AddGPOptions()
    self:AddOptions()

    self:AddSlashCmds()
    self:AddAwardAnnouncement()
	self:AddConsiderationAnnouncement()

	if GetLocale() == "zhCN" then
		SetCVar("profanityFilter", "0")
		self:DebugPrint("Disable profanity filter of zhCN client.")
	end
    self.initialize = true -- Set initialize to true, so option can be initialized correctly.
end

function RCEPGP:RefreshConfig(event, database, profile)
	self:Debug("RefreshConfig", event, database, profile)
	self.db = addon.db:GetNamespace("EPGP").profile
end

-- MAKESURE all messages are registered
-- MAKESURE statement are executed after the OnMessageReceived of RCLootCouncil if needed.
function RCEPGP:OnMessageReceived(msg, ...)
    self:DebugPrint("RCEPGP:OnMessageReceived", msg, ...)
	if msg == "RCMLAddItem" then
		local item, entry = ...
		entry.gp = GP:GetValue(item)
	elseif msg == "RCMLBuildMLdb" then
		local MLdb = ...
		self:BuildMLdb(MLdb)
    end
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
	local name, realm
    name = Ambiguate(inputName, "short") -- Convert to short name to be used as the argument to UnitFullName
    local _, ourRealmName = UnitFullName("player") -- Get the name of our realm WITHOUT SPACE.

    name, realm = UnitFullName(name) -- In order to return a name with correct capitialization, and the realm name WITHOUT SPACE.
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
        shortName = UpperFirstLowerRest(shortName)
        realmName = realmName:gsub(" ", "") -- Eliminate space in the name
        return shortName.."-"..realmName
    end
end

---------------------------------------------
-- GP functions
---------------------------------------------
function RCEPGP:GetCurrentAwardingGP()
	return currentAwardingGP
end

function RCEPGP:SetCurrentAwardingGP(gp)
	currentAwardingGP = gp
end

function RCEPGP:IncEPSecure(name, reason, amount, mass, undo)
	name = self:GetEPGPName(name)
	if not GS:IsCurrentState() then
		return self:ScheduleTimer("IncEPSecure", 0.5, name, reason, amount, mass, undo)
	end
	if not EPGP:CanIncEPBy(reason, amount) then
		self:Debug("IncEPSecure fails CanIncEPBy", name, reason, amount, mass, undo)
		return
	end
	EPGP:IncEPBy(name, reason, amount, mass, undo)
end

function RCEPGP:IncGPSecure(name, reason, amount)
	name = self:GetEPGPName(name)
	if self.db.dkpMode then -- If in DKP mode, decrease EP instead of increase GP.
		return self:IncEPSecure(name, reason, -amount)
	end
	if not GS:IsCurrentState() then
		return self:ScheduleTimer("IncGPSecure", 0.5, name, reason, amount)
	end
	if not EPGP:CanIncGPBy(reason, amount) then
		self:Debug("IncGPSecure fails CanIncGPBy", name, reason, amount)
		return
	end
	EPGP:IncGPBy(name, reason, amount)
end

-- "response" needs to be the response id(Number)
-- Only works for ML
function RCEPGP:GetResponseGP(response, isTier, isRelic)
    if response == "PASS" or response == "AUTOPASS" then
        return "0%"
    end
    local responseGP
    if isRelic and addon.db.profile.relicButtons then
		responseGP = self.db.gp.relicButtons[response]
    elseif isTier then
		responseGP = self.db.gp.tierButtons[response]
    else
		responseGP = self.db.gp.responses[response]
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
    if responseGP and string.match(responseGP, "^%d+%%") then
        text = "("..gp.." GP, "..responseGP..")"
    end
    return text
end

-- Get the amount of last EP/GP operations with given name and reason.
-- Reason can be not specified.
function RCEPGP:GetLastEPGPAmount(kind, name, reason)
	name = self:GetEPGPName(name)
    local logMod = EPGP:GetModule("log")
    if logMod and logMod.db and logMod.db.profile and logMod.db.profile.log then
        for i = #logMod.db.profile.log, 1, - 1 do

            local entry = logMod.db.profile.log[i]
            local _, kind2, name2, reason2, amount = unpack(entry)
            if kind2 == kind and name2 == name  then
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
			self:Print("|cffcb6700rcepgpdebug:|r "..tostring(msg).."|cffff6767", ...)
		else
			self:Print("|cffcb6700rcepgpdebug:|r "..tostring(msg).."|r")
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

---------------------------------------------
-- MLdb (Master looter's db)
---------------------------------------------

function RCEPGP:GetMLEPGPOverrideSetting(...)
	if select(1, ...) == nil then
		return nil
	end
	local mldbSetting = self:GetMLEPGPdb()
	local i = 1
	while select(i, ...) do
		local key = select(i, ...)
		if type(mldbSetting) == "table" and mldbSetting[key] then
			mldbSetting = mldbSetting[key]
		else
			mldbSetting = nil
			break
		end
		i = i + 1
	end
	if mldbSetting then
		return mldbSetting
	else
		local epgpSetting = self.db
		local j = 1
		while select(j, ...) do
			local key = select(i, ...)
			if type(epgpSetting) == "table" and epgpSetting[key] then
				epgpSetting = epgpSetting[key]
			else
				epgpSetting = nil
				break
			end
			j = j + 1
		end
		return epgpSetting
	end
end

function RCEPGP:GetMLEPGPdb()
	if not addon.mldb then
		return {}
	end
	if not addon.mldb.epgp then
		addon.mldb.epgp = {}
	end
	return addon.mldb.epgp
end

function RCEPGP:EPGPConfigTableChanged(val)
	-- The db was changed, so check if we should make a new mldb
	-- We can do this by checking if the changed value is a key in mldb
	if not addon.mldb then return RCLootCouncilML:UpdateMLdb() end -- mldb isn't made, so just make it

	for value in pairs(val) do
		for key in pairs(self:GetMLEPGPdb()) do
			if key == value then return RCLootCouncilML:UpdateMLdb() end
		end
	end
end

function RCEPGP:BuildMLdb(MLdb)
	local initialize = true
	for _, module in self:IterateModules() do
		if not module.initialize then
			initialize = false
		end
	end
	if not initialize then
		self:DebugPrint("BuildMLdb when not all modules are initialized. Retry after 1s.")
		return self:ScheduleTimer("BuildMLdb", 1, MLdb)
	end

	MLdb.epgp = {}
	MLdb.epgp.bid = CopyTable(self.db.bid)
end
