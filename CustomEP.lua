local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCCustomEPGP = addon:GetModule("RCCustomEPGP")
local RCCustomEP = RCCustomEPGP:NewModule("RCCustomEP", "AceConsole-3.0")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCCustomEPGP")


RCCustomEP.EPVariables = {
    {name = "online", label = "Online", cond = function(name) return RCCustomEP.IsOnline(name) end},
    {name = "isInZone", label = "In Zone", cond = function(name) return RCCustomEP.IsInZone(name) end},
    {name - "zone"}
}

RCCustomEP.allowedAPI = {
    "print", "strsplit", "strmatch",
}

local playersInfo = {}

function RCCustomEP:UpdateGuildInfo()
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

            if not UnitInRaid(Ambiguate(fullName, "short")) then
                info["online"] = online
                info["level"] = level
                info["zone"] = zone
            end
        end
    end
end

function RCCustomEP:UpdateRaidInfo()
    for i = 1, 40 do
        local name, rank, subgroup, level, class, classFileName, zone, online, isDead, groupRole, isML = GetRaidRosterInfo(i)
        if not playersInfo[fullName] then
            playersInfo[fullName] = {}
        end
        local info = playersInfo[fullName]
        if name then
            info["fullName"] = name
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
        end
    end
end

function RCCustomEP:GetUnitInfo(fullName, category)
    if not playersInfo[fullName] then
        return nil
    end
    return playersInfo[fullName][category]
end

function RCCustomEP:GetPlayerFullName()
    local name, realm = UnitFullName("player")
    return name.."-"..realm
end


---------------------------------------------------------


function RCCustomEP.IsOnline(fullName)
    return not RCCustomEP:GetUnitInfo(fullName, "online")
end

function RCCustomEP.IsInZone(fullName)
    local myFullName = RCCustomEP:GetPlayerFullName()
    local myZone = RCCustomEP:GetUnitInfo(myFullName, "zone")
    local zone = RCCustomEP:GetUnitInfo(fullName, "zone")
    return zone == myZone
end

function RCCustomEP.GetZone(fullName)
    return RCCustomEP:GetUnitInfo(fullName, "zone") or "UNKNOWN"
end
