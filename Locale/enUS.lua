-- Translate RCLootCouncil - EPGP to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil-epgp/localization/

-- Default english translation
local L = LibStub("AceLocale-3.0"):NewLocale("RCEPGP", "enUS", true, true)
if not L then return end

L["amount_must_be_number"] = "[amount] must be a number"
L["announce_#diffgp#_desc"] = "|cfffcd400 #diffgp#|r: The amount of GP the player gains from the item."
L["announce_#ep#_desc"] = "|cfffcd400 #ep#|r: The EP of player."
L["announce_#gp#_desc"] = "|cfffcd400 #gp#|r: The GP of player before getting the item."
L["announce_#newgp#_desc"] = "|cfffcd400 #newgp#|r: The GP of player after getting the item."
L["announce_#pr#_desc"] = "|cfffcd400 #pr#|r: The PR of player before getting the item."
L["announce_#newpr#_desc"] = "|cfffcd400 #newpr#|r: The PR of player after getting the item."
L["announce_#itemgp#_desc"] = "|cfffcd400 #itemgp#|r: The GP value of the item."
L["%s_formula_runtime_error"] = "'%s' formula has runtime error."
L["%s_formula_syntax_error"] = "'%s' formula has syntax error."
L["Award GP (Default: %s)"] = "Award GP (Default: %s)"
L["bidding_desc"] = "Enable this will add a button in the rightclick menu of the voting frame to award GP to a player according to his bid. Several modes are available. Player can send bid price to the loot master by sending a note that starts with integer in the RCLootCouncil popup."
L["chat_commands"] = "- epgp      - Open the RCLootCouncil-EPGP options interface"
L["Credit GP to %s"] = "Credit GP to %s"
L["Custom GP"] = "Custom GP"
L["customGP_desc"] = [=[

Custom GP allows you to define a custom GP rule for every gear piece.
You need to define a formula that calculates the GP value for the gear.
You can choose to disable this feature, to calculated GP in the default way of EPGP(dkp reloaded).
]=]
L["DKP Mode"] = true
L["dkp_mode_desc"] = "If checked, all GP increase/decrease operations done by the addon are converted to EP decrease/increase operations."
L["disable_gp_popup"] = "GP popup is automatically disabled by RCLootCouncil - EPGP."
L["EPGP_DKP_Reloaded_settings_received"] = "Received EPGP(dkp reloaded) settings through '/rc sync'."
L["error_recurring_running"] = "A recurring award is running."
L["formula_delete_confirm"] = "Are you sure you want to delete the formula %s?"
L["forbidden_function_used"] = "A forbidden function is used in a formula, but has been blocked from doing so. Please check if your formulas contain any malicious code!"
L["Formula 'formula' does not exist"] = "Formula %s does not exist"
L["GP Bid"] = "GP Bid"
L["gp_formula"] = "GP Formula"
L["gp_formula_help"] = [=[Enter lua code that returns GP value in the editbox below.
If your input is a regular statement to be evaluated, e.g. 'a and b or c', you don't need a return statement.
If you have any control blocks (e.g. if/then), you'll need return statements.
The following are the variables usable in the code.]=]
L["formula_syntax_error"] = "Formula has syntax error"
L["gp_value_help"] = [=[Example:
100%: use 100% of normal GP value
50%: use 50% of normal GP value
25: all items are worth 25 GP]=]
L["gp_variable_equipLoc_help"] = "String. The non-localized string representing the equipment slot. Recommend to use variable \"slotWeights\" instead if possible"
L["gp_variable_hasAvoid_help"] = "Integer. 1 if the item has avoidance, 0 otherwise."
L["gp_variable_hasIndes_help"] = "Integer. 1 if the item is indestructible, 0 otherwise."
L["gp_variable_hasLeech_help"] = "Integer. 1 if the item has leech, 0 otherwise."
L["gp_variable_hasSpeed_help"] = "Integer. 1 if the item has speed, 0 otherwise."
L["gp_variable_ilvl_help"] = "Integer. The item level of the item or the base ilvl of the token."
L["gp_variable_isHeroic_help"] = "Integer. 1 if the item is from heroic difficulty, 0 otherwise."
L["gp_variable_isMythic_help"] = "Integer. 1 if the item is from mythic difficulty, 0 otherwise."
L["gp_variable_isNormal_help"] = "Integer. 1 if the item is from normal difficulty, 0 otherwise."
L["gp_variable_isTitanforged_help"] = "Integer. 1 if the item is titanforged, 0 otherwise."
L["gp_variable_isToken_help"] = "Integer. 1 if the item is a set token, 0 otherwise."
L["gp_variable_isWarforged_help"] = "Integer. 1 if the item is warforged, 0 otherwise."
L["gp_variable_itemID_help"] = "Integer. The item id of the item."
L["gp_variable_link_help"] = "String. The full item link of the item"
L["gp_variable_numSocket_help"] = "Integer. The number of socket in the item."
L["gp_variable_rarity_help"] = "Integer. The rarity of the item. 3-Rare, 4-Epic, 5-Legendary"
L["gp_variable_slotWeights_help"] = "Number. The weights of the item according to its equipment slot."
L["gpOptions"] = "GP Percentage of Responses"
L["gpOptionsButton"] = "Open options to set GP percentage of responses"
L["Input must be a number."] = true
L["Input must be a non-negative number."] = true
L["Invalid input"] = true
L["need_restart_notification"] = "RCLootCouncil-EPGP v%s update requires full restart of the client. Some features of the addon don't work until client restarts."
L["new_version_detected"] = "Your version %s is outdated. Newer Version %s detected. You can update the addon from [https://mods.curse.com/addons/wow/269161-rclootcouncil-epgp]"
L["no_permission_to_edit_officer_note"] = "You don't have permission to edit officer note."
L["period_not_positive_error"] = "Period must be positive number"
L["rc_version_below_min_notification"] = "This version of RCLootCouncil-EPGP requires RCLootCouncil v%s+. Your RCLootCouncil is v%s. Please update your RCLootCouncil."
L["RCEPGP_desc"] = "A RCLootCouncil plugin that adds EPGP support and customization. Author: Safetee"
L["send_epgp_setting_desc"] = "If checked, '/rc sync' also sync EPGP(dkp reloaded) settings"
L["send_epgp_settings"] = "'/rc sync' also sends EPGP(dkp reloaded) settings"
L["Setting Sync"] = "Setting Sync"
L["setting_reset_notification"] = "RCLootCouncil-EPGP v%s resets all settings. Please reconfig your settings if needed."
L["slash_rc_command_failed"] = "Command fails. Please check if the inputs are correct. Make sure guild frame is not open."
L["slash_rc_gp_help"] = "- gp name reason [amount]      - Award GP to a character. See the detailed usage by '/rc gp help'"
L["slash_rc_gp_help_detailed"] = [=[

/rc gp name reason [amount]

Award GP to a character.

|cffffd000name|r: Required. The full name of the character. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to refer yourself or '%t' to refer your target.

|cffffd000reason|r: Required. The reason to award. This is usually a item link of the gear piece.

|cffffd000amount|r: Optional. Integer. The amount of GP awarding to the character. If omitted, this will be the GP value calculated by the addon whose item link is 'reason'
]=]
L["slash_rc_undogp_help"] = "- undogp name [reason]       - Undo the most recent GP operations to a character with the matching reason. See the detailed usage by '/rc undogp help'"
L["slash_rc_undogp_help_detailed"] = [=[

/rc undogp name [reason]
Undo the most recent GP operations to a character with the matching reason.

|cffffd000name|r: Required. The name of the character you want to undo EP. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to refer yourself or '%t' to refer your target.

|cffffd000reason|r: Optional. This is usually empty or a itemLink. If empty, undo the most recent GP operation, otherwise, undo the most recent operation with the same reason as the GP operation.
]=]
L["slot_weights"] = "Slot Weights"
L["Undo GP"] = "Undo GP"
L["You cannot use this command if you are not in raid."] = true
