local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")

------ Options ------
local defaults = {
    customGPEnabled = false,
    INVTYPE_HEAD = 1,
    INVTYPE_CHEST = 1,
    INVTYPE_ROBE = 1,
    INVTYPE_LEGS = 1,
    INVTYPE_WRIST = 0.56,
    INVTYPE_FINGER = 0.56,
    INVTYPE_CLOAK = 0.56,
    INVTYPE_NECK = 0.56,
    INVTYPE_SHOULDER = 0.75,
    INVTYPE_WAIST = 0.75,
    INVTYPE_FEET = 0.75,
    INVTYPE_HAND = 0.75,
    INVTYPE_TRINKET = 1.25,
    INVTYPE_RELIC = 0.667,
    formula = "1000 * 2 ^ (-915/30) * 2 ^ (ilvl/30) * slotWeights + hasSpeed * 25 + numSocket * 200"
}

RCEPGP.defaults = defaults

function RCEPGP:SetDefaults(restoreDefaults)
    for info, value in pairs(defaults) do
        if restoreDefaults or self:GetEPGPdb()[info] == nil or self:GetEPGPdb()[info] == "" then
            if type(value) == "boolean" then
                self:GetEPGPdb()[info] = value
            else
                self:GetEPGPdb()[info] = tostring(value)
            end
        end
    end
end

local function ValidateStatWeights(info, value)
    if value == "" then
        return true
    end
    if not tonumber(value) then
        addon:Print(LEP["Input must be a number."])
        return LEP["Input must be a number."]
    end
    return true
end

local function Getter(info, value)
    return RCEPGP:GetEPGPdb()[info[#info]]
end

local function Setter(info, value)
    if (not value) or value == "" then
        value = tostring(defaults[info[#info]])
    end
    RCEPGP:GetEPGPdb()[info[#info]] = value
end

local function CustomGPDisabled()
    return (not RCEPGP:GetEPGPdb().customGPEnabled)
end


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
                RCEPGP:SendMessage("RCGPResponseChanged")
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


    addon.options.args.settings.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(addon.db)
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RCLootCouncil", addon.options)
    LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil")
    addon:ConfigTableChanged("buttons");
    addon:ConfigTableChanged("tierButtons");
end

function RCEPGP:OptionsTable()
    self:SetDefaults()

    local options = {
        name = "RCLootCouncil - EPGP v"..self.version,
        order = 1,
        type = "group",
        childGroups = "tab",
        args = {
            gpOptions = {
                name = LEP["gpOptions"],
                order = 4,
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
            bidding = {
                name = LEP["Bidding"],
                order = 5,
                type = "group",
                inline = true,
                args = {
                    biddingEnabled = {
                        name = LEP["Enable Bidding"],
                        order = 1,
                        type = "toggle",
                        width = "full",
                        get = function() return self:GetEPGPdb().biddingEnabled end,
                        set = function(info, value) self:GetEPGPdb().biddingEnabled = value; RCEPGP:SetupColumns() end,
                    },
                    biddingDesc = {
                        name = LEP["bidding_desc"],
                        order = 2,
                        type = "description",
                        width = "full",
                    },
                },
            },
            customGP = {
                name = LEP["Custom GP"],
                order = 10,
                type = "group",
                inline = true,
                args = {
                    customGPEnabled = {
                        name = LEP["enable_custom_gp"],
                        order = 1,
                        type = "toggle",
                        width = "double",
                        get = Getter,
                        set = function(info, value)
                            self:GetEPGPdb()[info[#info]] = value
                        end,
                    },
                    restoreDefault = {
                        name = LEP["restore_default"],
                        order = 2,
                        type = "execute",
                        func = function() RCEPGP:SetDefaults(true) end,
                    },
                    slotWeights = {
                        name = LEP["slot_weights"],
                        order = 3,
                        type = "group",
                        inline = true,
                        args = {
                            -- Fill in later
                        },
                    },

                    formulaHelp = {
                        name = LEP["formula_help"],
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
                        get = Getter,
                        set = function(info, value)
                            if value == "" then
                                value = tostring(defaults[info[#info]])
                            end
                            self:GetEPGPdb()[info[#info]] = value
                            local func, err = RCEPGP:GetFormulaFunc()
                            if not func then
                                RCEPGP.epgpOptions.args.customGP.args.errorMsg.name = LEP["formula_syntax_error"]
                                RCEPGP.epgpOptions.args.customGP.args.errorDetailedMsg.name = err
                            else
                                RCEPGP.epgpOptions.args.customGP.args.errorMsg.name = ""
                                RCEPGP.epgpOptions.args.customGP.args.errorDetailedMsg.name = ""
                            end
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil");
                        end,
                        disabled = CustomGPDisabled,
                    },
                    errorMsg = {
                        name = "",
                        order = 151,
                        type = "description",
                        width = "full",
                    },
                    errorDetailedMsg = {
                        name = "",
                        order = 152,
                        type = "description",
                        width = "full",
                    },
                },
            },
        },
    }


    -- Add Options to set slot weights
    local slots = {"INVTYPE_HEAD", "INVTYPE_NECK", "INVTYPE_SHOULDER", "INVTYPE_CLOAK", "INVTYPE_NECK", "INVTYPE_CHEST", "INVTYPE_NECK", "INVTYPE_WRIST",
    "INVTYPE_HAND", "INVTYPE_WAIST", "INVTYPE_LEGS", "INVTYPE_FEET", "INVTYPE_FINGER", "INVTYPE_TRINKET", "INVTYPE_RELIC", }
    for i = 1, #slots do
        local slot = slots[i]
        options.args.customGP.args.slotWeights.args[slot] = {
            name = getglobal(slot),
            order = 10 + i,
            type = "input",
            width = "half",
            validate = ValidateStatWeights,
            get = Getter,
            set = Setter,
            disabled = CustomGPDisabled,
        }
    end

    -- Add descriptions for variables
    local variables = {"ilvl", "slotWeights", "isToken", "numSocket", "hasAvoid", "hasSpeed", "hasLeech",
    "hasIndes", "isNormal", "isHeroic", "isMythic", "isWarforged", "isTitanforged", "rarity", "itemID", "equipLoc", "link", }
    for i = 1, #variables do
        local var = variables[i]
        options.args.customGP.args["variable"..var] = {
            name = "|cFFFFFF00"..var.."|r",
            order = 100 + i * 2,
            fontSize = "medium",
            type = "description",
            width = "normal",
        }
        options.args.customGP.args["variable"..var.."help"] = {
            name = LEP["variable_"..var.."_help"],
            order = 101 + i * 2,
            fontSize = "small",
            type = "description",
            width = "double",
        }
    end

    self.epgpOptions = options
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RCLootCouncil - EPGP", self.epgpOptions)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil - EPGP", "EPGP", "RCLootCouncil")
    LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil - EPGP")
end

function RCEPGP:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory(RCEPGP.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(RCEPGP.optionsFrame)
end
