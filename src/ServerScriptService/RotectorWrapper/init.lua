--!nonstrict

--[[
	RoWrapper, a ROBLOX LuaU based wrapper,
	with easier integration to check users.

	See CHANGELOGS for more changes or information.

	- ptown2
	Licensed under the GNU General Public License v2.0
]]

-- TODO: Fix everything regarding this... See ExportTypes module.

local ExportTypes = require("@self/ExportTypes")
local RoWrapper = {
	-- Allow for the wrapper to do internal checks, such as Player Connection?
	AllowInternalChecks = false,
	-- Cached User Information, retains based on CacheExpiry.
	CachedUserInfo = {},
	-- Cached Group Information, retains based on CacheExpiry.
	CachedGroupInfo = {},

	-- Table containing ClientConfigs, currently and mostly un-used for now.
	ClientConfig = {
		AllowInternalChecks = true,
		ExcludeAdvInfo = false,
		BatchSize = 100,
		BatchDelay = 0.25,
		MaxRetries = 3,
		RetryDelay = 100,
		Timeout = 10,
		CacheExpiry = 600,
	},

	Players = game:GetService("Players"),
	Hook = require("@self/HookManager"),
	HTTPModule = require("@self/HTTPManager"),
	Enums = require("@self/EnumManager"),
} :: ExportTypes.RoWrapper

function RoWrapper.SetBaseClientData(clientdata)
	assert(clientdata, "No base client data defined.")

	-- Do this automatically, in a shitty fashion for now.
	for baseKey, baseValue in pairs(clientdata) do
		-- For now, ignore already preset values.
		if RoWrapper[baseKey] then
			warn(`{baseKey} is already defined, ignoring.`)
			continue
		end

		RoWrapper[baseKey] = baseValue
	end
end

function RoWrapper.GenerateRequestURL(urlType, appendUrl)
	assert(RoWrapper.ClientURL, "No base client URL defined.")
	assert(RoWrapper.Endpoints and RoWrapper.Endpoints[urlType], "No user method defined.")

	local excludeInfo = tostring(RoWrapper.ClientConfig.ExcludeAdvInfo)
	local reqUrl = `{RoWrapper.ClientURL}{RoWrapper.Endpoints[urlType]}`

	-- Appends whatever data if its a GET request.
	if appendUrl then
		reqUrl = `{reqUrl}/{appendUrl}`
	end

	-- Sets the advanced info to be seen or not.
	reqUrl = `{reqUrl}?excludeInfo={excludeInfo}`

	return reqUrl
end

function RoWrapper.CheckUserStatus(userId, ignoreCache)
	assert(userId, "No user id defined.")

	-- Verify if the user that's being called is already cached. Expires at least 10 mins after request.
	local uIdString = tostring(userId)
	local userCache = RoWrapper.CachedUserInfo[uIdString]
	if not ignoreCache and userCache and userCache.cacheExpiry >= os.time() then
		return RoWrapper.CachedUserInfo.data
	end

	-- Do the user lookup request. Single user.
	local jsonTable = RoWrapper.HTTPModule.RequestToUrl(
		RoWrapper.GenerateRequestURL("Users", userId)
	)
	assert(jsonTable, "No JSON data output given?")

	-- Save this info for a while. Maybe use dataservers for this???
	RoWrapper.CachedUserInfo[uIdString] = {
		data = jsonTable.data,
		cacheExpiry = os.time() + RoWrapper.ClientConfig.CacheExpiry,
	}

	local plyInstance = RoWrapper.Players:GetPlayerByUserId(userId)
	RoWrapper.Hook.Call("OnUserCheck", jsonTable.data, plyInstance)

	return jsonTable.data
end

function RoWrapper.CheckMultipleUserStatuses(userIds)
	assert(userIds, "No users id defined.")

	-- Do the user lookup request but with multiple users.
	local jsonTable = RoWrapper.HTTPModule.RequestToUrl(
		RoWrapper.GenerateRequestURL("Users"), { ids = userIds }
	)
	assert(jsonTable, "No JSON data output???")

	RoWrapper.Hook.Call("OnUserBatchCheck", jsonTable.data)

	return jsonTable.data
end

function RoWrapper.CheckGroupStatus(groupId, ignoreCache)
	assert(groupId, "No group id defined.")

	-- Verify if the group that's being called is already cached. Expires at least 10 mins after request.
	local gIdString = tostring(groupId)
	local groupCache = RoWrapper.CachedGroupInfo[gIdString]
	if ignoreCache and groupCache and groupCache.cacheExpiry >= os.time() then
		return RoWrapper.CachedGroupInfo.data
	end

	-- Do the group lookup request. Single group.
	local jsonTable = RoWrapper.HTTPModule.RequestToUrl(
		RoWrapper.GenerateRequestURL("Groups", groupId)
	)
	assert(jsonTable, "No JSON data output given?")

	-- Save this info for a while. Maybe use dataservers for this???
	RoWrapper.CachedGroupInfo[gIdString] = {
		data = jsonTable.data,
		cacheExpiry = os.time() + RoWrapper.ClientConfig.CacheExpiry,
	}

	RoWrapper.Hook.Call("OnGroupCheck", jsonTable.data)

	return jsonTable.data
end

function RoWrapper.CheckMultipleGroupStatuses(groupIds)
	assert(groupIds, "No groups id defined.")

	-- Do the group lookup request but with multiple groups.
	local jsonTable = RoWrapper.HTTPModule.RequestToUrl(
		RoWrapper.GenerateRequestURL("Groups"), { ids = groupIds }
	)
	assert(jsonTable, "No JSON data output???")

	RoWrapper.Hook.Call("OnGroupBatchCheck", jsonTable.data)

	return jsonTable.data
end

-- Automatic Player Connection Handler for Checking User Status
-- Calls <code>CheckUserStatus</code> directly without additional handling.
RoWrapper.Players.PlayerAdded:Connect(function(player)
	local isAllow = RoWrapper.AllowInternalChecks
	if not isAllow then return end

	RoWrapper.CheckUserStatus(player.UserId)

	print(`[RoWrapper Notice] Player connected: {player.Name} #{player.UserId}`)
end)

return RoWrapper
