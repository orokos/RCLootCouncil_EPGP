local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")

function RCEPGP:AddSlashCmds()
	-- key: the command
	-- func: the command function. Executed by '/rc command'
	-- help: The help message shown in '/rc help'
	-- helpDetailed: the help message of command. Printed by '/rc command help'
	self.SlashCmds = {
		["epgp"] = {func = RCEPGP.OpenOptions, help = LEP["chat_commands"], helpDetailed = nil, permission = false},
		["ep"] = {func = RCEPGP.IncEPBy, help = LEP["slash_rc_ep_help"], helpDetailed = LEP["slash_rc_ep_help_detailed"], permission = true},
		["gp"] = {func = RCEPGP.IncGPBy, help = LEP["slash_rc_gp_help"], helpDetailed = LEP["slash_rc_gp_help_detailed"], permission = true},
		["undogp"] = {func = RCEPGP.UndoGP, help = LEP["slash_rc_undogp_help"], helpDetailed = LEP["slash_rc_undogp_help_detailed"], permission = true},
		["massep"] = {func = RCEPGP.MassEP, help = LEP["slash_rc_massep_help"], helpDetailed = LEP["slash_rc_massep_help_detailed"], permission = true},
		["recurep"] = {func = RCEPGP.RecurEP, help = LEP["slash_rc_recurep_help"], helpDetailed = LEP["slash_rc_recurep_help_detailed"], permission = true},
		["stoprecur"] = {func = RCEPGP.RecurEP, help = LEP["slash_rc_stoprecur_help"], helpDetailed = LEP["slash_rc_stoprecur_help_detailed"], permission = true},
	}
	local i = 1
	for command, v in pairs(self.SlashCmds) do
		if v.func and v.help then
			self["SlashCmdFunc"..i] = function(self, ...) self:ExecuteSlashCmd(command, ...) end
			addon:CustomChatCmd(self, "SlashCmdFunc"..i, v.help, command)
		else
			error("SlashCmds func and help not specified: "..command)
		end
		i = i + 1
	end
end
-- /rc command ...
-- '/rc command help' shows the help of the command, if exists.
-- Terminate the command if the player has no officer note permissions
-- If the command function returns EXACTLY false, print command fails message.
function RCEPGP:ExecuteSlashCmd(command, ...)
	if self.SlashCmds[command] and self.SlashCmds[command].func then
		if self.SlashCmds[command].helpDetailed and (not select(1, ...) or string.lower(tostring(select(1, ...))) == "help") then
			self:Print(self.SlashCmds[command].helpDetailed)
			return
		end
		if self.SlashCmds[command].permission and not CanEditOfficerNote() then
			self:Print(LEP["no_permission_to_edit_officer_note"])
			return
		end
		local ret = self.SlashCmds[command].func(self, ...)
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

    local amount, reason2  = self:GetLastGPAmount(name, reason)
    if EPGP:CanIncGPBy(reason, amount) then
        EPGP:IncGPBy(name, reason2, -amount)
		return true
    else
		return false
    end
end


-- /rc massep [reason] [amount] [formulaIndexOrName1] [formulaIndexOrName2], ...
function RCEPGP:MassEP(reason, amount, ...)
    self:GetModule("RCCustomEP"):IncMassEPBy(reason, tonumber(amount), ...)
end

-- /rc recurep periodMin reason amount [formulaIndexOrName1] [formulaIndexOrName2], ...
function RCEPGP:RecurEP(periodMin, reason, amount, ...)
	self:GetModule("RCCustomEP"):StartRecurringEP(reason, tonumber(amount), tonumber(periodMin), ...)
end

function RCEPGP:StopRecur()
    EPGP:StopRecurringEP()
end

-- /rc ep name reason amount
function RCEPGP:IncEPBy(name, reason, amount)
    if name == "%p" then
        name = self:GetEPGPName("player")
    elseif name == "%t" then
        if not UnitExists("target") then
            self:Print(L["You must select a target"])
            return
        end
        name = self:GetEPGPName("target")
    end

	amount = tonumber(amount)
	if EPGP:CanIncEPBy(reason, amount) then
    	EPGP:IncEPBy(name, reason, amount)
		return true
	else
		return false
	end
end
