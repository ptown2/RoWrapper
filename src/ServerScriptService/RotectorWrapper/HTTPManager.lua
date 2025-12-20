local HTTPModule = {
	HTTPService = game:GetService("HttpService"),

	MaxRequestRetries = 3,
	DelayPerRequest = 0.75,	-- This is semi-exponentially increased per retry.
}

-- Internal function to handle HTTP related errors.
local function HandleErrorReport(warntext: string): nil
	warn("An error occured! " .. warntext)
	return nil
end

function HTTPModule.RequestToUrl(urlReq, bodyReq, canRetry)
	local is_post = (bodyReq and type(bodyReq) == "table")
	local lastSuccess, lastResponse, attemptsMade

	local uuidRequest = HTTPModule.HTTPService:GenerateGUID(false)
	local retryDelay, maxRetries = HTTPModule.DelayPerRequest, HTTPModule.MaxRequestRetries

	-- No retries? Then just cap it to to 1 attempt.
	if not canRetry then
		maxRetries = 1
	end

	for attemptsMade = 1, maxRetries do
		local success, response = pcall(function()
			local requestData = {
				Url = urlReq,
				Method = is_post and "POST" or "GET",
				Headers = {
					["Content-Type"] = "application/json",
				}
			}

			-- This just assumes that anything in the body becomes a POST thing.
			-- Surely that won't bite me on the ass later on, right?! :clueless:
			if is_post then
				requestData.Body = HTTPModule.HTTPService:JSONEncode(bodyReq)
			end

			return HTTPModule.HTTPService:RequestAsync(requestData)
		end)

		lastSuccess = success
		lastResponse = response

		if success and response and response.Success then
			break
		end

		-- This is to ensure that it isn't complete silence during attempts.
		print(`HTTPRequest ("{uuidRequest}") Attempt #{attemptsMade} failed...`)

		if attemptsMade < maxRetries then
			task.wait(attemptsMade + attemptsMade * retryDelay)
		end
	end

	-- Sent during a failed http request.
	if not lastSuccess then
		return HandleErrorReport(`Error making request {lastResponse}`)
	end

	-- Extremely unlikely but who knows...
	if not lastResponse then
		return HandleErrorReport("Did this pcall fail to send something?")
	end

	-- Given during a failed response.
	if not lastResponse.Success then
		return HandleErrorReport(`HTTP response error! Err. Code {lastResponse.StatusCode}: {lastResponse.StatusMessage}`)
	end

	-- Check if it can be decoded.
	local passBody, jsonBody = pcall(function()
		return HTTPModule.HTTPService:JSONDecode(lastResponse.Body)
	end)

	-- Future proofing for now...
	--[[
	local passHeader, jsonHeader = pcall(function()
		return HTTPModule.HTTPService:JSONDecode(response.Header)
	end)
	]]

	if not passBody then
		return HandleErrorReport(`Invalid JSON data! {jsonBody}`)
	end

	return jsonBody
end

return HTTPModule
