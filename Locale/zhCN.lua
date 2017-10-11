-- Translate RCLootCouncil - EPGP to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil-epgp/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCEPGP", "zhCN")
if not L then return end

-- Manually export from Curse here if you want to update the addon from Github, but not guarantee to be update-to-date.
--@debug@
L["announce_awards_desc2"] = [=[
RCLootCouncil-EPGP: #diffgp# 指代玩家从物品获取的GP量. #ep# 指代玩家的EP值. #gp# 指代玩家获取物品前的GP值. #pr# 指代玩家获取物品前的PR值. #newgp# 指代玩家获取物品后的GP值. #newpr# 指代玩家获取物品后的PR值.]=]
L["announce_formula_runtime_error"] = "你的GP公式含有运行时错误.出错时会使用默认公式."
L["Award GP (Default: %s)"] = "奖励GP （默认： %s)"
L["Bidding"] = "竞标"
L["bidding_desc"] = "玩家可以在RCLootCouncil弹窗中向战利品分配者发送以整数开始的备注以告知竞标出价."
L["chat_commands"] = "- epgp     - 打开RCLootCouncil-EPGP配置界面"
L["Credit GP to %s"] = "给 %s 增加GP"
L["Custom GP"] = "自定义GP"
L["customGP_desc"] = "自定义GP使你可以为每件装备定义自己的GP规则. 你需要为此定义计算GP值的公式. 你可以选择禁用此功能，以EPGP(dkp reloaded)的默认方式计算EP值"
L["disable_gp_popup"] = "GP弹窗被RCLootCouncil - EPGP自动禁用."
L["Enable Bidding"] = "开启竞标"
L["enable_custom_gp"] = "启用自定义GP"
L["EPGP_DKP_Reloaded_settings_received"] = "通过'/rc sync'收到了EPGP(dkp reloaded)的设置."
L["error_no_target"] = "错误. 你没有目标."
L["General"] = "常规"
L["GP Bid"] = "GP出价"
L["gp_formula"] = "GP公式"
L["gp_formula_help"] = "在下面的输入框输入返回GP值的LUA代码.\\n如果输入是单行语句, 例如 'a and b or c', 无需return语句.\\n如果有任何控制语句, 则需要return语句.\\n以下是代码中可用的变量."
L["gp_formula_syntax_error"] = "公式有语法错误. 将使用默认公式."
L["gp_value_help"] = [=[例:
100%: 使用100%GP值
50%: 使用50%GP值
25: 所有物品价值25GP]=]
L["gp_variable_equipLoc_help"] = "字符串. 代表栏位的非本地化字符串. 如果可能,建议使用变量slotWeights代替."
L["gp_variable_hasAvoid_help"] = "整数. 1如果物品带有闪避,否则为0."
L["gp_variable_hasIndes_help"] = "整数. 1如果物品永不磨损,否则为0."
L["gp_variable_hasLeech_help"] = "整数. 1如果物品带有吸血,否则为0."
L["gp_variable_hasSpeed_help"] = "整数. 1如果物品带有加速,否则为0."
L["gp_variable_ilvl_help"] = "整数.物品的装备等级或者是套装代币的基础装等"
L["gp_variable_isHeroic_help"] = "整数. 1如果物品来自英雄难度,否则为0."
L["gp_variable_isMythic_help"] = "整数. 1如果物品来自史诗难度,否则为0."
L["gp_variable_isNormal_help"] = "整数. 1如果物品来自普通难度,否则为0."
L["gp_variable_isTitanforged_help"] = "整数. 1如果物品泰坦造物,否则为0."
L["gp_variable_isToken_help"] = "整数. 1如果物品是套装代币,否则为0."
L["gp_variable_isWarforged_help"] = "整数. 1如果物品战火,否则为0."
L["gp_variable_itemID_help"] = "整数. 物品的ID."
L["gp_variable_link_help"] = "字符串. 物品的完整链接."
L["gp_variable_numSocket_help"] = "整数. 物品里插槽的数量."
L["gp_variable_rarity_help"] = "整数. 物品的稀有度. 3-稀有,4-史诗,5-传说."
L["gp_variable_slotWeights_help"] = "数字. 物品的栏位权重."
L["gpOptions"] = "回应的GP百分比"
L["gpOptionsButton"] = "打开配置回应的GP百分比的选项"
L["Input must be a number."] = "输入必须为数字."
L["need_restart_notification"] = "RCLootCouncil-EPGP v%s更新需要重启游戏客户端. 插件的某些功能无法正常使用直到游戏客户端重启."
L["new_version_detected"] = "你的版本%s已过期. 检测到新版本%s. 你可以从Curse.com或者Twitch客户端更新此插件."
L["no_permission_to_edit_officer_note"] = "你无权修改官员备注"
L["rc_version_below_min_notification"] = "此版本的RCLootCouncil-EPGP要求RCLootCouncil v%s+. 你的RCLootCouncil的版本为v%s. 请更新RCLootCouncil."
L["RCEPGP_desc"] = "一个给RCLootCouncil添加了EPGP支持与自定义的插件. 作者: Safetee"
L["send_epgp_setting_desc"] = "如果被选中, '/rc sync'也会同步EPGP(dkp reloaded)的设置"
L["send_epgp_settings"] = "'/rc sync'也同步EPGP(dkp reloaded)的设置"
L["Setting Sync"] = "设置同步"
L["setting_reset_notification"] = "RCLootCouncil-EPGP v%s 重置了所有的设置. 如果有需要请重新配置."
L["slash_rc_command_failed"] = "操作失败. 请检查是否输入正确."
L["slash_rc_gp_help"] = "- gp name reason [amount]      - 向一名玩家奖励GP.  使用'/rc gp help'来查看命令的详细用法"
L["slash_rc_gp_help_detailed"] = [=[/rc gp name reason [amount]

向一名玩家奖励GP

|cffffd000name|r: 必须. 玩家角色的全名. 如果和你的服务器相同服务器名可省略. 你也可以用%p指代你自己，用%t指代你的目标.

|cffffd000reason|r: 必须. 奖励的原因. 这一般是物品的链接.

|cffffd000amount|r: 可选. 整数. 奖励的GP值. 如果省略, 将会奖励插件计算的GP值.]=]
L["slash_rc_undogp_help"] = "- undogp name [reason]       - 撤销对一名玩家最近的GP操作. 用'/rc undogp help'查看此命令的详细用法."
L["slash_rc_undogp_help_detailed"] = [=[/rc undogp name [reason]
撤销对一名玩家最近的GP操作

|cffffd000name|r: 必须. 撤销GP的玩家角色全名. 如果和你服务器相同，服务器名可省略. 你也可以用'%p'指代你自己, 用'%t'指代你的目标.

|cffffd000reason|r: 可选. 这一般为空或者为物品的链接. 如果为空，撤销最近的GP操作，否则撤销最近的原因与此相同的GP操作.]=]
L["slot_weights"] = "栏位权重"
L["Undo GP"] = "撤销GP"
--@end-debug@


--@localization(locale="zhCN", format="lua_additive_table", same-key-is-true=true)@
