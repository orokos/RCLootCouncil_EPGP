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

## Known Issues
+ This modules always put columns "EP", "GP" and "PR" at the rightmost of voting frame.You cant use "RCLootCouncil - ExtraUtilities" to disable, set width or position of these columns at the moment. This module does not affect other columns from ExtraUtilities.  

## Bug Report
+ Appreciate any bug report, especially when this addon is not working for you. I will work on the bugs ASAP if I know the bug exists. I am not always the Master Looter in the guild, so I may not know the bug exists.
+ Report bug or make suggestion in the [curseforge issue tracker](https://wow.curseforge.com/projects/rclootcouncil-epgp/issues) or [github issue tracker](https://github.com/SafeteeWoW/RCLootCouncil_EPGP/issues)

Help to localize this project [here](https://wow.curseforge.com/projects/rclootcouncil-epgp/localization)  
Appreciate [evil_morfar](https://mods.curse.com/members/evil_morfar), the author of RCLootCouncil, who gives me suggestions while writing this module.
