-- Rotector Defined Enumerators

local RoEnums = {}

-- Enum Types for flag status.
local FlagTypes = {
	UNFLAGGED = 0,
	FLAGGED = 1,
	CONFIRMED = 2,
	QUEUED = 3,
	INTEGRATION = 4,
	MIXED = 5,
	PAST_OFFENDER = 6,
}
RoEnums.FlagTypes = FlagTypes

local SourceTypes = {
	BLOXLINK = 0,
	ROVER = 1,
	DISCORD = 2,
}
RoEnums.SourceTypes = SourceTypes

local VersionTypes = {
	COMPATIBLE = "compatible",
	OUTDATED = "outdated",
	CURRENT = "current",
	UNKNOWN = "unknown",
	NONE = "unknown",
}
RoEnums.VersionTypes = VersionTypes

-- Enum Types for user status reasoning.
local UserReasonTypes = {
	USER_PROFILE = "User Profile",
	FRIEND_NETWORK = "Friend Network",
	AVATAR_OUTFIT = "Avatar Outfit",
	GROUP_MEMBERSHIP = "Group Membership",
	CONDO_ACTIVITY = "Condo Activity",
	CHAT_MESSAGES = "Chat Messages",
	GAME_FAVORITES = "Game Favorites",
	EARNED_BADGES = "Earned Badges",
	USER_CREATIONS = "User Creations",
	OTHER_REASONS = "Other Reasons",
}
RoEnums.UserReasonTypes = UserReasonTypes

-- Enum Types for group status reasoning.
local GroupReasonTypes = {
	MEMBER = "Member Analysis",
	PURPOSE = "Group Purpose",
	DESCRIPTION = "Group Description",
	SHOUT = "Group Shout",
}
RoEnums.GroupReasonTypes = GroupReasonTypes

-- Enum Types for strict level checking.
local StrictLevel = {
	NONE = 0,
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
}
RoEnums.StrictLevel = StrictLevel

-- Enum to Flag comparison check.
-- Only localized to this module.
local FLAG_ISUNSAFE_LEVEL = {
	[FlagTypes.CONFIRMED] = 0,
	[FlagTypes.FLAGGED] = 1,
	[FlagTypes.MIXED] = 2,
	[FlagTypes.PAST_OFFENDER] = 3,
}

local FLAG_NAMES = {
	[FlagTypes.UNFLAGGED] = "UNFLAGGED",
	[FlagTypes.FLAGGED] = "FLAGGED",
	[FlagTypes.CONFIRMED] = "CONFIRMED",
	[FlagTypes.QUEUED] = "QUEUED",
	[FlagTypes.INTEGRATION] = "INTEGRATION",
	[FlagTypes.MIXED] = "MIXED",
	[FlagTypes.PAST_OFFENDER] = "PAST_OFFENDER",
}

local SOURCE_NAMES = {
	[SourceTypes.BLOXLINK] = "Bloxlink",
	[SourceTypes.ROVER] = "RoVer",
	[SourceTypes.DISCORD] = "Discord Profile",
}

local DISPLAY_AS_SEVERITY = {
	[UserReasonTypes.CHAT_MESSAGES] = true,
	[UserReasonTypes.CONDO_ACTIVITY] = true,
	[UserReasonTypes.OTHER_REASONS] = true,
}

-- Metamethods

function RoEnums.GetFlagName(flagType)
	assert(flagType, "Invalid flagType level")
	return FLAG_NAMES[flagType] or "UNKNOWN";
end

function RoEnums.GetReasonDescriptions(reasonsGiven, isGroup)
	if not reasonsGiven then return {} end

	local reasonDescs = {}
	for reasonKey, reasonData in pairs(reasonsGiven) do
		-- TODO: More complex and refined text method for detailed ban reason usage.
		-- ReasonData contains confidence, evidence, and message. Evidence has additional data as an iterable table.
		local reasonText = `{reasonKey}: {math.ceil(reasonData.confidence * 100)}%`
		if DISPLAY_AS_SEVERITY[reasonKey] then
			reasonText = reasonText .. " Severity Level"
		else
			reasonText = reasonText .. " Confidence"
		end

		table.insert(reasonDescs, reasonText)
	end

	return reasonDescs
end

function RoEnums.IsUnsafeFlag(flagType, strictLevel)
	assert(flagType, "Invalid flagType level")

	local flagLevel = FLAG_ISUNSAFE_LEVEL[flagType]
	strictLevel = strictLevel or 0

	return (flagLevel and flagLevel <= strictLevel)
end

function RoEnums.HasCondoFlag(reasonData, anyFlags)
	assert(reasonData, "No reason table data defined.")

	local hasCondoFlag = reasonData[UserReasonTypes.CONDO_ACTIVITY]
	if hasCondoFlag then
		local hasTrueFlags = hasCondoFlag.message:lower():find("[(discord)][(trap)]")
		return (hasCondoFlag.evidence and #hasCondoFlag.evidence > 0) or hasTrueFlags
	end

	local hasOtherFlag = reasonData[UserReasonTypes.OTHER_REASONS]
	return (hasOtherFlag and hasOtherFlag.message:lower():find("[(condo)]")) or (hasCondoFlag and anyFlags)
end

function RoEnums.HasRR34Flag(reasonData)
	assert(reasonData, "No reason table data defined.")

	local hasFlag = reasonData[UserReasonTypes.OTHER_REASONS]
	if not hasFlag then return end

	return hasFlag.message:lower():find("[(r34)][(rr34)]")
end

return RoEnums
