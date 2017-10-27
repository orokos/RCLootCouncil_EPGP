local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCLootCouncil-EPGP")
local RCEPGPHistory = RCEPGP:NewModule("RCEPGPHistory", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")
local LibDialog = LibStub("LibDialog-1.0")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")
local LootHistory = addon:GetModule("RCLootHistory")
local lootDB = addon:GetHistoryDB()

function RCEPGPHistory:OnInitialize()
    local rightClickMenu =
    RCEPGP:AddRightClickMenu(_G["RCLootCouncil_LootHistory_RightclickMenu"], LootHistory.rightClickEntries, RCEPGPHistory.rightClickEntries)
    self:RegisterMessage("RCHistory_NameEdit", "OnMessageReceived")
    self:RegisterMessage("RCHistory_ResponseEdit", "OnMessageReceived")
end

function RCEPGPHistory:OnMessageReceived(msg, ...)
    if msg == "RCHistory_NameEdit" then
        RCEPGP:RefreshMenu(1)
    elseif msg == "RCHistory_ResponseEdit" then
        RCEPGP:RefreshMenu(1)
    end
end

local function GetGPInfo(data)
    if data then
        local entry = lootDB[data.name][data.num]
        local name = RCEPGP:GetEPGPName(data.name)
        local class = entry.class
        local isTier = entry.tokenRoll
        local isRelic = entry.relicRoll
        local item = entry.lootWon
        local responseID = entry.responseID
        local responseGP = RCEPGP:GetResponseGP(responseID, isTier, isRelic) or 0
        local itemgp = GP:GetValue(item) or 0
        local gp = RCEPGP:GetFinalGP(responseGP, itemgp) or 0
        local lastgp = RCEPGP:GetLastGPAmount(name, item) or 0
        return name, class, item, responseGP, gp, lastgp
    end
    return "UNKNOWN", "UNKNOWN", "UNKNOWN", 0, 0, 0 -- nil protection
end

RCEPGPHistory.rightClickEntries = {
    { -- Level 1
        {-- Button 1: Class colored name
            pos = 1,
            notCheckable = true,
            notClickable = true,
            text = function(name, data)
                local name, class, item, responseGP, gp, lastgp = GetGPInfo(data)
                local text = ""
                local color = addon:GetClassColor(class)
                local colorCode = "|cff"..addon:RGBToHex(color.r, color.g, color.b)
                text = string.format("%s%s|r", colorCode, Ambiguate(name, "short"))
                return text
            end,
        },
        { -- Button 2: Undo button
            pos = 2,
            notCheckable = true,
            func = function(name, data)
                local name, class, item, responseGP, gp, lastgp = GetGPInfo(data)
                LibDialog:Spawn("RCEPGP_AWARD_GP", {
                    name = name,
                    gp = -lastgp,
                    class = class,
                    item = item,
                })
            end,
            text = function(name, data)
                local name, class, item, responseGP, gp, lastgp = GetGPInfo(data)
                return string.format(LEP["Undo GP"].." (%s)", -lastgp)
            end,
            disabled = function(name, data)
                local name, class, item, responseGP, gp, lastgp = GetGPInfo(data)
                return not EPGP:CanIncGPBy(item, -lastgp)
            end,
        },
        { -- Button 3: GP Button
            pos = 3,
            notCheckable = true,
            func = function(name, data)
                local name, class, item, responseGP, gp, lastgp = GetGPInfo(data)
                LibDialog:Spawn("RCEPGP_AWARD_GP", {
                    name = name,
                    gp = gp,
                    class = class,
                    item = item,
                })
            end,
            text = function(name, data)
                local name, class, item, responseGP, gp, lastgp = GetGPInfo(data)
                local text = string.format(LEP["Award GP (Default: %s)"], gp)
                if string.match(responseGP, "^%d+%%") then
                    text = string.format(LEP["Award GP (Default: %s)"], gp..", "..responseGP)
                end
                return text
            end,
            disabled = function(name, data)
                local name, class, item, responseGP, gp, lastgp = GetGPInfo(data)
                return not EPGP:CanIncGPBy(item, 1) -- disable if have no officer note permission.
            end
        },
        {-- Button 4 :Empty button
            pos = 4,
            text = "",
            notCheckable = true,
            disabled = true
        },
    },
}
