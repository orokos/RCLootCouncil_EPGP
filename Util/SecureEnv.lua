--- Provide a secure environment to execute user code.
-- @author: Safetee
-- 10/27/2017
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")

local B = {} -- blocked functions
-- Set the value below

-- Custom function environment to be used in Custom GP and custom EP.
-- Some code is copy and paste from WeakAuras 2
local function forbidden()
	RCEPGP:Print("|cffffff00"..LEP["forbidden_function_used"].."|r")
end

-- Get a function environment
-- 'overrides' contains the data you want to insert into the environment
local function GetSecureEnv(overrides)
	local env_getglobal
	local exec_env = setmetatable({}, { __index =
		function(t, k)
		if k == "_G" then
			return t
		elseif k == "getglobal" then
			return env_getglobal
		elseif B[k] then -- function blocked.
			return forbidden
		elseif overrides[k] then
			return overrides[k]
		else
			return _G[k]
		end
	end
	})

	env_getglobal = function(k)
		return exec_env[k]
	end
	return exec_env
end

local lastRunTimeErrorTime = {}
local ANNOUNCE_ERROR_INTERVAL = 3
-- Execute the function in a secure environment and print error without spamming.
-- @param funcString the func string used by "loadstring"
-- @param overrides this contains the data you want to insert info the secure environment
-- @return the return value of called function if the excution success. "error" if any error.
function RCEPGP:SecureExecString(funcString, overrides)
	local func, err = loadstring(funcString)
	if not func then
		func, err = loadstring("return "..funcString)
		if not func then
			self:Print(format(LEP["%s_formula_syntax_error"], funcString).." "..err)
			return "error"
		end
	end

	local env = GetSecureEnv(overrides)
	setfenv(func, env)

	local status, value = pcall(func)
	if not status and ((not lastRunTimeErrorTime[funcString]) or
		GetTime() - lastRunTimeErrorTime[funcString] > ANNOUNCE_ERROR_INTERVAL) then
		lastRunTimeErrorTime[funcString] = GetTime()
		self:Print(format(LEP["%s_formula_runtime_error"], funcString).."  "..value)
		return "error"
	end
	return value
end

-- blocked lua functions
B["AcceptSockets"] = true
B["AcceptTrade"] = true
B["AddIgnore"] = true
B["AddOrRemoveFriend"] = true
B["AddTradeMoney"] = true
B["BNAcceptFriendInvite"] = true
B["BNInviteFriend"] = true
B["BNRemoveFriend"] = true
B["BNReportFriendInvite"] = true
B["BNReportPlayer"] = true
B["C_LFGList"] = true
B["CalendarContextEventRemove"] = true
B["CalendarContextEventSignUp"] = true
B["CalendarEventRemoveInvite"] = true
B["CalendarEventSetAutoApprove"] = true
B["CalendarEventSetDate"] = true
B["CalendarEventSetLocked"] = true
B["CalendarEventSetTime"] = true
B["CalendarEventSetTitle"] = true
B["CalendarNewEvent"] = true
B["CalendarNewGuildAnnouncement"] = true
B["CalendarNewGuildEvent"] = true
B["CalendarRemoveEvent"] = true
B["CancelAuction"] = true
B["CancelSell"] = true
B["CreateFont"] = true
B["CreateFrame"] = true
B["CreateMacro"] = true
B["DeleteCursorItem"] = true
B["DeleteInboxItem"] = true
B["DeleteMacro"] = true
B["DemoteAssistant"] = true
B["DepositGuildBankMoney"] = true
B["DevTools_DumpCommand"] = true
B["DisableAddOn"] = true
B["DisableAllAddOns"] = true
B["EditMacro"] = true
B["EnableAddOn"] = true
B["EnableAllAddOns"] = true
B["EnumerateFrames"] = true
B["getfenv"] = true
B["GuildControlAddRank"] = true
B["GuildControlDelRank"] = true
B["GuildControlSaveRank"] = true
B["GuildControlSetRank"] = true
B["GuildControlSetRankFlag"] = true
B["GuildControlShiftRankDown"] = true
B["GuildControlShiftRankUp"] = true
B["GuildDemote"] = true
B["GuildDisband"] = true
B["GuildLeave"] = true
B["GuildPromote"] = true
B["GuildRosterSetOfficerNote"] = true
B["GuildRosterSetPublicNote"] = true
B["GuildSetLeader"] = true
B["GuildSetMOTD"] = true
B["GuildUninvite"] = true
B["hash_SlashCmdList"] = true
B["InviteUnit"] = true
B["LeaveParty"] = true
B["loadstring"] = true
B["MailFrame"] = true
B["pcall"] = true
B["PickupAction"] = true
B["PickupBagFromSlot"] = true
B["PickupCompanion"] = true
B["PickupContainerItem"] = true
B["PickupGuildBankItem"] = true
B["PickupGuildBankMoney"] = true
B["PickupInventoryItem"] = true
B["PickupItem"] = true
B["PickupMacro"] = true
B["PickupMerchantItem"] = true
B["PickupPetAction"] = true
B["PickupPetAction"] = true
B["PickupPlayerMoney"] = true
B["PickupPlayerMoney"] = true
B["PickupSpell"] = true
B["PickupStablePet"] = true
B["PickupTradeMoney"] = true
B["PickupTradeMoney"] = true
B["PlaceAction"] = true
B["PlaceAuctionBid"] = true
B["PromoteToAssistant"] = true
B["PromoteToLeader"] = true
B["PutItemInBackpack"] = true
B["PutItemInBag"] = true
B["ReloadUI"] = true
B["RestartGx"] = true
B["RunScript"] = true
B["SaveEquipmentSet"] = true
B["SendAddonMessage"] = true
B["SendChatMessage"] = true
B["SendMail"] = true
B["SetBindingMacro"] = true
B["SetCurrentGraphicsSetting"] = true
B["SetCVar"] = true
B["SetCVarBitfield"] = true
B["SetEveryoneIsAssistant"] = true
B["setfenv"] = true
B["SetGuildBankTabItemWithdraw"] = true
B["SetGuildBankWithdrawGoldLimit"] = true
B["SetGuildInfoText"] = true
B["SetGuildMemberRank"] = true
B["SetLookingForGuildComment"] = true
B["SetLookingForGuildSettings"] = true
B["SetLootMethod"] = true
B["SetLootSpecialization"] = true
B["SetScreenResolution"] = true
B["SetSendMailMoney"] = true
B["SetTradeMoney"] = true
B["SetUIVisibility"] = true
B["SlashCmdList"] = true
B["SocketContainerItem"] = true
B["SocketInventoryItem"] = true
B["SplitContainerItem"] = true
B["SplitGuildBankItem"] = true
B["StartAuction"] = true
B["StaticPopup_Show"] = true
B["StaticPopupDialogs"] = true
B["TradeFrame"] = true
B["UIParent"] = true
B["UninviteUnit"] = true
B["WithdrawGuildBankMoney"] = true
B["WorldFrame"] = true
