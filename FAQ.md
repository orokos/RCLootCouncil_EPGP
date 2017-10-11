**Make sure you have read the [FAQ of RCLootCouncil](https://wow.curseforge.com/projects/rclootcouncil/pages/faq)**  


**I encountered a bug.  Whether I should report it to RCLootCouncil or RCLootCouncil-EPGP and How should I report it?**  
If the problem is EPGP related(eg. GP is not awarded, calculated GP value is wrong), or cannot be reproduced with RCLootCouncil-EPGP disabled, you should report it to RCLootCouncil-EPGP. Report to RCLootCouncil otherwise.  
You should create a ticket to report bugs.  
[Create an Issue in RCLootCouncil-EPGP](https://wow.curseforge.com/projects/rclootcouncil-epgp/issues/create), or [Create an Issue in RCLootCouncil](https://wow.curseforge.com/projects/rclootcouncil/issues/create)  
Most importantly, after creating your ticket, press the "Attach" button and upload your Saved Variables file, located at:
"../World of Warcraft/WTF/Account/"account_name"/SavedVariables/RCLootCouncil.lua" 
If Curse are still rejecting .lua files, just rename it so it ends with .txt  
Note that this is the only save variable files you need to upload. The data of both RCLootCouncil-EPGP and RCLootCouncil are stored together in this file.  

**I tested the addon in a low-level raid, and the set token are not recognized correctly.**  
RCLootCouncil only includes information of set tokens no earlier than HFC(Tier 18, Patch 6.2). Set tokens in recent raid should be recognized correctly.

**Some rows in RCLootCouncil Voting Frame disappears when raid member responses.**  
Click the "Filter" Button in the topright cornder of the frame. Make sure everything in the dropdown is checked.

**How do I add items to a session/deal with BoE's?**  
As ML, type "/rc add [item]" where [item] is the link produced by shift-clicking an item. Note this only works before starting a session.
