-- This is a TODO thing, but idk how I can make this work properly.
-- Someone please teach me exporting data types for type checking.

export type RoWrapper = {
	Players: Players,
	Hook: HookManager,
	HTTPModule: HTTPModule,
	Enums: RoEnums,

	-- Sets variables defined on the function call to the <strong>ClientData</strong> structure.
	SetBaseClientData: typeof(function(clientdata: any) end),

	-- Generates a Rotector Client based-url on the endpoint type defined by the <strong>ClientData</strong> structure.
	-- Returns a Rotector Client URL requestable <strong>string</strong>.
	GenerateRequestURL: typeof(function(urlType: string, appendUrl: string?) return "" end),

	-- Check for a specific user's status.
	-- Uses <code>OnUserCheck</code> hook on-call, if successful.
	-- Additionally, returns a Rotector data status <strong>dictionary</strong>, if successful.
	CheckUserStatus: typeof(function(userId: string | number, ignoreCache: boolean?, useRetries: boolean) return {_G} end),

	-- Checks for multiple user statuses at once, <strong>up to 100 users</strong>. Iterable table with <code>userId</code> as <strong>integers</strong>.
	-- Uses <code>OnUserBatchCheck</code> hook on-call, if successful.
	-- Additionally, returns an <strong>iterable dictionary</strong> of <code>userIds</code> and their respective <strong>Rotector data status</strong>.
	-- TODO: Handle instancing of all players grabbed by this data, if applicable.
	CheckMultipleUserStatuses: typeof(function(userIds: {number}, ignoreCache: boolean?, useRetries: boolean) return {_G} end),

	-- Checks for a specific group's status.
	-- Uses <code>OnGroupCheck</code> hook on-call, if successful.
	-- Additionally, returns a <strong>dictionary</strong> of Rotector data status.
	CheckGroupStatus: typeof(function(groupIds: string | number, ignoreCache: boolean?, useRetries: boolean) return {_G} end),

	-- Checks for multiple group statuses at once, <strong>up to 100 groups</strong>. Iterable table with <code>groupId</code> as <strong>integers</strong>.
	-- Uses <code>OnGroupBatchCheck</code> hook on-call, if successful.
	-- Returns an <strong>iterable dictionary</strong> of <code>groupIds</code> and their respective <strong>Rotector data status</strong>.
	CheckMultipleGroupStatuses: typeof(function(groupIds: {number}, ignoreCache: boolean?, useRetries: boolean) return {_G} end),
}

export type HTTPModule = {
	HTTPService: HttpService,

	-- Handles <code>RequestAsync</code> internally for <code>GET|POST</code> requests to Rotector Client defined-urls.
	-- Returns the <strong>JSON Decoded Body of the request</strong>, or <strong>nil</strong> plus an error to console.
	RequestToUrl: typeof(function(urlReq: string, bodyReq: any, canRetry: boolean) return {_G} end),
}

export type HookManager = {
	-- Returns a table of all the hooks created within.
	GetTable: typeof(function() return {_G} end),

	-- Creates a script hooking element based on the indentified hook's event name and function when called from other scripts.
	Add: typeof(function(eventName: string, hookName: string, hookFunc: (any) -> any) end),

	-- Same as <code>HookManager.Add</code> method but removes the hook based on the event name and unique name suppplied.
	Remove: typeof(function(eventName: string, hookName: string) end),

	-- Calls the all the hook events defined by the event name. Hooks under the same event identifier will trigger all at once.
	Call: typeof(function(eventName: string, ...: any) return _G end),

	-- An additional alias for <code>HookManager.Call</code> function.	
	Run: typeof(function(eventName: string, ...: any) return _G end),
}

export type RoEnums = {
	FlagTypes: {
		SAFE: number,
		PENDING: number,
		UNSAFE: number,
		QUEUED: number,
		INTEGRATION: number,
		MIXED: number,
		PAST_OFFENDER: number,
	},

	UserReasonTypes: {
		USER_PROFILE: string,
		FRIEND_NETWORK: string,
		AVATAR_OUTFIT: string,
		GROUP_MEMBERSHIP: string,
		CONDO_ACTIVITY: string,
		CHAT_MESSAGES: string,
		GAME_FAVORITES: string,
		EARNED_BADGES: string,
		USER_CREATIONS: string,
		OTHER_REASONS: string,
	},

	GroupReasonTypes: {
		MEMBER: string,
		PURPOSE: string,
		DESCRIPTION: string,
		SHOUT: string,
	},

	StrictLevel: {
		NONE: number,
		LOW: number,
		MEDIUM: number,
		HIGH: number,
	},

	-- Gives the contextual name of the enum value based on the <code>flagType</code>.
	-- Returns the flag's name as a <code>string</code>.
	GetFlagName: typeof(function(flagType: number) return "" end),

	-- Gives a <strong>contextual description</strong> of the enum values based on the <code>reasonsGiven</code> structure.
	-- Returns a <code>table</code> of human-readable descriptions for why a user was flagged. 
	GetReasonDescriptions: typeof(function(reasonsGiven: {[string]: string}, isGroup: boolean?) return {""} end),
	
	-- Verifies if the given <code>flagType</code> reason is considered <code>UNSAFE</code> based on the <code>strictLevel</code> value.
	-- Returns a <code>boolean</code> if the user/group is contextually unsafe.
	IsUnsafeFlag: typeof(function(flagType: number, strictLevel: number?) return true end),
	
	-- Verifies if the given <code>reasonData</code> structure contains a condo flag or element applied.
	-- Returns a <code>boolean</code> if the user/group is contextually condo related.
	-- -----
	-- TODO: Include support for contextualizing groups. At least they're group purposed when reviewed?	
	IsConfirmedCondoFlag: typeof(function(reasonData: {any}) return true end),
}

export type RotectorData = {
	id: number,
	flagType: number,
	engineVersion: string,
	confidence: number,
	lastUpdated: number,
	processed: boolean,
	processedAt: number,
	queuedAt: number,
	reasons: {
		[string]: RotectorReasonsData
	},
}

export type RotectorReasonsData = {
	confidence: number,
	evidence: {
		[number]: string
	},
	message: string,
}

return nil
