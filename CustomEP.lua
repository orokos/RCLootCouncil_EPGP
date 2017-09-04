local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomEP = RCEPGP:NewModule("RCCustomEP", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local LibSpec = LibStub("LibGroupInSpecT-1.1")

local hasBeenAwardedOnce = {}

RCCustomEP.EPVariables = {
    {name = "isNotAwardedOnce", help = "", value = function(name) return RCCustomEP.HasNotBeenAwardedOnce(name) and 1 or 0 end, },
    {name = "isOnline", help = "Online", value = function(name) return RCCustomEP.IsOnline(name) and 1 or 0 end, },
    {name = "isInGuild", help = "Is In Guild", value = function(name) return RCCustomEP.IsInGuild(name) and 1 or 0 end, },
    {name = "isInZone", help = "In Zone", value = function(name) return RCCustomEP.IsInZone(name) and 1 or 0 end, },
    {name = "zone", help = "Name of Zone", value = function(name) return RCCustomEP.GetZone(name) or "UNKNOWN" end, },
    {name = "zoneId", help = "Name of Zone", value = function(name) return RCCustomEP.GetMapIDByName(RCCustomEP.GetZone(name)) end, },
    {name = "isInGroup", help = "", value = function(name) return RCCustomEP.IsInGroup(name) and 1 or 0 end, },
    {name = "isStandby", help = "", value = function(name) return RCCustomEP.IsStandby(name) and 1 or 0 end, },
    {name = "isMain", help = "", value = function(name) return RCCustomEP.IsMain(name) and 1 or 0 end, },
    {name = "isMaxLevel", help = "", value = function(name) return RCCustomEP.IsMaxLevel(name) and 1 or 0 end, },
    {name = "isMainMaxLevel", help = "", value = function(name) return RCCustomEP.IsMainMaxLevel(name) and 1 or 0 end, },
    {name = "rank", help = "Rank", value = function(name) return RCCustomEP.GetGuildRankIndex(name) end, },
    {name = "isTank", help = "Is Tank", value = function(name) return RCCustomEP.GetSpecRole(name) == "tank" end},
    {name = "isMelee", help = "Is Melee", value = function(name) return RCCustomEP.GetSpecRole(name) == "melee" end},
    {name = "isRanged", help = "Is Ranged", value = function(name) return RCCustomEP.GetSpecRole(name) == "ranged" end},
    {name = "isHealer", help = "Is Healer", value = function(name) return RCCustomEP.GetSpecRole(name) == "healer" end},
}
-- TODO:
1. isMobile
2. isTank
3. isHealer
4. isDPS
5. inputEP
6. inputName
7. class
8. level
9. ep
10. gp
11. pr
12. minep
13. decay
14. basegp
16. isRank..
15. isMainRank..

RCCustomEP.allowedAPI = {
    "print", "strsplit", "strmatch", "math"
}

function RCCustomEP:OnInitialize()
    self:RegisterChatCommand("ep", function(msg)
        RCCustomEP:UpdateRaidInfo()
        local name = self:GetArgs(msg, 1)
        local formula, err = loadstring(RCEPGP:GetEPGPdb().EPFormula)
        fenv = {}
        for _, entry in ipairs(RCCustomEP.EPVariables) do
            local variableName = entry.name
            local variableValue = entry.value(name)
            fenv[variableName] = variableValue
        end
        for _, funcName in ipairs(RCCustomEP.allowedAPI) do
            fenv[funcName] = _G[funcName]
        end
        formula = setfenv(formula, fenv)
        print(formula())
    end)
    self:RegisterEvent("GUILD_ROSTER_UPDATE")
    GuildRoster()
    LibSpec:Rescan()
end

function RCCustomEP:GUILD_ROSTER_UPDATE()
    self:UpdateGuildInfo()
    GuildRoster()
end

local playersInfo = {}

local lastUpdateTime
function RCCustomEP:UpdateGuildInfo()
    if lastUpdateTime and GetTime() - lastUpdateTime < 2 then
        return
    end
    lastUpdateTime = GetTime()

    local guildName, _, _ = GetGuildInfo("player")
    for i = 1, GetNumGuildMembers() do
        local fullName, rank, rankIndex, level, class, zone, note, officernote, online,
        status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo(i)
        if fullName then
            if not playersInfo[fullName] then
                playersInfo[fullName] = {}
            end
            local info = playersInfo[fullName]

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

            if not UnitInRaid(Ambiguate(fullName, "short")) then
                info["online"] = online
                info["level"] = level
                info["zone"] = zone
            end
        end
    end
end

function RCCustomEP:UpdateRaidInfo()
    local n = GetNumGroupMembers() or 0
    for i = 1, n do
        local fullName, rank, subgroup, level, class, classFileName, zone, online, isDead, groupRole, isML = GetRaidRosterInfo(i)
        if fullName then
            local guildName, guildRankName, guildRankIndex = GetGuildInfo("raid"..i)
            if not playersInfo[fullName] then
                playersInfo[fullName] = {}
            end
            local info = playersInfo[fullName]
            if fullName then
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
    end
end

function RCCustomEP:GetUnitInfo(fullName, category)
    if not playersInfo[fullName] then
        return nil
    end
    return playersInfo[fullName][category]
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
---------------------------------------------------------

function RCCustomEP.IsOnline(fullName)
    return RCCustomEP:GetUnitInfo(fullName, "online")
end

function RCCustomEP.IsInZone(fullName)
    return RCCustomEP:IsUnitInfoSameAsMe(fulName, "zone")
end

function RCCustomEP.IsInGuild(fullName)
    return RCCustomEP:IsUnitInfoSameAsMe(fulName, "guildName")
end

function RCCustomEP.GetZone(fullName)
    return RCCustomEP:GetUnitInfo(fullName, "zone")
end

function RCCustomEP.GetGuildRankIndex(fullName)
    return RCCustomEP:GetUnitInfo(fullName, "guildRankIndex") or 10
end

-- tank, melee, ranged, healer
function RCCustomEP.GetSpecRole(fullName)
    local guid = RCCustomEP:GetUnitInfo(fullName, "guid")
    return guid and LibSpec:GetCachedInfo(guid)
end

function RCCustomEP.IsInGroup(fullName)
    if not fullName then return false end
    local shortName = Ambiguate(fullName, "short")
    return UnitInParty(shortName) or UnitInRaid(shortName)
end

function RCCustomEP.IsMain(fullName)
    local ep, gp, main = EPGP:GetEPGP(fullName)
    return (not main) or (main == fullName)
end

function RCCustomEP.HasNotBeenAwardedOnce(fullName)
    return hasBeenAwardedOnce[fullName] == false
end

function RCCustomEP.IsStandby(fullName)
    return EPGP:IsMemberInExtrasList(fullName)
end

function RCCustomEP.IsMaxLevel(fullName)
    local ep, gp, main = EPGP:GetEPGP(fullName)
    main = main or fullName
    return RCCustomEP:GetUnitInfo(main, "level") == GetMaxPlayerLevel()
end

function RCCustomEP.IsMainMainLevel(fullName)
    return RCCustomEP:GetUnitInfo(fullName, "level") == GetMaxPlayerLevel()
end
