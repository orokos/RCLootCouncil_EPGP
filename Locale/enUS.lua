-- Translate RCLootCouncil - EPGP to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil-epgp/localization/

-- Default english translation
local L = LibStub("AceLocale-3.0"):NewLocale("RCEPGP", "enUS", true)
if not L then return end

L["gp_value_help"] = "Example:\r\n100%: use 100% of normal GP value\r\n50%: use 50% of normal GP value \r\n25: all items are worth 25 GP"
L["enable_custom_gp"] = "Enable Custom GearPoints"
L["formula_syntax_error"] = "Formula has syntax error. Default formula will be used instead."
L["restore_default"] = "Restore to Default"
L["slot_weights"] = "Slot Weights"
L["formula_help"] = "Enter lua code that returns GP value in the editbox below. The following are the variables usable in the code."
L["variable_ilvl_help"] = "Integer. The item level of the item or the base ilvl of the token."
L["variable_isToken_help"] = "Integer. 1 if the item is a set token, 0 otherwise."
L["variable_slotWeights_help"] = "Number. The weights of the item according to its equipment slot."
L["variable_numSocket_help"] = "Integer. The number of socket in the item."
L["variable_hasAvoid_help"] = "Integer. 1 if the item has avoidance, 0 otherwise."
L["variable_hasSpeed_help"] = "Integer. 1 if the item has speed, 0 otherwise."
L["variable_hasLeech_help"] = "Integer. 1 if the item has leech, 0 otherwise."
L["variable_hasIndes_help"] = "Integer. 1 if the item is indestructible, 0 otherwise."
L["variable_rarity_help"] = "Integer. The rarity of the item. 3-Rare, 4-Epic, 5-Legendary"
L["variable_itemID_help"] = "Integer. The item id of the item."
L["variable_equipLoc_help"] = "String. The non-localized string representing the equipment slot. Recommend to use variable \"slotWeights\" instead if possible"
L["gp_formula"] = "GP Formula"
L["Input must be a number."] = true
L["disable_gp_popup"] = "GP popup is automatically disabled by RCLootCouncil - EPGP."
L["GP Bid"] = true
L["Enable Bidding"] = true
L["Custom GP"] = true
L["bidding_desc"] = "Player can send bid price to the loot master by sending a note that starts with integer in the RCLootCouncil popup."
L["Bidding"] = true
