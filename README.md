This is an _**UNOFFICIAL**_ module of the loot distribution addon [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil) that adds full EPGP support to it.  
\(EPGP is a loot distribution system. [Read Here](http://www.epgpweb.com/help/system) for more information about the EPGP system.\)  

**Requires [EPGP(dkp reloaded)](https://mods.curse.com/addons/wow/epgp-dkp-reloaded) and [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil)**  
**Only the Loot master needs to install this module, [EPGP(dkp reloaded)](https://mods.curse.com/addons/wow/epgp-dkp-reloaded) and [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil)**  
**Other raid members just need to install [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil)**  
**This module should works fine together with the official modules [RCLootCouncil - GroupGear](https://mods.curse.com/addons/wow/rclootcouncil-groupgear) and [RCLootCouncil - ExtraUtilities](https://mods.curse.com/addons/wow/257427-rclootcouncil-extrautilities)**  

## Features
**Full EPGP Support**
######  
+ Show sorted EP, GP and PR value of raid members in RCLootCouncil Voting Frame  
+ Loot master can assign percentage GP value to the different responses from the raid members. The setting is in Interface->Addons->RCLootCouncil->Master Looter->Buttons and Responses. The final gp value calculated by the addon normally is itemGP*responseGPPercentage.  
+ Award GP automatically without any extra click. Simply click the first button of the rightclick menu in the RCLootCouncil Voting Frame to award item and GP value at the same time.

**Create Your Own GP Rule**
######  
+ Guild that does not use default GP rule of EPGP(dkp reloaded) can create own GP rule. Then this module will calculate the GP value automatically by the new rule instead of the default rule, that would free the loot master from human calculation. The setting is in Interface->Addons->RCLootCouncil->EPGP.  

**Easy GP Management After Loot Has Been Distributed**
######  
+ When a player change the mind about the loot after receiving it, guild Admins can visit RCLootCouncil Loot History ("/rc history") to undo last GP action or award GP to the player. If the response is changed or the player who received the item is changed, first click the 1st button in the rightclick menu to undo the previous GP, then use other buttons to change the response or the name of player who received the item, then award the GP by clicking the 2nd button in the rightclick menu.  

**Simple Bidding Feature**
######  
+ Players can send their GP bidding price to the loot master by sending a note which starts with integer in the RCLootCouncil popup.(Disabled by default. Loot master can enable it in Interface->Addons->RCLootCouncil->EPGP).

**Sync Settings Between Guild Members**
######  
+ This is actually the feature of RCLootCouncil itself, introduced by RCLootCouncil v2.5. Use command "/rc sync" to sync RCLootCouncil settings between guild members. The setting of this module is also synchronized because the setting of this module is a part of RCLootCouncil.   

**Enhanced Award Announcements** (v1.8+)
######  
+ You can add the awardee's EPGP related information to the award announcement. Check Interface->Addons->RCLootCouncil->Master Looter->Announcements for more information.

## Custom GP Rule Tutorial
**Introduction**
######  
+ Custom GP Rule is a disabled by default feature. If disabled, the GP value is calculated by the default way of EPGP(dkp reloaded). Chat commands "/rc epgp" to open the settings.
+ If Enabled, RCLootCouncil-EPGP, EPGP(dkp reloaded) and other EPGP related addons will use the custom GP Rule to calculate the GP value.
+ The default rule of custom GP Rule is the same as the default GP rule of EPGP(dkp reloaded), which I don't think give a fair GP value. If you do decide to use this feature, I highly recommend you to write your own rule to replace it.

**Problems in the default GP rule of EPGP(dkp reloaded), version 5.2.13.**
######  
+ GP value of artifact relics is heavily undervalued. One artifact relic provide much more stats than head piece of the same item level, but only worth 66.7% GP value of head piece. (Calcuate difference of stats between artifact with 3 relics and artifact without relics, then divides by 3. Then compare the result with the stats of head piece)
+ GP value grows slowly with item level. GP value doubles every 30 item level. GP value only increases 40% when item level increases by 15.
+ GP value of set piece and non-set piece have the same GP value. Obviously, set piece should charge more.  

**Formula, Variables and Slot Weights**
######  
+ Formula is used to calculate the GP value of the item. Formula should be written in LUA code. But you don't need any programming knowledge. For the most guild, you just need to summarize your rule into a simple one-line math formula and enter the formula into the RCLootCouncil-EPGP settings. Formula must returns a number(Don't need to be an integer. The addon will do rounding.)
+ Variables are built-in values that fetch the information of the item, which will assist you in creating the formula. Most variables can only have value 1 or 0, and you just need to do multiplication with those variable to make use of them in the formula.
+ Slot weights is used to give items in the different slot a different GP coefficient. Its value can be set in the settings. The addon automatically detects the slot of the item, and assign the value of variable `slotWeights` according to user settings and the item slot.

**Available Variables**
######  

+ `ilvl` The item level of the item or the base ilvl of the token.
+ `slotWeights` Number. The weights of the item according to its equipment slot.
+ `isToken` Integer. 1 if the item is a set token, 0 otherwise.
+ `numSocket` Integer. The number of socket in the item.
+ `hasAvoid` Integer. 1 if the item has avoidance, 0 otherwise.
+ `hasLeech` Integer. 1 if the item has leech, 0 otherwise.
+ `hasSpeed` Integer. 1 if the item has speed, 0 otherwise.
+ `hasIndes` Integer. 1 if the item is indestructible, 0 otherwise.
+ `isNormal` Integer. 1 if the item is from normal difficulty, 0 otherwise.
+ `isHeroic` Integer. 1 if the item is from heroic difficulty, 0 otherwise.
+ `isMythic` Integer. 1 if the item is from mythic difficulty, 0 otherwise.
+ `isWarforged` Integer. 1 if the item is warforged, 0 otherwise.
+ `isTitanforged` Integer. 1 if the item is titanforged, 0 otherwise.
+ `rarity`  Integer. The rarity of the item. 3-Rare, 4-Epic, 5-Legendary
+ `itemID` Integer. The item id of the item.
+ `equipLoc`  String. The non-localized string representing the equipment slot. Recommend to use variable _"slotWeights"_ instead if possible.
+ `link` String. The full item link of the item.

**Rules And Formulas Examples**
######  
+ **EPGP(dkp reloaded) v5.2.13 Default Rule**  
915 Head Piece worths base GP of 1000. GP Doubles for every 30 item level increases. Head/Chest/Legs worth 100%GP. Shoulder/Hand/Waist/Feet worth 75%GP. Cloak/Wrist/Neck/Finger worth 56%GP. Trinket worth 125%GP. Relic worth 66.7%GP. Item with Speed worths 25 extra GP. Each socket worths 200 extra GP. Set piece has the same GP value of non-set piece.
  + Slot Weights: Head/Chest/Legs = 1.0, Shoulder/Hand/Waist/Feet = 0.75, Cloak/Wrist/Neck/Finger = 0.56, Trinket = 1.25, Relic = 0.667
  + Formula : 1000 \* 2 ^ (-915/30) \* 2 ^ (ilvl/30) \* slotWeights + hasSpeed \* 25 + numSocket \* 200  

+ **Custom Rule Example 1**  
915 Head Piece worth base GP of 1000. GP Doubles for every 20 item level increases. Head/Chest/Legs worth 100%GP, Shoulder/Hand/Waist/Feet worth 75%GP, Cloak/Wrist worth 56%GP. Neck/Finger worth 82%GP. Trinket worth 125%GP. Relic worths 171%GP. (These numbers are calculated by the amount of main stats + 160% secondary stats each gear has.) Item with leech or speed worth 40 extra GP. Each socket worth 140 extra GP. The GP of set token is the same as the GP of non-set piece with plus 10.
  + Slot Weights: Head/Chest/Leg = 1.0, Shoulder/Hand/Waist/Feet = 0.75, Cloak/Wrist/ = 0.56, Neck/Finger = 0.82, Trinket = 1.25, Relic = 1.71
  + Formula: 1000 \* 2 ^ (-915/20) \* 2 ^ ((ilvl + isToken \* 10)/20) \* slotWeights + (hasSpeed + hasLeech) \* 40 + numSocket \* 140

+ **Custom Rule Example 2**  
Base GP is 100. +50% if the item is warforged. Double if the item is Titanforged. Double if item is from mythic. Half if the item is from normal. Double if the item is relic. Double if the item is trinket.
  + Slot Weights: Head/Chest/Leg/Shoulder/Hand/Waist/Feet/Cloak/Wrist/Neck/Finger = 1, Trinket/Relic = 2
  + Formula: 100 \* (1 - 0.5 \* isNormal) \* (1 + isMythic) \* (1 + 0.5 \* isWarforged) \* (1 + isTitanforged) \* slotWeights
+ **Custom Rule Example 3**  
The GP value is item level-900. +50% For Set Token. Doubles for trinket. Socket worths 5 item level.
  + Slot Weights: Head/Chest/Leg/Shoulder/Hand/Waist/Feet/Cloak/Wrist/Neck/Finger/Relic = 1, Trinket = 2
  + Formula: (ilvl - 900 + 5 \* numSocket) \* (1 + 0.5 \* isToken) \* slotWeights

**Test Your GP Rule**  
######  
1. **Turn on GP display on item tooltip**  
Go to Interface->Addons->EPGP->Tooltip. Check "Enable" and set "Quality threshold" to be rare or epic.
2. **Check GP value of items in Dungeon Journal**  
Open Dungeon Journal and mouseover a loot. Check if the GP value shown in the tooltip is your intended value.

## Commands
######  
+ **/rc epgp**   Open the RCLootCouncil - EPGP settings

## Planned Features
######
+ Enhancement to how EP is rewarded.
  + Add features similar to quick DKP v2 that gives different EP percentage to players offline, out of zone, different guild rank, using alt, etc.
  + Add ZeroSum EP Award among raid members in the zone. Many guild gives player minus EP if they make mistakes, but it is unfair to the people in the zone and good for subs because subs can never make a mistake. ZeroSum EP Award will help to solve this problem by moving EP of the player who makes a mistake to other players in the raid zone. This will make the average EP of players in the raid zone and subs unchanged, so it will be fair for everyone.

## Known Issues
+ RCLootCouncil v2.4.6 and older, v2.5Beta1, v2.5Beta2 do not work for Patch 7.3.  
  This module cannot do anything about that. This module should work fine after RCLootCouncil is updated.
+ This module always put columns "EP", "GP" and "PR" at the rightmost of voting frame. You cant use "RCLootCouncil - ExtraUtilities" to disable, set width or position of these columns at the moment. This module does not affect other columns from ExtraUtilities.
+ Missing translation. Only English, Chinese Simplified and Chinese traditional are fully localized right now. I can only translate language I know. Help to localize this project [here](https://wow.curseforge.com/projects/rclootcouncil-epgp/localization)

## Bug Report
+ Appreciate any bug report, especially when this addon is not working for you. I will work on the bugs ASAP if I know the bug exists. I am not always the Master Looter in the guild, so I may not know the bug exists.
+ Report bug or make suggestion in the [curseforge issue tracker](https://wow.curseforge.com/projects/rclootcouncil-epgp/issues) or [github issue tracker](https://github.com/SafeteeWoW/RCLootCouncil_EPGP/issues)

Appreciate [evil_morfar](https://mods.curse.com/members/evil_morfar), the author of RCLootCouncil, who gives me suggestions while writing this module.
