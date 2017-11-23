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
		["gp"] = {func = RCEPGP.IncGPBy, help = LEP["slash_rc_gp_help"], helpDetailed = LEP["slash_rc_gp_help_detailed"], permission = true},
		["undogp"] = {func = RCEPGP.UndoGP, help = LEP["slash_rc_undogp_help"], helpDetailed = LEP["slash_rc_undogp_help_detailed"], permission = true},
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
		if self.SlashCmds[command].help and select(1, ...) and string.lower(tostring(select(1, ...))) == "help" then
			self:Print(self.SlashCmds[command].help)
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

    -- TODO: More error checking?
    local amount, reason2  = self:GetLastGPAmount(name, reason)
    if EPGP:CanIncGPBy(reason, amount) then
        EPGP:IncGPBy(name, reason2, -amount)
		return true
    else
		return false
    end
end

--[[
-- /rc massep  reason amount [formulaIndexOrName]
function RCCustomEP:Massep(reason, amount, formulaIndexOrName, targetName, scheduleTime)
    if reason == "help" then
        RCEPGP:Print(LEP["slash_rc_massep_help_detailed"])
        return
    end
    self:IncMassEPBy(reason, tonumber(amount), formulaIndexOrName, targetName, scheduleTime)
end

-- /rc recurep periodMin reason amount [formulaIndexOrName] [targetName] [ScheduleTime AfterSecond/HH:MM:SS/HH:MM, realm time, 24hour format]
function RCCustomEP:Recurep(periodMin, reason, amount, formulaIndexOrName, targetName, scheduleTime)
    if periodMin == "help" then
        RCEPGP:Print(LEP["slash_rc_recurep_help_detailed"])
        return
    end
    if tonumber(periodMin) and tonumber(periodMin) > 0 then
        self:StartRecurringEP(reason, tonumber(amount), tonumber(periodMin), formulaIndexOrName, targetName, scheduleTime)
    else
        RCEPGP:Print(LEP["peroid_not_positive_error"])
    end
end
-- TODO formulaIndex is 0
-- /rc stoprecur
-- TODO: schedule stoprecur
function RCCustomEP:Stoprecur()
    EPGP:StopRecurringEP()
end

-- /rc ep name reason amount
function RCCustomEP:IncEPBy(name, reason, amount)
    if name == "help" then
        RCEPGP:Print(LEP["slash_rc_ep_help_detailed"])
        return
    end
    if name == "%p" then
        name = RCEPGP:GetEPGPName("player")
    elseif name == "%t" then
        if not UnitExists("target") then
            RCEPGP:Print(L["You must select a target"])
            return
        end
        name = RCEPGP:GetEPGPName("target")
    end
    -- TODO: more error checking?
    EPGP:IncEPBy(name, reason, amount)
end

function RCCustomEP:AddChatCommand()
    addon:CustomChatCmd(self, "IncEPBy", LEP["slash_rc_ep_help"], "ep")
    addon:CustomChatCmd(self, "Massep", LEP["slash_rc_massep_help"], "massep")
    addon:CustomChatCmd(self, "Recurep", LEP["slash_rc_recurep_help"], "recurep")
    addon:CustomChatCmd(self, "Stoprecur", LEP["slash_rc_stoprecur_help"], "stoprecur")
    addon:CustomChatCmd(self, "CancelAllScheduledEP", LEP["slash_rc_cancelallscheduledep_help"], "cancelallscheduledep")
end


--]]
