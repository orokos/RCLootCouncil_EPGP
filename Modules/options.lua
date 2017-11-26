--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomGP = RCEPGP:GetModule("RCCustomGP", true)
local RCCustomEP = RCEPGP:GetModule("RCCustomEP", true)

------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")

function RCEPGP:AddGPOptions()
    local options = addon.options
    local button, picker, text, gp = {}, {}, {}, {}
    for i = 1, addon.db.profile.maxButtons do
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["button" .. i].order = i * 4 + 1
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["picker" .. i].order = i * 4 + 2
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["picker" .. i].width = "half"
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["text" .. i].order = i * 4 + 3
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["gp" .. i] = {
            order = i * 4 + 4,
            name = "GP",
            desc = LEP["gp_value_help"],
            type = "input",
            width = "half",
			pattern = "^%d+%%?$",
            get = function() return self.db.gp.responses[i] end,
            set = function(info, value) self.db.gp.responses[i] = value end,
            hidden = function() return addon.db.profile.numButtons < i end,
        }
    end
    for k, v in pairs(addon.db.profile.responses.tier) do
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["button" .. k].order = v.sort * 4 + 1
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["color" .. k].order = v.sort * 4 + 2
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["color" .. k].width = "half"
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["text" .. k].order = v.sort * 4 + 3
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["gp" .. k] = {
            order = v.sort * 4 + 4,
            name = "GP",
            desc = LEP["gp_value_help"],
            type = "input",
            width = "half",
			pattern = "^%d+%%?$",
            get = function() return self.db.gp.tierButtons[v.sort] end,
            set = function(info, value) self.db.gp.tierButtons[v.sort] = value end,
            hidden = function() return not addon.db.profile.tierButtonsEnabled or addon.db.profile.tierNumButtons < v.sort end,
        }
    end

    -- Relic Buttons/Responses
    if addon.db.profile.responses.relic then
    	for k, v in pairs(addon.db.profile.responses.relic) do
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["button" .. k].order = v.sort * 4 + 1
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["color" .. k].order = v.sort * 4 + 2
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["color" .. k].width = "half"
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["text" .. k].order = v.sort * 4 + 3
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["gp" .. k] = {
                order = v.sort * 4 + 4,
                name = "GP",
                desc = LEP["gp_value_help"],
                type = "input",
                width = "half",
				pattern = "^%d+%%?$",
                get = function() return self.db.gp.relicButtons[v.sort] end,
                set = function(info, value) self.db.gp.relicButtons[v.sort] = value end,
                hidden = function() return not addon.db.profile.relicButtonsEnabled or addon.db.profile.relicNumButtons < v.sort end,
            }
    	end
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil")
end

function RCEPGP:OptionsTable()
	local options =
	{
	    name = "RCLootCouncil-EPGP",
	    type = "group",
	    childGroups = "tab",
	    inline = false,
		handler = self,
		get = self:DBGetFunc(),
		set = self:DBSetFunc(),
		args = {
            version = {
                name = function() return "|cFF87CEFAv"..self.version.."|r"..(self.tVersion and ("-"..self.tVersion) or "") end,
                type = "description",
                order = 1,
            },
            addonDesc = {
                name = LEP["RCEPGP_desc"],
                type = "description",
                order = 2,
            },
            website = {
                name = "|cffffd000https://mods.curse.com/addons/wow/269161-rclootcouncil-epgp|r",
                type = "description",
                order = 3,
            },
			mlTab = {
				name = L["Master Looter"],
				order = 2,
				type = "group",
				args = {
					gpOptions = {
						name = LEP["GP Options"],
						order = 0.5,
						type = "group",
						inline = true,
						args = {
							gpOptionsButton = {
								name = LEP["gpOptionsButton"],
								order = 1,
								width = "double",
								type = "execute",
								func = function()
									InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame.ml)
									InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame.ml) -- Twice due to blizz reasons
									LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil", "mlSettings", "buttonsTab")
								end,
							},
							header = {
								name = "",
								type = "header",
								order = 2,
							},
							dkpMode = {
								name = LEP["DKP Mode"],
								type = "toggle",
								desc = LEP["dkp_mode_desc"],
								confirm = function(_, value) if value then return LEP["dkp_mode_desc"] end end,
							}
						},
					},
					bid = {
						name = _G.BID,
						order = 1,
						type = "group",
						inline = true,
						get = self:DBGetFunc("bid"),
						set = self:DBSetFunc("bid"),
						args = {
							bidEnabled = {
								name = _G.ENABLE,
								desc = LEP["bidding_desc"],
								order = 1,
								type = "toggle",
								width = "full",
							},
							bidMode = {
								name = "Bid Mode",
								values = {
									prRelative="Highest PR*bid wins and gets GP of (gp of item)*bid",
									gpAbsolute="Highest bid wins and gets GP of bid.",
									gpRelative="Highest bid wins and gets GP of (gp of item)*bid",
								},
								order = 3,
								type = "select",
								width = "double",
								hidden = function() return not self.db.bid.bidEnabled end,
							},
							space = {
								name = "",
								order = 4,
								type = "description",
								width = "full",
							},
							minBid = {
								name = "Min Bid",
								order = 5,
								type = "input",
								validate = "ValidateBidOption",
								hidden = function() return not self.db.bid.bidEnabled end,
							},
							maxBid = {
								name = "Max Bid",
								order = 6,
								type = "input",
								validate = "ValidateBidOption",
								hidden = function() return not self.db.bid.bidEnabled or self.db.bid.bidMode ~= "prRelative" end
							},
							minNewPR = {
								name = "Min New PR",
								order = 7,
								type = "input",
								validate = "ValidateBidOption",
								hidden = function() return not self.db.bid.bidEnabled or self.db.bid.bidMode == "prRelative" end
							},
							defaultBid = {
								name = "Default Bid",
								order = 8,
								type = "input",
								validate = "ValidateBidOption",
								hidden = function() return not self.db.bid.bidEnabled end,
							},
						},
					},
				},
			},
            gpTab = {
                name = LEP["Custom GP"],
                order = 3,
                type = "group",
                get = self:DBGetFunc("customGP"),
                set = self:DBSetFunc("customGP"),
                args = {
                    customGPdesc = {
                        name = LEP["customGP_desc"],
                        order = 1,
                        type = "description",
                        width = "full",
                    },
                    customGPEnabled = {
                        name = _G.ENABLE,
                        order = 2,
                        type = "toggle",
                        width = "double",
                    },
                    slotWeights = {
                        name = LEP["slot_weights"],
                        order = 3,
                        type = "group",
                        inline = true,
						validate = "ValidateNumber",
						disabled = function() return (not self.db.customGP.customGPEnabled) end,
                        args = {
                            -- Fill in later
                        },
                    },
                    formulaHelp = {
                        name = LEP["gp_formula_help"],
                        order = 100,
                        type = "description",
                        width = "full",
                    },
                    space1 = {
                        name = "",
                        order = 101,
                        type = "description",
                    },
                    formula = {
                        name = LEP["gp_formula"],
                        order = 150,
                        multiline = 1,
                        type = "input",
                        width = "full",
						validate = "ValidateFormula",
						disabled = function() return (not self.db.customGP.customGPEnabled) end,
                    },
                    restoreDefault = {
                        name = _G.RESET_TO_DEFAULT,
                        order = 1000,
                        type = "execute",
                        func = function() self:DeepCopy(self.db.customGP, self.defaults.customGP, true) end,
                    },
                },
            },
            epTab = {
                name = LEP["Custom EP"],
                order = 4,
                type = "group",
                args = {
                        desc = {
                                order = 1,
                                name = LEP["customEP_desc"],
                                type = "description",
                        },
                        add = {
                            order = 2,
                            name = LEP["Add EP Formula"],
                            type = "execute",
                            disabled = function() return self.db.customEP.EPFormulas.count >= RCCustomEP.MaxFormulas end,
                            func = function()
								self.db.customEP.EPFormulas[self.db.customEP.EPFormulas.count+1] = {}
								self.db.customEP.EPFormulas[self.db.customEP.EPFormulas.count+1].name = RCCustomEP:EPFormulaGetUnrepeatedName("New")
								self.db.customEP.EPFormulas.count = self.db.customEP.EPFormulas.count + 1
								addon.db:GetNamespace("EPGP"):RegisterDefaults(self.defaults) -- Important
							end,
                        },
                    },
            	},
			}
        }

	local function EPFormulaOptionEntry(name, order)
		return {
			name = name,
			step = 0.001,
			order = order,
			type = "range",
			min = 0,
			max = 1,
			isPercent = true,
		}
	end
	local function EPFormulaRankEntry(rank)
		return {
			name = GuildControlGetRankName(rank+1) or "",
			hidden = not GuildControlGetRankName(rank+1),
			order = rank+1,
			type = "range",
			min = 0,
			max = 1,
			isPercent = true,
		}
	end


    for i=1,RCCustomEP.MaxFormulas do
        local formulaName = "Name"..i
        local description = "DESC1"..i
        local formula = "FORMULA"..i
        options.args.epTab.args["EPFormula"..i] = {
            name = function() return i..". "..(self.db.customEP.EPFormulas[i].name or "") end,
            type = "group",
            order = 100+i,
            hidden = function() return i > self.db.customEP.EPFormulas.count  end,
			get = self:DBGetFunc("customEP", "EPFormulas", i),
			set = self:DBSetFunc("customEP", "EPFormulas", i),
            args = {
                up = {
                    name = "up",
                    type = "execute",
					width = "half",
                    order = 1,
                    disabled = function() return i == 1 end,
                    func = function()
                        if i ~= 1 then
                            local entry1 = self.db.customEP.EPFormulas[i-1]
                            local entry2 = self.db.customEP.EPFormulas[i]
                            self.db.customEP.EPFormulas[i-1] = entry2
                            self.db.customEP.EPFormulas[i] = entry1
                            LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil-EPGP", "epTab", "EPFormula"..(i-1))
                        end
                    end,
                },
                down = {
                    name = "down",
                    type = "execute",
					width = "half",
                    order = 3,
                    disabled = function() return i >= self.db.customEP.EPFormulas.count end,
                    func = function()
                        if i < self.db.customEP.EPFormulas.count then
							local entry1 = self.db.customEP.EPFormulas[i+1]
                            local entry2 = self.db.customEP.EPFormulas[i]
                            self.db.customEP.EPFormulas[i+1] = entry2
                            self.db.customEP.EPFormulas[i] = entry1
                            LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil-EPGP", "epTab", "EPFormula"..(i+1))
                        end
                    end,
                },
                delete = {
                    name = _G.DELETE,
                    type = "execute",
					width = "half",
                    order = 5,
                    confirm = function() return format(LEP["formula_delete_confirm"], i..". "..self.db.customEP.EPFormulas[i].name) end,
                    func = function()
						table.remove(self.db.customEP.EPFormulas, i)
						wipe(self.db.customEP.EPFormulas[self.db.customEP.EPFormulas.count])
						self.db.customEP.EPFormulas[self.db.customEP.EPFormulas.count] = nil
						if self.db.customEP.EPFormulas.count > 0 then
							self.db.customEP.EPFormulas.count = self.db.customEP.EPFormulas.count-1
						end
						LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil-EPGP", "epTab", "EPFormula"..i)
					end,
                },
				name = {
					name = _G.NAME,
					order = 6,
					type = "input",
					set = function(info, value)
						value = RCCustomEP:EPFormulaGetUnrepeatedName(value)
						self:DBSetFunc("customEP", "EPFormulas", i)(info, value);
					end
				},
				onlineStatus = {
					name = "Online Status",
					order = 10,
					type = "group",
					inline = true,
					args = {
						online = EPFormulaOptionEntry(_G.GUILD_ONLINE_LABEL, 1),
						offline = EPFormulaOptionEntry(_G.PLAYER_OFFLINE, 2),
					},
				},
				groupStatus = {
					name = "Group Status",
					order = 11,
					type = "group",
					inline = true,
					args = {
						inGroup = EPFormulaOptionEntry(LEP["In Group"], 1),
						standby = EPFormulaOptionEntry(LEP["In standby"], 2),
						calendarSignedUp = EPFormulaOptionEntry(LEP["signed up in calendar"], 3),
						completelyNotInGroup = EPFormulaOptionEntry(LEP["None of the above"], 4),
					},
				},
				ranks = {
					name = _G.RANK,
					order = 12,
					type = "group",
					inline = true,
					args = {
						isRank0 = EPFormulaRankEntry(0),
						isRank1 = EPFormulaRankEntry(1),
						isRank2 = EPFormulaRankEntry(2),
						isRank3 = EPFormulaRankEntry(3),
						isRank4 = EPFormulaRankEntry(4),
						isRank5 = EPFormulaRankEntry(5),
						isRank6 = EPFormulaRankEntry(6),
						isRank7 = EPFormulaRankEntry(7),
						isRank8 = EPFormulaRankEntry(8),
						isRank9 = EPFormulaRankEntry(9),
						notInGuild = EPFormulaOptionEntry(LEP["Not in your guild"], 11),
					},
				},
				zones = {
					name = _G.ZONE,
					order = 13,
					type = "group",
					inline = true,
					args = {
						inZones = EPFormulaOptionEntry(LEP["In Zones"], 1),
						notInZones = EPFormulaOptionEntry(LEP["Not In Zones"], 2),
						zones = {
							name = _G.ZONE,
							desc = LEP["customep_zones_desc"],
							width = "full",
							type = "input",
							order = 3,
						}
					},
				}
            }
        }
    end


    -- Add Options to set slot weights
	local invTypes = {
		"INVTYPE_RELIC", "INVTYPE_TRINKET", "INVTYPE_HEAD", "INVTYPE_CHEST", "INVTYPE_LEGS", "INVTYPE_SHOULDER",
		"INVTYPE_HAND", "INVTYPE_WAIST", "INVTYPE_FEET", "INVTYPE_CLOAK", "INVTYPE_WRIST", "INVTYPE_NECK", "INVTYPE_FINGER"}
    for i = 1, #invTypes do
		local type = invTypes[i]
        options.args.gpTab.args.slotWeights.args[RCCustomGP.INVTYPESlots[type]] = {
            name = _G[type],
            order = 10 + i,
            type = "input",
            width = "half",
        }
    end

    -- Add descriptions for GP variables
    for i = 1, #RCCustomGP.GPVariables do
        local variableName = RCCustomGP.GPVariables[i].name
        options.args.gpTab.args["variable"..variableName] = {
            name = "|cFFFFFF00"..variableName.."|r",
            order = 100 + i * 2,
            fontSize = "medium",
            type = "description",
            width = "normal",
        }
        options.args.gpTab.args["variable"..variableName.."help"] = {
            name = RCCustomGP.GPVariables[i].help,
            order = 101 + i * 2,
            fontSize = "small",
            type = "description",
            width = "double",
        }
    end

    return options
end

-- Create a get function for given category
function RCEPGP:DBGetFunc(...)
	local args = {...}
	return function(info)
		local t = self.db
		for i=1,#args do
			t = t[args[i]]
		end
		return t[info[#info]]
	end
end

-- Create a set function for given category
function RCEPGP:DBSetFunc(...)
	local args = {...}
	return function(info, value)
		local t = self.db
		local default = self.defaults.profile
		for i=1,#args do
			t = t[args[i]]
			default = default and default[args[i]]
		end
		if default and (value == nil or value == "") then -- Reset to default, if default exists
			t[info[#info]] = default[info[#info]]
		else
			t[info[#info]] = value
		end
		if #args > 0 then
			self:ConfigTableChanged(unpack(args), info[#info])
		else
			self:ConfigTableChanged(info[#info])
		end
	end
end

function RCEPGP:ValidateNumber(info, value)
	if value == "" then
		return true
	end
	if not tonumber(value) then
		return LEP["Input must be a number."]
	end
	return true
end

function RCEPGP:ValidateBidOption(info, value)
	if value == "" then
		return true
	end
	if not tonumber(value) or tonumber(value) < 0 then
		return LEP["Input must be a non-negative number."]
	end
	if info[#info] == "maxBid" then
		if (self.db.bid.defaultBid ~= "" and tonumber(value) < tonumber(self.db.bid.defaultBid)) or
			tonumber(value) < tonumber(self.db.bid.minBid) then
				return LEP["Invalid input"]
		end
	elseif info[#info] == "defaultBid" then
		if value ~= "" and tonumber(value) < tonumber(self.db.bid.minBid) or
		(self.db.bid.bidMode == "prRelative" and tonumber(value) > tonumber(self.db.bid.maxBid)) then
			return LEP["Invalid input"]
		end
	elseif info[#info] == "minBid" then
		if (self.db.bid.defaultBid ~= "" and tonumber(value) > tonumber(self.db.bid.defaultBid)) or
		(self.db.bid.bidMode == "prRelative" and tonumber(value) > tonumber(self.db.bid.maxBid)) then
			return LEP["Invalid input"]
		end
	end
	return true
end

function RCEPGP:ValidateFormula(info, value)
	if value == "" then
		return true
	end
	local func, err = loadstring(value)
	if not func then
		local func, err = loadstring("return "..value)
		if not func then
			return LEP["formula_syntax_error"].."\n"..err
		end
	end
	return true
end

function RCEPGP:ConfigTableChanged(...)
	self:SendMessage("RCEPGPConfigTableChanged", ...)
end

function RCEPGP:AddOptions()
	local initialize = true
	for _, module in self:IterateModules() do
		if not module.initialize then
			initialize = false
		end
	end
	if not initialize then
		return self:ScheduleTimer("AddOptions", 0.5)
	end
	self.epgpOptions = self:OptionsTable()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RCLootCouncil-EPGP", self.epgpOptions)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil-EPGP", "EPGP", "RCLootCouncil")
    LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil-EPGP")
    return self.epgpOptions
end

function RCEPGP:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end
