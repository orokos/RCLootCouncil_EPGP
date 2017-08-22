local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGPHistory = addon:NewModule("RCEPGPHistory", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local RCEPGP = addon:GetModule("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")
local LibDialog = LibStub("LibDialog-1.0")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")
local LootHistory = addon:GetModule("RCLootHistory")
local lootDB = addon:GetHistoryDB()

function RCEPGPHistory:OnInitialize()
	local rightClickMenu = _G["RCLootCouncil_LootHistory_RightclickMenu"]
	Lib_UIDropDownMenu_Initialize(rightClickMenu, self.RightClickMenu, "MENU")
end

function RCEPGPHistory:GetLastGPAmount(name, item)
	local logMod = EPGP:GetModule("log")
	if log then
		for i =#logMod.db.profile.log, 1, -1 do
			local entry = logMod.db.profile.log[i]
			local timestamp, kind, name2, reason, amount = unpack(entry)
			if kind == 'GP' and name2 == name and reason == item then
				return amount
			end
		end
	end
	return 0
end

function RCEPGPHistory:GetEPGPNameByGuild(name)
	for i = 1, GetNumGuildMembers() do
		local fullName = GetGuildRosterInfo(index)
		if fullName then
			local shortName = Ambiguate(fullName, "short")
			if shortName == Ambiguate(name, "short") then
				return fullName
			end
		end
	end
	return name
end

function RCEPGPHistory.RightClickMenu(menu, level)
	local data = menu.datatable

	if data then
		local entry = lootDB[data.name][data.num]
		local name = RCEPGP:GetEPGPName(data.name)
		-- Dont use "data.name" after this line. use "name" instead.
		local class = entry.class
		local isTier = entry.tokenRoll
		local item = entry.lootWon
		local responseID = entry.responseID
		local responseGP = RCEPGP:GetResponseGP(responseID, isTier)

		local gp = GP:GetValue(item) or 0
		if string.match(responseGP, "^%d+$") then
		  gp = tonumber(responseGP)
		else -- responseGP is percentage like 55%
		  local coeff = tonumber(string.match(responseGP, "%d+"))/100
		  gp = math.floor(coeff * gp)
		end

		if level == 1 then
			info = Lib_UIDropDownMenu_CreateInfo()
			local lastgp = RCEPGPHistory:GetLastGPAmount(name, item)
			info.text = string.format(LEP["Undo GP"].." (%s)", -lastgp)
			info.func = function()
							LibDialog:Spawn("RCEPGP_AWARD_GP", {
									name = name,
							        gp = -lastgp,
							        class = class,
							        item = item,
				    		}) 
						end
			info.notCheckable = true
			info.disabled = false
			if (not EPGP:CanIncGPBy(item, -lastgp)) then
		      info.disabled = true
		    end
		    Lib_UIDropDownMenu_AddButton(info, level)

		   	---------------------------------------------------------
			info = Lib_UIDropDownMenu_CreateInfo()
			info.text = string.format(LEP["Award GP (Default: %s)"], gp)
			if string.match(responseGP, "^%d+%%") then
      			info.text = string.format(LEP["Award GP (Default: %s)"], gp..", "..responseGP)
    		end
			info.func = function()
							LibDialog:Spawn("RCEPGP_AWARD_GP", {
									name = name,
							        gp = gp,
							        class = class,
							        item = item,
				    		}) 
						end
			info.notCheckable = true
			info.disabled = false
			if (not EPGP:CanIncGPBy(item, gp)) then
		      info.disabled = true
		    end
		    Lib_UIDropDownMenu_AddButton(info, level)
		end
	end

	LootHistory.RightClickMenu(menu, level)
end

-- Mostly copy from EPGP/popup.lua
LibDialog:Register("RCEPGP_AWARD_GP", {
  text = "Unknown Item",
  icon = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
  buttons = {
    {
      text = _G.ACCEPT,
      on_click = function(self, data, reason)
        local gp = tonumber(self.editboxes[1]:GetText())
        EPGP:IncGPBy(data.name, data.item, gp)
      end,
    },
    {
      text = _G.CANCEL,
    },
  },
  editboxes = {
    {
      auto_focus = true,
    },
  },
  on_show = function(self, data)
    local color = addon:GetClassColor(data.class)
    local colorCode = "|cff"..addon:RGBToHex(color.r, color.g, color.b)
    self.text:SetFormattedText("%s%s|r\n"..LEP["Credit GP to %s"].."\n", colorCode, data.name, data.item)
    local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(data.item)
    self.icon:SetTexture(icon)
    local gp = data.gp
    self.editboxes[1]:SetText(gp)
    self.editboxes[1]:HighlightText()
    if not self.icon_frame then
      local icon_frame = CreateFrame("Frame", nil, self)
      icon_frame:ClearAllPoints()
      icon_frame:SetAllPoints(self.icon)
      icon_frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", - 3, icon_frame:GetHeight() + 6)
        GameTooltip:SetHyperlink(self:GetParent().data.item)
      end)
      icon_frame:SetScript("OnLeave", function(self)
        GameTooltip:FadeOut()
      end)
      self.icon_frame = icon_frame
    end
    if self.icon_frame then
      self.icon_frame:EnableMouse(true)
      self.icon_frame:Show()
    end
  end,
  on_hide = function(self, data)
    if ChatEdit_GetActiveWindow() then
      ChatEdit_FocusActiveWindow()
    end
    if self.icon_frame then
      self.icon_frame:EnableMouse(false)
      self.icon_frame:Hide()
    end
  end,
  on_update = function(self, elapsed)
    local gp = tonumber(self.editboxes[1]:GetText())
    if EPGP:CanIncGPBy(self.data.item, gp) then
      self.buttons[1]:Enable()
    else
      self.buttons[1]:Disable()
    end
  end,
  hide_on_escape = true,
  show_while_dead = true,
})