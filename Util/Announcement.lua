--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")
local GP = LibStub("LibGearPoints-1.2")

function RCEPGP:AddAwardAnnouncement()
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
		RCLootCouncilML.awardStrings['#itemgp#'] = function(_, item) return GP:GetValue(item) or 0 end

		if RCLootCouncilML.awardStringsDesc then
			tinsert(RCLootCouncilML.awardStringsDesc, LEP["announce_#diffgp#_desc"])
			tinsert(RCLootCouncilML.awardStringsDesc, LEP["announce_#ep#_desc"])
			tinsert(RCLootCouncilML.awardStringsDesc, LEP["announce_#gp#_desc"])
			tinsert(RCLootCouncilML.awardStringsDesc, LEP["announce_#newgp#_desc"])
			tinsert(RCLootCouncilML.awardStringsDesc, LEP["announce_#pr#_desc"])
			tinsert(RCLootCouncilML.awardStringsDesc, LEP["announce_#newpr#_desc"])
			tinsert(RCLootCouncilML.awardStringsDesc, LEP["announce_#itemgp#_desc"])
		end
    end
end

function RCEPGP:AddConsiderationAnnouncement()
    if RCLootCouncilML.announceItemStrings then -- Requires RCLootCouncil v2.7
		if RCLootCouncilML.announceItemStringsDesc then
			RCLootCouncilML.announceItemStrings["#itemgp#"] = function(_, item) return GP:GetValue(item) or 0 end
			tinsert(RCLootCouncilML.announceItemStringsDesc, LEP["announce_#itemgp#_desc"])
		end
    end
end
