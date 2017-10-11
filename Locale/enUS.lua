-- Translate RCLootCouncil - EPGP to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil-epgp/localization/

-- Default english translation
local L = LibStub("AceLocale-3.0"):NewLocale("RCEPGP", "enUS", true)
if not L then return end

L["gp_value_help"] = "Example:\r\n100%: use 100% of normal GP value\r\n50%: use 50% of normal GP value \r\n25: all items are worth 25 GP"
L["enable_custom_gp"] = "Enable Custom GearPoints"
L["gp_formula_syntax_error"] = "Formula has syntax error. Default formula will be used instead."
L["slot_weights"] = "Slot Weights"
L["gp_formula_help"] = "Enter lua code that returns GP value in the editbox below.\nIf your input is a regular statement to be evaluated, e.g. 'a and b or c', you don't need a return statement.\nIf you have any control blocks (e.g. if/then), you'll need return statements.\nThe following are the variables usable in the code."
L["gp_variable_ilvl_help"] = "Integer. The item level of the item or the base ilvl of the token."
L["gp_variable_isToken_help"] = "Integer. 1 if the item is a set token, 0 otherwise."
L["gp_variable_slotWeights_help"] = "Number. The weights of the item according to its equipment slot."
L["gp_variable_numSocket_help"] = "Integer. The number of socket in the item."
L["gp_variable_hasAvoid_help"] = "Integer. 1 if the item has avoidance, 0 otherwise."
L["gp_variable_hasSpeed_help"] = "Integer. 1 if the item has speed, 0 otherwise."
L["gp_variable_hasLeech_help"] = "Integer. 1 if the item has leech, 0 otherwise."
L["gp_variable_hasIndes_help"] = "Integer. 1 if the item is indestructible, 0 otherwise."
L["gp_variable_rarity_help"] = "Integer. The rarity of the item. 3-Rare, 4-Epic, 5-Legendary"
L["gp_variable_itemID_help"] = "Integer. The item id of the item."
L["gp_variable_equipLoc_help"] = "String. The non-localized string representing the equipment slot. Recommend to use variable \"slotWeights\" instead if possible"
L["gp_formula"] = "GP Formula"
L["Input must be a number."] = true
L["disable_gp_popup"] = "GP popup is automatically disabled by RCLootCouncil - EPGP."
L["GP Bid"] = true
L["Enable Bidding"] = true
L["Custom GP"] = true
L["bidding_desc"] = "Player can send bid price to the loot master by sending a note that starts with integer in the RCLootCouncil popup."
L["Bidding"] = true
L["Credit GP to %s"] = true
L["Undo GP"] = true
L["Award GP (Default: %s)"] = true
L["gp_variable_link_help"] = "String. The full item link of the item"
L["announce_formula_runtime_error"] = "Your GP formula has runtime error. Default formula is used when error occurs."
L["chat_commands"] = "- epgp      - Open the RCLootCouncil-EPGP options interface"
L["gpOptions"] = "GP Percentage of Responses"
L["gpOptionsButton"] = "Open options to set GP percentage of responses"
L["gp_variable_isNormal_help"] = "Integer. 1 if the item is from normal difficulty, 0 otherwise."
L["gp_variable_isHeroic_help"] = "Integer. 1 if the item is from heroic difficulty, 0 otherwise."
L["gp_variable_isMythic_help"] = "Integer. 1 if the item is from mythic difficulty, 0 otherwise."
L["gp_variable_isWarforged_help"] = "Integer. 1 if the item is warforged, 0 otherwise."
L["gp_variable_isTitanforged_help"] = "Integer. 1 if the item is titanforged, 0 otherwise."
L["announce_awards_desc2"] = "\nRCLootCouncil-EPGP: #diffgp# for the amount of GP the player gains from the item. #ep# for the EP of player. #gp# for the GP of player before getting the item. #pr# for the PR of player before getting the item. #newgp# for the GP of player after getting the item. #newpr# for the PR of player after getting the item."

L["customGP_desc"] = [=[

Custom GP allows you to define a custom GP rule for every gear piece.
You need to define a formula that calculates the GP value for the gear.
You can choose to disable this feature, to calculated GP in the default way of EPGP(dkp reloaded).
]=]

L["slash_rc_gp_help"] = "- gp name reason [amount]      - Reward GP of amount to the character with name with reason. See the detailed usage by '/rc gp help'"
L["slash_rc_gp_help_detailed"] = [=[

/rc gp name reason [amount]

Award GP of amount to the character with name with reason.

|cffffd000name|r: Required. The full name of the character. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to refer yourself or '%t' to refer your target.

|cffffd000reason|r: Required. The reason to award. This is usually a item link of the gear piece.

|cffffd000amount|r: Optional. Integer. The amount of GP awarding to the character. If omitted, this will be the GP value calculated by the addon whose item link is 'reason'
]=]

L["new_version_detected"] = "Your version %s is outdated. Newer Version %s detected. You can update the addon from [https://mods.curse.com/addons/wow/269161-rclootcouncil-epgp]"
L["need_restart_notification"] = "RCLootCouncil-EPGP v%s update requires full restart of the client. Some features of the addon don't work until client restarts."
L["rc_version_below_min_notification"] = "This version of RCLootCouncil-EPGP requires RCLootCouncil v%s+. Your RCLootCouncil is v%s. Please update your RCLootCouncil."
L["EPGP_DKP_Reloaded_settings_received"] = "Received EPGP(dkp reloaded) settings through '/rc sync'."

L["General"] = true
L["Setting Sync"] = true
L["send_epgp_settings"] = "'/rc sync' also sends EPGP(dkp reloaded) settings"
L["send_epgp_setting_desc"] = "If checked, '/rc sync' also sync EPGP(dkp reloaded) settings"
L["setting_reset_notification"] = "RCLootCouncil-EPGP v%s resets all settings. Please reconfig your settings if needed."
L["RCEPGP_desc"] = "A RCLootCouncil plugin that adds EPGP support and customization. Author: Safetee"
L["slash_rc_undogp_help_detailed"] = [=[

/rc undogp name [reason]
Undo the most recent GP operations to a character with the matching reason.

|cffffd000name|r: Required. The name of the character you want to undo EP. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to refer yourself or '%t' to refer your target.

|cffffd000reason|r: Optional. This is usually empty or a itemLink. If empty, undo the most recent GP operation, otherwise, undo the most recent operation with the same reason as this one.
]=]
L["slash_rc_undogp_help"] = "- undogp name [reason]       - Undo the most recent GP operations to a character with the matching reason. See the detailed usage by '/rc undogp help'"
L["slash_rc_command_failed"] = "Command fails. Please check if the inputs are correct."
L["no_permission_to_edit_officer_note"] = "You don't have permission to edit officer note."
L["error_no_target"] = "Error. You don't have a target."
--[[
L["Change name to %s"] = true
L["Change Name To..."] = true
--]]

--[[

L["ep_variable_name_help"] = "String. The full name of the characher we are processing."
L["ep_variable_isOnline_help"] = "Integer. 1 if that character is online. 0 otherwise."
L["ep_variable_guildName_help"] = "String. The name of that character's guild."
L["ep_variable_zone_help"] = "String. The zone name of that character."
L["ep_variable_zoneId_help"] = "Integer. The zone Id of that character."
L["ep_variable_isInRaid_help"] = "Integer. 1 if that character is in the raid. 0 otherwise."
L["ep_variable_isStandby_help"] = "Integer. 1 if that character is in the standby list of EPGP(dkp reloaded). 0 otherwise."
L["ep_variable_isMain_help"] = "Integer. 1 if that character is main character, defined by the officer's note. 0 otherwise."
L["ep_variable_isMaxLevel_help"] = "Integer. 1 if that character is max level. 0 otherwise."
L["ep_variable_rank_help"] = "Integer. The guild rank number of that character. 0 for the guild master. 1 for the next guild rank. Then 2,3,4,5,6,..."
L["ep_variable_isTank_help"] = "Integer. 1 if the role of that character is tank. 0 otherwise."
L["ep_variable_isHealer_help"] = "Integer. 1 if the role of that character is healer. 0 otherwise."
L["ep_variable_isDPS_help"] = "Integer. 1 if the role of that character is damager. 0 otherwise."
L["ep_variable_isMeleeDPS_help"] = "Integer. 1 if that character is a melee DPS. Require you are nearby to that character. 0 otherwise."
L["ep_variable_isRangedDPS_help"] = "Integer. 1 if that character is a ranged DPS. Require you are nearby to that character. 0 otherwise."
L["ep_variable_level_help"] = "Integer. The level of that character."
L["ep_variable_class_help"] = "String. Non-localized class name of that character. For example: 'DRUID', 'DEATHKNIGHT', 'DEMONHUNTER'"
L["ep_variable_ep_help"] = "Integer. The EP(Effort Point) of that character."
L["ep_variable_gp_help"] = "Integer. The GP(Gear Point) of that character."
L["ep_variable_pr_help"] = "Number. The PR(Priority) of that character."
L["ep_variable_targetName_help"] = "String. The target name of the formula. The target name is from '/rc massep [reason] [amount] [formulaIndexOrName] [target name]. This variable is used to specify a special character in the formula."
L["ep_variable_isTargetName_help"] = "Integer. 1 if the name of that character is target name of the formula."
L["ep_variable_isRankX_help"] = "Integer. 1 if that character is in that guild rank. 0 for guild master. 1 for the next guild rank. Then 2,3,4,..."
L["ep_variable_main_prefix_help"] = "The above variables can be prefixed by 'main' to form new variables that checks for the main character's value instead. For example, 'mainisRank1' returns 1 if the main's rank is rank1. "
L["ep_variable_same_prefix_help"] = "Integer. The above variables can be prefixed by 'same' to check if the value is the same as you. 1 if it is same. 0 otherwise."
L["ep_variable_targetname_prefix_help"] = "The above variables can be prefixed by 'targetname' to check the value of input name.  The target name is  from '/rc massep [reason] [amount] [formulaIndexOrName] [input name]'"
L["ep_variable_minep_help"] = "Integer. The min EP of EPGP(dkp reloaded)."
L["ep_variable_decay_help"] = "Number. The decay of EPGP(dkp reloaded)."
L["ep_variable_baseGP_help"] = "Integer. The base GP of EPGP(dkp reloaded)."
L["ep_variable_inputEPAmount_help"] = "Integer. The input ep amount from '/rc massep [reason][amount]' or '/rc recurep [periodMin][reason][amount]'"
L["ep_variable_count_help"] = "Function whose argument is a string formula that returns the count of guild or raid characters whose formula value is non-zero. For example, count('isOnline') returns the number of characters that are online, count('isMaxLevel*isOnline') returns the number of max level characters that are online."
L["ep_variable_isNormalRaid_help"] = "Integer. 1 if the raid difficulty is normal. 0 otherwise."
L["ep_variable_isHeroicRaid_help"] = "Integer. 1 if the raid difficulty is heroic. 0 otherwise."
L["ep_variable_isMythicRaid_help"] = "Integer. 1 if the raid difficulty is mythic. 0 otherwise."
L["Custom EP Variables"] = true

L["customEP_desc"] = [=[

Custom EP allows you to customize who and how much to award while doing a mass EP award and you need to define formulas here for that.
The addon calculates the formula value for all characters in the guild or raid and add that value to the character's EP.
(Characters with the same main character, defined by the officer note, are only be awarded once.)
There are some variables to help you write the formulas and you can get their information from 'Custom EP Variables' Tab.
You can use chat commands '/rc massep', '/rc recurep' or '/rc epgui' to mass award gp.
You can get their information by '/rc help'.
]=]
L["customEPVariable_desc"] = "These variables are used for custom EP. Check the 'Custom EP' Tab for extra information."
L["ep_variable_calendarSignedUp_help"] = "Function whose argument is no argument or a string. Returns 1 if the character signups up in one of today's calendar event (whose title contains the argument, if argument exists). Return 0 otherwise. For example, 'calendarSignedUp()' returns 1 if the character has signed up in one of today's calendar event."



-- Locale to Custom EP GUI
L["RCLootCouncil-EPGP Custom EP GUI"] = true
L["slash_rc_epgui_help"] = "- gui      - A GUI that can do custom mass ep award and manage scheduled ep award."
L["Award Reason"] = true
L["gui_award_reason_tooltip1"] ="Reason for EP award"
L["gui_award_reason_tooltip2"] = "Must not be empty"
L["EP Award Amount"] = true
L["gui_award_amount_tooltip1"] = "Amount of EP to be awarded"
L["gui_award_amount_tooltip2"] = "Must be an integer"
L["Recurring Award Period"] = true
L["gui_recurring_period_tooltip1"] = "The period of recurring EP Award in minutes"
L["gui_recurring_period_tooltip2"] = "If 0 or empty, EP is awarded immediately instead of periodically"
L["gui_recurring_period_tooltip3"] = "Must be non-negative number"
L["Scheduled Award Time"] = true
L["gui_scheduled_time_tooltip1"] = "If not 0 or empty, schedule for the EP award at a later time"
L["gui_scheduled_time_tooltip2"] = "If a number, schedule for award after that amount of seconds"
L["gui_scheduled_time_tooltip3"] = "If HH:MM or HH:MM:SS, schedule for award at the next realm time."
L["EP Award Formula"] = true
L["Default Mass EP Formula"] = true
L["Modify Formulas..."] = true
L["Description"] = true
L["Formula"] = true
L["default_mass_ep_formula_desc"] = "The default Mass EP Award of EPGP(dkp reloaded)\nAward EP to characters in the raid or standby list."
L["Formula Target Name"] = true
L["gui_target_name_tooltip1"] = "Specify the character name of 'targetName' variable in the custom EP formula"
L["gui_target_name_tooltip2"] = "Not used in the default EP formula. Can be empty if your formula does not use this variable."
L["gui_target_name_tooltip3"] = "As a name, this must not contain space"
L["Schedule to Start Recurring Mass EP Award"] = true
L["Start Recurring Mass EP Award"] = true
L["Schedule Mass EP Award"] = true
L["Mass EP Award"] = true
L["Index"] = true
L["Award Period"] = true
L["Name"] = true
L["Countdown(s)"] = true
L["End Time\n(Realm Time)"] = true
L["Cancel"] = true
L["Scheduled EP Award"] = true

L["slash_rc_massep_help"] = "- massep reason amount [formulaIndexOrName] [targetName] [scheduledTime]      - Do a mass EP award. See the detailed usage by '/rc massep help'"
L["slash_rc_recurep_help"] = "- recurep periodMin reason amount [formulaIndexOrName] [targetName] [scheduledTime]      - Start a recurring mass ep award. See the detailed usage by '/rc recurep help'"
L["slash_rc_stoprecur_help"] = "- stoprecur      - Stop recurring EP Award."
L["peroid_not_positive_error"] = "'periodMin' must be a positive number."
L["slash_rc_massep_help_detailed"] = [=[

/rc massep reason amount [formulaIndexOrName] [targetName] [scheduledTime]

Do a mass EP award.

|cffffd000reason|r: Required. The reason to award.

|cffffd000amount|r: Required. must be integer. The amount of EP to award and this equals to 'inputEPAmount' variable in the custom EP formula.

|cffffd000formulaIndexOrName|r: Optional. The index or the name of custom EP formula. If this is empty or 0, you will use the default way of EPGP(dkp reloaded) to do a mass EP award. Otherwise, the EP formula will be used to determine how much EP everyone gets.

|cffffd000targetName|r: Optional. This is used by formula variables with 'targetName', which are used to specify one special character in the formula. This can also be '%t', which will be converted to the fullname of your in-game target. If your formula does not use this variable, this can be anything.

|cffffd000scheduledTime|r: Optional. If this is 0 or empty, the mass ep award is done immediately right now. Otherwise, the award is scheduled at a later time. If this is a number X, the award is scheduled after X seconds. If this is a time HH:MM:SS or HH:MM, the award is scheduled at the next realm time of HH:MM:SS(or HH:MM:00). You can use '/rc epgui' or '/rc cancelallscheduledep' to cancel the scheduled EP award.
]=]
L["slash_rc_recurep_help_detailed"] = [=[

/rc recurep periodMin reason amount [formulaIndexOrName] [targetName] [scheduledTime]

Start a recurring mass EP award that do award every periodMin.

|cffffd000periodMin|r: Required. Must be a positive number. The period of the award.

|cffffd000reason|r: Required. The reason to award.

|cffffd000amount|r: Required. Must be integer. The amount of EP to award and this equals to 'inputEPAmount' variable in the custom EP formula.

|cffffd000formulaIndexOrName|r: Optional. The index or the name of custom EP formula. If this is empty or 0, you will use the default way of EPGP(dkp reloaded) to do a mass EP award. Otherwise, the EP formula will be used to determine how much EP everyone gets.

|cffffd000targetName|r: Optional. This is used by formula variables with 'targetName', which are used to specify one special character in the formula. This can also be '%t', which will be converted to the fullname of your in-game target. If your formula does not use this variable, this can be anything.

|cffffd000scheduledTime|r: Optional. If this is 0 or empty, the mass ep award is done immediately right now. Otherwise, the award is scheduled at a later time. If this is a number X, the award is scheduled after X seconds. If this is a time HH:MM:SS or HH:MM, the award is scheduled at the next realm time of HH:MM:SS(or HH:MM:00). You can use '/rc epgui' or '/rc cancelallscheduledep' to cancel the scheduled EP award.
]=]
L["Custom EP"] = true

L["Add EP Formula"] = true
L["ep_formula_delete_confirm"] ="Do you confirm to delete the formula %s ?"
L["ep_formula_name_desc"] = "The name of EP formula."
L["ep_formula_desc_desc"] = "The description of EP formula which help people to understand how this formula award EP."
L["ep_formula_formula_desc"] = "The formula that calculates the EP to be awarded to every guild or raid members. The formula should return a number."
L["Option EP GUI"] = true

L["slash_rc_ep_help"] = "- ep name reason amount      - Reward EP of amount to the character with name with reason. See the detailed usage by '/rc ep help'"
L["slash_rc_ep_help_detailed"] = [=[

/rc ep name reason amount

Award EP of amount to the character with name with reason.

|cffffd000name|r: Required. The full name of the character. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to specify yourself or '%t' to specify your target.

|cffffd000reason|r: Required. The reason to award.

|cffffd000amount|r: Required. Integer. The amount of EP awarding to the character.
]=]

L["slash_rc_cancelallscheduledep_help"] = "- cancelallscheduledep    - Cancel all scheduled ep operations."
L["RCEPGP_CUSTOMEP_SCHEDULE_RESUME"] = "RCLootCouncil-EPGP: Do you want to resume the schduled EP operations?"
L["cancel_all_scheduled_ep"] = "All scheduled EP operations have been canceled."
--]] -- TODO
