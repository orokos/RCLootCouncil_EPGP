local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")
local LibDialog = LibStub("LibDialog-1.0")
local LootFrame = addon:GetModule("RCLootFrame")
local RCLF = RCEPGP:NewModule("RCEPGPLootFrame", "AceHook-3.0")

local hookRunning = false

function RCLF:OnEnable()
	self:SecureHook(LootFrame.EntryManager, "GetEntry", "HookGetEntry")
end

function RCLF:HookGetEntry(_, item)
	if not hookRunning then
		hookRunning = true
		local frame = LootFrame.EntryManager:GetEntry(item)
		if not self:IsHooked(frame, "Update") then
			self:SecureHook(frame, "Update", "HookEntryUpdate")
			frame:Update()
		end
	end
	hookRunning = false
end

function RCLF.HookEntryUpdate(_, entry)
	local lootTable = addon:GetLootTable()
	local text = entry.itemLvl:GetText()
	local session = entry.item.sessions and entry.item.sessions[1]
	if session then
		local gp = lootTable[session].gp
		if gp then
			entry.itemLvl:SetText(entry.itemLvl:GetText().."  |cffffff00GP: "..gp.."|r")
		end
	end
end
