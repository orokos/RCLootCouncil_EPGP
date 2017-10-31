--- Store epgp's setting in the saved variable of RC, in order to transmit it with "/rc sync"
-- @author: Safetee
-- 10/27/2017

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")



-- Link table in RCEPGP's saved variable with EPGP's saved variable together.
-- Used to send EPGP(dkp reloaded) settings with RC sync
function RCEPGP:EPGPDkpReloadedSettingToRC()
	self:GetEPGPdb().EPGPDkpReloadedDB = {}
	self:GetEPGPdb().EPGPDkpReloadedDB.children = {}
	if EPGP.db and EPGP.db.children then
		for module, entry in pairs(EPGP.db.children) do
			if module ~= "log" then -- Not gonna sync "log" module because it is too big. Probably will sync it with RCHistory Later.
				self:GetEPGPdb().EPGPDkpReloadedDB.children[module] = {}
				-- link the table to the table of EPGP settings.
				self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile = EPGP.db.children[module].profile
			end
		end
	end
	self:Debug("Save EPGP(dkp reloaded) settings to RCLootCouncil Saved Variables.")
end

-- Restore settings stored in RC to EPGP(dkp reloaded)
function RCEPGP:RCToEPGPDkpReloadedSetting()
	if not self:GetEPGPdb().sendEPGPSettings then return end

	local syncHappened = false
	if self:GetEPGPdb().EPGPDkpReloadedDB and self:GetEPGPdb().EPGPDkpReloadedDB.children then
		for module, entry in pairs(self:GetEPGPdb().EPGPDkpReloadedDB.children) do
			if module ~= "log" then -- Not gonna sync "log" module because it is too big. Probably will sync it with RCHistory Later.

				if EPGP.db.children[module].profile and self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile and
					EPGP.db.children[module].profile ~= self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile then
					syncHappened = true
				end

				local mod = EPGP:GetModule(module)
				-- Copy settings
				self:DeepCopy(EPGP.db.children[module].profile, self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile)

				if mod then -- Enable module if needed
					if self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile.enabled then
						mod:Enable()
					else
						mod:Disable()
					end
				end
			end
		end
	end

	if not syncHappened then return end -- No actual sync happened. (This can happen when sync from a user without RCLootCoucil-EPGP installed).

	self:Debug("Restore EPGP(dkp reloaded) settings from RCLootCouncil Saved Variables.")
	self:EPGPDkpReloadedSettingToRC() -- Link table in RCEPGP's saved variable with EPGP's saved variable together.
	self:Print(LEP["EPGP_DKP_Reloaded_settings_received"])
end
