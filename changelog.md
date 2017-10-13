### v2.0.1
---
###### Bugfixes
  - Fix bugs in setting synchronization
    - Fix synchronization of EPGP(dkp reloaded) settings is not working.
    - Fix nil error when sync from a user without RCLootCouncil-EPGP installed.

### v2.0.0
---
- **All Settings of RCLootCouncil-EPGP are reseted.**
  - Please reconfig the settings, especially if you are using custom GP of this addon.
- **Require RCLootCouncil v2.6.0+**. No longer work for v2.5.x due to RCLootCouncil API changes.
- Support to set up the GP value for relic responses, which is a new feature in RCLootCouncil v2.6.0
- You will be notified to update RCLootCouncil-EPGP when a new version is detected.
- The settings of EPGP(dkp reloaded) can now be sent to other people through '/rc sync'.
  - You can turn off this in the RCLootCouncil-EPGP settings, which can be opened by '/rc epgp'
  - This is enabled by default.
- Add two chat commands:
  - /rc gp name reason [amount]: Award GP to a player. Reason is usually the itemLink he's awarded. amount can be omitted to award the GP value calcuated by the addon.
  - /rc undogp name [reason]: Undo the most recent GP operations to a player, if the reason is not specified, otherwise undo the most recent GP operations with the matching reason.
- The keyword of award text is changed from '#xxxx' to '#xxxx#'.
  - For example, '#diffgp' is changed to '#diffgp#'
  - You shouldn't need to change the award text manually. The addon updates the text automatically.
- Thanks to the RCLootCouncil API changes, the performance is improved.
- Localization now uses the Curse automatic pacakaging system.
  - Update to the localization will be applied to the new downloads of the addon without the need to upload a version.
  - Go to https://wow.curseforge.com/projects/rclootcouncil-epgp/localization to help translate this addon.
###### Bugfixes
  - Fix a bug that custom GP returns unintended value for some chests.

### v1.9.2
---
###### Bugfixes
- Fix the text in rightclick menu not showing in some case.
- Another fix to FPS drop when rightclick menu opens.


### v1.9.1
---
- This addon no longer enforces to always disable the GP popup of EPGP(dkp reloaded). Instead, the GP popup of EPGP(dkp reloaded) is only disabled when the RCLootCouncil Voting Frame opens and the enable status of GP popup is restored to user setting when the Voting Frame closes.

### v1.9
---
- **This update requires full restart of the game client**
- **This update requires RCLootCouncil v2.5.0+. Now this module no longer work with older RCLootCouncil version.**
- Auto disable profanity filter(Mature Language Filter) for Chinese Simplified client.
  - It is reported that in Patch 7.3, Chinese Simplified client filters out some number in officer's note, which causes missing of EP/GP value. The addons disable the filter by doing `/console SET profanityFilter "0"`
- Restructure the code and make it more organized.
- When the Custom GP Formula has runtime error, the addon will print the error message.
- Variable "equipLoc" removed.
- Automatically enable the gp dispaly on item tooltip.
- (Advanced user with LUA knowledge) formula now allows to use some item related APIs, such as "print", "GetItemInfo", "GetItemStats".<br>
  Still have no access to global environment and most APIs for security reason.

###### Bugfixes

- Fix an issue that change the stat weights of Custom GP Rule does not update the GP of items you have seen recently.
- Fix bid in voting frame sometimes display incorrectly if response is received while switching session.
- Fix FPS drop when rightclick menu opens.

### v1.8.1
---
###### Bugfixes

- Fix missing localization

### v1.8
---
- Enhanced Award Announcements (**Requires RCLootCouncil v2.5.0+**)

  - You can add the awardee's EPGP related information to the award announcement.<br>
    Check Interface->Addons->RCLootCouncil->Master Looter->Announcements for more information.

### v1.7.2
---
**You should have updated RCLootCouncil to v2.5, as older versions of RCLootCouncil does not support Patch 7.3**

###### Bugfixes

- Fix GP not working when you are not using custom GP Rule.
- Fix GP tooltip performance issues when you are using custom GP rule.

### v1.7.1
---
- Should now support SYNC feature introduced by RCLootCouncil-v2.5Beta1

###### Known Issues

- RCLootCouncil v2.4.6 and older, v2.5Beta1, v2.5Beta2 do not work for Patch 7.3.<br>
  This module cannot do anything about that. This module should work fine after RCLootCouncil is updated.

### v1.7
---
- Add chat command "/rc epgp" to get access to RCLootCouncil - EPGP settings.
- Add variables "isNormal", "isHeroic", "isMythic", "isWarforged", "isTitanforged" to custom GP rule.
- One line formula in custom GP rule no longer needs "return"
- GP editbox in voting frame now affords 5 digits instead of 4.
- Add Tier21 token info
- Ready for patch 7.3

### v1.6
---
- All rightclick menus are refreshed every frame rather than only when opened. This allows you to make multiple changes in one menu without reopening the menu.
- Add "link" variable to Custom GP Rule Feature for advanced user.

### v1.5
---
- Add "Undo GP" and "Award GP" button in rightclick menu of the RCLootCouncil History Frame to help manage GP after loot has been distributed by the loot master.
- "Undo GP" button: Undo the last GP action that awards the exact item to the exact player
- "Award GP" button: Award GP amount to the player. The default GP amount is determined by the item and response in the history. You will be able to adjust the GP amount in the following popup.

### v1.4.1
---
###### Bugfixes

- Fix lua error that prevent EP, GP, PR to be shown.

### v1.4
---
- The result of enabling/disabling custom GP rules is applied immediately while voting frame is open.
- Update the default custom GP formula to accomodate the most recent EPGP addon update.

### v1.3
---
###### Bugfixes

- Fix a bad LUA error that prevents settings to be shown. (Issue #3)<br>
  Thanks for the issue report from Wulfbayne.<br>
  Bidding and custom GP feature should now function correctly.

### v1.2.1
---
###### Bugfixes

- Fix a bug in sorting that could cause the game client to stuck in infinite loop(game crash).

### v1.2
---
- Add a simple bidding feature.<br>
  (Disabled by default. Enable this feature in Interface->Addons->RCLootCouncil->EPGP).<br>
  Players can send their bidding price to the loot master by sending a note which starts with integer in the RCLootCouncil popup.<br>
  Loot Master can see the bidding price and assign GP accordingly.

### v1.1.2
---
- Display version number in the setting.

###### Bugfixes

- Issue #2: No longer use global variable "RCVotingFrame".

### v1.1.1
---
###### Bugfixes

- Keep disabling the GP popup of EPGP(dkp reloaded) rather than only disable it once when the addon is loaded. This should fix the issue that some people still get GP popup of EPGP with this addon.

### v1.1
---
- Changes to custom GP rules are applied immediately while voting frame is open.

### v1.0.1Beta
---
- Add ruRU (Russian) localization. Thanks to the translation by Uptys.

### v1.0Beta
---
- Add Support to create customized GP Points Rule. This feature is in Beta.<br>
  The setting is under Interface->RCLootCouncil->EPGP.<br>
  Support enUS, zhCN, zhTW localization.

### v0.8.2
---
- Disable the GP popup of "EPGP(dkp reloaded)" when this addon is enabled.

### v0.8
---
- Award with GP button is now clickable when the GP value of response/item is 0

### v0.7
---
- Improve EP, GP, PR text format.<br>
  If EP, GP, PR are unknown, they are shown as "?" instead of 0.<br>
  GP text is now grey.<br>
  EP text is red if its value is less than MIN_EP, grey otherwise.<br>
  PR text shows 4 digits of effective number instead of 4 digits after dot.

### v0.6
---
- Improve sorting.<br>
  If sorted by PR, PR is sorted in descending order by default.<br>
  If sorted by response, equal response is sorted by PR in descending order.

###### Bugfixes

- Fix custom GP editbox Focusing issue. No longer auto focus GP editbox. The focus of GP editbox is automatically cleared after 3s unused or when rightclick menu opens.

### v0.5.3
---
###### Bugfixes

- Fix a bug occurring when realm name contains space.

### v0.5.2
---
###### Bugfixes

- Fix a bug in v0.5 that sometimes fails when the player is from the same realm as the ML

### v0.5
---
###### Bugfixes

- Hopefully fix the EPGP error for some non-English names and names with space.

### v0.4
---
- Now the addon can be used with RCLootCouncil - ExtraUtilities.

### v0.0.3.2
---
- Add more EPGP Support.<br>
  You can now assign GP values to different responses.<br>
  There is a GP editbox showing the GP value of the item. You can change it to your custom GP value. Add a command on the very top of right click menu to award item and add GP to the player according to the GP in the editbox and GP of his response.

### v0.0.2
---
- Member whose EP is less than MinEP will be sorted after member whose EP is greater than MinEP EP, GP and PR information are refreshed when EPGP value is changed.

### v0.0.1
---
- Initial release. Show EP, GP and PR in the RCLootCouncil VotingFrame
