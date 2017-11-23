local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
_G.RCCustomEP = RCEPGP:NewModule("RCCustomEP", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceBucket-3.0", "AceTimer-3.0")
local LEP = LibStub("AceLocale-3.0"):GetLocale("RCEPGP")
local EPGP = LibStub("AceAddon-3.0"):GetAddon("EPGP")
local LibSpec = LibStub("LibGroupInSpecT-1.1")
local LibDialog = LibStub("LibDialog-1.0")

local lastOtherCalendarOpenEvent = 0
local eventOpenQueue = {}
local candidateInfos = {} -- The information of all raid and guild members, not including calendar infos.
local eventInfos = {} -- The information of the calendar event today.

function RCCustomEP:OnInitialize()
	self.candidateInfos = candidateInfos
	self.eventInfos = eventInfos
	self.eventOpenQueue = eventOpenQueue
	self.MaxFormulas = 100
	self:RegisterEvent("CALENDAR_OPEN_EVENT", "OPEN_CALENDAR")
	self:RegisterBucketEvent({"CALENDAR_UPDATE_EVENT_LIST", "CALENDAR_UPDATE_INVITE_LIST"}, 10, "UPDATE_CALENDAR")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 10, "GROUP_ROSTER_UPDATE")
	self:RegisterBucketEvent("GUILD_ROSTER_UPDATE", 20, "GUILD_ROSTER_UPDATE")
	self:SecureHook("CalendarOpenEvent", "OnCalendarOpenEvent")
	GuildRoster()
	self:ProcessEventOpenQueue()
	self:ScheduleTimer("UPDATE_CALENDAR", 10)
	LibSpec:Rescan()
	self.initialize = true
end

function RCCustomEP:GROUP_ROSTER_UPDATE()
	RCEPGP:DebugPrint("RCCustomEP", "GROUP_ROSTER_UPDATE")
	for i = 1, GetNumGroupMembers() or 0 do
		local name, rank, subgroup, level, class, classFileName, zone, online, isDead, groupRole, isML = GetRaidRosterInfo(i)
		if name then
			local unitID
			if IsInRaid() then
				unitID = "raid"..i
			else
				unitID = "party"..i
			end
			local fullName = RCEPGP:GetEPGPName(name)
			local guildName, guildRankName, guildRankIndex = GetGuildInfo(unitID)
			if not candidateInfos[fullName] then
				candidateInfos[fullName] = {}
			end
			local info = candidateInfos[fullName]
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
			info["role"] = UnitGroupRolesAssigned(unitID)
			info["guildName"] = guildName
			info["guildRank"] = guildRankName
			info["guildRankIndex"] = guildRankIndex
			info["guid"] = UnitGUID("raid"..i)
		else
			RCEPGP:DebugPrint("GROUP_ROSTER_UPDATE uncached, retry after 1s.")
			self:ScheduleTimer("GROUP_ROSTER_UPDATE", 1)
		end
	end
end

function RCCustomEP:GUILD_ROSTER_UPDATE()
	if not IsInGuild() then return end
	if (not GetNumGuildMembers()) or (GetNumGuildMembers() == 0) then
		RCEPGP:DebugPrint("RCCustomEP", "GUILD_ROSTER_UPDATE", "but no infomation is fetched.")
		return
	end
	RCEPGP:DebugPrint("RCCustomEP", "GUILD_ROSTER_UPDATE")
	local guildName, _, _ = GetGuildInfo("player")
	self.playerGuild = guildName

	for i = 1, GetNumGuildMembers() do
		local fullName, rank, rankIndex, level, class, zone, note, officernote, online,
		status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo(i)
		if fullName then
			fullName = RCEPGP:GetEPGPName(fullName)
			if not candidateInfos[fullName] then
				candidateInfos[fullName] = {}
			end
			local info = candidateInfos[fullName]

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
			if (not UnitInRaid(Ambiguate(fullName, "short")) and not UnitInParty(Ambiguate(fullName, "short"))) then
				info["online"] = online
				info["level"] = level
				info["zone"] = zone
			end
		end
	end
	GuildRoster()
end

function RCCustomEP:GetEventTimeDiff(month, day, year, hour, min)
	if year < 100 then year = year + 2000 end
	local eventTime = time({year=year, month=month, day=day, hour=hour, min=min, sec=0})
	-- Get current server time
	local _, month, day, year = CalendarGetDate()
	local hour, min = GetGameTime()
	local now = time({year=year, month=month, day=day, hour=hour, min=min, sec=0})
	return eventTime - now
end

function RCCustomEP:GenerateEventID(offset, day, i)
	if offset >= 0 then
		return offset*10000+day*100+i
	else
		return offset*10000-day*100-i
	end
end

-- Check the events in yesterday, today and tomorrow and open all guild events within +-12h of now.
function RCCustomEP:UPDATE_CALENDAR()
	if _G.CalendarFrame and (not self:IsHooked(_G.CalendarFrame, "OnHide")) then
		self:SecureHookScript(_G.CalendarFrame, "OnHide", function() self:UPDATE_CALENDAR() end)
	end
	if _G.CalendarFrame and _G.CalendarFrame:IsShown() then
		return -- Don't update when Blizzard calendar is shown
	end

	RCEPGP:DebugPrint("RCCustomEP", "UPDATE_CALENDAR")

	local prevMonth, prevYear, prevNumDays = CalendarGetMonth(-1);
	local nextMonth, nextYear, nextNumDays = CalendarGetMonth(1);
	local month	   , year	 , numDays 	   = CalendarGetMonth();

	local weekday, month, day, year = CalendarGetDate()
	local existEvents = {}
	wipe(eventOpenQueue)

	local monthYesterday, dayYesterday, yearYesterday, offsetYesterday
	if day == 1 then
		offsetYesterday = -1
		monthYesterday = prevMonth
		dayYesterday = prevNumDays
		yearYesterday = prevYear
	else
		offsetYesterday = 0
		monthYesterday = month
		dayYesterday = day - 1
		yearYesterday = year
	end

	local monthTomorrow, dayTomorrow, yearTomorrow, offsetTomorrow
	if day == numDays then
		offsetTomorrow = 1
		monthTomorrow = nextMonth
		dayTomorrow = 1
		yearTomorrow = nextYear
	else
		offsetTomorrow = 0
		monthTomorrow = month
		dayTomorrow = day + 1
		yearTomorrow = year
	end

	-- Check yesterday
	for i=1, CalendarGetNumDayEvents(offsetYesterday, dayYesterday) do
		local event = C_Calendar.GetDayEvent(offsetYesterday, dayYesterday, i)
		local id = self:GenerateEventID(offsetYesterday, dayYesterday, i)
		if event then
			local title, startTime, calendarType = event.title, event.startTime, event.calendarType
			if event and event.calendarType == "GUILD_EVENT" and math.abs(self:GetEventTimeDiff(startTime.month, startTime.monthDay, startTime.year, startTime.hour, startTime.minute)) < 12*60*60 then -- within +- 12h
				existEvents[id] = true
				tinsert(eventOpenQueue, {offsetYesterday, dayYesterday, i})
			end
		end
	end

	-- Check today
	for i=1, CalendarGetNumDayEvents(0, day) do
		local event = C_Calendar.GetDayEvent(0, day, i)
		local id = self:GenerateEventID(0, day, i)
		if event then
			local title, startTime, calendarType = event.title, event.startTime, event.calendarType
			if event and event.calendarType == "GUILD_EVENT" and math.abs(self:GetEventTimeDiff(startTime.month, startTime.monthDay, startTime.year, startTime.hour, startTime.minute)) < 12*60*60 then -- within +- 12h
				existEvents[id] = true
				tinsert(eventOpenQueue, {0, day, i})
			end
		end
	end

	-- Check yesterday
	for i=1, CalendarGetNumDayEvents(offsetTomorrow, dayTomorrow) do
		local event = C_Calendar.GetDayEvent(offsetTomorrow, dayTomorrow, i)
		local id = self:GenerateEventID(offsetTomorrow, dayTomorrow, i)
		if event then
			local title, startTime, calendarType = event.title, event.startTime, event.calendarType
			if event and event.calendarType == "GUILD_EVENT" and math.abs(self:GetEventTimeDiff(startTime.month, startTime.monthDay, startTime.year, startTime.hour, startTime.minute)) < 12*60*60 then -- within +- 12h
				existEvents[id] = true
				tinsert(eventOpenQueue, {offsetTomorrow, dayTomorrow, i})
			end
		end
	end

	for id, _ in pairs(eventInfos) do
		if not existEvents[id] then
			eventInfos[id] = nil
		end
	end
end

-- This module calls CalendarOpenEvent with additional argument identifer to know if the call if made by us.
function RCCustomEP:OnCalendarOpenEvent(offset, day, index, identifier)
	if identifier ~= "RCCustomEP" then
		lastOtherCalendarOpenEvent = GetTime()
	end
end

-- Process event open queue (open one event in the queue) every several second.
function RCCustomEP:ProcessEventOpenQueue()
	self:ScheduleTimer("ProcessEventOpenQueue", 2)
	if _G.CalendarFrame and _G.CalendarFrame:IsShown() then
		return -- Don't update when Blizzard calendar is shown
	end
	if GetTime() < lastOtherCalendarOpenEvent + 20 then  -- temporary supends this module open events when other program open events for 20s
		return
	end
	local entry = tremove(eventOpenQueue, 1)
	if entry then
		CalendarOpenEvent(entry[1], entry[2], entry[3], "RCCustomEP")
	end
end

function RCCustomEP:OPEN_CALENDAR()
	local title, description, creator, eventType, repeatOption, maxSize, textureIndex, weekday, month, day, year, hour, minute,
	lockoutWeekday, lockoutMonth, lockoutDay, lockoutYear, lockoutHour, lockoutMinute, locked, autoApprove, pendingInvite,
	inviteStatus, inviteType, calendarType = CalendarGetEventInfo()

	RCEPGP:DebugPrint("RCCustomEP", "OPEN_CALENDAR", tostring(title))

	if calendarType == "GUILD_EVENT" and math.abs(self:GetEventTimeDiff(month, day, year, hour, minute)) < 12*60*60 then
		local monthOffset, day, index = CalendarGetEventIndex()
		local id = self:GenerateEventID(monthOffset, day, index)
		if not eventInfos[id] then
			eventInfos[id] = {}
		end
		eventInfos[id].title = title
		eventInfos[id].month = month
		eventInfos[id].day = day
		eventInfos[id].year = year
		eventInfos[id].hour = hour
		eventInfos[id].minute = minute

		if not eventInfos[id].signupList then
			eventInfos[id].signupList = {}
		end
		wipe(eventInfos[id].signupList)

		for i = 1, CalendarEventGetNumInvites() do
			local name, level, className, classFileName, inviteStatus, modStatus, inviteIsMine, inviteType = CalendarEventGetInvite(i)
			if name then
				name = RCEPGP:GetEPGPName(name)
				local info
				if not eventInfos[id].signupList[name] then
					eventInfos[id].signupList[name] = {}
				end
				info = eventInfos[id].signupList[name]
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
	end
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

function RCCustomEP:StartRecurringEP(reason, amount, periodMin, formulaIndexOrName)
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
		vars.recurring_ep_period_mins = tonumber(periodMin)
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
--@param ... the formulas
function RCCustomEP:IncMassEPBy(reason, amount, ...)
	amount = tonumber(amount)
	if not amount then
		RCEPGP:Print("[amount] must be a number") -- TODO locale
		return
	end

	if not select(1, ...) then
		RCEPGP:Debug("Origin MassEP", reason, amount)
		return EPGP:IncMassEPBy(reason, amount)
	end

	if not self.initialize then return end

	local awarded_mains = {}
	local awarded_list = {}
	RCEPGP:Debug("Custom MassEP", reason, amount, ...)

	for _, formulaIndexOrName in ipairs({...}) do
		local formula
		for index=1,RCEPGP:GetEPGPdb().customEP.EPFormulas.count do
			local f = RCEPGP:GetEPGPdb().customEP.EPFormulas[index]
			if index == tonumber(formulaIndexOrName) or f.name == formulaIndexOrName then
				formula = f
				break
			end
		end
		if not formula then
			return RCEPGP:Print(format(LEP["Formula 'formula' does not exist"], formulaIndexOrName))
		end

		for name, info in pairs(candidateInfos) do
			name = RCEPGP:GetEPGPName(name)
			local ep, _, main = EPGP:GetEPGP(name)
			main = main or name
			if ep then
				local onlineCoeff
				if info["online"] then
					onlineCoeff = formula.online
				else
					onlineCoeff = formula.offline
				end
				local groupCoeff
				if UnitInRaid(Ambiguate(name, "short")) or UnitInParty(Ambiguate(name, "short")) then
					groupCoeff = formula.inGroup
				elseif EPGP:IsMemberInExtrasList(name) then
					groupCoeff = formula.standby
				else
					local signedUpInEvent = false
					for _, event in pairs(eventInfos) do
						local signupStatus = event.signupList[name]
						if signupStatus and signupStatus ~= _G.CALENDAR_INVITESTATUS_OUT
							and signupStatus ~= _G.CALENDAR_INVITESTATUS_TENTATIVE then
								signedUpInEvent = true
						end
					end
					if signedUpInEvent then
						groupCoeff = formula.calendarSignedUp
					else
						groupCoeff = formula.completelyNotInGroup
					end
				end
				local rankCoeff
				if info["guildName"] ~= self.playerGuild then
					rankCoeff = formula.notInGuild
				else
					local rankIndex = info["guildRankIndex"] or ""
					rankCoeff = formula["isRank"..rankIndex] or 0
				end

				print(name, onlineCoeff, groupCoeff, rankCoeff)


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

-----------------------------------------------------------------------------------------------

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
