-- Translate RCLootCouncil - EPGP to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil-epgp/localization/

-- Default english translation
local L = LibStub("AceLocale-3.0"):NewLocale("RCEPGP", "enUS", true)
if not L then return end

L["%s_formula_runtime_error"] = "'%s' formula has runtime error."
L["%s_formula_syntax_error"] = "'%s' formula has syntax error."
L["Add to recurring award"] = true
L["Also screenshot in test mode"] = true
L["Also screenshot when the item is bagged and will be awarded later"] = true
L["amount_must_be_number"] = "Amount must be a number"
L["announce_#diffgp#_desc"] = "|cfffcd400 #diffgp#|r: The amount of GP the player gains."
L["announce_#ep#_desc"] = "|cfffcd400 #ep#|r: The EP of player."
L["announce_#gp#_desc"] = "|cfffcd400 #gp#|r: The GP of player before getting the item."
L["announce_#itemgp#_desc"] = "|cfffcd400 #itemgp#|r: The GP value of the item."
L["announce_#newgp#_desc"] = "|cfffcd400 #newgp#|r: The GP of player after getting the item."
L["announce_#newpr#_desc"] = "|cfffcd400 #newpr#|r: The PR of player after getting the item."
L["announce_#pr#_desc"] = "|cfffcd400 #pr#|r: The PR of player before getting the item."
L["announce_awards_desc2"] = [=[
RCLootCouncil-EPGP: #diffgp# for the amount of GP the player gains from the item. #ep# for the EP of player. #gp# for the GP of player before getting the item. #pr# for the PR of player before getting the item. #newgp# for the GP of player after getting the item. #newpr# for the PR of player after getting the item.]=]
L["announce_formula_runtime_error"] = "Your GP formula has runtime error. Default formula is used when error occurs."
L["Award GP (Default: %s)"] = true
L["Bid"] = true
L["Bid Mode"] = true
L["bid_gpAbsolute_desc"] = "Highest bid wins and gets GP of bid."
L["bid_gpRelative_desc"] = "Highest bid wins and gets GP of (gp of item)*bid"
L["bid_prRelative_desc"] = "Highest PR*bid wins and gets GP of (gp of item)*bid"
L["Bidding"] = true
L["bidding_desc"] = "Enable this will add a button in the rightclick menu of the voting frame to award GP to a player according to his bid. Several modes are available. Player can send bid price to the loot master by sending a note that starts with integer in the RCLootCouncil loot frame. They can also send \"min\" for the minimum bid, \"max\" for the maximum bid, and \"default\" for the default bid."
L["chat_commands"] = "- epgp      - Open the RCLootCouncil-EPGP options interface"
L["Credit GP to %s"] = true
L["Custom EP"] = true
L["Custom GP"] = true
L["customEP_desc"] = [=[

Custom EP allows you to customize who should be included in mass EP award.
You can mass award EP with Custom EP in this window or by the command '/rc massep' or '/rc recurep'
Run these commands without argument to show their help message.
]=]
L["customEP_formula_add_recur_award_confirm"] = "Are you sure you want to add the formula %s to the running recurring award?"
L["customEP_formula_award_confirm"] = "Are you sure you want to do mass EP award by the formula %s?"
L["customEP_formula_start_recur_award_confirm"] = "Are you sure you want to start recurring award by the formula %s?"
L["customEP_formula_stop_recur_award_confirm"] = "Are you sure you want to stop recurring award?"
L["customEP_in_group_desc"] = "The EP percentage when the candidate is in your group."
L["customEP_in_standby_desc"] = "The EP percentage when the candidate is in EPGP's standby list but not in group."
L["customEP_in_zones_desc"] = "The EP percentage when the zone of the candidate matches any zone below."
L["customEP_massEP_by_formulas"] = "Mass EP award by the formulas: %s"
L["customEP_none_of_the_above_desc"] = "The EP percentage when the candidate is not in group, not in EPGP standby list, and does not sign up in calendar."
L["customEP_not_in_zones_desc"] = "The EP percentage when the zone of the candidate does not match any zone below."
L["customEP_offline_desc"] = "The EP percentage when the candidate is offline."
L["customEP_online_desc"] = "The EP percentage when the candidate is online."
L["customEP_rank_desc"] = "The EP percentage when the candidate guild rank matches this."
L["customEP_signed_up_in_calendar_desc"] = "The EP percentage when the candidate signs up in a guild event that starts within +-12h of the current time, but not in the group, nor in the EPGP standby list."
L["customEP_zones_desc"] = "Enter the zones' names or ids here. Multiple zones need be to splited by comma(','). Leading and trailing spaces are ignored."
L["customGP_desc"] = [=[

Custom GP allows you to define a custom GP rule for every gear piece.
You need to define a formula that calculates the GP value for the gear.
You can choose to disable this feature, to calculated GP in the default way of EPGP(dkp reloaded).
]=]
L["Default Bid"] = true
L["default_bid_desc"] = "The default bid to use if the candidate does not send his bid."
L["disable_gp_popup"] = "GP popup is automatically disabled by RCLootCouncil - EPGP."
L["DKP Mode"] = true
L["dkp_mode_desc"] = "If checked, all GP increase/decrease operations done by the addon are converted to EP decrease/increase operations."
L["Down"] = true
L["Enable Bidding"] = true
L["enable_custom_gp"] = "Enable Custom GearPoints"
L["EPGP_DKP_Reloaded_settings_received"] = "Received EPGP(dkp reloaded) settings through '/rc sync'."
L["error_no_target"] = "Error. You don't have a target."
L["forbidden_function_used"] = "A forbidden function is used in a formula, but has been blocked from doing so. Please check if your formulas contain any malicious code!"
L["Formula 'formula' does not exist"] = "Formula %s does not exist"
L["formula_delete_confirm"] = "Are you sure you want to delete the formula %s?"
L["formula_syntax_error"] = "Formula has syntax error"
L["General"] = true
L["GP Bid"] = true
L["GP Options"] = true
L["gp_formula"] = "GP Formula"
L["gp_formula_help"] = [=[Enter lua code that returns GP value in the editbox below.
If your input is a regular statement to be evaluated, e.g. 'a and b or c', you don't need a return statement.
If you have any control blocks (e.g. if/then), you'll need return statements.
The following are the variables usable in the code.]=]
L["gp_formula_syntax_error"] = "Formula has syntax error. Default formula will be used instead."
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
L["Group Status"] = true
L["In Group"] = true
L["In Standby"] = true
L["In Zones"] = true
L["Input must be a non-negative number."] = true
L["Input must be a number."] = true
L["Invalid input"] = true
L["Max Bid"] = true
L["Min Bid"] = true
L["Min New PR"] = true
L["min_new_pr_desc"] = "The addon will calculate the candidate's maximum bids to ensure his PR does not drop below this value after winning the item and getting the GP."
L["need_restart_notification"] = "RCLootCouncil-EPGP v%s update requires full restart of the client. Some features of the addon don't work until client restarts."
L["new_version_detected"] = "Your version %s is outdated. Newer Version %s detected. You can update the addon from [https://mods.curse.com/addons/wow/269161-rclootcouncil-epgp]"
L["no_permission_to_edit_officer_note"] = "You don't have permission to edit officer note."
L["None of the above"] = true
L["Not in your guild"] = true
L["Not in Zones"] = true
L["Online Status"] = true
L["period_not_positive_error"] = "Period must be positive number"
L["rc_version_below_min_notification"] = "This version of RCLootCouncil-EPGP requires RCLootCouncil v%s+. Your RCLootCouncil is v%s. Please update your RCLootCouncil."
L["RCEPGP_desc"] = "A RCLootCouncil plugin that adds EPGP support and customization. Author: Safetee"
L["Recurring Award Period(Min)"] = true
L["recurring_award_formulas"] = "Current formulas for recurring award: %s"
L["recurring_award_running"] = "A recurring award is already running. Add this formula into the recurring award."
L["Screenshot"] = true
L["Screenshot failed"] = true
L["Screenshot only when GP is awarded"] = true
L["Screenshot succeeded"] = true
L["Screenshot when a item is awarded"] = true
L["send_epgp_setting_desc"] = "If checked, '/rc sync' also sync EPGP(dkp reloaded) settings"
L["send_epgp_settings"] = "'/rc sync' also sends EPGP(dkp reloaded) settings"
L["Setting Sync"] = true
L["setting_reset_notification"] = "RCLootCouncil-EPGP v%s resets all settings. Please reconfig your settings if needed."
L["Signed up in calendar"] = true
L["slash_help_footer"] = "---End of EPGP commands---"
L["slash_help_header"] = "---EPGP commands. Running the command with no argument shows the detailed help messages---"
L["slash_rc_command_failed"] = "Command fails. Please check if the inputs are correct. Make sure guild frame is not open."
L["slash_rc_ep_help"] = "- ep name reason amount      - Award EP to a character."
L["slash_rc_ep_help_detailed"] = [=[

/rc ep name reason amount

Award EP to a character.

|cffffd000name|r: Required. The full name of the character. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to refer yourself or '%t' to refer your target.

|cffffd000reason|r: Required. The reason to award.

|cffffd000amount|r: Required. Integer. The amount of EP awarding to the character.
]=]
L["slash_rc_gp_help"] = "- gp name reason [amount]      - Award GP to a character."
L["slash_rc_gp_help_detailed"] = [=[

/rc gp name reason [amount]

Award GP to a character.

|cffffd000name|r: Required. The full name of the character. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to refer yourself or '%t' to refer your target.

|cffffd000reason|r: Required. The reason to award. This is usually a item link of the gear piece.

|cffffd000amount|r: Optional. Integer. The amount of GP awarding to the character. If omitted, this will be the GP value calculated by the addon whose item link is 'reason'
]=]
L["slash_rc_massep_help"] = "- massep reason amount [formula ...]  - Mass EP Award using custom EP feature."
L["slash_rc_massep_help_detailed"] = [=[

- massep reason amount [formulaIndexOrName, ...]

Mass EP Award using custom EP feature.

|cffffd000reason|r: Required. The reason to award.

|cffffd000amount|r: Required. Integer. The amount of EP to be mass awarded.

|cffffd000formula ...|r: Optional. If omitted, mass EP in the default way of EPGP(dkp reloaded). If this argument is specified, the amount of EP each person gains depend the configuration of the custom EP formula. See the custom EP panel in the option('/rc epgp') for more information.
You should specify either the formula index(number) or the formula name. You can also specify multiple formulas here.
"/rc massep reason amount TEST1" then "/rc massep reason amount TEST2" awards the same EP as "/rc massep reason amount TEST1 TEST2"
]=]
L["slash_rc_recurep_help"] = "- recurep reason amount period [formula ...]   - Start recurring mass EP Award using custom EP feature."
L["slash_rc_recurep_help_detailed"] = [=[

- recurep reason amount period [formula ...]

Start recurring mass EP Award using custom EP feature.
If the recurring award is already running, then the formulas will be added to the current recurring award.

|cffffd000periodMin|r: The period for the recurring award (in minute).

See the description of other argument by '/rc massep'
]=]
L["slash_rc_stoprecur_help"] = " - stoprecur   - Stop recurring EP award."
L["slash_rc_undogp_help"] = "- undogp name [reason]       - Undo the most recent GP operations to a character with the matching reason."
L["slash_rc_undogp_help_detailed"] = [=[

/rc undogp name [reason]
Undo the most recent GP operation (EP operation in DKP mode) to a character with the matching reason.

|cffffd000name|r: Required. The name of the character you want to undo EP. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to refer yourself or '%t' to refer your target.

|cffffd000reason|r: Optional. This is usually empty or a itemLink. If empty, undo the most recent GP operation, otherwise, undo the most recent operation with the same reason as the GP operation.
]=]
L["slash_rc_zs_help"] = "- zs name reason amount   - ZeroSum EP award."
L["slash_rc_zs_help_detailed"] = [=[

|cffffd000- zs name reason amount|r
EP award is redistributed evenly among all other group members in the same zone as the awardee.
|cffffd000- zsr name reason amount|r
EP award is redistributed evenly among all other group members with the same role (Tank, Damager, Healer) in the same zone as the awardee.
|cffffd000- zsdr name reason amount|r
EP award is redistributed evenly among all other group members with the same detailed role (Tank, Melee DPS, Ranged DPS, Healer) in the same zone as the awardee.

|cffffd000name|r: Required. The full name of the character. Realm name can be omitted if he's in the same realm of you. You can also use '%p' to refer yourself or '%t' to refer your target.

|cffffd000reason|r: Required. The reason to award.

|cffffd000amount|r: Optional. Integer. The amount of EP awarding to the character and this EP amount will be redistributed to other people so the total EP of the group is unchanged.


Examples:
"/rc zs PERSON1 mistake -100": If 11 people in group, PERSON1 gains -100 EP and all other gains 10EP

"/rc zsr PERSON2 mistake -100": If 11 people in group and PERSON2 is DPS and there are 4 other DPS. PERSON1 gains -100 and the other 4 DPS gains 25EP. Other people have no EP change.

]=]
L["slash_rc_zsdr_help"] = "- zsdr name reason amount   - ZeroSum EP award by detailed role."
L["slash_rc_zsr_help"] = "- zsr name reason amount   - ZeroSum EP award by role."
L["slot_weights"] = "Slot Weights"
L["Undo GP"] = true
L["Up"] = true
L["You cannot use this command if you are not in raid."] = true
