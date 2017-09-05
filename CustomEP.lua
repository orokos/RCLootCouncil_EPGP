local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomEP = RCEPGP:NewModule("RCCustomEP", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local LibSpec = LibStub("LibGroupInSpecT-1.1")

local hasBeenAwardedOnce = {}
local isInGuild = {}
local allInfos = {}


local inputName = "    "
local amount = "    "

RCCustomEP.MaxFormulas = 100

RCCustomEP.EPVariables = {
    {name = "isNotAwardedOnce", help = "", value = function(name) return (not hasBeenAwardedOnce[fullName]) and 1 or 0 end, },
    {name = "isOnline", help = "Online", value = function(name) return RCCustomEP.GetUnitInfo(fullName, "online") and 1 or 0 end, },
    {name = "isInGuild", help = "Is In Guild", value = function(name) return RCCustomEP:IsUnitInfoSameAsMe(fulName, "guildName") and 1 or 0 end, },
    {name = "isInZone", help = "In Zone", value = function(name) return RCCustomEP:IsUnitInfoSameAsMe(fulName, "zone") and 1 or 0 end, },
    {name = "zone", help = "Name of Zone", value = function(name) return RCCustomEP.GetUnitInfo(fullName, "zone") or "UNKNOWN" end, },
    {name = "zoneId", help = "Name of Zone", value = function(name) return RCCustomEP.GetMapIDByName(RCCustomEP.GetZone(name)) end, },
    {name = "isInRaid", help = "", value = function(name) return UnitInRaid(Ambiguate(fullName, "short")) and 1 or 0 end, },
    {name = "isStandby", help = "", value = function(name) return EPGP:IsMemberInExtrasList(fullName) and 1 or 0 end, },
    {name = "isMain", help = "", value = function(name) return RCCustomEP.IsMain(name) and 1 or 0 end, },
    {name = "isMaxLevel", help = "", value = function(name) return RCCustomEP:GetUnitInfo(fullName, "level") == GetMaxPlayerLevel() and 1 or 0 end, },
    {name = "rank", help = "Rank", value = function(name) return RCCustomEP:GetUnitInfo(fullName, "guildRankIndex") or 10 end, },
    {name = "isTank", help = "Is Tank", value = function(name) return RCCustomEP:GetUnitInfo(fullName, "role") == "TANK" end},
    {name = "isHealer", help = "Is Healer", value = function(name) return RCCustomEP:GetUnitInfo(fullName, "role") == "HEALER" end},
    {name = "isDPS", help = "Is DPS", value = function(name) return RCCustomEP:GetUnitInfo(fullName, "role") == "DAMAGER" end},
    {name = "isMeleeDPS", help = "Is Melee DPS", value = function(name) return RCCustomEP.GetSpecRole(name) == "melee" end},
    {name = "isRangedDPS", help = "Is Ranged DPS", value = function(name) return RCCustomEP.GetSpecRole(name) == "ranged" end},
    {name = "level", help = "", value = function(name) return RCCustomEP.GetUnitInfo(fullName, "110") or 1 end,},
    {name = "class", help = "", value = function(name) return RCCustomEP.GetUnitInfo(fullName, "class") or "UNKNOWN" end,},
}

table.insert(RCCustomEP.EPVariables, {once = true, name = "minep", help = "", value = function() return EPGP.db.profile.min_ep end, })
table.insert(RCCustomEP.EPVariables, {once = true, name = "decay", help = "", value = function() return EPGP.db.profile.decay_p}) -- Integer
table.insert(RCCustomEP.EPVariables, {once = true, name = "basegp", help = "", value = function() return EPGP.db.profile.base_gp})
--[[TODO:
1. isMobile
5. inputEP
6. inputName
7. class
9. ep
10. gp
11. pr
16. isRank..
15. isMainRank..]]--

RCCustomEP.allowedAPI = {
    "print", "strsplit", "strmatch", "math"
}

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function RCCustomEP:GetEPFormulaFunc(indexOrName)
    local formulaStr = ""
    if type(indexOrName) == "number" then
        formulaStr = RCEPGP:GetEPGPdb().EPFormulas[indexOrName].formula
    else
        for i, entry in ipairs(RCEPGP:GetEPGPdb().EPFormulas) do
            if entry.name == indexOrName then
                formulaStr = entry.formula
            end
        end
    end

    local func, err = loadstring("return "..formulaStr)
    if not func then
        func, err = loadstring(formulaStr)
    end
    return func, err
end

function RCCustomEP:OnInitialize()
    self:SecureHook(addon, "ChatCommand", self.DoEPStuff, self)
    self:RegisterEvent("GUILD_ROSTER_UPDATE")
    GuildRoster()
    LibSpec:Rescan()
end

function RCCustomEP:DoEPStuff(msg)
    RCCustomEP:UpdateRaidInfo()
    local command, funcIndexOrName, inputName = self:GetArgs(msg, 3)
    if tonumber(funcIndexOrName) then funcIndexOrName = tonumber(funcIndexOrName) end

    local fenv = {}
    local formula, err = RCCustomEP:GetEPFormulaFunc(funcIndexOrName)
    for name, _ in pairs(allInfos) do


        for _, entry in ipairs(RCCustomEP.EPVariables) do
            local variableName = entry.name
            local variableValue = entry.value(name)
            fenv[variableName] = variableValue
        end
        for _, funcName in ipairs(RCCustomEP.allowedAPI) do
            fenv[funcName] = _G[funcName]
        end
        formula = setfenv(formula, fenv)
        local result = formula()
        if result and result ~= 0 then
            print(name..": "..tostring(result))
        end
    end
end

local function deleteInvalidInfos()
    for fullName, _ in pairs(allInfos) do
        if (not isInGuild[fullName]) and (not UnitInRaid(Ambiguate(fullName, "short"))) then
            allInfos[fullName] = nil
        end
    end
end

local lastUpdateTime
function RCCustomEP:GUILD_ROSTER_UPDATE()
    if lastUpdateTime and GetTime() - lastUpdateTime < 2 then
        return
    end
    lastUpdateTime = GetTime()

    local guildName, _, _ = GetGuildInfo("player")
    local isInGuildTemp = {}
    for i = 1, GetNumGuildMembers() do
        local fullName, rank, rankIndex, level, class, zone, note, officernote, online,
        status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo(i)
        if fullName then
            isInGuildTemp[fullName] = true
            if not allInfos[fullName] then
                allInfos[fullName] = {}
            end
            local info = allInfos[fullName]

            info["fullName"] = fullName
            info["guildRank"] = rank
            info["guildRankIndex"] = rankIndex
            info["note"] = note
            info["officernote"] = officernote
            info["status"] = status
            info["classFileName"] = classFileName -- NonLocalizedClassName
            info["achievementPoints"] = achievementPoints
            info["achievementRank"] = achievementRank
            info["isMobile"] = isMobile
            info["canSoR"] = canSoR
            info["reputation"] = reputation
            info["guildName"] = guildName
            if (not UnitInRaid(Ambiguate(fullName, "short"))) then
                info["online"] = online
                info["level"] = level
                info["zone"] = zone
            end
        end
    end
    isInGuild = isInGuildTemp
    deleteInvalidInfos()
    GuildRoster()
end

function RCCustomEP:UpdateRaidInfo()
    local n = GetNumGroupMembers() or 0
    for i = 1, n do
        local fullName, rank, subgroup, level, class, classFileName, zone, online, isDead, groupRole, isML = GetRaidRosterInfo(i)
        if fullName then
            local guildName, guildRankName, guildRankIndex = GetGuildInfo("raid"..i)
            if not allInfos[fullName] then
                allInfos[fullName] = {}
            end
            local info = allInfos[fullName]
            info["fullName"] = fullName
            info["raidRank"] = rank
            info["subgroup"] = subgroup
            info["level"] = level
            info["classFileName"] = classFileName
            info["zone"] = zone
            info["online"] = online
            info["isDead"] = isDead
            info["groupRole"] = groupRole
            info["isML"] = isML
            info["role"] = UnitGroupRolesAssigned("raid"..i)
            info["guildName"] = guildName
            info["guildRank"] = guildRankName
            info["guildRankIndex"] = guildRankIndex
            info["guid"] = UnitGUID("raid"..i)
        end
    end
    deleteInvalidInfos()
end

function RCCustomEP:IsUnitInfoSameAsMe(fullName, category)
    local mine = RCCustomEP:GetUnitInfo(myFullName, category)
    local other = RCCustomEP:GetUnitInfo(fullName, category)
    return mine == other
end

function RCCustomEP:GetPlayerFullName()
    local name, realm = UnitFullName("player")
    return name.."-"..realm
end

local mapIDByNameCache = {}
function RCCustomEP.GetMapIDByName(mapName)
    if not mapName then return -999 end
    if mapIDByNameCache[mapName] then
        return id
    end
    local id = -999
    for i=9999, 1, -1 do
         local name = GetMapNameByID(i)
         if mapName == name then
             id = i
             break
         end
    end
    mapIDByNameCache[mapName] = id
    return id
end

function RCCustomEP:GetUnitInfo(fullName, category)
    return allInfos[fullName] and allInfos[fullName][category]
end
---------------------------------------------------------

-- tank, melee, ranged, healer
function RCCustomEP.GetSpecRole(fullName)
    local guid = RCCustomEP:GetUnitInfo(fullName, "guid")
    return guid and LibSpec:GetCachedInfo(guid)
end

function RCCustomEP.IsMain(fullName)
    local ep, gp, main = EPGP:GetEPGP(fullName)
    return (not main) or (main == fullName)
end

----- Modified from EPGP/epgp_recurring.lua -----------------------------------
local LEPGP = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local Debug = LibStub("LibDebug-1.0")
local DLG = LibStub("LibDialog-1.0")

local callbacks = EPGP.callbacks

local frame = _G["EPGP_RecurringAwardFrame"]
local timeout = 0
local function RecurringTicker(self, elapsed)
  -- EPGP's db is available after GUILD_ROSTER_UPDATE. So we have a
  -- guard.
  if not EPGP.db then return end

  local vars = EPGP.db.profile
  local now = GetTime()
  if now > vars.next_award and GS:IsCurrentState() then
    EPGP:IncMassEPBy(vars.next_award_reason, vars.next_award_amount,
                     vars.next_formula, vars.next_input_name)
    vars.next_award =
      vars.next_award + vars.recurring_ep_period_mins * 60
  end
  timeout = timeout + elapsed
  if timeout > 0.5 then
    callbacks:Fire("RecurringAwardUpdate",
                   vars.next_award_reason,
                   vars.next_award_amount,
                   vars.next_award - now)
    timeout = 0
  end
end
frame:SetScript("OnUpdate", RecurringTicker)
frame:Hide()

function EPGP:StartRecurringEP(reason, amount, formula, inputName)
  local vars = EPGP.db.profile
  if vars.next_award then
    return false
  end

  vars.next_award_reason = reason
  vars.next_award_amount = amount
  vars.next_award = GetTime() + vars.recurring_ep_period_mins * 60
  vars.next_formula = formula
  vars.next_input_name = inputName
  frame:Show()

  callbacks:Fire("StartRecurringAward",
                 vars.next_award_reason,
                 vars.next_award_amount,
                 vars.recurring_ep_period_mins)
  return true
end

function EPGP:CancelRecurringEP()
  DLG:Dismiss("EPGP_RECURRING_RESUME")
  local vars = EPGP.db.profile
  vars.next_award_reason = nil
  vars.next_award_amount = nil
  vars.next_award = nil
  vars.next_formula = nil
  vars.next_input_name = nil
  frame:Hide()
end
-------------------------------------------------------------------------------
-- TODO: Finish this.
local oldIncMassEPBy = EPGP.IncMasEPBy
function EPGP:IncMassEPBy(reason, amount, formula, inputName)
  if not formula then
      return oldIncMassEPBy(EPGP, reason, amount)
  end

  local awarded = {}
  local awarded_mains = {}
  local extras_awarded = {}
  local extras_amount = math.floor(self.db.profile.extras_p * 0.01 * amount)
  local extras_reason = reason .. " - " .. L["Standby"]

  for i=1,EPGP:GetNumMembers() do
    local name = EPGP:GetMember(i)
    if EPGP:IsMemberInAwardList(name) then
      -- EPGP:GetMain() will return the input name if it doesn't find a main,
      -- so we can't use it to validate that this actually is a character who
      -- can recieve EP.
      --
      -- EPGP:GetEPGP() returns nil for ep and gp, if it can't find a
      -- valid member based on the name however.
      local ep, gp, main = EPGP:GetEPGP(name)
      local main = main or name
      if ep and not awarded_mains[main] then
        if EPGP:IsMemberInExtrasList(name) then
          EPGP:IncEPBy(name, extras_reason, extras_amount, true)
          extras_awarded[name] = true
        else
          EPGP:IncEPBy(name, reason, amount, true)
          awarded[name] = true
        end
        awarded_mains[main] = true
      end
    end
  end
  if next(awarded) then
    if next(extras_awarded) then
      callbacks:Fire("MassEPAward", awarded, reason, amount,
                     extras_awarded, extras_reason, extras_amount)
    else
      callbacks:Fire("MassEPAward", awarded, reason, amount)
    end
  end
end
