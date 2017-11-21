local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomEP = RCEPGP:NewModule("RCCustomEP", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local LibSpec = LibStub("LibGroupInSpecT-1.1")
local LibDialog = LibStub("LibDialog-1.0")

local hasPlayerLogin = false
local isInGuild = {}
local allInfos = {} -- The information of all raid and guild members, not including calendar infos.
local calendarInfos = {} -- The information of the calendar event today.

RCCustomEP.initialize = false -- if the module has been initialized
RCCustomEP.realmTimeDiff = 0  -- Time difference between realm time and UTC in sec
RCCustomEP.targetName = ""    -- 'target Name variable'
RCCustomEP.inputEPAmount = 0  -- inputEPAmount variable
RCCustomEP.MaxFormulas = 100  -- The max amount of formulas we are storing.
RCCustomEP.EPVariables = {}

function RCCustomEP:GetEPVariables()
    --[[
       name: The name of the variable
       help: The description of the variable shown in the option.
       value: a function which receives 3 args: name, fenv, isFirstPass
         Returns: Any value that suitable for the usage of this variable.
         name: The full name of the character we are processing.
         fenv: The function environment we are using. Useful when this returns a function that process a string.
         isFirstPass: Some variable needs two passes for each character to get the final value. For example, the count variable.
       display_name: If specified, the option table show this as the name instead. Mutliple variables with the same display name are only shown once.
    --]]

    local EPVariables = {
        {name = "name", help = LEP["ep_variable_name_help"], value = function(name) return name or "UNKNOWN" end, },
        {name = "isOnline", help = LEP["ep_variable_isOnline_help"], value = function(name) return self:GetUnitInfo(name, "online") and 1 or 0 end, },
        {name = "guildName", help = LEP["ep_variable_guildName_help"], value = function(name) return self:GetUnitInfo(name, "guildName") or "UNKNOWN" end, },
        {name = "zone", help = LEP["ep_variable_zone_help"], value = function(name) return self:GetUnitInfo(name, "zone") or "UNKNOWN" end, },
        {name = "zoneId", help = LEP["ep_variable_zoneId_help"], value = function(name) return self:GetMapIDByName(self:GetUnitInfo(name, "zone") or "UNKNOWN") end, },
        {name = "isInRaid", help = LEP["ep_variable_isInRaid_help"], value = function(name) return (name and UnitInRaid(Ambiguate(name, "short"))) and 1 or 0 end, },
        {name = "isStandby", help = LEP["ep_variable_isStandby_help"], value = function(name) return (name and EPGP:IsMemberInExtrasList(name)) and 1 or 0 end, },
        {name = "isMain", help = LEP["ep_variable_isMain_help"], value = function(name) return self:IsMain(name) and 1 or 0 end, },
        {name = "isMaxLevel", help = LEP["ep_variable_isMaxLevel_help"], value = function(name) return self:GetUnitInfo(name, "level") == GetMaxPlayerLevel() and 1 or 0 end, },
        {name = "rank", help = LEP["ep_variable_rank_help"], value = function(name) return self:GetUnitInfo(name, "guildRankIndex") or 10 end, },
        {name = "isTank", help = LEP["ep_variable_isTank_help"], value = function(name) return self:GetUnitInfo(name, "role") == "TANK" and 1 or 0 end},
        {name = "isHealer", help = LEP["ep_variable_isHealer_help"], value = function(name) return self:GetUnitInfo(name, "role") == "HEALER" and 1 or 0 end},
        {name = "isDPS", help = LEP["ep_variable_isDPS_help"], value = function(name) return self:GetUnitInfo(name, "role") == "DAMAGER" and 1 or 0 end},
        {name = "isMeleeDPS", help = LEP["ep_variable_isMeleeDPS_help"], value = function(name) return self:GetSpecRole(name) == "melee" and 1 or 0 end},
        {name = "isRangedDPS", help = LEP["ep_variable_isRangedDPS_help"], value = function(name) return self:GetSpecRole(name) == "ranged" and 1 or 0 end},
        {name = "level", help = LEP["ep_variable_level_help"], value = function(name) return self:GetUnitInfo(name, "level") or 1 end,},
        {name = "class", help = LEP["ep_variable_class_help"], value = function(name) return self:GetUnitInfo(name, "class") or "UNKNOWN" end,},
        {name = "ep", help = LEP["ep_variable_ep_help"], value = function(name) return select(1, EPGP:GetEPGP(name)) or 0 end, },
        {name = "gp", help = LEP["ep_variable_gp_help"], value = function(name) return select(2, EPGP:GetEPGP(name)) or 0 end, },
        {name = "pr", help = LEP["ep_variable_pr_help"], value = function(name) local ep, gp = EPGP:GetEPGP(name); if ep and gp then return ep/gp else return 0 end end, },
        {name = "targetName", help = LEP["ep_variable_targetName_help"], value = function(name) return name == self.targetName end, },
        {name = "isTargetName", help = LEP["ep_variable_isTargetName_help"], value = function(name) return (name and name == self.targetName) and 1 or 0 end, },
        {name = "isNormalRaid", help = LEP["ep_variable_isNormalRaid_help"], value = function(name) local diff = GetRaidDifficultyID(); return diff == 1 or diff == 3 or diff == 4 or diff == 14 end},
        {name = "isHeroicRaid", help = LEP["ep_variable_isHeroicRaid_help"], value = function(name) local diff = GetRaidDifficultyID(); return diff == 2 or diff == 5 or diff == 6 or diff == 15 end},
        {name = "isMythicRaid", help = LEP["ep_variable_isMythicRaid_help"], value = function(name) local diff = GetRaidDifficultyID(); return diff == 16 or diff == 23 end},
    }

    -- isRank0, ..., isRank9
    for i=0,9 do
        table.insert(EPVariables, {name = "isRank"..i, display_name = "isRank0, isRank1,..., isRank9", help = LEP["ep_variable_isRankX_help"], value = function(name) return self:GetUnitInfo(name, "guildRankIndex") == i and 1 or 0 end, })
    end

    -- mainXXX variables
    for i, entry in ipairs(EPVariables) do
        if (not entry.name:find("main")) then
            table.insert(EPVariables, {name = "main"..entry.name, display_name = "main...", help = LEP["ep_variable_main_prefix_help"], value = function(name) local _, _, main = EPGP:GetEPGP(name); main = main or name; return entry.value(main) end, })
        end
    end

    -- sameXXX variables
    for i, entry in ipairs(EPVariables) do
        if (not entry.name:find("same")) then
            table.insert(EPVariables, {name = "same"..entry.name, display_name = "same...", help = LEP["ep_variable_same_prefix_help"], value = function(name) return entry.value(self:GetPlayerFullName()) == entry.value(main) and 1 or 0 end, })
        end
    end

    for i, entry in ipairs(EPVariables) do
        if (not entry.name:find("targetname")) then
            table.insert(EPVariables, {name = "targetname"..entry.name, display_name = "targetname...", help = LEP["ep_variable_targetname_prefix_help"], value = function() if not self.targetName then return 0 end; return entry.value(self.targetName) end, })
        end
    end

    table.insert(EPVariables, {name = "minep", help = LEP["ep_variable_minep_help"], value = function() return EPGP.db.profile.min_ep end, })
    table.insert(EPVariables, {name = "decay", help = LEP["ep_variable_decay_help"], value = function() return EPGP.db.profile.decay_p end, }) -- Integer
    table.insert(EPVariables, {name = "baseGP", help = LEP["ep_variable_baseGP_help"], value = function() return EPGP.db.profile.base_gp end, })
    table.insert(EPVariables, {name = "inputEPAmount", help = LEP["ep_variable_inputEPAmount_help"], value = function() return self.inputEPAmount end, })

    -- Special count function

    -- TODO: fix function format of count
    table.insert(EPVariables, {name = "count", needTwoPasses = true, help = LEP["ep_variable_count_help"], value = function(name, fenv, isFirstPass) return function(formulaStr) return self.CountFunction(name, fenv, formulaStr, isFirstPass) end end, })

    -- TODO: special sum function
    -- CalendarCheckFunction
    table.insert(EPVariables, {name = "calendarSignedUp", help = LEP["ep_variable_calendarSignedUp_help"], value = function(name, fenv) return function(titleKeyword) return self.CalendarSignedUpFunction(name, fenv, titleKeyword) end end, })

    return EPVariables
end

function RCCustomEP:GetMassEPQueue()
    local db = self:GetCustomEPdb()
    if not db.massEPQueue then
        db.massEPQueue = {}
    end
    return db.massEPQueue
end

function RCCustomEP:GetEPFormulaFunc(indexOrName)
    local formulaStr
    if self:GetCustomEPdb().EPFormulas[indexOrName] then
        formulaStr = self:GetCustomEPdb().EPFormulas[indexOrName].formula
    elseif tonumber(indexOrName) and self:GetCustomEPdb().EPFormulas[tonumber(indexOrName)] then
        formulaStr = self:GetCustomEPdb().EPFormulas[tonumber(indexOrName)].formula
    end
    if not formulaStr then return nil end

    for i, entry in ipairs(self:GetCustomEPdb().EPFormulas) do
        if entry.name == indexOrName then
            formulaStr = entry.formula
        end
    end

    local func, err = loadstring("return "..formulaStr)
    if not func then
        func, err = loadstring(formulaStr)
    end
    return func, err, formulaStr
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
    self.defaults = {
        EPFormulas = {
            {name = "test", desc = "WTF", formula = "123", },
        },
    }
    self:AddChatCommand()
    self:RegisterEvent("GUILD_ROSTER_UPDATE")
    self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST", "UPDATE_CALENDAR")
    self:RegisterEvent("CALENDAR_OPEN_EVENT", "OPEN_CALENDAR")
    self:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST", "UPDATE_CALENDAR")
    self:RegisterEvent("PLAYER_LOGIN")
    --[[GuildRoster()
    C_Timer.After(10, function() self:UPDATE_CALENDAR() end)
    LibSpec:Rescan()
    self.EPVariables = self:GetEPVariables()
    RCEPGP:SetdbDefaults(self:GetCustomEPdb(), self.defaults, false)
    self:SendMessage("RCCustomEPRuleChanged")
    self.initialize = true

    self:SecureHook(RCLootCouncil, "UpdateDB", function()
        self:CancelAllScheduledEP()
    end)
--]]
end

-- /rc massep  reason amount [formulaIndexOrName] [targetName] [ScheduleTime AfterSecond/HH:MM:SS/HH:MM, realm time, 24hour format]
function RCCustomEP:Massep(reason, amount, formulaIndexOrName, targetName, scheduleTime)
    if reason == "help" then
        RCEPGP:Print(LEP["slash_rc_massep_help_detailed"])
        return
    end
    self:IncMassEPBy(reason, tonumber(amount), formulaIndexOrName, targetName, scheduleTime)
end

-- /rc recurep periodMin reason amount [formulaIndexOrName] [targetName] [ScheduleTime AfterSecond/HH:MM:SS/HH:MM, realm time, 24hour format]
function RCCustomEP:Recurep(periodMin, reason, amount, formulaIndexOrName, targetName, scheduleTime)
    if periodMin == "help" then
        RCEPGP:Print(LEP["slash_rc_recurep_help_detailed"])
        return
    end
    if tonumber(periodMin) and tonumber(periodMin) > 0 then
        self:StartRecurringEP(reason, tonumber(amount), tonumber(periodMin), formulaIndexOrName, targetName, scheduleTime)
    else
        RCEPGP:Print(LEP["peroid_not_positive_error"])
    end
end
-- TODO formulaIndex is 0
-- /rc stoprecur
-- TODO: schedule stoprecur
function RCCustomEP:Stoprecur()
    EPGP:StopRecurringEP()
end

-- /rc ep name reason amount
function RCCustomEP:IncEPBy(name, reason, amount)
    if name == "help" then
        RCEPGP:Print(LEP["slash_rc_ep_help_detailed"])
        return
    end
    if name == "%p" then
        name = RCEPGP:GetEPGPName("player")
    elseif name == "%t" then
        if not UnitExists("target") then
            RCEPGP:Print(L["You must select a target"])
            return
        end
        name = RCEPGP:GetEPGPName("target")
    end
    -- TODO: more error checking?
    EPGP:IncEPBy(name, reason, amount)
end

function RCCustomEP:CancelAllScheduledEP()
    wipe(self:GetCustomEPdb().massEPQueue)
    RCEPGP:Print(LEP["cancel_all_scheduled_ep"])
    self:SendMessage("RCCustomEPQueueRemoved")
end

function RCCustomEP:AddChatCommand()
    addon:CustomChatCmd(self, "IncEPBy", LEP["slash_rc_ep_help"], "ep")
    addon:CustomChatCmd(self, "Massep", LEP["slash_rc_massep_help"], "massep")
    addon:CustomChatCmd(self, "Recurep", LEP["slash_rc_recurep_help"], "recurep")
    addon:CustomChatCmd(self, "Stoprecur", LEP["slash_rc_stoprecur_help"], "stoprecur")
    addon:CustomChatCmd(self, "CancelAllScheduledEP", LEP["slash_rc_cancelallscheduledep_help"], "cancelallscheduledep")
end

local timeLastCalendarUpdate = GetTime()
local indexLastCalendarUpdate = 1
function RCCustomEP:UPDATE_CALENDAR(nextIndex)
    if not nextIndex or type(nextIndex) ~= 'number' then nextIndex = 1 end
    if GetTime() - timeLastCalendarUpdate < 10 and nextIndex <= indexLastCalendarUpdate then
        C_Timer.After(10-GetTime()+timeLastCalendarUpdate+1, function() self:UPDATE_CALENDAR(nextIndex) end)
        return
    end
    timeLastCalendarUpdate = GetTime()
    indexLastCalendarUpdate = nextIndex
    if _G.CalendarFrame and (not self:IsHooked(_G.CalendarFrame, "OnHide")) then
        self:SecureHookScript(_G.CalendarFrame, "OnHide", function() self:UPDATE_CALENDAR(1) end)
    end
    if _G.CalendarFrame and _G.CalendarFrame:IsShown() then
        return -- Don't update when Blizzard calendar is shown
    end

    RCEPGP:DebugPrint("RCCustomEP", "UPDATE_CALENDAR")

    local weekday, month, day, year = CalendarGetDate()
    local existEvents = {}

    for i=1, CalendarGetNumDayEvents(0, day) do
		local event = C_Calendar.GetDayEvent(0, day, i);
		local title, hour, min, calendarType = event.title, event.startTime.hour, event.startTime.minute, event.calendarType
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
		local event = C_Calendar.GetDayEvent(0, day, i);
		local title, hour, min, calendarType = event.title, event.startTime.hour, event.startTime.minute, event.calendarType
        if title and (calendarType == "PLAYER" or calendarType == "GUILD_EVENT") then
            CalendarOpenEvent(0, day, i) -- handles the rest in OPEN_CALENDAR
            return
        end
    end
end

function RCCustomEP:GetRealmTimeDiff() -- Time difference between realm time and UTC in sec
    local curDate = date("!*t")
    local curTime = time(curDate)
    local hour, min = GetGameTime()
    local weekday, month, day, year = CalendarGetDate()
    local newDate = {}
    newDate["year"] = year
    newDate["month"] = month
    newDate["day"] = day
    newDate["hour"] = hour
    newDate["min"] = min
    newDate["sec"] = curDate["sec"]
    newDate["isdst"] = curDate["isdst"]
    local result = (math.floor(((time(newDate) - curTime))/900+0.5))*900 -- 15min precision.
    return result
end

function RCCustomEP:GetUTCEndTime(realmTime) -- "realmTime" is a string which is sec/HH:MM/HH:MM:SS,(realm time)
                                    -- return a number representing the UTC end time (either now+time if "realmTime" is number or the time string )
    local now = time(date("!*t")) -- current UTC time
    local isUTCdst = date("!*t").isdst
    if tonumber(realmTime) and tonumber(realmTime) >= 0 then -- realmTime is a number, representing a time diff.
        return now + tonumber(realmTime)
    elseif type(realmTime)=='string' then

        if string.match(realmTime, "([^(0-9|:)]+)") then -- invalid time.
            return
        end

        local weekday, month, day, year = CalendarGetDate()
        local hour, _ = string.match(realmTime, "(%d+)")
        local _, min = string.match(realmTime, "(%d+):(%d+)")
        local _, _, sec = string.match(realmTime, "(%d+):(%d+):(%d+)")

        if not min then min = 0 end
        if not sec then sec = 0 end
        hour, min, sec = tonumber(hour), tonumber(min), tonumber(sec)
        --print(sec)
        if hour and min and sec and (hour >= 0 and hour < 24 and min >= 0 and min < 60 and sec >=0 and sec < 60) then
            hour, min, sec = tonumber(hour), tonumber(min), tonumber(sec)
            local endTime = time({ hour=hour, min=min, sec=sec, day=day, month=month, year=year, isdst=isUTCdst })
            endTime = endTime - RCCustomEP.realmTimeDiff
            if endTime < now then
                endTime = endTime + 24*60*60
            end
            return endTime
        end
    end
end

function RCCustomEP:PLAYER_LOGIN()
    hasPlayerLogin = true
    self.realmTimeDiff = self:GetRealmTimeDiff()
    RCEPGP:DebugPrint("PLAYER_LOGIN")
    RCEPGP:DebugPrint("RealmTimeDiff ", self.realmTimeDiff)
    self:RemoveExpiredEntryInQueue()
    if next(self:GetMassEPQueue()) then
        LibDialog:Spawn("RCEPGP_CUSTOMEP_SCHEDULE_RESUME")
    end
end

function RCCustomEP:RemoveExpiredEntryInQueue()
    local queue = self:GetMassEPQueue()
    local deletedOneEntry
    repeat
        deletedOneEntry = false
        for key, entry in pairs(queue) do
            if entry.UTCEndTime and entry.UTCEndTime < time(date("!*t")) then
                table.remove(queue, key)
                 addon:SendMessage("RCCustomEPQueueRemoved", entry)
                -- TODO: Debug info
                deletedOneEntry = true
                break
            end
        end
    until deletedOneEntry == false
end

function RCCustomEP:OPEN_CALENDAR()
    if _G.CalendarFrame and _G.CalendarFrame:IsShown() then
        return -- Don't update when Blizzard calendar is shown
    end

    local title, description, creator, eventType, repeatOption, maxSize, textureIndex, weekday, month, day, year, hour, minute,
          lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute, locked, autoApprove, pendingInvite,
          inviteStatus, inviteType, calendarType = CalendarGetEventInfo()

    local weekday2, month2, day2, year2 = CalendarGetDate()
    if weekday ~= weekday2 or month ~= month2 or day ~= day2 or year ~= year2 then -- Only process event on today.
        return
    end
    RCEPGP:DebugPrint("RCCustomEP", "OPEN_CALENDAR", tostring(title))

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
                name = self:GetFullName(name)
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
        C_Timer.After(2, function() self:UPDATE_CALENDAR(index+1) end) -- process the next event
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

    if (not GetNumGuildMembers()) or (GetNumGuildMembers() == 0) then
        RCEPGP:DebugPrint("RCCustomEP", "GUILD_ROSTER_UPDATE", "but no infomation is fetched.")
        return
    end
    RCEPGP:DebugPrint("RCCustomEP", "GUILD_ROSTER_UPDATE")

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
            RCEPGP:DebugPrint("RCCustomEP", fullName.." is no longer in the guild. removed.")
        end
    end
    deleteInvalidInfos()
    GuildRoster()
end

function RCCustomEP:UpdateRaidInfo()
    RCEPGP:DebugPrint("RCCustomEP", "UpdateRaidInfo")
    local n = GetNumGroupMembers() or 0
    for i = 1, n do
        local name, rank, subgroup, level, class, classFileName, zone, online, isDead, groupRole, isML = GetRaidRosterInfo(i)
        if name then
            local fullName = self:GetFullName(name)
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

-- TODO: calendar date when it crosses midnight
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

    if self.counting then
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
    local guid = self:GetUnitInfo(fullName, "guid")
    return guid and LibSpec:GetCachedInfo(guid) and LibSpec:GetCachedInfo(guid).spec_role_detailed
end

function RCCustomEP:IsMain(fullName)
    local ep, gp, main = EPGP:GetEPGP(fullName)
    return (not main) or (main == fullName)
end

----- Modified from EPGP/epgp_recurring.lua -----------------------------------
local LEPGP = LibStub("AceLocale-3.0"):GetLocale("EPGP")
local GS = LibStub("LibGuildStorage-1.2")
local Debug = LibStub("LibDebug-1.0")
local DLG = LibStub("LibDialog-1.0")

RCCustomEP.recurTickFrame = CreateFrame("Frame", "RCCustomEP_Recur_Tick_Frame")
RCCustomEP.recurTickFrame.timeout = 0

RCCustomEP.recurTickFrame:SetScript("OnUpdate", function(self, elapsed)
  if _G["EPGP_RecurringAwardFrame"]:IsShown() then
      return
  end

  if not EPGP.db then return end

  local vars = EPGP.db.profile
  if not vars.next_award then return end

  local now = GetTime()
  if now > vars.next_award and GS:IsCurrentState() then
    RCCustomEP:IncMassEPBy(vars.next_award_reason, vars.next_award_amount,
                     vars.next_formula, vars.next_target_name)
    vars.next_award =
      vars.next_award + vars.recurring_ep_period_mins * 60
  end
  self.timeout = self.timeout + elapsed
  if self.timeout > 0.5 then
    EPGP.callbacks:Fire("RecurringAwardUpdate",
                   vars.next_award_reason,
                   vars.next_award_amount,
                   vars.next_award - now)
    self.timeout = 0
  end
end)
RCCustomEP.recurTickFrame:Show() -- TODO: Only show this frame when needed.

function RCCustomEP:StartRecurringEP(reason, amount, periodMin, formulaIndexOrName, targetName, scheduleTime)
  -- TODO: Only guild officer can execute this func
  if type(reason) ~= "string" or type(amount) ~= "number" or #reason == 0 then
    return false
  end
  if formulaIndexOrName then
      local formulaFunc = self:GetEPFormulaFunc(formulaIndexOrName)
      if not formulaFunc then
          print("Custom RecurringEP: Formula does not exist or has syntax error. Abort.")
          RCEPGP:Debug("Custom RecurringEP: Formula does not exist or has syntax error. Abort.")
          return
      end
  end

  local vars = EPGP.db.profile
  if tonumber(periodMin) then

     if scheduleTime and scheduleTime ~= 0 and scheduleTime ~= "" and scheduleTime ~= "0" then -- Schedule to run this later.
          local UTCEndTime = self:GetUTCEndTime(scheduleTime)
          if not UTCEndTime then
              RCEPGP:Print("Ilformed [ScheduleTime]. Must be one of number/HH:MM/HH:MM:SS")
              return
          end

          -- TODO
          RCEPGP:Debug("Schedule Custom RecurringEP", reason, amount, periodMin, formulaIndexOrName, targetName, scheduleTime)
          local queue = self:GetMassEPQueue()
          local entry = {
              type = "recurep",
              UTCEndTime = UTCEndTime,
              reason = reason,
              amount = amount,
              periodMin = periodMin,
              formulaIndexOrName = formulaIndexOrName,
              targetName = targetName,
          }
          table.insert(queue, entry)
          addon:SendMessage("RCCustomEPQueueAdded", entry)
          self.scheduleTickFrame:Show()
          return
      else
          RCEPGP:Debug("Custom RecurringEP", reason, amount, periodMin, formulaIndexOrName, targetName, scheduleTime)
          vars.recurring_ep_period_mins = tonumber(periodMin)
      end
  end

  if vars.next_award then
    return false -- TODO: Annouce this
  end

  vars.next_award_reason = reason
  vars.next_award_amount = amount
  vars.next_award = GetTime() + vars.recurring_ep_period_mins * 60
  vars.next_formula = formulaIndexOrName
  vars.next_target_name = targetName

  EPGP.callbacks:Fire("StartRecurringAward",
                 vars.next_award_reason,
                 vars.next_award_amount,
                 vars.recurring_ep_period_mins)
  return true
end


-------------------------------------------------------------------------------
-- TODO: Finish this.
function RCCustomEP:IncMassEPBy(reason, amount, formulaIndexOrName, targetName, scheduleTime)

  amount = tonumber(amount)
  if not amount then
    RCEPGP:Print("[amount] must be a number") -- TODO locale
    return
  end

  if scheduleTime and scheduleTime ~= 0 and scheduleTime ~= "" and scheduleTime ~= "0" then -- Schedule to run this later.
      local UTCEndTime = self:GetUTCEndTime(scheduleTime)
      if not UTCEndTime then
          RCEPGP:Print("Ilformed [ScheduleTime]. Must be one of number/HH:MM/HH:MM:SS")
          return
      end

        RCEPGP:Debug("Schedule Custom MassEP", reason, amount, formulaIndexOrName, targetName, scheduleTime)
      -- TODO
      local queue = self:GetMassEPQueue()
      local entry = {
          type = "massep",
          UTCEndTime = UTCEndTime,
          reason = reason,
          amount = amount,
          formulaIndexOrName = formulaIndexOrName,
          targetName = targetName,
      }
      table.insert(queue, entry)
      addon:SendMessage("RCCustomEPQueueAdded", entry)
      self.scheduleTickFrame:Show()
      return
  end

  if not formulaIndexOrName then
      RCEPGP:Debug("Origin MassEP", reason, amount)
      return EPGP:IncMassEPBy(reason, amount)
  end

  if not self.initialize then return end

  RCEPGP:Debug("Custom MassEP", reason, amount, formulaIndexOrName, targetName, scheduleTime)

  if targetName == "%t" then
      if not UnitExists("%t") then
          self:Print(L["You must select a target"])
      else
          targetName = self:GetFullName("target")
      end
  elseif arg4 == "%p" then
      targetName = self:GetFullName("player")
  end

  local formulaFunc, err, formulaStr = self:GetEPFormulaFunc(formulaIndexOrName)
  if not formulaFunc then
      print("Formula does not exist or has syntax error. Abort.")
      RCEPGP:Debug("Formula does not exist or has syntax error. Abort.")
      return
  end
  RCEPGP:Debug("Formula String:", tostring(formulaStr))

  self:UpdateRaidInfo()
  self.targetName = targetName
  self.inputEPAmount = amount
  local fenv = {}
  for _, funcName in ipairs(self.allowedAPI) do
      fenv[funcName] = _G[funcName]
  end
  local awarded_mains = {}
  local awarded_list = {}

  countFuncCount = {} -- reset variable for special count func
  self.counting = true -- for count func
  for name, _ in pairs(allInfos) do -- Execute formula extra time for the special "count" variable
      for _, entry in ipairs(self.EPVariables) do
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

  self.counting = false
  for name, _ in pairs(allInfos) do
      local ep, _, main = EPGP:GetEPGP(name)
      main = main or name
      if ep and (not awarded_mains[main]) then
          for _, entry in ipairs(self.EPVariables) do
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

  -- TODO
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

--------------------------------------------------------------------------------
RCCustomEP.scheduleTickFrame = CreateFrame("Frame", "RCCustomEP_Schedule_Tick_Frame")
RCCustomEP.scheduleTickFrame.timeout = 0

RCCustomEP.scheduleTickFrame:SetScript("OnUpdate", function(self, elapsed)
    if not RCCustomEP.initialize then return end

    self.timeout = self.timeout + elapsed
    if self.timeout < 1 then
        return
    end
    self.timeout = 0
    self.lastUpdateTime = GetTime()
    local queue = RCCustomEP:GetMassEPQueue()
    for _, entry in ipairs(queue) do
        if entry.UTCEndTime and entry.UTCEndTime < time(date("!*t")) then
            if entry.type == "massep" then
                self:IncMassEPBy(entry.reason, entry.amount, entry.formulaIndexOrName, entry.targetName)
            elseif entry.type == "recurep" then
                self:StartRecurringEP(entry.reason, entry.amount, entry.periodMin, entry.formulaIndexOrName, entry.targetName)
            end
        elseif not entry.UTCEndTime then
            RCEPGP:DebugPrint("ERROR. No UTCEndTime in entry.")
        end
    end
    RCCustomEP:RemoveExpiredEntryInQueue()

    if not next(queue) then
        self:Hide()
    end
end)
RCCustomEP.scheduleTickFrame:Hide()

------------------------------------------------------------------------------------------------
function RCCustomEP:GetCustomEPdb()
    if not RCEPGP:GetEPGPdb().customEP then
        RCEPGP:GetEPGPdb().customEP = {}
    end
    return RCEPGP:GetEPGPdb().customEP
end

function RCCustomEP:RestoreToDefault()
    RCEPGP:SetdbDefaults(self:GetCustomEPdb(), self.defaults, true)
    self:SendMessage("RCCustomEPRuleChanged")
end

function RCCustomEP.EPFormulaGetter(index, category)
    if (not RCCustomEP:GetCustomEPdb().EPFormulas) or (not RCCustomEP:GetCustomEPdb().EPFormulas[index]) then
        return ""
    end
    return RCCustomEP:GetCustomEPdb().EPFormulas[index][category]
end

function RCCustomEP.EPFormulaSetter(index, category, value)
    if (not RCCustomEP:GetCustomEPdb().EPFormulas[index]) then
        RCCustomEP:GetCustomEPdb().EPFormulas[index] = {}
    end
    if category == "name" then
        RCCustomEP:GetCustomEPdb().EPFormulas[index][category] = RCCustomEP:EPFormulaGetUnrepeatedName(value, index)
    else
        RCCustomEP:GetCustomEPdb().EPFormulas[index][category] = value
    end
end

function RCCustomEP:EPFormulaGetUnrepeatedName(name, index)
    name = string.gsub(name, " ", "_") -- We don't allow space in the name, so replace it by "_"
    local function isRepeated(name)
        for i, entry in pairs(self:GetCustomEPdb().EPFormulas) do
            if entry.name == name and i ~= index then
                return true
            end
        end
        return false
    end
    if not isRepeated(name) then
        return name
    else
        local i = 2
        while isRepeated(name.."_"..i) do
            i = i + 1
        end
        return name.."_"..i
    end
end


LibDialog:Register("RCEPGP_CUSTOMEP_SCHEDULE_RESUME", {
    text = LEP["RCEPGP_CUSTOMEP_SCHEDULE_RESUME"],
    buttons = {
    {
      text = _G.YES,
      on_click = function(self, data, reason)
      end,
    },
    {
      text = _G.NO,
      on_click = function(self, data, reason)
        RCCustomEP:CancelAllScheduledEP()
      end,
    },
    },
    on_cancel = function(self, data, reason)
        if reason ~= "override" then
          RCCustomEP:CancelAllScheduledEP()
        end
    end,
    hide_on_escape = true,
    show_while_dead = true,
})

-- TODO: schedule /epgp decay
-- TODO: ep operation fails when frame opens.
