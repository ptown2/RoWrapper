local HTTPModule = {
	HTTPService = game:GetService("HttpService"),
}

-- Internal function to handle HTTP related errors.
local function HandleErrorReport(warntext: string): nil
	warn("An error occured! " .. warntext)
	return nil
end

function HTTPModule.RequestToUrl(urlReq, bodyReq)
	local is_post = (bodyReq and type(bodyReq) == "table")

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
			requestData.Body = self.HTTPService:JSONEncode(bodyReq)
		end

		return self.HTTPService:RequestAsync(requestData)
	end)

	-- Sent during a failed http request.
	if not success then
		return HandleErrorReport(`Error making request {response}`)
	end

	-- Extremely unlikely but who knows...
	if not response then
		return HandleErrorReport("Did this pcall fail to send something?")
	end

	-- Given during a failed response.
	if not response.Success then
		return HandleErrorReport(`HTTP response error! Err. Code {response.StatusCode}: {response.StatusMessage}`)
	end

	-- Check if it can be decoded.
	local passBody, jsonBody = pcall(function()
		return self.HTTPService:JSONDecode(response.Body)
	end)

	-- Future proofing for now...
	--[[
	local passHeader, jsonHeader = pcall(function()
		return self.HTTPService:JSONDecode(response.Header)
	end)
	]]

	if not passBody then
		return HandleErrorReport(`Invalid JSON data! {jsonBody}`)
	end

	return jsonBody
end

return HTTPModule
