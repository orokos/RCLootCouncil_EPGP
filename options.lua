local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")

------ Options ------
local addon_db = addon:Getdb()
if not addon_db.epgp then
   addon_db.epgp = {}
end

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
   formula = "return 1000 * 2 ^ (-915/30) * 2 ^ (ilvl/30) * slotWeights + hasSpeed * 25 + numSocket * 200" 
}

RCEPGP.defaults = defaults

local function SetDefaults(restoreDefaults)
   if not addon_db.epgp then
      addon_db.epgp = {}
   end
   for info, value in pairs(defaults) do
      if restoreDefaults or addon_db.epgp[info] == nil or addon_db.epgp[info] == "" then
         if type(value) == "boolean" then
            addon_db.epgp[info] = value
         else
            addon_db.epgp[info] = tostring(value)
         end
      end
   end

   if addon_db.epgp.customGPEnabled then
      RCEPGP:ApplyNewLibGearPoints()
   end
   RCEPGP:SendMessage("RCGPRuleChanged")
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
   return addon_db.epgp[info[#info]]
end 

local function Setter(info, value)
   if (not value) or value == "" then
      value = tostring(defaults[info[#info]])
   end
   addon_db.epgp[info[#info]] = value
   RCEPGP:SendMessage("RCGPRuleChanged")
end

local function CustomGPDisabled()
   return (not addon_db.epgp.customGPEnabled)
end


function RCEPGP:AddGPOptions()
  local options = addon:OptionsTable()

  addon.options = addon:OptionsTable()

  if addon_db.epgp.customGPEnabled then
      RCEPGP:ApplyNewLibGearPoints()
  else
      RCEPGP:RestoraOldLibGearPoints()
  end

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
   SetDefaults()
   if not addon_db.epgp then
      addon_db.epgp = {}
   end

   local options = {
      name = "RCLootCouncil - EPGP v"..self.version,
      order = 1,
      type = "group",
      childGroups = "tab",
      args = {
         bidding = {
            name = LEP["Bidding"],
            order = 0,
            type = "group",
            inline = true,
            args = {
               biddingEnabled = {
                  name = LEP["Enable Bidding"],
                  order = 1,
                  type = "toggle",
                  width = "full",
                  get = function() return addon_db.epgp.biddingEnabled end,
                  set = function(info, value) addon_db.epgp.biddingEnabled = value; RCEPGP:SetupColumns() end,
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
                        addon_db.epgp[info[#info]] = value
                        if addon_db.epgp.customGPEnabled then
                           RCEPGP:ApplyNewLibGearPoints()
                        else
                           RCEPGP:RestoraOldLibGearPoints()
                        end
                        RCEPGP:SendMessage("RCGPRuleChanged")
                     end,
               },
               restoreDefault = {
                  name = LEP["restore_default"],
                  order = 2,
                  type = "execute",
                  func = function() SetDefaults(true) end,
               },
               slotWeights = {
                  name = LEP["slot_weights"],
                  order = 3,
                  type = "group",
                  inline = true,
                  args = {
                     INVTYPE_HEAD = {
                        name = _G.INVTYPE_HEAD,
                        order = 11, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_NECK = {
                        name = _G.INVTYPE_NECK,
                        order = 12, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_SHOULDER = {
                        name = _G.INVTYPE_SHOULDER,
                        order = 13, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_CLOAK = {
                        name = _G.INVTYPE_CLOAK,
                        order = 14, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_CHEST = {
                        name = _G.INVTYPE_CHEST,
                        order = 15, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_WRIST = {
                        name = _G.INVTYPE_WRIST,
                        order = 16, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_HAND = {
                        name = _G.INVTYPE_HAND,
                        order = 17, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_WAIST = {
                        name = _G.INVTYPE_WAIST,
                        order = 18, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_LEGS = {
                        name = _G.INVTYPE_LEGS,
                        order = 19, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_FEET = {
                        name = _G.INVTYPE_FEET,
                        order = 20, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_FINGER = {
                        name = _G.INVTYPE_FINGER,
                        order = 21, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_TRINKET = {
                        name = _G.INVTYPE_TRINKET,
                        order = 22, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
                     INVTYPE_RELIC = {
                        name = _G.EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC,
                        order = 23, 
                        type = "input",
                        width = "half",
                        validate = ValidateStatWeights,
                        get = Getter,
                        set = Setter,
                        disabled = CustomGPDisabled,
                     },
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
         variableIlvl = {
            name = "|cFFFFFF00ilvl|r",
            order = 102,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableIlvlHelp = {
            name = LEP["variable_ilvl_help"],
            order = 103,
            type = "description",
            width = "double",
         },
         variableSlotWeights = {
            name = "|cFFFFFF00slotWeights|r",
            order = 104,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableSlotWeightHelp = {
            name = LEP["variable_slotWeights_help"],
            order = 105,
            type = "description",
            width = "double",
         },
         variableIsToken = {
            name = "|cFFFFFF00isToken|r",
            order = 106,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableIsTokenHelp = {
            name = LEP["variable_isToken_help"],
            order = 107,
            type = "description",
            width = "double",
         },
         variableNumSocket = {
            name = "|cFFFFFF00numSocket|r",
            order = 108,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableNumSocketHelp = {
            name = LEP["variable_numSocket_help"],
            order = 109,
            type = "description",
            width = "double",
         },
         variableHasAvoid = {
            name = "|cFFFFFF00hasAvoid|r ",
            order = 110,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableHasAvoidHelp = {
            name = LEP["variable_hasAvoid_help"],
            order = 111,
            type = "description",
            width = "double",
         },
         variableHasSpeed = {
            name = "|cFFFFFF00hasSpeed|r",
            order = 112,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableHasSpeedHelp = {
            name = LEP["variable_hasSpeed_help"],
            order = 113,
            type = "description",
            width = "double",
         },
         variableHasLeech = {
            name = "|cFFFFFF00hasLeech|r",
            order = 114,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableHasLeechHelp = {
            name = LEP["variable_hasLeech_help"],
            order = 115,
            type = "description",
            width = "double",
         },
         variableHasIndes = {
            name = "|cFFFFFF00hasIndes|r",
            order = 116,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableHasIndesHelp = {
            name = LEP["variable_hasIndes_help"],
            order = 117,
            type = "description",
            width = "double",
         },
         variableRarity = {
            name = "|cFFFFFF00rarity|r",
            order = 118,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableRarityHelp = {
            name = LEP["variable_rarity_help"],
            order = 119,
            type = "description",
            width = "double",
         },
         variableItemID = {
            name = "|cFFFFFF00itemID|r",
            order = 120,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableItemIDHelp = {
            name = LEP["variable_itemID_help"],
            order = 121,
            type = "description",
            width = "double",
         },
         variableEquipLoc = {
            name = "|cFFFFFF00equipLoc|r",
            order = 122,
            fontSize = "medium",
            type = "description",
            width = "normal",
         },
         variableEquipLocHelp = {
            name = LEP["variable_equipLoc_help"],
            order = 123,
            type = "description",
            width = "double",
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
               addon_db.epgp[info[#info]] = value
               local func, err = loadstring(value)
               if not func then
                  RCEPGP.epgpOptions.args.customGP.args.errorMsg.name = LEP["formula_syntax_error"]
                  RCEPGP.epgpOptions.args.customGP.args.errorDetailedMsg.name = err
               else
                  RCEPGP.epgpOptions.args.customGP.args.errorMsg.name = ""
                  RCEPGP.epgpOptions.args.customGP.args.errorDetailedMsg.name = ""
               end
               LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil");
               RCEPGP:SendMessage("RCGPRuleChanged")
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

   self.epgpOptions = options
   LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RCLootCouncil - EPGP", self.epgpOptions)
   self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RCLootCouncil - EPGP", "EPGP", "RCLootCouncil")
   LibStub("AceConfigRegistry-3.0"):NotifyChange("RCLootCouncil - EPGP")
end
