

local playersInfo = {}

function RCEP:UpdateGuildInfo()
	for i=1, GetNumGuildMembers() do
		local fullName, rank, rankIndex, level, class, zone, note, officernote, online,
			  status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo(i)
		if fullName then
			if not playersInfo[fullName] then
				playersInfo[fullName] = {}
			end
			local info = playersInfo[fullName]

			info["fullName"] = fullName
			info["guildRank"] = rank
			info["guildRankIndex"] = rankIndex
			info["note"] = note
			info["officernote"] = officernote
			info["status"] = status
			info["classFileName"] = classFileName -- NonLocalizedClassName
			info["achievementPoints"] = achievementPoints
			info["achievementRank"] = achievementRank
			info["isMobile"] = isMobile
			info["canSoR"] = canSoR
			info["reputation"] = reputation

			if not UnitInRaid(Ambiguate(fullName, "short")) then
				info["online"] = online
				info["level"] = level
				info["zone"] = zone
			end
		end
	end
end

function RCEP:UpdateRaidInfo()
	for i=1,40 do
		local name, rank, subgroup, level, class, classFileName, zone, online, isDead, groupRole, isML = GetRaidRosterInfo(i)
		if not playersInfo[fullName] then
			playersInfo[fullName] = {}
		end
		local info = playersInfo[fullName]
		if name then
			info["fullName"] = name
			info["raidRank"] = rank
			info["subgroup"] = subgroup
			info["level"] = level
			info["classFileName"] = classFileName
			info["zone"] = zone
			info["online"] = online
			info["isDead"] = isDead
			info["groupRole"] = groupRole
			info["isML"] = isML
			info["role"] = UnitGroupRolesAssigned("raid"..i)
		end
	end
end

function RCEP:GetUnitInfo(fullName, category)
	if not playersInfo[fullName] then
		return nil
	end
	return playersInfo[fullName][category]
end

function RCEP:GetPlayerFullName()
	local name, realm = UnitFullName("player")
	return name.."-"..realm
end


---------------------------------------------------------


function RCEP.IsOffline(fullName)
	return not RCEP:GetUnitInfo(fullName, "online")
end

function RCEP.IsNotInZone(fullName)
	local myFullName = RCEP:GetPlayerFullName()
	local myZone = RCEP:GetUnitInfo(myFullName, "zone")
	local zone = RCEP:GetUnitInfo(fullName, "zone")
	return zone ~= myZone
end

local conditionals ={
	{name = "offline", label = "Offline", cond = RCEP.IsOffline},
	{name = "isNotInZone", label = "Not In Zone", cond = RCEP.IsInZone},

}