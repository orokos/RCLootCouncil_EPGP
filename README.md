### This addon is no longer maintained because the author has been Afk from the World of Warcraft. Any fork for this repository is welcome
     
     
     
     
     
     
     
     
     
     
     
     
     
**The author of RCLootCouncil-EPGP is NOT the author of RCLootCouncil. Please do NOT report any EPGP related bugs to RCLootCouncil. Before reporting any bugs, make sure to read the [FAQ](https://wow.curseforge.com/projects/rclootcouncil-epgp/pages/faq)!**


**Requires [EPGP(dkp reloaded)](https://mods.curse.com/addons/wow/epgp-dkp-reloaded) and [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil). This addon cannot be enabled without those two addons enabled.**

---
This is an _**UNOFFICIAL**_ module of the loot distribution addon [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil) that adds full EPGP support and customization to it.  
\(EPGP is a loot distribution system. [Read Here](http://www.epgpweb.com/help/system) for more information about the EPGP system.\)  



Only the Master Looter needs to install this module, [EPGP(dkp reloaded)](https://mods.curse.com/addons/wow/epgp-dkp-reloaded) and [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil)

Other raid members just need to install [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil), but it's still recommended to install this addon and [EPGP(dkp reloaded)](https://mods.curse.com/addons/wow/epgp-dkp-reloaded), especially for council members.

This module should works fine together with the official modules [RCLootCouncil - GroupGear](https://mods.curse.com/addons/wow/rclootcouncil-groupgear) and [RCLootCouncil - ExtraUtilities](https://mods.curse.com/addons/wow/257427-rclootcouncil-extrautilities)

## Features
**Full EPGP Support**
######  
+ Show sorted EP, GP and PR value of raid members in RCLootCouncil Voting Frame  
+ Loot master can assign percentage GP value to the different responses from the raid members. The setting is in Interface->Addons->RCLootCouncil->Master Looter->Buttons and Responses. The final gp value calculated by the addon normally is itemGP*responseGPPercentage.  
+ Award GP automatically without any extra click. Simply click the first button of the rightclick menu in the RCLootCouncil Voting Frame to award item and GP value at the same time.
+ If the raid member wants to change response after he has responded, and that change will affect the final GP value, Master Looter can use "Change Response" button in the rightclick menu to change his response.
+ Easily change awardee in the voting frame. Simply award the item which has been awarded to another people. The GP operations to the previous awardee will be reverted automatically.

**Create Your Own GP Rule**
######  
+ Guild that does not use default GP rule of EPGP(dkp reloaded) can create own GP rule. Then this module will calculate the GP value automatically by the new rule instead of the default rule, that would free the master looter from human calculation. The setting is in Interface->Addons->RCLootCouncil->EPGP.
+ See the detailed tutorial below (Custom GP Tutorial)

**Create Your Own EP Rule** (v2.2)
######  
+ You can customize who should be included in the mass EP award or recurring EP Award, without forcing people to stay inside the raid group the entire night.
+ See the detailed tutorial below (Custom EP Tutorial)

**Easy GP Management After Loot Has Been Distributed**
######  
+ When a player change the mind about the loot after receiving it, guild Admins can visit RCLootCouncil Loot History ("/rc history") to undo last GP action or award GP to the player. If the response is changed or the player who received the item is changed, first click the 1st button in the rightclick menu to undo the previous GP, then use other buttons to change the response or the name of player who received the item, then award the GP by clicking the 2nd button in the rightclick menu.  

**Bidding Feature**
######  
+ Players can send their GP bidding price to the loot master by sending a note which starts with integer in the RCLootCouncil popup.(Disabled by default. Loot master can enable it in Interface->Addons->RCLootCouncil->EPGP).  
+ This feature is improved in v2.2. See the detailed explanation below.

**ZeroSum EP Award** (v2.2)
######  
+ Offer a way to evaluate player performance which is fair for both substitudes and non-substitudes. Use commands '/rc zs', '/rc zsr' or '/rc zsdr' to run it. See the defail explanation below.

**Sync Settings Between Guild Members**
######  
+ This is actually the feature of RCLootCouncil itself, introduced by RCLootCouncil v2.5. Use command "/rc sync" to sync RCLootCouncil-EPGP settings between guild members.

**Enhanced Award Announcements** (v1.8+)
######  
+ You can add the awardee's EPGP related information to the award announcement. Check Interface->Addons->RCLootCouncil->Master Looter->Announcements for more information.

## Bidding
**Introduction**
######  
For long time, EPGP system does not provide good bidding system because unlike DKP amount that you can only use all your DKP, there is no cap on the GP value you can bid. RCLootCouncil-EPGP resolves this issue that allows the master looter to setup a Min New PR value. The addon will limit the GP bid of the candidate so that his PR will not drop below Min New PR after getting the GP.

**Modes**
+ **Highest bid wins and gets GP of bid** (gp Absolute mode)  
  This works similar as bidding in DKP when min new pr is set to 1. In this way, the bid of candidate will limited by EP-GP.
+ **"Highest bid wins and gets GP of (gp of item)*bid** (gp Relative Mode)  
  This actually works the same as above, except the bid value of people are changed to percentage value.
+ **"Highest bid*pr wins and gets GP of (gp of item)*bid** (pr Relative Mode)  
    This is an interesting mode. Instead of setting min new PR, Master Looter limits the maximum bid by raw value. The Master Looter should makes the maximum bid small, for example, 2. This is used to allow candidates to express their willingness to get the item.

## ZeroSum EP Tutorial
**Introduction**
######  
The goal of ZeroSum EP allows the Master Looter to evaluate people by performance, in a way that is fair to both substitutes and non-substitudes.

**The problem that using EP reduction to evaluate performance**
Some guild reduces EP when the people make mistakes. The problem is that this benefits substitudes, but unfair to people inside the raid. It's impossible that substitudes who is outside of the raid makes any mistake. Therefore, overtime, people who sits more often will be more likely to have more EP. Some guild attempts to solve this problem by giving substitubes less EP, but this does not feel good to substitudes. Besides, it is hard to find a balance between EP reduction and less EP to substitudes.

**How ZeroSum EP solves the problem**
Whenever a person makes mistake, EP managers can use ZeroSum EP Award to redistribute a partial of his EP to other raid members in the same zone. The EP of people that are outside of the instance will be unaffected. The idea is people should be awarded when someone else makes mistake when he does not. After many ZeroSum EP awards, people who has better performance than the average of the raid gains EP. People who has worse performance than the average of the raid loses EP.

**Commands**
+ /rc zs name reason amount
  Award people with "name" the amount, and redistribute that amount evenly among all other raid members in the same zone.
  Example: /rc zs PERSON1 mistake -190. Suppose 20 man in the raid zone, PERSON1 gains -190 EP, all other members gains 10EP.
+ /rc zsr name reason amount.
  Similar to above, except the amount is redistributed among all other people with the same role(TANK, DAMAGER, HEALER) as the award target. This is more fair than the above, because boss mechanic does not apply to everyone.
+ /rc zsdr name reason amount.
  Similar to above, except the amount is redistributed among all other people with the same detail role(TANK, MELEE DPS, RANGED DPS, HEALER)

## Custom EP Tutorial
**Introduction**
######  
+ CustomEP features fetches the information of everyone in the raid or in the group, and apply Custom EP rule to them. People whose EP change is not 0 will be awarded.
+ The purpose of this feature is to allow people to leave the raid, but still be able to receive EP award.

**How to use**
+ You need to create a formula to use this feature. Open the option panel('/rc epgp') and then goto the "Custom EP" panel. Press the add button to create a formula.
+ Use command '/rc massep' or click the button "Award EP" to do mass ep award.
+ Use command '/rc recurep' or click the button "Recurring award starts" to start recurring EP Award.

**Categories**
+ There are currently the following categories available in the custom EP. In each category, any guild or group member will satisfy one and only one variable under it. (For example, in Online status category, people is either online or offline.) The final EP percentage of the person is the multiplication of all variables he satisfied. For example, if a person is online, in group, guild rank 1, in zone, and the percentage of all those settings are 0.5, the final EP percentage of him is 0.5*0.5*0.5*0.5 = 0.0625
+ See their meaning in game.
+ **Online Status**: `Online`, `Offline`:
+ **Group Status**: `In Group`, `In standby`, `Signed up in calendar`, `None of the above`
+ **Rank**: `GuildRank0`, `GuildRank1`, ..., `Not in your guild`
+ **Zone**: `In Zone`, `Not in Zone`

**Examples**
+ You want to award people above guild rank 4 who is either in the group, or is online. You will to create two formulas:
  + FORMULA1: `offline`=0, `In Group`=0,`variables that guild rank>4`=0. all other variables should be set as 1.
  + FORMULA2: `In Group`=1, `In standby`=0, `Signed up in calendar`=0, `None of the above`=0
  + You can run the mass EP award :
    + Click "Award EP" once in FORMULA1 then "Award EP" once in FORMULA2
	+ Or by the command "/rc massep reason amount FORMULA1 FORMULA2"
  + The method to run recurring EP award is similar.



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
+ For most of the commands with arguments, run them in-game without argument show detailed help message.
+ **/rc epgp**   Open the RCLootCouncil - EPGP settings
+ **/rc gp name reason [amount]** Award GP to a character.
+ **/rc undogp name [reason]** Undo the most recent GP operations to a character.
+ **/rc massep reason amount [formulas, ...]** Mass EP award using CustomEP.
+ **/rc ep name reason amount** Award EP to a player.
+ **/rc recurep reason amount period [formulas, ...]** Start recurring EP award using Custom EP.
+ **/rc stoprecur** Stop recurring award.
+ **/rc zs name reason amount** ZeroSum EP award.
+ **/rc zsr name reason amount** ZeroSum EP award by role.
+ **/rc zsdr name reason amount** ZeroSum EP award by detailed role.

## Tips
+ **Easily award GP when the raid member changes his mind after responsed to RCLootCouncil, BEFORE the loot is distributed.**  
Often a person click "Pass" and later tells the loot master that he actually wants this item. You may find it hard to award GP to him because the award GP button awards 0GP to person who pass. Simply click "Change Response" button to change his response to fix this problem.

+ **Easily fix GP when the raid member changes his mind AFTER the loot is distributed.**  
If two raid members notifies the loot master and trades the loot after RCLootCouncil session ends and GP has been awarded, you can easily fix the GP of two members. Use '/rc history' to open the history frame. Find the item and undo the GP operation to the origin awardee in the Rightclick menu. Then change the name of awardee in the rightclick menu. Then award the GP to the new awardee.

## Planned Features
######  
+ Feel free to send your ideas on Curseforge.

## Known Issues
+ This module always put columns "EP", "GP" and "PR" at the rightmost of voting frame. You cant use "RCLootCouncil - ExtraUtilities" to disable, set width or position of these columns at the moment. This module does not affect other columns from ExtraUtilities.
+ Need translation for many languages. Only English, Chinese Simplified and Chinese traditional are fully localized right now. I can only translate language I know. Help to localize this project [here](https://wow.curseforge.com/projects/rclootcouncil-epgp/localization)

## Bug Report
+ **Again, before reporting any bugs, make sure to read the [FAQ](https://wow.curseforge.com/projects/rclootcouncil-epgp/pages/faq)!**
+ Appreciate any bug report, especially when this addon is not working for you. I will work on the bugs ASAP if I know the bug exists. I am not always the Master Looter in the guild, so I may not know the bug exists.
+ Report bug or make suggestion in the [curseforge issue tracker](https://wow.curseforge.com/projects/rclootcouncil-epgp/issues) or [github issue tracker](https://github.com/SafeteeWoW/RCLootCouncil_EPGP/issues)

Appreciate [evil_morfar](https://mods.curse.com/members/evil_morfar), the author of RCLootCouncil, who gives me suggestions while writing this module.

## About the Author
+ My main character is "Safetyy" on the server Illidan-US. Sadly, the username "Safetee" is not avaiable when I transferred to that server. I wrote several small addons before. This is the first major addon I write.

---
**The author of RCLootCouncil-EPGP is NOT the author of RCLootCouncil. Please do NOT report any EPGP related bugs to RCLootCouncil. Before reporting any bugs, make sure to read the [FAQ](https://wow.curseforge.com/projects/rclootcouncil-epgp/pages/faq)!**


**Requires [EPGP(dkp reloaded)](https://mods.curse.com/addons/wow/epgp-dkp-reloaded) and [RCLootCouncil](https://mods.curse.com/addons/wow/rclootcouncil). This addon cannot be enabled without those two addons enabled.**
