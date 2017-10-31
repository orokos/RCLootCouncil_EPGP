-- A library to compute Gear Points for items as described in
-- http://code.google.com/p/epgp/wiki/GearPoints
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomGP = RCEPGP:NewModule("RCCustomGP", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0", "AceTimer-3.0")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")

local MAJOR_VERSION = "LibGearPoints-1.2"

-- Backup functions of LibGearPoints from EPGP
local functionOldLibGearPoints = {}
local versionOldLibGearPoints = LibStub.minors[MAJOR_VERSION]
local oldLib = LibStub:GetLibrary(MAJOR_VERSION)
for funcName, func in pairs(oldLib) do
    functionOldLibGearPoints[funcName] = func
end

local db

function RCCustomGP:OnInitialize()
	db = RCEPGP:GetEPGPdb()
	local success = self:LocalizeItemStatusText()
	if not success then
		return self:ScheduleTimer("OnInitialize", 1)
	end
	self.itemInfoCache = {}
	self.gpCache = {}
    self.GPVariables = {
        { name = "ilvl", help = LEP["gp_variable_ilvl_help"], value = function(itemLink) return select(2, self:GetRarityIlvlSlot(itemLink)) or 0 end, },
        { unCached = true, name = "slotWeights", help = LEP["gp_variable_slotWeights_help"], value = function(itemLink) return RCCustomGP:GetSlotWeights(itemLink) or 0 end, },
        -- if unCached is true, then we don't cache it in RCCustomGP.itemInfoCache
        { name = "isToken", help = LEP["gp_variable_isToken_help"], value = function(itemLink) return self:IsItemToken(itemLink) and 1 or 0 end, },
        { name = "hasAvoid", help = LEP["gp_variable_hasAvoid_help"], value = function(itemLink) return self:GetBonusInfo(itemLink).hasAvoid and 1 or 0 end, },
        { name = "hasLeech", help = LEP["gp_variable_hasLeech_help"], value = function(itemLink) return self:GetBonusInfo(itemLink).hasLeech and 1 or 0 end, },
        { name = "hasSpeed", help = LEP["gp_variable_hasSpeed_help"], value = function(itemLink) return self:GetBonusInfo(itemLink).hasSpeed and 1 or 0 end, },
        { name = "hasIndes", help = LEP["gp_variable_hasIndes_help"], value = function(itemLink) return self:GetBonusInfo(itemLink).hasIndes and 1 or 0 end, },
        { name = "numSocket", help = LEP["gp_variable_numSocket_help"], value = function(itemLink) return self:GetBonusInfo(itemLink).numSocket or 0 end, },
        { name = "rarity", help = LEP["gp_variable_rarity_help"], value = function(itemLink) return select(1, self:GetRarityIlvlSlot(itemLink)) or 0 end, },
        { name = "itemID", help = LEP["gp_variable_itemID_help"], value = function(itemLink) return addon:GetItemIDFromLink(itemLink) or 0 end, },
        { name = "isNormal", help = LEP["gp_variable_isNormal_help"], value = function(itemLink) return self:IsItemNormalDifficulty(itemLink) and 1 or 0 end, },
        { name = "isHeroic", help = LEP["gp_variable_isHeroic_help"], value = function(itemLink) return self:IsItemHeroicDifficulty(itemLink) and 1 or 0 end, },
        { name = "isMythic", help = LEP["gp_variable_isMythic_help"], value = function(itemLink) return self:IsItemMythicDifficulty(itemLink) and 1 or 0 end, },
        { name = "isWarforged", help = LEP["gp_variable_isWarforged_help"], value = function(itemLink) return self:IsItemWarforged(itemLink) and 1 or 0 end, },
        { name = "isTitanforged", help = LEP["gp_variable_isTitanforged_help"], value = function(itemLink) return self:IsItemTitanforged(itemLink) and 1 or 0 end, },
        { name = "link", help = LEP["gp_variable_link_help"], value = function(itemLink) return itemLink or 0 end, },
    }
    self.INVTYPESlots = {
		INVTYPE_HEAD		    = "HeadSlot",
		INVTYPE_NECK		    = "NeckSlot",
		INVTYPE_SHOULDER	    = "ShoulderSlot",
		INVTYPE_CLOAK		    = "BackSlot",
		INVTYPE_CHEST		    = "ChestSlot",
        INVTYPE_ROBE		    = "ChestSlot", -- Be careful that INVTYPE_CHEST and INVTYPE_ROBE shares chest slot
		INVTYPE_WRIST		    = "WristSlot",
		INVTYPE_HAND		    = "HandsSlot",
		INVTYPE_WAIST		    = "WaistSlot",
		INVTYPE_LEGS		    = "LegsSlot",
		INVTYPE_FEET		    = "FeetSlot",
        INVTYPE_FINGER		    = "FingerSlot",
        INVTYPE_TRINKET		    = "TrinketSlot",
        INVTYPE_RELIC           = "RelicSlot",
    }
    self:RegisterMessage("RCUpdateDB", "OnMessageReceived")
	self:RegisterMessage("RCEPGPConfigTableChanged", "OnMessageReceived")
    self.initialize = true
end

function RCCustomGP:OnMessageReceived(msg, ...)
	RCEPGP:DebugPrint("RCCustomGP:OnMessageReceived", msg, ...)
	if msg == "RCUpdateDB" then
		db = RCEPGP:GetEPGPdb()
	elseif msg == "RCEPGPConfigTableChanged" then
		if "customGP" == select(1, ...) then
			RCEPGP:DebugPrint("Wipe GP cache due to custom GP rule changed.")
			wipe(self.gpCache)
			self:SendMessage("RCCustomGPRuleChanged")
		end
	end
end

--------------------Start of GP Calculation -------------------------------

LibStub.minors[MAJOR_VERSION] = 10200
local lib = LibStub:GetLibrary(MAJOR_VERSION)

local recent_items_queue = {}
local recent_items_map = {}

local function UpdateRecentLoot(itemLink)
    if recent_items_map[itemLink] then return end

    table.insert(recent_items_queue, 1, itemLink)
    recent_items_map[itemLink] = true
    if #recent_items_queue > 30 then
        local itemLink = table.remove(recent_items_queue)
        recent_items_map[itemLink] = nil
    end
end

function lib:GetNumRecentItems()
    if not db.customGP.customGPEnabled then
        return functionOldLibGearPoints["GetNumRecentItems"](oldLib)
    end
    return #recent_items_queue
end

function lib:GetRecentItemLink(i)
    if not db.customGP.customGPEnabled then
        return functionOldLibGearPoints["GetRecentItemLink"](oldLib, i)
    end
    return recent_items_queue[i]
end

function lib:GetValue(item)
    if not db.customGP.customGPEnabled then
        return functionOldLibGearPoints["GetValue"](oldLib, item)
    end
    if not item then return end
    if not RCCustomGP.initialize then return end

    local _, itemLink, rarity, level, _, itemClass, itemSubClass, _, equipLoc = GetItemInfo(item)
    if not itemLink then return end
	if level < 463 and (not RCCustomGP:GetTokenInfo(itemLink)) then
		return nil, nil, level, rarity, equipLoc
	end

    UpdateRecentLoot(itemLink)

    if RCCustomGP.gpCache[itemLink] then -- Return GP directly if it is cached.
        return RCCustomGP.gpCache[itemLink]
    end

    local itemID = addon:GetItemIDFromLink(itemLink)

    local itemData = {}

    if RCCustomGP.itemInfoCache[itemLink] then
        itemData = RCCustomGP.itemInfoCache[itemLink]
        for _, entry in ipairs(RCCustomGP.GPVariables) do
            if entry.unCached then
                local variableName = entry.name
                local variableValue = entry.value(itemLink)
                itemData[variableName] = variableValue
            end
        end
    else
        for _, entry in ipairs(RCCustomGP.GPVariables) do
            local variableName = entry.name
            local variableValue = entry.value(itemLink)
            itemData[variableName] = variableValue
            RCEPGP:DebugPrint("CustomGPVariable", variableName, variableValue)
        end
        RCCustomGP.itemInfoCache[itemLink] = itemData
    end

	local high = tonumber(RCEPGP:SecureExecString(db.customGP.formula, itemData)) or 0
	high = math.floor(0.5 + high)

    RCEPGP:DebugPrint("ItemGPUpdate", itemLink, high)
    RCCustomGP.gpCache[itemLink] = high
    return high, nil, level, rarity, equipLoc
end

--------------------Get the information of item -------------------------------

function RCCustomGP:GetTokenInfo(itemLink)
    local id = addon:GetItemIDFromLink(itemLink)
    local ilvl = addon:GetTokenIlvl(itemLink)
    local slot = RCTokenTable[id]
    return ilvl, slot
end

function RCCustomGP:GetRarityIlvlSlot(itemLink)
    local _, itemLink, rarity, level, _, itemClass, itemSubClass, _, equipLoc = GetItemInfo(itemLink)
    local itemBonuses = select(17, addon:DecodeItemLink(itemLink))
    if addon.db.global.localizedSubTypes[itemSubClass] == "Artifact Relic" then
        equipLoc = "INVTYPE_RELIC"
    end
    local slot = self.INVTYPESlots[equipLoc]
    if self:GetTokenInfo(itemLink) then
		level, slot = self:GetTokenInfo(itemLink)
    end
    return rarity, level, slot
end

local ITEM_BONUS_TYPE = {
    [40] = "AVOIDANCE", -- avoidance, no material value
    [41] = "LEECH", -- leech, no material value
    [42] = "SPEED", -- speed, arguably useful, so 25 gp
    [43] = "INDESTRUCT", -- indestructible, no material value
    [523] = "SOCKET", -- extra socket
    [563] = "SOCKET", -- extra socket
    [564] = "SOCKET", -- extra socket
    [565] = "SOCKET", -- extra socket
    [572] = "SOCKET", -- extra socket
    [1808] = "SOCKET", -- extra socket
}

function RCCustomGP:GetBonusInfo(itemLink)
    local itemBonuses = select(17, addon:DecodeItemLink(itemLink))
    local hasAvoid = false
    local hasLeech = false
    local hasSpeed = false
    local hasIndes = false
    local numSocket = 0

    for _, value in pairs(itemBonuses) do
        local type = ITEM_BONUS_TYPE[value]
        if type == "AVOIDANCE" then
            hasAvoid = true
        elseif type == "LEECH" then
            hasLeech = true
        elseif type == "SPEED" then
            hasSpeed = true
        elseif type == "INDESTRUCT" then
            hasIndes = true
        elseif type == "SOCKET" then
            numSocket = numSocket + 1
        end
    end
    return {hasAvoid = hasAvoid, hasLeech = hasLeech, hasSpeed = hasSpeed, hasIndes = hasIndes, numSocket = numSocket}
end

function RCCustomGP:GetSlotWeights(itemLink)
    local slot = select(3, RCCustomGP:GetRarityIlvlSlot(itemLink))
    if slot and db.customGP[slot] then
        return tonumber(db.customGP[slot])
    end
end

function RCCustomGP:IsItemToken(itemLink)
    return not not self:GetTokenInfo(itemLink)
end

----- Get the difficulty/forged status of item --------------------------------------
local tooltip = LibStub("LibItemUtils-1.0").tooltip

local function GetTextLeft2(link)
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(link)
    if tooltip:NumLines() > 1 then
        local line = getglobal(tooltip:GetName()..'TextLeft2')
        if line and line.GetText then
            local text = line:GetText()
            if text:find("|c") then
                text = text:sub(11, - 3) -- remove color code
            end
            tooltip:Hide()
            return text
        end
    end
    tooltip:Hide()
    return ""
end

function RCCustomGP:IsItemHasKeyword(item, keyword)
    if (not keyword) or keyword == "" then return false end
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(item)
    if tooltip:NumLines() > 1 then
        for i = 2, 5 do -- Check 4 lines, just in case.
            local line = getglobal(tooltip:GetName()..'TextLeft'..i)
            if line and line.GetText then
                local text = line:GetText()
                if text and text:find(keyword)then
                    tooltip:Hide()
                    return true
                end
            end
        end
    end
    tooltip:Hide()
    return false
end

local statusTextItems =
{
    Heroic = "|cffa335ee|Hitem:147425::::::::2:71::5:3:3562:1497:3528:::|h[Cord of Pilfered Rosaries]|h|r",
    Mythic = "|cffa335ee|Hitem:147425::::::::2:71::6:3:3563:1512:3528:::|h[Cord of Pilfered Rosaries]|h|r",
    LFR = "|cffa335ee|Hitem:147424::::::::2:71::4:3:3564:1467:3528:::|h[Treads of Violent Intrusion]|h|r",
    Warforged = "|cffa335ee|Hitem:147425::::::::2:71::3:3:3561:1487:3336:::|h[Cord of Pilfered Rosaries]|h|r",
    Titanforged = "|cffa335ee|Hitem:147424::::::::2:71::3:3:3561:1507:3337:::|h[Treads of Violent Intrusion]|h|r",
}

-- store the item status text in the saved variable\
-- @param return if success. Should call this function again if failed.
function RCCustomGP:LocalizeItemStatusText()
	if not addon.db.global.localizedItemStatus then
		addon.db.global.localizedItemStatus = {}
	end
	if addon.db.global.localizedItemStatus.created ~= GetLocale() then
		addon.db.global.localizedItemStatus.created = false
	end

	local success = true
	for key, item in pairs(statusTextItems) do
		if not addon.db.global.localizedItemStatus[key] or not addon.db.global.localizedItemStatus.created then
			GetItemInfo(item)
			addon.db.global.localizedItemStatus[key] = GetTextLeft2(item)
			if not addon.db.global.localizedItemStatus[key] or addon.db.global.localizedItemStatus[key] == "" then
				success = false
				addon.db.global.localizedItemStatus[key] = nil
			end
		end
	end

	if success then
		addon.db.global.localizedItemStatus.created = GetLocale()
	end
	return success
end

function RCCustomGP:IsItemNormalDifficulty(item)
    return not (self:IsItemHeroicDifficulty(item) or self:IsItemMythicDifficulty(item) or self:IsItemLFRDifficulty(item) )
end

function RCCustomGP:IsItemHeroicDifficulty(item)
    return self:IsItemHasKeyword(item, addon.db.global.localizedItemStatus.Heroic)
end

function RCCustomGP:IsItemMythicDifficulty(item)
    return self:IsItemHasKeyword(item, addon.db.global.localizedItemStatus.Mythic)
end

function RCCustomGP:IsItemLFRDifficulty(item)
    return self:IsItemHasKeyword(item, addon.db.global.localizedItemStatus.LFR)
end

function RCCustomGP:IsItemWarforged(item)
    return self:IsItemHasKeyword(item, addon.db.global.localizedItemStatus.Warforged)
end

function RCCustomGP:IsItemTitanforged(item)
    return self:IsItemHasKeyword(item, addon.db.global.localizedItemStatus.Titanforged)
end
