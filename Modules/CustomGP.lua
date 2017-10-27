-- A library to compute Gear Points for items as described in
-- http://code.google.com/p/epgp/wiki/GearPoints
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCLootCouncil-EPGP")
local RCCustomGP = RCEPGP:NewModule("RCCustomGP", "AceConsole-3.0", "AceEvent-3.0")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")

local MAJOR_VERSION = "LibGearPoints-1.2"

-- Backup functions of LibGearPoints from EPGP
local functionOldLibGearPoints = {}
local versionOldLibGearPoints = LibStub.minors[MAJOR_VERSION]
local oldLib = LibStub:GetLibrary(MAJOR_VERSION)
for funcName, func in pairs(oldLib) do
    functionOldLibGearPoints[funcName] = func
end

local itemInfoCache = {} -- Cache the info of items we have seen for better performance.
local gpCache = {} -- Cache the GP of items for even better performance. The gpCache must be wiped whenever the GP formula or slotweights changes.
RCCustomGP.itemInfoCache = itemInfoCache
RCCustomGP.gpCache = gpCache
-- To be set in OnInitialize
RCCustomGP.GPVariables = {}
RCCustomGP.slotsWithWeight = {}

function RCCustomGP:OnInitialize()
    self.defaults = {
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
    }
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
        { name = "itemID", help = LEP["gp_variable_itemID_help"], value = function(itemLink) return self:GetItemID(itemLink) or 0 end, },
        { name = "isNormal", help = LEP["gp_variable_isNormal_help"], value = function(itemLink) return self:IsItemNormalDifficulty(itemLink) and 1 or 0 end, },
        { name = "isHeroic", help = LEP["gp_variable_isHeroic_help"], value = function(itemLink) return self:IsItemHeroicDifficulty(itemLink) and 1 or 0 end, },
        { name = "isMythic", help = LEP["gp_variable_isMythic_help"], value = function(itemLink) return self:IsItemMythicDifficulty(itemLink) and 1 or 0 end, },
        { name = "isWarforged", help = LEP["gp_variable_isWarforged_help"], value = function(itemLink) return self:IsItemWarforged(itemLink) and 1 or 0 end, },
        { name = "isTitanforged", help = LEP["gp_variable_isTitanforged_help"], value = function(itemLink) return self:IsItemTitanforged(itemLink) and 1 or 0 end, },
        { name = "link", help = LEP["gp_variable_link_help"], value = function(itemLink) return itemLink or 0 end, },
    }
    self.slotsWithWeight = {
        RelicSlot = {
            name = _G.INVTYPE_RELIC,
            order = 1,
        },
        TrinketSlot = {
            name = _G.INVTYPE_TRINKET,
            order = 2,
        },
        HeadSlot = {
            name = _G.INVTYPE_HEAD,
            order = 3,
        },
        ChestSlot = {
            name = _G.INVTYPE_CHEST,
            order = 4,
        },
        LegsSlot = {
            name = _G.INVTYPE_LEGS,
            order = 5,
        },
        ShoulderSlot = {
            name = _G.INVTYPE_SHOULDER,
            order = 6,
        },
        HandsSlot = {
            name = _G.INVTYPE_HAND,
            order = 7,
        },
        WaistSlot = {
            name = _G.INVTYPE_WAIST,
            order = 8,
        },
        FeetSlot = {
            name = _G.INVTYPE_FEET,
            order = 9,
        },
        NeckSlot = {
            name = _G.INVTYPE_NECK,
            order = 10,
        },
        FingerSlot = {
            name = _G.INVTYPE_FINGER,
            order = 11,
        },
        BackSlot = {
            name = _G.INVTYPE_CLOAK,
            order = 12,
        },
        WristSlot = {
            name = _G.INVTYPE_WRIST,
            order = 13,
        },
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
    RCEPGP:SetdbDefaults(self:GetCustomGPdb(), self.defaults, false)
    self:SendMessage("RCCustomGPRuleChanged")
    self.initialize = true
end

function RCCustomGP:OnMessageReceived(msg, ...)
    RCEPGP:DebugPrint("RCCustomGP", "ReceiveMessage", msg)
    if msg == "RCUpdateDB" then
        RCEPGP:SetdbDefaults(self:GetCustomGPdb(), self.defaults, false)
    end
end

function RCCustomGP:GetCustomGPdb()
    if not RCEPGP:GetEPGPdb().customGP then
        RCEPGP:GetEPGPdb().customGP = {}
    end
    return RCEPGP:GetEPGPdb().customGP
end

function RCCustomGP.OptionGetter(info)
    return RCCustomGP:GetCustomGPdb()[info[#info]]
end

function RCCustomGP.OptionSetter(info, value)
    RCEPGP:DebugPrint("Wipe GP cache due to custom GP rule changed.")
    wipe(RCCustomGP.gpCache)
    RCCustomGP:SendMessage("RCCustomGPRuleChanged")
    if value == "" or value == nil then
        value = RCCustomGP.defaults[info[#info]]
    end
    RCCustomGP:GetCustomGPdb()[info[#info]] = value
end

function RCCustomGP:RestoreToDefault()
    RCEPGP:SetdbDefaults(self:GetCustomGPdb(), self.defaults, true)
    self:SendMessage("RCCustomGPRuleChanged")
end
--------------------Start of GP Calculation -------------------------------

LibStub.minors[MAJOR_VERSION] = 10200
local lib = LibStub:GetLibrary(MAJOR_VERSION)

local ItemUtils = LibStub("LibItemUtils-1.0")

-- The default quality threshold:
-- 0 - Poor
-- 1 - Uncommon
-- 2 - Common
-- 3 - Rare
-- 4 - Epic
-- 5 - Legendary
-- 6 - Artifact
local quality_threshold = 4

local recent_items_queue = {}
local recent_items_map = {}

local relicSubClass
local function GetRelicSubClassString()
    if not relicSubClass then -- If not cached obtain
        local _, itemLink, rarity, level, _, itemClass, itemSubClass, _, equipLoc = GetItemInfo(140819) -- ID of some relic
        relicSubClass = itemSubClass
    end

    return relicSubClass
end


-- Given a list of item bonuses, return the ilvl delta it represents
-- (15 for Heroic, 30 for Mythic)
local function GetItemBonusLevelDelta(itemBonuses)
    for _, value in pairs(itemBonuses) do
        -- Item modifiers for heroic are 566 and 570; mythic are 567 and 569
        if value == 566 or value == 570 then return 15 end
        if value == 567 or value == 569 then return 30 end
    end
    return 0
end

local function UpdateRecentLoot(itemLink)
    if recent_items_map[itemLink] then return end

    table.insert(recent_items_queue, 1, itemLink)
    recent_items_map[itemLink] = true
    if #recent_items_queue > 15 then
        local itemLink = table.remove(recent_items_queue)
        recent_items_map[itemLink] = nil
    end
end

function lib:GetNumRecentItems()
    if not RCCustomGP:GetCustomGPdb().customGPEnabled then
        return functionOldLibGearPoints["GetNumRecentItems"](oldLib)
    end
    return #recent_items_queue
end

function lib:GetRecentItemLink(i)
    if not RCCustomGP:GetCustomGPdb().customGPEnabled then
        return functionOldLibGearPoints["GetRecentItemLink"](oldLib, i)
    end
    return recent_items_queue[i]
end

--- Return the currently set quality threshold.
function lib:GetQualityThreshold()
    if not RCCustomGP:GetCustomGPdb().customGPEnabled then
        return functionOldLibGearPoints["GetQualityThreshold"](oldLib)
    end
    return quality_threshold
end

--- Set the minimum quality threshold.
-- @param itemQuality Lowest allowed item quality.
function lib:SetQualityThreshold(itemQuality)
    if not RCCustomGP:GetCustomGPdb().customGPEnabled then
        return functionOldLibGearPoints["SetQualityThreshold"](oldLib, itemQuality)
    end
    itemQuality = itemQuality and tonumber(itemQuality)
    if not itemQuality or itemQuality > 6 or itemQuality < 0 then
        return error("Usage: SetQualityThreshold(itemQuality): 'itemQuality' - number [0,6].", 3)
    end
    quality_threshold = itemQuality
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

function lib:GetValue(item)
    if not RCCustomGP:GetCustomGPdb().customGPEnabled then
        return functionOldLibGearPoints["GetValue"](oldLib, item)
    end
    if not item then return end
    if not RCCustomGP.initialize then return end

    local _, itemLink, rarity, level, _, itemClass, itemSubClass, _, equipLoc = GetItemInfo(item)
    if not itemLink then return end
    UpdateRecentLoot(itemLink)

    if gpCache[itemLink] then -- Return GP directly if it is cached.
        return gpCache[itemLink]
    end

    local itemID = RCCustomGP:GetItemID(itemLink)
    if level < 463 and (not RCCustomGP:GetTokenInfo(itemLink)) then
        return nil, nil, level, rarity, equipLoc
    end

    local formula, err = RCCustomGP:GetFormulaFunc()
    if not formula then
        formula, err = RCCustomGP:GetDefaultFormulaFunc()
    end

    local fenv

    local itemData = {}

    if itemInfoCache[itemLink] then
        itemData = itemInfoCache[itemLink]
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
        itemInfoCache[itemLink] = itemData
    end

    local fenv = RCEPGP:GetFuncEnv(itemData)
    formula = setfenv(formula, fenv)

    local status, value = pcall(formula)

    local high
    if status then -- No Error
        high = tonumber(value)
    else -- Error
        formula = RCCustomGP:GetDefaultFormulaFunc()
        formula = setfenv(formula, fenv)
        high = tonumber(formula())
        RCCustomGP:AnnounceRuntimeError(value)
    end

    if high then
        high = math.floor(0.5 + high)
    else
        high = 0
    end

    RCEPGP:DebugPrint("ItemGPUpdate", itemLink, high)
    gpCache[itemLink] = high
    return high, nil, level, rarity, equipLoc
end

--------------------End of GP Calculation -------------------------------

function RCCustomGP:GetTokenInfo(itemLink)
    local id = self:GetItemID(itemLink)
    local ilvl = RCTokenIlvl[id]
    local slot = RCTokenTable[id]
    return ilvl, slot
end

function RCCustomGP:GetFormulaFunc()
    local formula, err = loadstring("return "..self:GetCustomGPdb().formula)
    if not formula then
        formula, err = loadstring(self:GetCustomGPdb().formula)
    end
    return formula, err
end

function RCCustomGP:GetDefaultFormulaFunc()
    local formula, err = loadstring(self.defaults.formula)
    if not formula then
        formula, err = loadstring("return "..self.defaults.formula)
    end
    return formula, err
end

local ANNOUNCE_INTERVAL = 2
local lastErrorTime
function RCCustomGP:AnnounceRuntimeError(errMsg)
    if (not lastErrorTime) or GetTime() - lastErrorTime > ANNOUNCE_INTERVAL then
        lastErrorTime = GetTime()
        self:Print(LEP["announce_formula_runtime_error"].."\n"..errMsg)
    end
end

local ItemUtils = LibStub:GetLibrary("LibItemUtils-1.0")
local tooltip = ItemUtils.tooltip

local links =
{
    Heroic = "|cffa335ee|Hitem:147425::::::::2:71::5:3:3562:1497:3528:::|h[Cord of Pilfered Rosaries]|h|r",
    Mythic = "|cffa335ee|Hitem:147425::::::::2:71::6:3:3563:1512:3528:::|h[Cord of Pilfered Rosaries]|h|r",
    LFR = "|cffa335ee|Hitem:147424::::::::2:71::4:3:3564:1467:3528:::|h[Treads of Violent Intrusion]|h|r",
    Warforged = "|cffa335ee|Hitem:147425::::::::2:71::3:3:3561:1487:3336:::|h[Cord of Pilfered Rosaries]|h|r",
    Titanforged = "|cffa335ee|Hitem:147424::::::::2:71::3:3:3561:1507:3337:::|h[Treads of Violent Intrusion]|h|r",
}

for _, item in pairs(links) do -- Load item infos into memory
    GetItemInfo(item)
end

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
    local link = select(2, GetItemInfo(item))
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(link)
    if tooltip:NumLines() > 1 then
        for i = 2, 5 do -- Check 4 lines, just in case.
            local line = getglobal(tooltip:GetName()..'TextLeft' .. i)
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

------------------------------------------------------------------------------

function RCCustomGP:GetRarityIlvlSlot(itemLink)
    local _, itemLink, rarity, level, _, itemClass, itemSubClass, _, equipLoc = GetItemInfo(itemLink)
    local itemBonuses = ItemUtils:BonusIDs(itemLink)
    if equipLoc == "" and itemSubClass == GetRelicSubClassString() then
        equipLoc = "INVTYPE_RELIC"
    end
    local slot = self.INVTYPESlots[equipLoc]
    local itemID = RCCustomGP:GetItemID(itemLink)
    if self:GetTokenInfo(itemLink) then
        level, slot = self:GetTokenInfo(itemLink)
        level = level + GetItemBonusLevelDelta(itemBonuses)
    end
    return rarity, level, slot
end

function RCCustomGP:GetBonusInfo(itemLink)
    local itemBonuses = ItemUtils:BonusIDs(itemLink)
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
    if slot and RCCustomGP:GetCustomGPdb()[slot] then
        return tonumber(RCCustomGP:GetCustomGPdb()[slot])
    end
end

function RCCustomGP:IsItemToken(itemLink)
    return not not self:GetTokenInfo(itemLink)
end

function RCCustomGP:GetItemID(itemLink)
    return tonumber(itemLink:match("item:(%d+)"))
end

function RCCustomGP:IsItemNormalDifficulty(item)
    return not (self:IsItemHeroicDifficulty(item) or self:IsItemMythicDifficulty(item) or self:IsItemLFRDifficulty(item) )
end

function RCCustomGP:IsItemHeroicDifficulty(item)
    return self:IsItemHasKeyword(item, GetTextLeft2(links.Heroic))
end

function RCCustomGP:IsItemMythicDifficulty(item)
    return self:IsItemHasKeyword(item, GetTextLeft2(links.Mythic))
end

function RCCustomGP:IsItemLFRDifficulty(item)
    return self:IsItemHasKeyword(item, GetTextLeft2(links.LFR))
end

function RCCustomGP:IsItemWarforged(item)
    return self:IsItemHasKeyword(item, GetTextLeft2(links.Warforged))
end

function RCCustomGP:IsItemTitanforged(item)
    return self:IsItemHasKeyword(item, GetTextLeft2(links.Titanforged))
end
