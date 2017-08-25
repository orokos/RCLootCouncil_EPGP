-- Translate RCLootCouncil - EPGP to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil-epgp/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCEPGP", "ruRU")
if not L then return end

L["enable_custom_gp"] = "Включить пользовательское значение GP"
L["formula_help"] = "Введите LUA код, который возвращает значение GP в поле ниже. Вы можете использовать следующие переменные."
L["formula_syntax_error"] = "Формула содержит синтаксическую ошибку. Вместо нее будет использована формула по умолчанию."
L["gp_formula"] = "Формула GP"
L["gp_value_help"] = [=[Пример:
100%: использовать 100% от обычного значения GP
50%: использовать 50% от обычного значения GP
25: все вещи стоят 25 GP]=]
L["Input must be a number."] = "Значение должно быть числом."
L["restore_default"] = "Вернуть по умолчанию"
L["slot_weights"] = "Вес слотов"
L["variable_equipLoc_help"] = "Строка. Не локализованная строка с названием слота экипировки. Рекомендуется использовать переменную \"slotWeights\" вместо нее"
L["variable_hasAvoid_help"] = "Целочисленное значение. 1 - если на предмете есть избегание, 0 в противном случае."
L["variable_hasIndes_help"] = "Целочисленное значение. 1 - если предмет не теряет прочности, 0 в противном случае."
L["variable_hasLeech_help"] = "Целочисленное значение. 1 - если на предмете есть самоисцеление, 0 в противном случае."
L["variable_hasSpeed_help"] = "Целочисленное значение. 1 - если предмет c дополнительной скоростью передвижения, 0 в противном случае."
L["variable_ilvl_help"] = "Целочисленное значение. Уровень предмета или базовый ilvl токена."
L["variable_isToken_help"] = "Целочисленное значение. 1 - если это тировый токен, 0 в противном случае."
L["variable_itemID_help"] = "Целочисленное значение. Id предмета."
L["variable_numSocket_help"] = "Целочисленное значение. Количество гнезд в предмете."
L["variable_rarity_help"] = "Целочисленное значение. Редкость предмета. 3-редкий, 4-эпический, 5-легендарный"
L["variable_slotWeights_help"] = "Число. Вес предмета в зависимости от слота экипировки."
L["disable_gp_popup"] = "Всплывающее окно GP автоматически отключается с помощью RCLootCouncil - EPGP."
L["GP Bid"] = "ставку GP"
L["Custom GP"] = "пользовательское значение GP"
L["Enable Bidding"] = "разрешать ставки"
L["Bidding"] = "ставки"

-- Need translation
--L["bidding_desc"] = "Player can send bid price to the loot master by sending a note that starts with integer."
L["Credit GP to %s"] = "Начислить GP для игрока %s"
L["Undo GP"] = "Отменить GP"

-- Need translation
--L["Award GP (Default: %s)"]
--L["variable_link_help"] 

