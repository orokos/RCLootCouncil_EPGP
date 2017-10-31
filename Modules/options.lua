local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomGP = RCEPGP:GetModule("RCCustomGP", true)
--local RCCustomEP = RCEPGP:GetModule("RCCustomEP", true) -- TODO
--local RCCustomEPGUI = RCEPGP:GetModule("RCCustomEPGUI", true)

------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")

function RCEPGP:AddGPOptions()
    local options = addon:OptionsTable()

    local button, picker, text, gp = {}, {}, {}, {}
    for i = 1, addon.db.profile.maxButtons do
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["button" .. i].order = i * 4 + 1;
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["picker" .. i].order = i * 4 + 2;
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["picker" .. i].width = "half";
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["text" .. i].order = i * 4 + 3;
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
        options.args.mlSettings.args.buttonsTab.args.buttonOptions.args["gp" .. i] = gp;
    end


    for k, v in pairs(addon.db.profile.responses.tier) do
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["button" .. k].order = v.sort * 4 + 1
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["color" .. k].order = v.sort * 4 + 2
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["color" .. k].width = "half"
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["text" .. k].order = v.sort * 4 + 3
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
        options.args.mlSettings.args.buttonsTab.args.tierButtonsOptions.args["gp" .. k] = gp
    end

    -- Relic Buttons/Responses
    if addon.db.profile.responses.relic then
    	for k, v in pairs(addon.db.profile.responses.relic) do
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["button" .. k].order = v.sort * 4 + 1
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["color" .. k].order = v.sort * 4 + 2
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["color" .. k].width = "half"
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["text" .. k].order = v.sort * 4 + 3
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
            options.args.mlSettings.args.buttonsTab.args.relicButtonsOptions.args["gp" .. k] = gp
    	end
    end

    --options.args.settings.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(addon.db)
    --LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RCLootCouncil", options)
    LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil")
end

function RCEPGP:OptionsTable()
	local options =
	{
	    name = "RCLootCouncil-EPGP",
	    order = 1,
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
                order = 5,
                type = "group",
                args = {
                    gpOptions = {
                        name = LEP["gpOptions"],
                        order = 3,
                        type = "group",
                        inline = true,
                        args = {
                            gpOptionsButton = {
                                name = LEP["gpOptionsButton"],
                                order = 1,
                                width = "double",
                                type = "execute",
                                func = function()
                                    InterfaceOptionsFrame_OpenToCategory(optionsFrame.ml)
                                    InterfaceOptionsFrame_OpenToCategory(optionsFrame.ml) -- Twice due to blizz reasons
                                    LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil", "mlSettings", "buttonsTab")
                                end,
                            },
                        },
                    },
                    sync = {
                        name = LEP["Setting Sync"],
                        order = 4,
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
                    bidding = {
                        name = _G.BID,
                        order = 5,
                        type = "group",
                        inline = true,
                        args = {
                            biddingEnabled = {
                                name = _G.ENABLE,
                                desc = LEP["bidding_desc"],
                                order = 1,
                                type = "toggle",
                                width = "full",
                            },
                        },
                    },
                },
            },
            gpTab = {
                name = LEP["Custom GP"],
                order = 6,
                type = "group",
                get = self:DBGetFunc("customGP"),
                set = self:DBSetFunc("customGP"),
				disabled = function() return (not self:GetEPGPdb().customGP.customGPEnabled) end,
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
						disabled = false,
                    },
                    slotWeights = {
                        name = LEP["slot_weights"],
                        order = 3,
                        type = "group",
                        inline = true,
						validate = "VaildateNumber",
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
                    },
                    restoreDefault = {
                        name = _G.RESET_TO_DEFAULT,
                        order = 1000,
                        type = "execute",
                        func = function() self:DeepCopy(self:GetEPGPdb().customGP, self.defaults.customGP, true) end,
                    },
                },
            },
		}
            --[[
            epTab = {
                name = LEP["Custom EP"],
                order = 7,
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
                            disabled = function() return #RCCustomEP:GetCustomEPdb().EPFormulas >= RCCustomEP.MaxFormulas end,
                            func = function() table.insert(RCCustomEP:GetCustomEPdb().EPFormulas, {
                                    name = RCCustomEP:EPFormulaGetUnrepeatedName("New"),
                                    desc = "",
                                    formula = "0",
                                }) end,
                        },
                        openEPGUI = {
                            order = 3,
                            name = LEP["Option EP GUI"],
                            type = "execute",
                            func = function() RCCustomEPGUI:ShowFrame() end,
                        },
                        restoreDefault = {
                            name = _G.RESET_TO_DEFAULT,
                            order = 4,
                            type = "execute",
                            func = function() RCCustomEP:RestoreToDefault() end,
                        },

                    },
            },
           epVariablesTab = {
               name = LEP["Custom EP Variables"],
               order = 8,
               type = "group",
               args = {
                   desc = {
                           order = 1,
                           name = LEP["customEPVariable_desc"],
                           type = "description",
                   },
               },
           }
           --]] --TODO: feature not available in v2.0
        }

        --[[
    -- Add EP Formulas
    for i=1,RCCustomEP.MaxFormulas do
        local formulaName = "Name"..i
        local description = "DESC1"..i
        local formula = "FORMULA"..i
        options.args.epTab.args["EPFormula"..i] = {
            name = function() return i..". "..RCCustomEP.EPFormulaGetter(i, "name") end,
            type = "group",
            order = 100+i,
            hidden = function() return i > #RCCustomEP:GetCustomEPdb().EPFormulas;  end,
            args = {
                up = {
                    name = "Move up",
                    type = "execute",
                    order = 1,
                    disabled = function() return i == 1 end,
                    func = function()
                        if i ~= 1 then
                            local entry1 = RCCustomEP:GetCustomEPdb().EPFormulas[i-1]
                            local entry2 = RCCustomEP:GetCustomEPdb().EPFormulas[i]
                            RCCustomEP:GetCustomEPdb().EPFormulas[i-1] = entry2
                            RCCustomEP:GetCustomEPdb().EPFormulas[i] = entry1
                            LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil - EPGP", "epTab", "EPFormula"..(i-1))
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
                    disabled = function() return i == #RCCustomEP:GetCustomEPdb().EPFormulas end,
                    func = function()
                        if i ~= #RCCustomEP:GetCustomEPdb().EPFormulas then
                            local entry1 = RCCustomEP:GetCustomEPdb().EPFormulas[i+1]
                            local entry2 = RCCustomEP:GetCustomEPdb().EPFormulas[i]
                            RCCustomEP:GetCustomEPdb().EPFormulas[i+1] = entry2
                            RCCustomEP:GetCustomEPdb().EPFormulas[i] = entry1
                            LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil - EPGP", "epTab", "EPFormula"..(i+1))
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
                space3 = {
                    name = "  ",
                    type = "description",
                    width = "full",
                    order = 6,
                },
                name = {
                    name = "Name",
                    type = "input",
                    desc = LEP["ep_formula_name_desc"],
                    order = 7,
                    get = function() return RCCustomEP.EPFormulaGetter(i, "name") end,
                    set = function(_, value) RCCustomEP.EPFormulaSetter(i, "name", value) end,
                },
                space4 = {
                    name = "  ",
                    type = "description",
                    width = "full",
                    order = 8,
                },
                desc = {
                    name = "Description",
                    type = "input",
                    width = "full",
                    desc = LEP["ep_formula_desc_desc"],
                    get = function() return RCCustomEP.EPFormulaGetter(i, "desc") end,
                    set = function(_, value) RCCustomEP.EPFormulaSetter(i, "desc", value) end,
                    order = 9,
                },
                formula = {
                    name = "Formula",
                    type = "input",
                    width = "full",
                    desc = LEP["ep_formula_formula_desc"],
                    multiline = 7,
                    get = function() return RCCustomEP.EPFormulaGetter(i, "formula") end,
                    set = function(_, value)
                        RCCustomEP.EPFormulaSetter(i, "formula", value)
                        local func, err = RCCustomEP:GetEPFormulaFunc(i)
                        if not func then
                            self.epgpOptions.args.epTab.args["EPFormula"..i].args.errorMsg.name = LEP["formula_syntax_error"]
                            self.epgpOptions.args.epTab.args["EPFormula"..i].args.errorDetailedMsg.name = err
                        else
                            self.epgpOptions.args.epTab.args["EPFormula"..i].args.errorMsg.name = ""
                            self.epgpOptions.args.epTab.args["EPFormula"..i].args.errorDetailedMsg.name = ""
                        end
                    end,
                    order = 10,
                },
                errorMsg = {
                    name = "",
                    order = 11,
                    type = "description",
                    width = "full",
                },
                errorDetailedMsg = {
                    name = "",
                    order = 12,
                    type = "description",
                    width = "full",
                },
            }
        }
    end

    -- Add descriptions for EP variables
    local EPVariablesDisplayed = {}
    for i = 1, #RCCustomEP.EPVariables do
        local variableName = RCCustomEP.EPVariables[i].display_name or RCCustomEP.EPVariables[i].name
        if not EPVariablesDisplayed[variableName] then
            EPVariablesDisplayed[variableName] = true
            options.args.epVariablesTab.args["variable"..variableName] = {
                name = "|cFFFFFF00"..variableName.."|r",
                order = 100 + i * 2,
                fontSize = "medium",
                type = "description",
                width = "normal",
            }
            options.args.epVariablesTab.args["variable"..variableName.."help"] = {
                name = RCCustomEP.EPVariables[i].help,
                order = 101 + i * 2,
                fontSize = "small",
                type = "description",
                width = "double",
            }
        end
    end
    --]] --TODO: feature not available in v2.0

    -- Add Options to set slot weights
    local orderedSlots = {}
    for slot, info in pairs(RCCustomGP.slotsWithWeight) do
        table.insert(orderedSlots, {
            name = info.name,
            order = info.order,
            slot = slot,
        })
    end
    table.sort(orderedSlots, function(a, b)
        if not a.order then return false end
        if not b.order then return true end
        return a.order < b.order
    end)

    for i = 1, #orderedSlots do
        local slot = orderedSlots[i].slot
        local name = orderedSlots[i].name
        options.args.gpTab.args.slotWeights.args[slot] = {
            name = name,
            order = 10 + i,
            type = "input",
            width = "half",
            validate = function(info, value)
                if value == "" then
                    return true
                end
                if not tonumber(value) then
                    return LEP["Input must be a number."]
                end
                return true
            end,
			--usage = "Must be a number",
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
			t[info[#info]] = default
		else
			t[info[#info]] = value
		end
		self:ConfigTableChanged(unpack(args), info[#info])
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

function RCEPGP:ValidateFormula(info, value)
	if value == "" then
		return true
	end
	local func, err = loadstring(value)
	if not func then
		local func, err = loadstring("return "..value)
		if not func then
			return LEP["formula_syntax_error"].." "..err
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
