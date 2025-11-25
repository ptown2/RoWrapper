local Players = game:GetService("Players")
local ServerService = game:GetService("ServerScriptService")
local RotectorScript = ServerService:WaitForChild("RotectorWrapper")

local RotectorClient = require(RotectorScript)
local ExportTypes = require(RotectorScript.ExportTypes)

-- Setup client data.
RotectorClient.SetBaseClientData({
	AllowInternalChecks = true,
	ClientURL = "https://roscoe.robalyx.com/v1/",
	Endpoints = {
		Users = "lookup/roblox/user",
		Groups = "lookup/roblox/group",
	},
})

-- Setup a config for async bans
local BanAsyncConfig: BanConfigType = {
	Duration = -1,
	DisplayReason = "You have been flagged as a potential unsafe user, please contact us for more information.",
	PrivateReason = "<Default Rotector Reason>",
	ExcludeAltAccounts = false,
	ApplyToUniverse = true,
}

-- Add a hook for when user checking is called.
RotectorClient.Hook.Add("OnUserCheck", "TargetPureUnsafe", function(data: ExportTypes.RotectorData, playerObject: Player)
	local enum = RotectorClient.Enums

	-- If you're doing manual checks, most likely this will come out nil.
	-- But it tries to capture the player IF it exists in the server.
	print(playerObject)

	-- Can use to verify confidence levels
	if data.confidence and data.confidence < 0.25 then return end

	-- Even check if they're still pending to be fully reviewed.
	if data.flagType == enum.FlagTypes.PENDING then
		warn(`This user is still pending for review, proceed with caution...`)
	end

	-- It now has strict level checking, defaults to 1 for UNSAFE; 2 for UNSAFE + MIXED; 3 for BOTH + PAST OFFENDER
	if enum.IsUnsafeFlag(data.flagType, enum.StrictLevel.MEDIUM) then
		print(`ALARM! UNSAFE USER ID {playerObject or data.id}!`)

		-- Condo users begone.
		if data.reasons and enum.IsConfirmedCondoFlag(data.reasons) then
			warn(`DANGER!!! {playerObject or data.id} IS CONFIRMED CONDO USER!!!`)

			-- Setup the final parts of the BanAsync.
			BanAsyncConfig.UserIds = { data.id }
			BanAsyncConfig.PrivateReason = table.concat(enum.GetReasonDescriptions(data.reasons), ", ")

			local success, err = pcall(function()
				Players:BanAsync(BanAsyncConfig)
			end)
		end
	else
		print(`Player {playerObject or data.id} came out without any unsafe flags for now.`)
	end
end)
