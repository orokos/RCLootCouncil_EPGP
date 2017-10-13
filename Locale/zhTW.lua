-- Translate RCLootCouncil - EPGP to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil-epgp/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCEPGP", "zhTW")
if not L then return end

-- Manually export from Curse here if you want to update the addon from Github, but not guarantee to be update-to-date.
--@debug@
L["announce_awards_desc2"] = [=[
RCLootCouncil-EPGP: #diffgp# - 玩家從物品獲取的GP量. #ep# - 玩家的EP值. #gp# - 玩家獲取物品前的GP值. #pr# - 玩家獲取物品前的PR值. #newgp# - 玩家獲取物品后的GP值. #newpr# - 玩家獲取物品后的PR值.]=]
L["announce_formula_runtime_error"] = "你的GP公式含有運行時錯誤.出錯時會使用默認公式."
L["Award GP (Default: %s)"] = "獎勵GP （默認： %s)"
L["Bidding"] = "拍賣"
L["bidding_desc"] = "玩家可以在RCLootCouncil彈窗中向戰利品分配者發送以整數開始的筆記以告知競標出價."
L["chat_commands"] = "- epgp     - 開啟RCLootCouncil-EPGP設定介面"
L["Credit GP to %s"] = "獎勵裝備點數予%s"
L["Custom GP"] = "自定義GP"
L["customGP_desc"] = "自定義GP使你可以為每件裝備定義自己的GP規則. 你需要為此定義計算GP值的公式. 你可以選擇禁用此功能，以EPGP(dkp reloaded)的默認方式計算EP值"
L["disable_gp_popup"] = "GP彈窗被RCLootCouncil - EPGP自動禁用."
L["Enable Bidding"] = "啟用拍賣"
L["enable_custom_gp"] = "啟用自定義GP"
L["EPGP_DKP_Reloaded_settings_received"] = "通過'/rc sync'收到了EPGP(dkp reloaded)的設置."
L["error_no_target"] = "錯誤. 你沒有目標."
L["forbidden_function_used"] = "公式內一個被禁止的命令試圖被執行，已經被阻止。請檢查公式是否含有惡意代碼!"
L["General"] = "常規"
L["GP Bid"] = "GP出價"
L["gp_formula"] = "GP公式"
L["gp_formula_help"] = [=[在下面的輸入框輸入返回GP值的LUA代碼.
如果輸入是單行語句, 例如 'a and b or c', 無需return語句.
如果有任何控制語句, 則需要return語句.
以下是代碼中可用的變量.]=]
L["gp_formula_syntax_error"] = "公式有語法錯誤. 將使用默認公式."
L["gp_value_help"] = [=[例:
100%: 使用100%GP值
50%: 使用50%GP值
25: 所有物品價值25GP]=]
L["gp_variable_equipLoc_help"] = "字符串. 代表欄位的非本地化字符串. 如果可能,建議使用變量slotWeights代替."
L["gp_variable_hasAvoid_help"] = "整數. 1如果物品帶有迴避,否則為0."
L["gp_variable_hasIndes_help"] = "整數. 1如果物品永不磨損,否則為0."
L["gp_variable_hasLeech_help"] = "整數. 1如果物品帶有汲取,否則為0."
L["gp_variable_hasSpeed_help"] = "整數. 1如果物品帶有速度,否則為0."
L["gp_variable_ilvl_help"] = "整數.物品的裝備等級或者是套裝代幣的基礎裝等"
L["gp_variable_isHeroic_help"] = "整數. 1如果物品來自英雄難度,否則為0."
L["gp_variable_isMythic_help"] = "整數. 1如果物品來自傳奇難度,否則為0."
L["gp_variable_isNormal_help"] = "整數. 1如果物品來自普通難度,否則為0."
L["gp_variable_isTitanforged_help"] = "整數. 1如果物品泰坦造物,否則為0."
L["gp_variable_isToken_help"] = "整數. 1如果物品是套裝代幣,否則為0."
L["gp_variable_isWarforged_help"] = "整數. 1如果物品戰鑄,否則為0."
L["gp_variable_itemID_help"] = "整數. 物品的ID."
L["gp_variable_link_help"] = "字符串. 物品的完整鏈接."
L["gp_variable_numSocket_help"] = "整數. 物品裡插槽的數量."
L["gp_variable_rarity_help"] = "整數. 物品的稀有度. 3-精良,4-史詩,5-傳說."
L["gp_variable_slotWeights_help"] = "數字. 物品的欄位權重."
L["gpOptions"] = "回應的GP百分比"
L["gpOptionsButton"] = "打開配置回應的GP百分比的選項"
L["Input must be a number."] = "輸入必須為數字."
L["need_restart_notification"] = "RCLootCouncil-EPGP v%s更新需要重啟游戲客戶端. 插件的某些功能無法正常使用直到游戲客戶端重啟."
L["new_version_detected"] = "你的版本%s已過期. 檢測到新版本%s. 你可以從Curse.com或者Twitch客戶端更新此插件."
L["no_permission_to_edit_officer_note"] = "你無權修改官員備注"
L["rc_version_below_min_notification"] = "此版本的RCLootCouncil-EPGP要求RCLootCouncil v%s+. 你的RCLootCouncil的版本為v%s. 請更新RCLootCouncil."
L["RCEPGP_desc"] = "一個給RCLootCouncil添加了EPGP支持與自定義的插件. 作者: Safetee"
L["send_epgp_setting_desc"] = "如果被選中, '/rc sync'也會同步EPGP(dkp reloaded)的設置"
L["send_epgp_settings"] = "'/rc sync'也同步EPGP(dkp reloaded)的設置"
L["Setting Sync"] = "設置同步"
L["setting_reset_notification"] = "RCLootCouncil-EPGP v%s 重置了所有的設置. 如果有需要請重新配置."
L["slash_rc_command_failed"] = "操作失敗. 請檢查是否輸入正確."
L["slash_rc_gp_help"] = "- gp name reason [amount]      - 向一名玩家獎勵GP.  使用'/rc gp help'來查看命令的詳細用法"
L["slash_rc_gp_help_detailed"] = [=[/rc gp name reason [amount]

向一名玩家獎勵GP

|cffffd000name|r: 必須. 玩家角色的全名. 如果和你的服務器相同服務器名可省略. 你也可以用%p指代你自己，用%t指代你的目標.

|cffffd000reason|r: 必須. 獎勵的原因. 這一般是物品的鏈接.

|cffffd000amount|r: 可選. 整數. 獎勵的GP值. 如果省略, 將會獎勵插件計算的GP值.]=]
L["slash_rc_undogp_help"] = "- undogp name [reason]       - 撤銷對一名玩家最近的GP操作. 用'/rc undogp help'查看此命令的詳細用法."
L["slash_rc_undogp_help_detailed"] = [=[/rc undogp name [reason]
撤銷對一名玩家最近的GP操作

|cffffd000name|r: 必須. 撤銷GP的玩家角色全名. 如果和你服務器相同，服務器名可省略. 你也可以用'%p'指代你自己, 用'%t'指代你的目標.

|cffffd000reason|r: 可選. 這一般為空或者為物品的鏈接. 如果為空，撤銷最近的GP操作，否則撤銷最近的原因與此相同的GP操作.]=]
L["slot_weights"] = "欄位權重"
L["Undo GP"] = "取消GP"
--@end-debug@


--@localization(locale="zhTW", format="lua_additive_table", same-key-is-true=true)@
