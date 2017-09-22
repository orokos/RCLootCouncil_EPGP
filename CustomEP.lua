local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomEP = RCEPGP:NewModule("RCCustomEP", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local LibSpec = LibStub("LibGroupInSpecT-1.1")

local isInGuild = {}
local allInfos = {} -- not including calendar infos.
local calendarInfos = {}


RCCustomEP.inputName = ""
RCCustomEP.inputEPAmount = 0

RCCustomEP.MaxFormulas = 100

RCCustomEP.EPVariables = {
    {name = "isOnline", help = LEP["variable_isOnline_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "online") and 1 or 0 end, },
    {name = "guildName", help = LEP["variable_guildName_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "guildName") or "UNKNOWN" end, },
    {name = "zone", help = LEP["variable_zone_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "zone") or "UNKNOWN" end, },
    {name = "zoneId", help = LEP["variable_zoneId_help"], value = function(name) return RCCustomEP:GetMapIDByName(RCCustomEP:GetUnitInfo(name, "zone") or "UNKNOWN") end, },
    {name = "isInRaid", help = LEP["variable_isInRaid_help"], value = function(name) return (name and UnitInRaid(Ambiguate(name, "short"))) and 1 or 0 end, },
    {name = "isStandby", help = LEP["variable_isStandby_help"], value = function(name) return (name and EPGP:IsMemberInExtrasList(name)) and 1 or 0 end, },
    {name = "isMain", help = LEP["variable_isMain_help"], value = function(name) return RCCustomEP.IsMain(name) and 1 or 0 end, },
    {name = "isMaxLevel", help = LEP["variable_isMaxLevel_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "level") == GetMaxPlayerLevel() and 1 or 0 end, },
    {name = "rank", help = LEP["variable_rank_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "guildRankIndex") or 10 end, },
    {name = "isTank", help = LEP["variable_isTank_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "role") == "TANK" and 1 or 0 end},
    {name = "isHealer", help = LEP["variable_isHealer_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "role") == "HEALER" and 1 or 0 end},
    {name = "isDPS", help = LEP["variable_isDPS_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "role") == "DAMAGER" and 1 or 0 end},
    {name = "isMeleeDPS", help = LEP["variable_isMeleeDPS_help"], value = function(name) return RCCustomEP:GetSpecRole(name) == "melee" and 1 or 0 end},
    {name = "isRangedDPS", help = LEP["variable_isRangedDPS_help"], value = function(name) return RCCustomEP:GetSpecRole(name) == "ranged" and 1 or 0 end},
    {name = "level", help = LEP["variable_level_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "level") or 1 end,},
    {name = "class", help = LEP["variable_class_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "class") or "UNKNOWN" end,},
    {name = "ep", help = LEP["variable_ep_help"], value = function(name) return select(1, EPGP:GetEPGP(name)) or 0 end, },
    {name = "gp", help = LEP["variable_gp_help"], value = function(name) return select(2, EPGP:GetEPGP(name)) or 0 end, },
    {name = "pr", help = LEP["variable_pr_help"], value = function(name) local ep, gp = EPGP:GetEPGP(name); if ep and gp then return ep/gp else return 0 end end, },
    {name = "isInputName", help = LEP["variable_isInputName_help"], value = function(name) return (name and name == RCCustomEP.inputName) and 1 or 0 end, },
}

-- isRank0, ..., isRank9
for i=0,9 do
    table.insert(RCCustomEP.EPVariables, {name = "isRank"..i, display_name = "isRank0, isRank1,..., isRank9", help = LEP["variable_isRankX_help"], value = function(name) return RCCustomEP:GetUnitInfo(name, "guildRankIndex") == i and 1 or 0 end, })
end

-- mainXXX variables
for i, entry in ipairs(RCCustomEP.EPVariables) do
    if (not entry.name:find("main")) then
        table.insert(RCCustomEP.EPVariables, {name = "main"..entry.name, display_name = "main", help = LEP["variable_main_prefix_help"], value = function(name) local _, _, main = EPGP:GetEPGP(name); main = main or name; return entry.value(main) end, })
    end
end

-- sameXXX variables
for i, entry in ipairs(RCCustomEP.EPVariables) do
    if (not entry.name:find("same")) then
        table.insert(RCCustomEP.EPVariables, {name = "same"..entry.name, display_name = "same", help = LEP["variable_same_prefix_help"], value = function(name) return entry.value(RCCustomEP:GetPlayerFullName()) == entry.value(main) and 1 or 0 end, })
    end
end

for i, entry in ipairs(RCCustomEP.EPVariables) do
    if (not entry.name:find("inputname")) then
        table.insert(RCCustomEP.EPVariables, {name = "inputname"..entry.name, display_name = "inputname", help = LEP["variable_inputname_prefix_help"], value = function() if not RCCustomEP.inputName then return 0 end; return entry.value(RCCustomEP.inputName) end, })
    end
end

table.insert(RCCustomEP.EPVariables, {name = "minep", help = LEP["variable_minep_help"], value = function() return EPGP.db.profile.min_ep end, })
table.insert(RCCustomEP.EPVariables, {name = "decay", help = LEP["variable_decay_help"], value = function() return EPGP.db.profile.decay_p end, }) -- Integer
table.insert(RCCustomEP.EPVariables, {name = "baseGP", help = LEP["variable_baseGP_help"], value = function() return EPGP.db.profile.base_gp end, })
table.insert(RCCustomEP.EPVariables, {name = "inputEPAmount", help = LEP["variable_inputEPAmount_help"], value = function() return RCCustomEP.inputEPAmount end, })

-- Special count function
table.insert(RCCustomEP.EPVariables, {name = "count", help = LEP["variable_count_help"], value = function(name, fenv) return function(formulaStr) return RCCustomEP.CountFunction(name, fenv, formulaStr) end end, })

-- CalendarCheckFunction
table.insert(RCCustomEP.EPVariables, {name = "calendarSignedUp", help = LEP["variable_calendarSignedUp_help"], value = function(name, fenv) return function(titleKeyword) return RCCustomEP.CalendarSignedUpFunction(name, fenv, titleKeyword) end end, })


RCCustomEP.allowedAPI = {
    "print", "strsplit", "strmatch", "math"
}

function RCCustomEP:GetEPFormulaFunc(indexOrName)
    local formulaStr
    if RCEPGP:GetEPGPdb().EPFormulas[indexOrName] then
        formulaStr = RCEPGP:GetEPGPdb().EPFormulas[indexOrName].formula
    elseif tonumber(indexOrName) and RCEPGP:GetEPGPdb().EPFormulas[tonumber(indexOrName)] then
        formulaStr = RCEPGP:GetEPGPdb().EPFormulas[tonumber(indexOrName)].formula
    end
    if not formulaStr then return nil end

    for i, entry in ipairs(RCEPGP:GetEPGPdb().EPFormulas) do
        if entry.name == indexOrName then
            formulaStr = entry.formula
        end
    end

    local func, err = loadstring("return "..formulaStr)
    if not func then
        func, err = loadstring(formulaStr)
    end
    return func, err
end

function RCCustomEP:GetFullName(name)
    local name2, realm = UnitFullName(Ambiguate(name, "short"))
    local _, ourRealmName = UnitFullName("player")
    if not realm then realm = ourRealmName end
    local fullName = name
    if name2 then
        fullName = name2.."-"..realm
    end
    return fullName
end

function RCCustomEP:OnInitialize()

    local oldChatCommand = RCLootCouncil.ChatCommand
    self:RawHook(addon, "ChatCommand", function(self, msg)
        local command, arg1, arg2, arg3, arg4, arg5, arg6 = self:GetArgs(msg, 7)

        if command == "massep" then
            -- /rc massep  [reason] [amount] [formulaIndexOrName] [inputName] [debug]
            if arg4 == "%t" then
                arg4 = RCCustomEP:GetFullName("target")
            end
            EPGP:IncMassEPBy(arg1, tonumber(arg2), arg3, arg4, arg5)
        elseif command == "recurep" then
            -- /rc massep [intervalMin] [reason] [amount] [formulaIndexOrName] [inputName] [debug]
            if arg5 == "%t" then
                arg5 = RCCustomEP:GetFullName("target")
            end
            if tonumber(arg1) then
                EPGP.db.profile.recurring_ep_period_mins = tonumber(arg1)
                EPGP:StartRecurringEP(arg2, tonumber(arg3), arg4, arg5, arg6)
            end
        elseif command == "stoprecur" then
            EPGP:StopRecurringEP()
        else
            oldChatCommand(self, msg)
        end
    end)
    self:RegisterEvent("GUILD_ROSTER_UPDATE")
    self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST", "UPDATE_CALENDAR")
    self:RegisterEvent("CALENDAR_OPEN_EVENT", "OPEN_CALENDAR")
    self:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST", "UPDATE_CALENDAR")
    GuildRoster()
    OpenCalendar()
    C_Timer.After(10, function() RCCustomEP:UPDATE_CALENDAR() end)
    LibSpec:Rescan()
end

function RCCustomEP:UPDATE_CALENDAR(nextIndex)
    if not nextIndex or type(nextIndex) ~= 'number' then nextIndex = 1 end
    if _G.CalendarFrame and (not self:IsHooked(_G.CalendarFrame, "OnHide")) then
        self:SecureHookScript(_G.CalendarFrame, "OnHide", function() RCCustomEP:UPDATE_CALENDAR(1) end)
    end
    if _G.CalendarFrame and _G.CalendarFrame:IsShown() then
        return -- Don't update when Blizzard calendar is shown
    end

    local weekday, month, day, year = CalendarGetDate()
    local existEvents = {}

    for i=1, CalendarGetNumDayEvents(0, day) do
        local title, hour, min, calendarType = CalendarGetDayEvent(0, day, i)
        if title and (calendarType == "PLAYER" or calendarType == "GUILD_EVENT") then
            existEvents[title] = true
        end
    end

    for title, _ in pairs(calendarInfos) do
        if (not existEvents[title]) and calendarInfos[title] then
            wipe(calendarInfos[title])
            calendarInfos[title] = nil
        end
    end

    for i=nextIndex, CalendarGetNumDayEvents(0, day) do
        local title, hour, min, calendarType = CalendarGetDayEvent(0, day, i)
        if title and (calendarType == "PLAYER" or calendarType == "GUILD_EVENT") then
            CalendarOpenEvent(0, day, i) -- handles the rest in OPEN_CALENDAR
            return
        end
    end
end

function RCCustomEP:OPEN_CALENDAR()
    if _G.CalendarFrame and _G.CalendarFrame:IsShown() then
        return -- Don't update when Blizzard calendar is shown
    end


    local title, description, creator, eventType, repeatOption, maxSize, textureIndex, weekday, month, day, year, hour, minute,
          lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute, locked, autoApprove, pendingInvite,
          inviteStatus, inviteType, calendarType = CalendarGetEventInfo()

    if title and (calendarType == "PLAYER" or calendarType == "GUILD_EVENT") then
        if not calendarInfos[title] then
            calendarInfos[title] = {}
        end
        calendarInfos[title].month = month
        calendarInfos[title].day = day
        calendarInfos[title].year = year
        calendarInfos[title].hour = hour
        calendarInfos[title].minute = minute

        if not calendarInfos[title].signupList then
            calendarInfos[title].signupList = {}
        end

        local existMembers = {}
        for i = 1, CalendarEventGetNumInvites() do
            local name, level, className, classFileName, inviteStatus, modStatus, inviteIsMine, inviteType = CalendarEventGetInvite(i)
            if name then
                name = RCCustomEP:GetFullName(name)
                existMembers[name] = true
                local info
                if not calendarInfos[title].signupList[name] then
                    calendarInfos[title].signupList[name] = {}
                end
                info = calendarInfos[title].signupList[name]
                local weekday, month, day, year, hour, minute = CalendarEventGetInviteResponseTime(i)
                info.month = month
                info.day = day
                info.year = year
                info.hour = hour
                info.minute = minute
                info.inviteStatus = inviteStatus --_G.CALENDAR_INVITESTATUS_OUT _G.CALENDAR_INVITESTATUS_TENTATIVE
                info.modStatus = modStatus
                info.inviteIsMine = inviteIsMine
            end
        end

        for name, _ in pairs(calendarInfos[title].signupList) do -- Remove people no longer signed up.
            if not existMembers[name] and calendarInfos[title].signupList[name] then
                wipe(calendarInfos[title].signupList[name])
                calendarInfos[title].signupList[name] = nil
            end
        end

        local monthOffset, day, index = CalendarGetEventIndex()
        C_Timer.After(2, function() RCCustomEP:UPDATE_CALENDAR(index+1) end) -- process the next event
    end
end

local function deleteInvalidInfos()
    for fullName, _ in pairs(allInfos) do
        if (not isInGuild[fullName]) and (not UnitInRaid(Ambiguate(fullName, "short"))) then
            allInfos[fullName] = nil
        end
    end
end

local lastUpdateTime
local isInGuildTemp = {}
function RCCustomEP:GUILD_ROSTER_UPDATE()
    if lastUpdateTime and GetTime() - lastUpdateTime < 2 then
        return
    end
    lastUpdateTime = GetTime()

    local guildName, _, _ = GetGuildInfo("player")
    wipe(isInGuildTemp)
    for i = 1, GetNumGuildMembers() do
        local fullName, rank, rankIndex, level, class, zone, note, officernote, online,
        status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo(i)
        if fullName then
            isInGuildTemp[fullName] = true
            isInGuild[fullName] = true
            if not allInfos[fullName] then
                allInfos[fullName] = {}
            end
            local info = allInfos[fullName]

            info["fullName"] = fullName
            info["guildRank"] = rank
            info["guildRankIndex"] = rankIndex
            info["note"] = note
            info["officernote"] = officernote
            info["status"] = status
            info["class"] = classFileName -- NonLocalizedClassName
            info["achievementPoints"] = achievementPoints
            info["achievementRank"] = achievementRank
            info["isMobile"] = isMobile
            info["canSoR"] = canSoR
            info["reputation"] = reputation
            info["guildName"] = guildName
            if (not UnitInRaid(Ambiguate(fullName, "short"))) then
                info["online"] = online
                info["level"] = level
                info["zone"] = zone
            end
        end
    end
    for fullName, _ in pairs(isInGuild) do
        if not isInGuildTemp[fullName] then
            isInGuild[fullName] = nil
        end
    end
    deleteInvalidInfos()
    GuildRoster()
end

function RCCustomEP:UpdateRaidInfo()
    local n = GetNumGroupMembers() or 0
    for i = 1, n do
        local name, rank, subgroup, level, class, classFileName, zone, online, isDead, groupRole, isML = GetRaidRosterInfo(i)
        if name then
            local fullName = RCCustomEP:GetFullName(name)
            local guildName, guildRankName, guildRankIndex = GetGuildInfo("raid"..i)
            if not allInfos[fullName] then
                allInfos[fullName] = {}
            end
            local info = allInfos[fullName]
            info["fullName"] = fullName
            info["raidRank"] = rank
            info["subgroup"] = subgroup
            info["level"] = level
            info["class"] = classFileName
            info["zone"] = zone
            info["online"] = online
            info["isDead"] = isDead
            info["groupRole"] = groupRole
            info["isML"] = isML
            info["role"] = UnitGroupRolesAssigned("raid"..i)
            info["guildName"] = guildName
            info["guildRank"] = guildRankName
            info["guildRankIndex"] = guildRankIndex
            info["guid"] = UnitGUID("raid"..i)
        end
    end
    deleteInvalidInfos()
end

function RCCustomEP:GetPlayerFullName()
    local name, realm = UnitFullName("player")
    return name.."-"..realm
end

local mapIDByNameCache = {}
function RCCustomEP:GetMapIDByName(mapName)
    if not mapName then return -1 end
    if mapIDByNameCache[mapName] then
        return id
    end
    local id = -1
    for i=9999, 1, -1 do
         local name = GetMapNameByID(i)
         if mapName == name then
             id = i
             break
         end
    end
    mapIDByNameCache[mapName] = id
    return id
end

function RCCustomEP:GetUnitInfo(fullName, category)
    return allInfos[fullName] and allInfos[fullName][category]
end

local countFuncCount = {}
RCCustomEP.counting = true
function RCCustomEP.CountFunction(name, fenv, formulaStr)
    if not formulaStr then return 0 end
    if not countFuncCount[formulaStr] then
        countFuncCount[formulaStr] = {}
        countFuncCount[formulaStr].count = 0
        countFuncCount[formulaStr].list = {}
    end

    if RCCustomEP.counting then
        if not countFuncCount[formulaStr].list[name] then
            local f = loadstring(formulaStr) or loadstring("return "..formulaStr)
            f = setfenv(f, fenv)
            if f then
                local value = f()
                if value and value ~= 0 then
                    countFuncCount[formulaStr].count = countFuncCount[formulaStr].count + 1
                end
            end

            countFuncCount[formulaStr].list[name] = true
        end
        return 0
    else
        return countFuncCount[formulaStr].count or 0
    end
end


function RCCustomEP.CalendarSignedUpFunction(name, fenv, titleKeyword)
    for title, entry in pairs(calendarInfos) do
        if (not titleKeyword) or string.find(title, titleKeyword) then
            if entry.signupList and entry.signupList[name] then
                if entry.signupList[name].inviteStatus ~=-_G.CALENDAR_INVITESTATUS_OUT
                   and entry.signupList[name].inviteStatus ~= _G.CALENDAR_INVITESTATUS_TENTATIVE then
                       return 1
                end
            end
        end
    end
    return 0
end
---------------------------------------------------------

-- tank, melee, ranged, healer
function RCCustomEP:GetSpecRole(fullName)
    local guid = RCCustomEP:GetUnitInfo(fullName, "guid")
    return guid and LibSpec:GetCachedInfo(guid) and LibSpec:GetCachedInfo(guid).spec_role_detailed
end

function RCCustomEP.IsMain(fullName)
    local ep, gp, main = EPGP:GetEPGP(fullName)
    return (not main) or (main == fullName)
end

----- Modified from EPGP/epgp_recurring.lua -----------------------------------
local LEPGP = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local Debug = LibStub("LibDebug-1.0")
local DLG = LibStub("LibDialog-1.0")

local callbacks = EPGP.callbacks

local frame = _G["EPGP_RecurringAwardFrame"]
local timeout = 0
local function RecurringTicker(self, elapsed)
  -- EPGP's db is available after GUILD_ROSTER_UPDATE. So we have a
  -- guard.
  if not EPGP.db then return end

  local vars = EPGP.db.profile
  local now = GetTime()
  if now > vars.next_award and GS:IsCurrentState() then
    EPGP:IncMassEPBy(vars.next_award_reason, vars.next_award_amount,
                     vars.next_formula, vars.next_input_name)
    vars.next_award =
      vars.next_award + vars.recurring_ep_period_mins * 60
  end
  timeout = timeout + elapsed
  if timeout > 0.5 then
    callbacks:Fire("RecurringAwardUpdate",
                   vars.next_award_reason,
                   vars.next_award_amount,
                   vars.next_award - now)
    timeout = 0
  end
end
frame:SetScript("OnUpdate", RecurringTicker)
frame:Hide()

function EPGP:StartRecurringEP(reason, amount, formulaIndexOrName, inputName)
  -- TODO: Only guild officer can execute this func
  if type(reason) ~= "string" or type(amount) ~= "number" or #reason == 0 then
    return false
  end
  if formula then
      local formulaFunc = RCCustomEP:GetEPFormulaFunc(formulaIndexOrName)
      if not formulaFunc then
          print("Formula does not exist or has syntax error. Abort.")
          return
      end
  end
  local vars = EPGP.db.profile
  if vars.next_award then
    return false -- TODO: Annouce this
  end

  vars.next_award_reason = reason
  vars.next_award_amount = amount
  vars.next_award = GetTime() + vars.recurring_ep_period_mins * 60
  vars.next_formula = formulaIndexOrName
  vars.next_input_name = inputName
  frame:Show()

  callbacks:Fire("StartRecurringAward",
                 vars.next_award_reason,
                 vars.next_award_amount,
                 vars.recurring_ep_period_mins)
  return true
end

function EPGP:CancelRecurringEP()
  DLG:Dismiss("EPGP_RECURRING_RESUME")
  local vars = EPGP.db.profile
  vars.next_award_reason = nil
  vars.next_award_amount = nil
  vars.next_award = nil
  vars.next_formula = nil
  vars.next_input_name = nil
  frame:Hide()
end
-------------------------------------------------------------------------------
-- TODO: Finish this.
local oldIncMassEPBy = EPGP.IncMassEPBy
function EPGP:IncMassEPBy(reason, amount, formulaIndexOrName, inputName, debug)
  if not formulaIndexOrName then
      return oldIncMassEPBy(EPGP, reason, amount)
  end

  local formulaFunc = RCCustomEP:GetEPFormulaFunc(formulaIndexOrName)
  if not formulaFunc then
      print("Formula does not exist or has syntax error. Abort.")
      return
  end
  RCCustomEP:UpdateRaidInfo()
  RCCustomEP.inputName = inputName
  RCCustomEP.inputEPAmount = amount
  local fenv = {}
  for _, funcName in ipairs(RCCustomEP.allowedAPI) do
      fenv[funcName] = _G[funcName]
  end
  local awarded_mains = {}
  local awarded_list = {}

  countFuncCount = {} -- reset variable for special count func
  RCCustomEP.counting = true -- for count func
  for name, _ in pairs(allInfos) do -- Execute formula extra time for the special "count" variable
      for _, entry in ipairs(RCCustomEP.EPVariables) do
          local variableName = entry.name
          local variableValue = entry.value(name, fenv)
          fenv[variableName] = variableValue
      end
      formulaFunc = setfenv(formulaFunc, fenv)
      local status, err = pcall(formulaFunc)
      if not status then
          print(err)
          return
      end
  end

  RCCustomEP.counting = false
  for name, _ in pairs(allInfos) do
      local ep, _, main = EPGP:GetEPGP(name)
      main = main or name
      if ep and (not awarded_mains[main]) then
          for _, entry in ipairs(RCCustomEP.EPVariables) do
              local variableName = entry.name
              local variableValue = entry.value(name, fenv)
              fenv[variableName] = variableValue
          end

          formulaFunc = setfenv(formulaFunc, fenv)
          local status, err = pcall(formulaFunc)
          if not status then -- Error
              print(err)
              return
          end
          local awardAmount = math.floor((err or 0) + 0.5)
                                                 -- TODO: EPGP:IncEPBy(name, reason, amount, true)
          local ep = tonumber(awardAmount or 0)
          if ep and ep ~= 0 then
              awarded_mains[main] = true
              if not awarded_list[ep] then
                  awarded_list[ep] = {}
              end
              table.insert(awarded_list[ep], name)
          end
      end
  end
  -- sort award_list by ep and awarded_list[ep] by alphabet
  local sorted_list = {}
  for ep, list in pairs(awarded_list) do
      table.sort(list, function(a, b) return a < b end)
      table.insert(sorted_list, {ep=ep, list=list})
  end
  table.sort(sorted_list, function(a, b) return a.ep < b.ep end)

  for _, entry in ipairs(sorted_list) do
      local linePrint = entry.ep.." "
      for _, name in ipairs(entry.list) do
          linePrint = linePrint..name.." "
      end
      print(linePrint)
  end

  -- TODO: Actaully EP award
--[[
  for _, entry in ipairs(sorted_list) do
      EPGP.callbacks:Fire("MassEPAward", entry.list, reason, entry.ep)
  end]]--

end
