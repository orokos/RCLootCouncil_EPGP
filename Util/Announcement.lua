local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")

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
