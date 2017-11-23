local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomGP = RCEPGP:GetModule("RCCustomGP", true)
local RCCustomEP = RCEPGP:GetModule("RCCustomEP", true)

------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")

function RCEPGP:AddGPOptions()
    local options = addon:OptionsTable()

    addon.options = addon:OptionsTable()

    local button, picker, text, gp = {}, {}, {}, {}
    for i = 1, addon.db.profile.maxButtons do
        addon.options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["button" .. i].order = i * 4 + 1;
        addon.options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["picker" .. i].order = i * 4 + 2;
        addon.options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["picker" .. i].width = "half";
        addon.options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["text" .. i].order = i * 4 + 3;
        gp = {
            order = i * 4 + 4,
            name = "GP",
            desc = LEP["gp_value_help"],
            type = "input",
            width = "half",
            get = function() return addon.db.profile.responses[i].gp or "100%" end,
            set = function(info, value)
                if not value then value = "100%" end
                value = tostring(value)
                if string.match(value, "^%d+%%$") or string.match(value, "^%d+$") then
                    addon.db.profile.responses[i].gp = tostring(value)
                end
            end,
            hidden = function() return addon.db.profile.numButtons < i end,
        }
        if not addon.db.profile.responses[i].gp then
            addon.db.profile.responses[i].gp = "100%"
        end
        addon.options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["gp" .. i] = gp;
    end


    for k, v in pairs(addon.db.profile.responses.tier) do
        addon.options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["button" .. k].order = v.sort * 4 + 1
        addon.options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["color" .. k].order = v.sort * 4 + 2
        addon.options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["color" .. k].width = "half"
        addon.options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["text" .. k].order = v.sort * 4 + 3
        gp = {
            order = v.sort * 4 + 4,
            name = "GP",
            desc = LEP["gp_value_help"],
            type = "input",
            width = "half",
            get = function() return addon.db.profile.tierButtons[v.sort].gp or "100%" end,
            set = function(info, value)
                if not value then value = "100%" end
                value = tostring(value)
                if string.match(value, "^%d+%%$") or string.match(value, "^%d+$") then
                    addon:ConfigTableChanged("responses");addon.db.profile.tierButtons[v.sort].gp = tostring(value)
                end
            end,
            hidden = function() return not addon.db.profile.tierButtonsEnabled or addon.db.profile.tierNumButtons < v.sort end,
        }
        if not addon.db.profile.tierButtons[v.sort].gp then
            addon.db.profile.tierButtons[v.sort].gp = "100%"
        end
        addon.options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["gp" .. k] = gp
    end

    -- Relic Buttons/Responses
    if addon.db.profile.responses.relic then
    	for k, v in pairs(addon.db.profile.responses.relic) do
            addon.options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["button" .. k].order = v.sort * 4 + 1
            addon.options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["color" .. k].order = v.sort * 4 + 2
            addon.options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["color" .. k].width = "half"
            addon.options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["text" .. k].order = v.sort * 4 + 3
            gp = {
                order = v.sort * 4 + 4,
                name = "GP",
                desc = LEP["gp_value_help"],
                type = "input",
                width = "half",
                get = function() return addon.db.profile.relicButtons[v.sort].gp or "100%" end,
                set = function(info, value)
                    if not value then value = "100%" end
                    value = tostring(value)
                    if string.match(value, "^%d+%%$") or string.match(value, "^%d+$") then
                        addon:ConfigTableChanged("responses");addon.db.profile.relicButtons[v.sort].gp = tostring(value)
                    end
                end,
                hidden = function() return not addon.db.profile.relicButtonsEnabled or addon.db.profile.relicNumButtons < v.sort end,
            }
            if not addon.db.profile.relicButtons[v.sort].gp then
                addon.db.profile.relicButtons[v.sort].gp = "100%"
            end
            addon.options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["gp" .. k] = gp
    	end
    end

    addon.options.args.settings.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(addon.db)
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RCLootCouncil", addon.options)
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
                name = function() return "|cFF87CEFAv"..self.version.."|r-"..self.testVersion end,
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
            generalTab = {
                name = _G.GENERAL,
                order = 1,
                type = "group",
                args = {
                    gpOptions = {
                        name = LEP["gpOptions"],
                        order = 1,
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
                        },
                    },
                    sync = {
                        name = LEP["Setting Sync"],
                        order = 2,
                        type = "group",
                        inline = true,
                        args = {
                            sendEPGPSettings = {
                                name = LEP["send_epgp_settings"],
                                desc = LEP["send_epgp_setting_desc"],
                                order = 1,
                                type = "toggle",
                                width = "full",
                            },
                        },
                    },
					columns = {
						name = "Columns",
						desc = "Enable or disable some columns in the voting frame",
						order = 3,
						type = "group",
						inline = true,
						get = self:DBGetFunc("columns"),
						set = self:DBSetFunc("columns"),
						args = {
							epColumnEnabled = {
								name = "EP",
								order = 1,
								type = "toggle",
								width = "half",
							},
							gpColumnEnabled = {
								name = "GP",
								order = 2,
								type = "toggle",
								width = "half",
							},
						}
					},
                },
            },
			mlTab = {
				name = "Master Looter",
				order = 2,
				type = "group",
				args = {
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
								order = 1,
								type = "toggle",
								width = "full",
							},
							desc = {
								name = LEP["bidding_desc"],
								order = 2,
								type = "description",
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
								hidden = function() return not self:GetEPGPdb().bid.bidEnabled end,
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
								hidden = function() return not self:GetEPGPdb().bid.bidEnabled end,
							},
							maxBid = {
								name = "Max Bid",
								order = 6,
								type = "input",
								validate = "ValidateBidOption",
								hidden = function() return not self:GetEPGPdb().bid.bidEnabled or self:GetEPGPdb().bid.bidMode ~= "prRelative" end
							},
							minNewPR = {
								name = "Min New PR",
								order = 7,
								type = "input",
								validate = "ValidateBidOption",
								hidden = function() return not self:GetEPGPdb().bid.bidEnabled or self:GetEPGPdb().bid.bidMode == "prRelative" end
							},
							defaultBid = {
								name = "Default Bid",
								order = 8,
								type = "input",
								validate = "ValidateBidOption",
								hidden = function() return not self:GetEPGPdb().bid.bidEnabled end,
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
					customGPdesc2 = {
						name = LEP["customGP_desc2"],
						order = 1.5,
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
						disabled = function() return (not self:GetEPGPdb().customGP.customGPEnabled) end,
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
						disabled = function() return (not self:GetEPGPdb().customGP.customGPEnabled) end,
                    },
                    restoreDefault = {
                        name = _G.RESET_TO_DEFAULT,
                        order = 1000,
                        type = "execute",
                        func = function() self:DeepCopy(self:GetEPGPdb().customGP, self.defaults.customGP, true) end,
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
                            disabled = function() return self:GetEPGPdb().customEP.EPFormulas.count >= RCCustomEP.MaxFormulas end,
                            func = function() table.insert(self:GetEPGPdb().customEP.EPFormulas, {
                                    name = RCCustomEP:EPFormulaGetUnrepeatedName("New"),
                                    desc = "",
                                    formula = "0",
                                }) end,
                        },
                    },
            	},
			}
        }

	local function EPFormulaOptionEntry(name, order)
		return {
			name = name,
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
            name = function() return i..". "..(self:GetEPGPdb().customEP.EPFormulas[i].name or "") end,
            type = "group",
            order = 100+i,
            hidden = function() return i > self:GetEPGPdb().customEP.EPFormulas.count  end,
			get = self:DBGetFunc("customEP", "EPFormulas", i),
			set = self:DBSetFunc("customEP", "EPFormulas", i),
            args = {
                up = {
                    name = "Move up",
                    type = "execute",
                    order = 1,
                    disabled = function() return i == 1 end,
                    func = function()
                        if i ~= 1 then
                            local entry1 = self:GetEPGPdb().customEP.EPFormulas[i-1]
                            local entry2 = self:GetEPGPdb().customEP.EPFormulas[i]
                            self:GetEPGPdb().customEP.EPFormulas[i-1] = entry2
                            self:GetEPGPdb().customEP.EPFormulas[i] = entry1
                            LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil-EPGP", "epTab", "EPFormula"..(i-1))
                        end
                    end,
                },
                space1 = {
                    name = "  ",
                    type = "description",
                    width = "double",
                    order = 2,
                },
                down = {
                    name = "Move down",
                    type = "execute",
                    order = 3,
                    --disabled = function() return i == #RCCustomEP:GetCustomEPdb().EPFormulas end,
                    func = function()
                        if i < self:GetEPGPdb().customEP.EPFormulas.count then
							local entry1 = self:GetEPGPdb().customEP.EPFormulas[i+1]
                            local entry2 = self:GetEPGPdb().customEP.EPFormulas[i]
                            self:GetEPGPdb().customEP.EPFormulas[i+1] = entry2
                            self:GetEPGPdb().customEP.EPFormulas[i] = entry1
                            LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil-EPGP", "epTab", "EPFormula"..(i+1))
                        end
                    end,
                },
                space2 = {
                    name = "  ",
                    type = "description",
                    width = "double",
                    order = 4,
                },
                delete = {
                    name = "Delete",
                    type = "execute",
                    order = 5,
                    confirm = function() return format(LEP["ep_formula_delete_confirm"], i..". "..RCCustomEP.EPFormulaGetter(i, "name")) end,
                    func = function() table.remove(RCCustomEP:GetCustomEPdb().EPFormulas, i) end,
                },
				onlineStatus = {
					name = "Online Status",
					order = 6,
					type = "group",
					inline = true,
					args = {
						online = EPFormulaOptionEntry(_G.GUILD_ONLINE_LABEL, 1),
						offline = EPFormulaOptionEntry(_G.PLAYER_OFFLINE, 2),
					},
				},
				groupStatus = {
					name = "Group Status",
					order = 7,
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
					order = 8,
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
		local t = self:GetEPGPdb()
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
		local t = self:GetEPGPdb()
		local default = self.defaults
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
		if (self:GetEPGPdb().bid.defaultBid ~= "" and tonumber(value) < tonumber(self:GetEPGPdb().bid.defaultBid)) or
			tonumber(value) < tonumber(self:GetEPGPdb().bid.minBid) then
				return LEP["Invalid input"]
		end
	elseif info[#info] == "defaultBid" then
		if value ~= "" and tonumber(value) < tonumber(self:GetEPGPdb().bid.minBid) or
		(self:GetEPGPdb().bid.bidMode == "prRelative" and tonumber(value) > tonumber(self:GetEPGPdb().bid.maxBid)) then
			return LEP["Invalid input"]
		end
	elseif info[#info] == "minBid" then
		if (self:GetEPGPdb().bid.defaultBid ~= "" and tonumber(value) > tonumber(self:GetEPGPdb().bid.defaultBid)) or
		(self:GetEPGPdb().bid.bidMode == "prRelative" and tonumber(value) > tonumber(self:GetEPGPdb().bid.maxBid)) then
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
