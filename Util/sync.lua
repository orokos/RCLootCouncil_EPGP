local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")

addon.Sync.syncHandlers["epgp"] =
{
	text = "EPGP",
	receive = function(data)
		wipe(RCEPGP.db)
		for k, v in pairs(data) do
			RCEPGP.db[k] = v
		end
		addon.db:GetNamespace("EPGP"):RegisterDefaults(self.defaults)
		RCEPGP:SendMessage("RCEPGPUpdateDB")
	end,
	send = function()
		return RCEPGP.db
	end,
}
