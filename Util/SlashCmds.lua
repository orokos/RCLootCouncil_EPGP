local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")

RCEPGP.SlashCmds = {
	["gp"] = {func = RCEPGP.IncGPBy, help = LEP["slash_rc_gp_help_detailed"]},
	["undogp"] = {func = RCEPGP.UndoGP, help = LEP["slash_rc_undogp_help_detailed"]},
}
-- /rc command ...
-- '/rc command help' shows the help of the command, if exists.
-- Terminate the command if the player has no officer note permissions
-- If the command function returns EXACTLY false, print command fails message.
function RCEPGP:ExecuteSlashCmd(command, ...)
	if self.SlashCmds[command] and self.SlashCmds[command].func then
		if string.lower(select(1, ...)) == "help" and self.SlashCmds[command].help then
			self:Print(self.SlashCmds[command].help)
			return
		end
		if not CanEditOfficerNote() then
			self:Print(LEP["no_permission_to_edit_officer_note"])
			return
		end
		local ret = self.SlashCmds[command].func(...)
		if ret == false then
			self:Print(LEP["slash_rc_command_failed"])
		end
	else
		error("Slash Command not found")
	end
end

function RCEPGP:GetSlashCmdName(name)
	if name == "%p" then
		name = self:GetEPGPName("player")
	elseif name == "%t" then
		if not UnitExists("target") then
			self:Print(L["You must select a target"])
			return
		end
		name = self:GetEPGPName("target")
	end
end
-- /rc gp name reason [amount]
function RCEPGP:IncGPBy(name, reason, amount)
	name = RCEPGP:GetSlashCmdName(name)
	if not name then
		return
	end

	amount = amount and tonumber(amount) or GP:GetValue(reason)

    if EPGP:CanIncGPBy(reason, amount) then
        EPGP:IncGPBy(name, reason, amount)
		return true
    else
        return false
    end
end

-- /rc undogp name reason
-- Undo the previous GP operations to 'name' with 'reason'
-- Reason by be nil to match the most recent GP operation to 'name'
function RCEPGP:UndoGP(name, reason)
	name = RCEPGP:GetSlashCmdName(name)
	if not name then
		return
	end

    -- TODO: More error checking?
    local amount, reason2  = self:GetLastGPAmount(name, reason)
    if EPGP:CanIncGPBy(reason, amount) then
        EPGP:IncGPBy(name, reason2, -amount)
		return true
    else
		return false
    end
end
