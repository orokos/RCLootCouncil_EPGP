local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")

-- /rc gp name reason [amount]
function RCEPGP:IncGPBy(name, reason, amount)
    if name == "help" then
        self:Print(LEP["slash_rc_gp_help_detailed"])
        return
    end
    if not CanEditOfficerNote() then
        self:Print(LEP["no_permission_to_edit_officer_note"])
        return
    end
    if name == "%p" then
        name = self:GetEPGPName("player")
    elseif name == "%t" then
        if not UnitExists("target") then
            self:Print(L["You must select a target"])
            return
        end
        name = self:GetEPGPName("target")
    end

    if not amount then
        amount = GP:GetValue(reason)
    else
        amount = tonumber(amount)
    end

    if EPGP:CanIncGPBy(reason, amount) then
        EPGP:IncGPBy(name, reason, amount)
    else
        self:Print(LEP["slash_rc_command_failed"])
    end
end

-- /rc undogp name reason
-- Undo the previous GP operations to 'name' with 'reason'
-- Reason by be nil to match the most recent GP operation to 'name'
function RCEPGP:UndoGP(name, reason)
    if name == "help" then
        self:Print(LEP["slash_rc_undogp_help_detailed"])
        return
    end
    if not CanEditOfficerNote() then
        self:Print(LEP["no_permission_to_edit_officer_note"])
        return
    end
    if name == "%p" then
        name = RCEPGP:GetEPGPName("player")
    elseif name == "%t" then
        if not UnitExists("target") then
            RCEPGP:Print(LEP["error_no_target"])
            return
        end
        name = self:GetEPGPName("target")
    end

    -- TODO: More error checking?
    local amount, reason2  = self:GetLastGPAmount(name, reason)
    if EPGP:CanIncGPBy(reason, amount) then
        EPGP:IncGPBy(name, reason2, -amount)
    else
        self:Print(LEP["slash_rc_command_failed"])
    end
end
