local version = "2.0.0"
local tocVersion = GetAddOnMetadata("RCLootCouncil_EPGP", "Version")
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:NewModule("RCEPGP", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local GP = LibStub("LibGearPoints-1.2")
local LibDialog = LibStub("LibDialog-1.0")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")
RCEPGP.version = version

local ExtraUtilities = addon:GetModule("RCExtraUtilities", true) -- nil if ExtraUtilites not enabled.
local RCVotingFrame = addon:GetModule("RCVotingFrame")
local originalCols = {unpack(RCVotingFrame.scrollCols)}

local session = 1

local PREFIX = "RCLC_EPGP"

function RCEPGP:GetEPGPdb()
    if not addon:Getdb().epgp then
        addon:Getdb().epgp = {}
        self:SetDefaults()
    end
    return addon:Getdb().epgp
end

function RCEPGP:OnInitialize()
    self:Enable()
end

function RCEPGP.UpdateVotingFrame()
    RCVotingFrame:Update()
end

function RCEPGP:CompareVersion(v1, v2)
    local a1, b1, c1 = strsplit(".", v1)
    a1 = tonumber(a1 or 0); b1 = tonumber(b1 or 0); c1 = tonumber(c1 or 0)
    local a2, b2, c2 = strsplit(".", v2)
    a2 = tonumber(a2 or 0); b2 = tonumber(b2 or 0); c2 = tonumber(c2 or 0)
    if a1 < a2 then return -1 end
    if a1 > a2 then return 1 end
    if b1 < b2 then return -1 end
    if b1 > b2 then return 1 end
    if c1 < c2 then return -1 end
    if c1 > c2 then return 1 end
    return 0
end

function RCEPGP:OnEnable()
    EPGP.RegisterCallback(self, "StandingsChanged", RCEPGP.UpdateVotingFrame)

    addon:SecureHook(RCVotingFrame, "OnEnable", self.AddGPEditBox)
    -- v1.9 change: Prehook instead of posthook to fix wrong bid display
    self:Hook(RCVotingFrame, "SwitchSession", function(self, s) session = s; RCEPGP:UpdateGPEditbox(); end)
    self:AddRightClickMenu(_G["RCLootCouncil_VotingFrame_RightclickMenu"], RCVotingFrame.rightClickEntries, self.rightClickEntries)
    if ExtraUtilities then
        addon:SecureHook(ExtraUtilities, "SetupColumns", function() self:SetupColumns() end)
        addon:SecureHook(ExtraUtilities, "UpdateColumn", function() self:SetupColumns() end)
    end
    self:DisableGPPopup()
    self.EnableGPTooltip()
    self.DisablezhCNProfanityFilter()
    self:OptionsTable()
    self:AddGPOptions()
    self:AddChatCommand()
    self:AddAnnouncement()
    self:SetupColumns()

    local lastVersion = RCEPGP:GetEPGPdb().version
    if not lastVersion then lastVersion = "1.9.2" end
    self:SecureHook(RCLootCouncil, "UpdateDB", function() RCEPGP:GetEPGPdb().version = version end)

    if self:CompareVersion(lastVersion, "2.0.0") == -1 then
        self:UpdateAnnounceKeyword_v2_0_0()
    end
    if self:CompareVersion(tocVersion, "2.0.0") == -1 then
        self:ShowNeedRestartDialog(version)
    end
    RCEPGP:GetEPGPdb().version = version

    self:RegisterEvent("PLAYER_LOGIN", function() C_Timer.After(5, function() self:SendVersion("GUILD") end) end)
    self:RegisterEvent("GROUP_JOINED", function() C_Timer.After(5, function() self:SendVersion("RAID") end) end)

    self:RegisterComm(PREFIX)

    self:EPGPDkpReloadedSettingToRC()
    self:RCToEPGPDkpReloadedSetting()

    for _, entry in ipairs(RCVotingFrame.rightClickEntries[1]) do
        if entry.text == L["Award"] then
            entry.text = L["Award"].." (0 GP)"
        end
    end
end

function RCEPGP:UpdateGPEditbox()
    local lootTable = RCVotingFrame:GetLootTable()
    if lootTable then
        local t = lootTable[session]
        if t then
            local gp = GP:GetValue(t.link) or 0
            RCVotingFrame.frame.editbox:SetNumber(gp)
        end
    end
end


function RCEPGP:OnDisable()
    -- Reset cols
    RCVotingFrame.scrollCols = originalCols
end

function RCEPGP.DisablezhCNProfanityFilter()
    if GetLocale() == "zhCN" then
        SetCVar("profanityFilter", "0")
    end
end

-- We only want to disable GP popup of EPGP(dkp reloaded) when RCLootCouncil Voting Frame is opening.
-- Restore to previous setting of EPGP loot popup when Voting Frame closes.
local isDisablingEPGPPopup = false
local isEPGPPopupEnabled = false
function RCEPGP:DisableGPPopup()
    if EPGP and EPGP.GetModule then
        local loot = EPGP:GetModule("loot")
        if loot then
            self:SecureHook(RCVotingFrame, "Show", function()
                local loot = EPGP:GetModule("loot")
                if not isDisablingEPGPPopup then
                    isEPGPPopupEnabled = loot.db.profile.enabled
                end
                loot.db.profile.enabled = false
                loot:Disable()
                isDisablingEPGPPopup = true
            end)

            self:SecureHook(RCVotingFrame, "Hide", function()
                C_Timer.After(5, function() -- Delay it because loot event may be triggered slight after Session ends.
                    local loot = EPGP:GetModule("loot")
                    loot.db.profile.enabled = isEPGPPopupEnabled
                    if isEPGPPopupEnabled then
                        loot:Enable()
                    else
                        loot:Disable()
                    end
                    isDisablingEPGPPopup = false
                end)
            end)
        end
    end
end

function RCEPGP.EnableGPTooltip()
    if EPGP and EPGP.GetModule then
        local gptooltip = EPGP:GetModule("gptooltip")
        if gptooltip and gptooltip.db then
            gptooltip.db.profile.enabled = true
        end
        if gptooltip and gptooltip.Enable then
            gptooltip:Enable()
        end
    end
end

local function RemoveColumn(t, column)
    for i = 1, #t do
        if t[i] and t[i].colName == column.colName then
            table.remove(t, i)
        end
    end
end

local function ReinsertColumnAtTheEnd(t, column)
    RemoveColumn(t, column)
    table.insert(t, column)
end

function RCEPGP:SetupColumns()
    local ep =
    { name = "EP", DoCellUpdate = self.SetCellEP, colName = "ep", sortnext = self:GetScrollColIndexFromName("response"), width = 60, align = "CENTER", defaultsort = "dsc" }
    local gp =
    { name = "GP", DoCellUpdate = self.SetCellGP, colName = "gp", sortnext = self:GetScrollColIndexFromName("response"), width = 50, align = "CENTER", defaultsort = "dsc" }
    local pr =
    { name = "PR", DoCellUpdate = self.SetCellPR, colName = "pr", width = 50, align = "CENTER", comparesort = self.PRSort, defaultsort = "dsc" }
    local bid =
    { name = "Bid", DoCellUpdate = self.SetCellBid, colName = "bid", sortnext = self:GetScrollColIndexFromName("response"), width = 50, align = "CENTER",
    defaultsort = "dsc" }

    ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, ep)
    ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, gp)
    ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, pr)

    if self:GetEPGPdb().biddingEnabled then
        ReinsertColumnAtTheEnd(RCVotingFrame.scrollCols, bid)
    else
        RemoveColumn(RCVotingFrame.scrollCols, bid)
    end

    RCEPGP:ResponseSortPRNext()

    if RCVotingFrame.frame then
        RCVotingFrame.frame.UpdateSt()
    end
end

function RCEPGP:GetScrollColIndexFromName(colName)
    for i, v in ipairs(RCVotingFrame.scrollCols) do
        if v.colName == colName then
            return i
        end
    end
end

function RCEPGP:ResponseSortPRNext()
    local responseIdx = self:GetScrollColIndexFromName("response")
    local prIdx = self:GetScrollColIndexFromName("pr")
    if responseIdx then
        RCVotingFrame.scrollCols[responseIdx].sortnext = prIdx
    end
end

---------------------------------------------
-- Lib-st UI functions
---------------------------------------------

-- Uppercase the first character of the string and lowercase the rest of characters.
-- Str can contain unicode characters.
local function UpperFirstLowerRest(str)
    local isFirstChar = true
    local result = ""

    for c in str:gmatch(".[\128-\191]*") do -- string can contains unicode characters.
        --https://stackoverflow.com/questions/22129516/string-sub-issue-with-non-english-characters
        if isFirstChar then
            isFirstChar = false
            result = result..c:upper()
        else
            result = result..c:lower()
        end
    end
    return result
end

-- Trying to fix some issue where RCLootCouncil handles some names differently with EPGP
-- EPGP requires fullname (name-realm) with the correct capitialization,
-- and realm name cannot contain space.
function RCEPGP:GetEPGPName(inputName)
    if not inputName then return nil end

    --------- First try to find name in the raid ------------------------------
    local name = Ambiguate(inputName, "short") -- Convert to short name to be used as the argument to UnitFullName
    local _, ourRealmName = UnitFullName("player") -- Get the name of our realm WITHOUT SPACE.

    local name, realm = UnitFullName(name) -- In order to return a name with correct capitialization, and the realm name WITHOUT SPACE.
    if name then -- Found the name in the raid
        if realm and realm ~= "" then
            return name.."-"..realm
        else
            return name.."-"..ourRealmName
        end
    else -- Name not found in raid, fix capitialiation and space in realm name manually.
        local shortName, realmName = strsplit("-", inputName)
        local shortName = UpperFirstLowerRest(shortName)
        realmName = realmName:gsub(" ", "") -- Eliminate space in the name
        return shortName.."-"..realmName
    end
end

local COLOR_RED = "|cFFFF0000"
local COLOR_GREY = "|cFF808080"

function RCEPGP.SetCellEP(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local name = data[realrow].name
    name = RCEPGP:GetEPGPName(name)
    local ep, gp, main = EPGP:GetEPGP(name)
    if not ep then
        frame.text:SetText(COLOR_RED.."?")
    elseif ep >= EPGP.db.profile.min_ep then
        frame.text:SetText(COLOR_GREY..ep)
    else
        frame.text:SetText(COLOR_RED..ep)
    end
    data[realrow].cols[column].value = ep or 0
end

function RCEPGP.SetCellGP(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local name = data[realrow].name
    name = RCEPGP:GetEPGPName(name)
    local ep, gp, main = EPGP:GetEPGP(name)
    if not gp then
        frame.text:SetText(COLOR_GREY.."?")
    else
        frame.text:SetText(COLOR_GREY..gp)
    end
    data[realrow].cols[column].value = gp or 0
end

function RCEPGP.SetCellPR(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local name = data[realrow].name
    name = RCEPGP:GetEPGPName(name)
    local ep, gp, main = EPGP:GetEPGP(name)
    local pr
    if ep and gp then
        pr = ep / gp
    end

    if not pr then
        frame.text:SetText("?")
    else
        frame.text:SetText(string.format("%.4g", pr))
    end

    data[realrow].cols[column].value = pr or 0
end

function RCEPGP:GetBid(name)
    local lootTable = RCVotingFrame:GetLootTable()

    -- nil protection
    if session and name and lootTable and lootTable[session]
    and lootTable[session].candidates and lootTable[session].candidates[name] then
        local note = lootTable[session].candidates[name].note
        if note then
            local bid = tonumber(string.match(note, "[0-9]+"))
            return bid
        end
    end
end

function RCEPGP.SetCellBid(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
    local name = data[realrow].name
    local bid = RCEPGP:GetBid(name)
    if bid then
        frame.text:SetText(tostring(bid))
        data[realrow].cols[column].value = bid
    else
        data[realrow].cols[column].value = 0
        frame.text:SetText("")
    end
end

function RCEPGP.PRSort(table, rowa, rowb, sortbycol)
    local column = table.cols[sortbycol]
    local a, b = table:GetRow(rowa), table:GetRow(rowb);
    -- Extract the rank index from the name, fallback to 100 if not found

    local nameA = RCEPGP:GetEPGPName(a.name)
    local nameB = RCEPGP:GetEPGPName(b.name)

    local a_ep, a_gp = EPGP:GetEPGP(nameA)
    local b_ep, b_gp = EPGP:GetEPGP(nameB)

    if (not a_ep) or (not a_gp) then
        return false
    elseif (not b_ep) or (not b_gp) then
        return true
    end

    local a_pr = a_ep / a_gp
    local b_pr = b_ep / b_gp

    local a_qualifies = a_ep >= EPGP.db.profile.min_ep
    local b_qualifies = b_ep >= EPGP.db.profile.min_ep

    if a_qualifies == b_qualifies and a_pr == b_pr then
        if column.sortnext then
            local nextcol = table.cols[column.sortnext];
            if nextcol and not(nextcol.sort) then
                if nextcol.comparesort then
                    return nextcol.comparesort(table, rowa, rowb, column.sortnext);
                else
                    return table:CompareSort(rowa, rowb, column.sortnext);
                end
            end
        end
        return false
    else
        local direction = column.sort or column.defaultsort or "dsc";
        if direction:lower() == "asc" then
            if a_qualifies == b_qualifies then
                return a_pr < b_pr
            else
                return b_qualifies
            end
        else
            if a_qualifies == b_qualifies then
                return a_pr > b_pr
            else
                return a_qualifies
            end
        end
    end
end

----------------------------------------------------------------
function RCEPGP.AddGPEditBox()
    if not RCVotingFrame.frame.gpString then
        local gpstr = RCVotingFrame.frame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        gpstr:SetPoint("CENTER", RCVotingFrame.frame.content, "TOPLEFT", 300, - 60)
        gpstr:SetText("GP: ")
        gpstr:Show()
        gpstr:SetTextColor(1, 1, 0, 1) -- Yellow
        RCVotingFrame.frame.gpString = gpstr
    end


    local editbox_name = "RCLootCouncil_GP_EditBox"
    if not RCVotingFrame.frame.editbox then
        local editbox = _G.CreateFrame("EditBox", editbox_name, RCVotingFrame.frame.content, "AutoCompleteEditBoxTemplate")
        editbox:SetWidth(40)
        editbox:SetHeight(32)
        editbox:SetFontObject("ChatFontNormal")
        editbox:SetNumeric(true)
        editbox:SetMaxLetters(5)
        editbox:SetAutoFocus(false)

        local left = editbox:CreateTexture(("%sLeft"):format(editbox_name), "BACKGROUND")
        left:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Left2]])
        left:SetWidth(8)
        left:SetHeight(32)
        left:SetPoint("LEFT", -5, 0)

        local right = editbox:CreateTexture(("%sRight"):format(editbox_name), "BACKGROUND")
        right:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Right2]])
        right:SetWidth(8)
        right:SetHeight(32)
        right:SetPoint("RIGHT", 5, 0)

        local mid = editbox:CreateTexture(("%sMid"):format(editbox_name), "BACKGROUND")
        mid:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Mid2]])
        mid:SetHeight(32)
        mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
        mid:SetPoint("TOPRIGHT", right, "TOPLEFT", 0, 0)

        --local label = editbox:CreateFontString(editbox_name, "ARTWORK", "GameFontNormalSmall")
        --label:SetPoint("RIGHT", editbox, "LEFT", - 15, 0)
        --label:Show()
        editbox.left = left
        editbox.right = right
        editbox.mid = mid
        --editbox.label = label

        editbox:SetPoint("LEFT", RCVotingFrame.frame.gpString, "RIGHT", 10, 0)
        editbox:Show()

        -- Auto release Focus after 3s editbox is not used
        local loseFocusTime = 3
        editbox:SetScript("OnEditFocusGained", function(self, userInput) self.lastUsedTime = GetTime() end)
        editbox:SetScript("OnTextChanged", function(self, userInput) RCVotingFrame:Update(); self.lastUsedTime = GetTime() end)
        editbox:SetScript("OnUpdate", function(self, elapsed)
            if self.lastUsedTime and GetTime() - self.lastUsedTime > loseFocusTime then
                self.lastUsedTime = nil
                if editbox:HasFocus() then
                    editbox:ClearFocus()
                end
            end
        end)
        if not RCEPGP:IsHooked(_G["Lib_DropDownList1"], "OnShow") then
            RCEPGP:SecureHookScript(_G["Lib_DropDownList1"], "OnShow", function()
                if RCVotingFrame.frame and RCVotingFrame.frame.editbox then
                    RCVotingFrame.frame.editbox:ClearFocus()
                end
            end)
        end
        RCVotingFrame.frame.editbox = editbox
    end
end

-- "response" needs to be the response id(Number), or the button name(not response name)
function RCEPGP:GetResponseGP(response, isTier)
    if response == "PASS" or response == "AUTOPASS" then
        return "0%"
    end
    local responseGP = "100%"

    if isTier then
        for k, v in pairs(addon.db.profile.tierButtons) do
            if v.text == response then
                responseGP = v.gp or responseGP
                break
            elseif k == response then
                responseGP = v.gp or responseGP
                break
            end
        end
    else
        for k, v in pairs(addon.db.profile.responses) do
            if v.text == response then
                responseGP = v.gp or responseGP
                break
            elseif k == response then
                responseGP = v.gp or responseGP
                break
            end
        end
    end
    return responseGP
end

-- responseGP: string. example: "100%", "1524"
-- itemGP: Integer. The gear point of the item
-- Return: return type is always integer
-- If responseGP is percentage, return responseGP*itemGP, else return responseGP
function RCEPGP:GetFinalGP(responseGP, itemGP)
    local gp
    if string.match(responseGP, "^%d+$") then
        gp = tonumber(responseGP)
    else -- responseGP is percentage like 55%
        local coeff = tonumber(string.match(responseGP, "%d+"))/100
        gp = math.floor(coeff * itemGP)
    end
    return gp
end

-- Add button attributes "RCEPGP_dynamicText", "RCEPGP_dynamicDisabled", "RCEPGP_dynamicArg"
-- dynamicExist: [func] if return false, this button does not exist.
-- dynamicText: [func] Set the text of this button every frame to be the return value of the function
-- dynamicDisabled: [func] Disable or Enable the button every frame. Disable if returns true.
-- dynamicArg: The argument to the above function.
local lastHookedLib_UIDropDownMenu_AddButton = nil
function RCEPGP:AddRightClickMenu(menu, RCEntries, myEntries)

    local rehookFrame = _G["RCEPGP_Rehook_AddButton"] or CreateFrame("FRAME", "RCEPGP_Rehook_AddButton")
    -- Keep to rehook because other addon can modify Lib_UIDropDownMenu_AddButton
    rehookFrame:SetScript("OnUpdate", function()
        if lastHookedLib_UIDropDownMenu_AddButton ~= Lib_UIDropDownMenu_AddButton then
            self:Unhook("Lib_UIDropDownMenu_AddButton")
            self:SecureHook("Lib_UIDropDownMenu_AddButton", function(info, level)
                if ( not level ) then
                    level = 1;
                end
                local listFrame = _G["Lib_DropDownList"..level];
                local listFrameName = listFrame:GetName();
                local index = listFrame and (listFrame.numButtons) or 1;
                local button = _G[listFrameName.."Button"..index]
                if info.dynamicExist and (not info.dynamicExist()) then -- Remove button
                    listFrame.numButtons = listFrame.numButtons - 1
                    button.iconOnly = nil
                    button.icon = nil
                    button.iconInfo = nil;
                    button.func = nil
                    button.owner = nil
                    button.hasOpacity = nil
                    button.opacity = nil
                    button.opacityFunc = nil
                    button.cancelFunc = nil
                    button.swatchFunc = nil
                    button.keepShownOnClick = nil
                    button.tooltipTitle = nil
                    button.tooltipText = nil
                    button.arg1 = nil
                    button.arg2 = nil
                    button.hasArrow = nil
                    button.hasColorSwatch = nil
                    button.notCheckable = nil
                    button.menuList = nil
                    button.tooltipWhileDisabled = nil
                    button.tooltipOnButton = nil
                    button.noClickSound = nil
                    button.padding = nil
                    button.dynamicText = nil
                    button.dynamicDisabled = nil
                    button.dynamicArg = nil
                    button:SetText("")
                elseif button then
                    button.dynamicText = info.dynamicText
                    button.dynamicDisabled = info.dynamicDisabled
                    button.dynamicArg = info.dynamicArg
                end
            end)
            lastHookedLib_UIDropDownMenu_AddButton = Lib_UIDropDownMenu_AddButton
        end
    end)

    for level, entries in ipairs(myEntries) do
        table.sort(entries, function(i, j) return i.pos < j.pos end)
        for id=1, #entries do
            local entry = entries[id]
            entry.dynamicArg = menu
            table.insert(RCEntries[level], entry.pos, entry)
        end

        local updateInterval = 0.5
        local lastUpdateTime = nil
        self:SecureHookScript(menu, "OnUpdate", function()
            if lastUpdateTime and GetTime() - lastUpdateTime < updateInterval then return end
            if Lib_UIDropDownMenu_GetCurrentDropDown() ~= menu then return end
            if not Lib_DropDownList1:IsShown() then
                lastUpdateTime = nil
                return
            end
            lastUpdateTime = GetTime()

            for level = 1, 4 do
                local dynamicTextChanged = false
                for i = 1, LIB_UIDROPDOWNMENU_MAXBUTTONS do
                    local button = _G["Lib_DropDownList"..level.."Button"..i]
                    if button then
                        if button.dynamicText then
                            local text = button.dynamicText(button.dynamicArg)
                            local oldText = button:GetText()
                            if text ~= oldText then
                                dynamicTextChanged = true
                            end
                            if button.colorCode then
                                button:SetText(button.colorCode..text.."|r")
                            else
                                button:SetText(text);
                            end
                        end
                        if button.dynamicDisabled then
                            local disabled = button.dynamicDisabled(button.dynamicArg)
                            if disabled then
                                button:Disable()
                            else
                                button:Enable()
                            end
                        end
                    end
                    if dynamicTextChanged then -- For performance reason
                        menu.noResize = false
                        Lib_UIDropDownMenu_Refresh(menu, nil, level)
                    end
                end
            end
        end)
    end
end

local function GetGPInfo(name)
    local lootTable = RCVotingFrame:GetLootTable()
    if lootTable and lootTable[session] and lootTable[session].candidates
    and name and lootTable[session].candidates[name] then
        local data = lootTable[session].candidates[name]
        local responseGP = RCEPGP:GetResponseGP(data.response, data.isTier)
        local editboxGP = RCVotingFrame.frame.editbox:GetNumber()
        local gp = RCEPGP:GetFinalGP(responseGP, editboxGP)
        local item = lootTable[session].link
        local bid = RCEPGP:GetBid(name)
        return data, name, item, responseGP, gp, bid
    else -- Error occurs
        return nil, "UNKNOWN", "UNKNOWN", "UNKNOWN", 0, 0 -- nil protection
    end
end

RCEPGP.rightClickEntries = {
    { -- Level 1
        { -- Button 1
            pos = 2,
            dynamicExist = function() return RCEPGP:GetEPGPdb().biddingEnabled end,
            notCheckable = true,
            func = function(name)
                local data, name, item, responseGP, gp, bid = GetGPInfo(name)
                if not data then return end
                LibDialog:Spawn("RCEPGP_CONFIRM_AWARD", {
                    session,
                    name,
                    data.response,
                    nil,
                    data.votes,
                    data.gear1,
                    data.gear2,
                    data.isTier,
                    bid,
                    responseGP
                })
            end,
            dynamicText = function(menu)
                local data, name, item, responseGP, gp, bid = GetGPInfo(menu.name)
                if not bid then bid = "?" end
                return L["Award"].." ("..bid.." "..LEP["GP Bid"]..")"
            end,
            dynamicDisabled = function(menu)
                local data, name, item, responseGP, gp, bid = GetGPInfo(menu.name)
                return not bid
            end,
        },
        { -- Button 2
        pos = 3,
        notCheckable = true,
        func = function(name)
            local data, name, item, responseGP, gp, bid = GetGPInfo(name)
            if not data then return end
            LibDialog:Spawn("RCEPGP_CONFIRM_AWARD", {
                session,
                name,
                data.response,
                nil,
                data.votes,
                data.gear1,
                data.gear2,
                data.isTier,
                gp,
                responseGP
            })
        end,
        dynamicText = function(menu)
            local data, name, item, responseGP, gp, bid = GetGPInfo(menu.name)
            local text = L["Award"].." ("..gp.." GP)"
            if string.match(responseGP, "^%d+%%") then
                text = L["Award"].." ("..gp.." GP, "..responseGP..")"
            end
            return text
        end,
        dynamicDisabled = function(menu)
            local data, name, item, responseGP, gp, bid = GetGPInfo(menu.name)
            return (not EPGP:CanIncGPBy(item, gp)) and gp and (gp ~= 0)
        end,
        },
    },
}

local currentAwardingGP = 0 -- Record it for annoucement of the new GP and new PR value.

function RCEPGP:GetCurrentAwardingGP()
    return currentAwardingGP
end

LibDialog:Register("RCEPGP_CONFIRM_AWARD", {
    text = "something_went_wrong",
    icon = "",
    on_show = function(self, data)
        local session, player, response, reason, votes, item1, item2, isTierRoll, gp, responseGP = unpack(data, 1, 10)
        self:SetFrameStrata("FULLSCREEN")
        local session, player = unpack(data)
        self.text:SetText(format(L["Are you sure you want to give #item to #player?"].." ("..gp.." GP)", RCLootCouncilML.lootTable[session].link, addon.Ambiguate(player)))
        if string.match(responseGP, "^%d+%%") then
            self.text:SetText(format(L["Are you sure you want to give #item to #player?"].." ("..gp.." GP, "..responseGP.."%"..")", RCLootCouncilML.lootTable[session].link, addon.Ambiguate(player)))
        end
        self.icon:SetTexture(RCLootCouncilML.lootTable[session].texture)
    end,
    buttons = {
        { text = L["Yes"],
            on_click = function(self, data)
                -- IDEA Perhaps come up with a better way of handling this
                local session, player, response, reason, votes, item1, item2, isTierRoll, gp, responseGP = unpack(data, 1, 9)
                currentAwardingGP = gp -- This varible to be used in announcement
                local item = RCLootCouncilML.lootTable[session].link -- Store it now as we wipe lootTable after Award()
                local isToken = RCLootCouncilML.lootTable[session].token
                local awarded = RCLootCouncilML:Award(session, player, response, reason, isTierRoll)
                if awarded then -- log it
                    RCLootCouncilML:TrackAndLogLoot(player, item, response, addon.target, votes, item1, item2, reason, isToken, isTierRoll)
                    if gp and gp ~= 0 then
                        EPGP:IncGPBy(RCEPGP:GetEPGPName(player), item, gp)
                    end
                end
                -- We need to delay the test mode disabling so comms have a chance to be send first!
                if addon.testMode and RCLootCouncilML:HasAllItemsBeenAwarded() then RCLootCouncilML:EndSession() end
                currentAwardingGP = 0
            end,
        },
        { text = L["No"],
        },
    },
    hide_on_escape = true,
    show_while_dead = true,
})

function RCEPGP:AddChatCommand()
    addon:CustomChatCmd(self, "OpenOptions", LEP["chat_commands"], "EPGP", "epgp")
end

function RCEPGP:AddAnnouncement()
    if RCLootCouncilML.awardStrings then -- Requires RCLootCouncil v2.5
        local function GetEPGPInfo(name)
            name = self:GetEPGPName(name)
            local ep = "?"
            local gp = "?"
            local pr = "?"
            local newgp = "?"
            local newpr = "?"
            ep, gp = EPGP:GetEPGP(name)
            if ep and gp then
                pr = string.format("%.4g", ep / gp)
            end

            if ep and gp then
                newgp = math.floor(gp + self:GetCurrentAwardingGP() + 0.5)
                newpr = string.format("%.4g", ep / newgp)
            end

            if not ep then ep = "?" end
            if not gp then gp = "?" end

            return ep, gp, pr, newgp, newpr
        end

        RCLootCouncilML.awardStrings['#diffgp#'] = function(name) return self:GetCurrentAwardingGP() end
        RCLootCouncilML.awardStrings['#ep#'] = function(name) return select(1, GetEPGPInfo(name)) end
        RCLootCouncilML.awardStrings['#gp#'] = function(name) return select(2, GetEPGPInfo(name)) end
        RCLootCouncilML.awardStrings['#pr#'] = function(name) return select(3, GetEPGPInfo(name)) end
        RCLootCouncilML.awardStrings['#newgp#'] = function(name) return select(4, GetEPGPInfo(name)) end
        RCLootCouncilML.awardStrings['#newpr#'] = function(name) return select(5, GetEPGPInfo(name)) end

        L["announce_awards_desc2"] = L["announce_awards_desc2"].." "..LEP["announce_awards_desc2"]
        addon.options.args.mlSettings.args.announcementsTab.args.awardAnnouncement.args.outputDesc.name = L["announce_awards_desc2"]

    end
end

function RCEPGP:UpdateAnnounceKeyword_v2_0_0()
    for i=1, #addon:Getdb().awardText do
        local text = addon:Getdb().awardText[i].text
        if text then
            if not text:find('#diffgp#') then text = text:gsub('#diffgp', '#diffgp#') end
            if not text:find('#ep#') then text = text:gsub('#ep', '#ep#') end
            if not text:find('#gp#') then text = text:gsub('#gp', '#gp#') end
            if not text:find('#pr#') then text = text:gsub('#pr', '#pr#') end
            if not text:find('#newgp#') then text = text:gsub('#newgp', '#newgp#') end
            if not text:find('#newpr#') then text = text:gsub('#newpr', '#newpr#') end
            addon:Getdb().awardText[i].text = text
        end
    end
end

function RCEPGP:SendVersion(channel)
    print("SendVersion")
    if not IsInGuild() and channel == "GUILD" then return end
    if not IsInGroup() and (channel == "RAID" or channel == "PARTY") then return end
    local serializedMsg = self:Serialize("version", RCEPGP.version)
    local _, a, b = self:Deserialize(serializedMsg)
    print(a)
    print(b)
    self:SendCommMessage(PREFIX, serializedMsg, "GUILD", "")
end

local newestVersionDetected = RCEPGP.version
function RCEPGP:OnCommReceived(prefix, serializedMsg, distri, sender)
    local test, command, data = self:Deserialize(serializedMsg)
    if test then
        if command == "version" then
            local otherVersion = data
            if self:CompareVersion(newestVersionDetected, otherVersion) == -1 then
                self:Print(string.format("New Version %s detected. Please update the addon.", otherVersion))
                newestVersionDetected = otherVersion
            end
        end
    end
end

function RCEPGP:ShowNeedRestartDialog()
    StaticPopupDialogs["RCEPGP_NEED_RESTART"] = {
        text = "RCLootCouncil-EPGP v%s update requires full restart of the client. Some features of the addon don't work until client restarts.",
        button1 = "I'll restart the client.",
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show ("RCEPGP_NEED_RESTART", version)
end

function RCEPGP:EPGPDkpReloadedSettingToRC()
    self:GetEPGPdb().EPGPDkpReloadedDB = {}
    self:GetEPGPdb().EPGPDkpReloadedDB.children = {}
    if EPGP.db and EPGP.db.children then
        for module, entry in pairs(EPGP.db.children) do
            if module ~= "log" then -- Not gonna sync "log" module because it is too big. Probably will sync it with RCHistory Later.
                self:GetEPGPdb().EPGPDkpReloadedDB.children[module] = {}
                -- link the table to the table of EPGP settings.
                self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile = EPGP.db.children[module].profile
            end
        end
    end
end

function RCEPGP:RCToEPGPDkpReloadedSetting()
    if self:GetEPGPdb().EPGPDkpReloadedDB and self:GetEPGPdb().EPGPDkpReloadedDB.children then
        for module, entry in pairs(self:GetEPGPdb().EPGPDkpReloadedDB.children) do
            if self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile then
                for key, value in pairs(self:GetEPGPdb().EPGPDkpReloadedDB.children[module].profile) do
                    EPGP.db.children[module].profile[key] = value
                end
            end
        end
    end
    RCEPGP:EPGPDkpReloadedSettingToRC()
end
