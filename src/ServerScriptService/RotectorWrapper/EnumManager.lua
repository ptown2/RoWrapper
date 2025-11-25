-- Rotector Defined Enumerators

local RoEnums = {}

-- Enum Types for flag status.
local FlagTypes = {
	SAFE = 0,
	PENDING = 1,
	UNSAFE = 2,
	QUEUED = 3,
	INTEGRATION = 4,
	MIXED = 5,
	PAST_OFFENDER = 6,
}
RoEnums.FlagTypes = FlagTypes

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
	[FlagTypes.UNSAFE] = 1,
	[FlagTypes.MIXED] = 2,
	[FlagTypes.PAST_OFFENDER] = 3,
}

local FLAG_NAMES = {
	[FlagTypes.SAFE] = "SAFE",
	[FlagTypes.PENDING] = "PENDING",
	[FlagTypes.UNSAFE] = "UNSAFE",
	[FlagTypes.QUEUED] = "QUEUED",
	[FlagTypes.INTEGRATION] = "INTEGRATION",
	[FlagTypes.MIXED] = "MIXED",
	[FlagTypes.PAST_OFFENDER] = "PAST_OFFENDER",
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
		-- ReasonData contains confidence, evidence, and message.
		table.insert(reasonDescs, `{reasonKey}: {reasonData.confidence}%`)
	end

	return reasonDescs
end

function RoEnums.IsUnsafeFlag(flagType, strictLevel)
	assert(flagType, "Invalid flagType level")

	local flagLevel = FLAG_ISUNSAFE_LEVEL[flagType]
	strictLevel = strictLevel or 1

	return (flagLevel and flagLevel <= strictLevel)
end

function RoEnums.IsConfirmedCondoFlag(reasonData)
	assert(reasonData, "No reason table data defined.")
	return (reasonData and reasonData[UserReasonTypes.CONDO_ACTIVITY])
end

return RoEnums
