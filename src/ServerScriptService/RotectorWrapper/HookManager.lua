-- Hook module forked and modified entirely from Garry's Mod... UGLY I KNOW!

local HookManager = {}
local RegisteredHooks = {}

-- Checks if the argument supplied is properly valid.
-- PS: lol... lmao even? this doesn't work properly on ROBLOX but whatever...
local function IsValid(object)
	if not object or object == nil then
		return false
	end

	return true
end

function HookManager.GetTable()
	return RegisteredHooks
end

function HookManager.Add(eventName, hookName, hookFunc)
	if type(eventName) ~= "string" then
		warn(`Bad argument #1 to 'Add' (string expected, got {type(eventName)})`)
		return 
	end

	if type(hookFunc) ~= "function" then
		warn(`Bad argument #3 to 'Add' (function expected, got {type(hookFunc)})`)
		return
	end

	local typeCheck = type(hookName)
	local notValid = not IsValid(hookName) or (typeCheck == "number" or typeCheck == "boolean" or typeCheck == "function")
	if type(hookName) ~= "string" and notValid then
		warn(`Bad argument #2 to 'Add' (string expected, got {type(hookName)})`)
		return
	end

	if RegisteredHooks[eventName] == nil then
		RegisteredHooks[eventName] = {}
	end

	RegisteredHooks[eventName][hookName] = hookFunc
end

function HookManager.Remove(eventName, hookName)
	if type(eventName) ~= "string" then
		warn(`Bad argument #1 to 'Remove' (string expected, got {type(eventName)})`)
		return
	end

	local typeCheck = type(hookName)
	local notValid = not IsValid(hookName) or (typeCheck == "number" or typeCheck == "boolean" or typeCheck == "function")
	if type(hookName) ~= "string" and notValid then
		warn(`Bad argument #2 to 'Remove' (string expected, got {type(hookName)})`)
		return
	end

	if not RegisteredHooks[eventName] then
		return
	end

	RegisteredHooks[eventName][hookName] = nil
end

function HookManager.Call(eventName, ...)
	local hookTable = RegisteredHooks[eventName]

	if hookTable ~= nil then
		local a, b, c, d, e, f, g, h
		for k, v in pairs(hookTable) do
			if type(k) == "string" then
				a, b, c, d, e, f, g, h = v(...)
			else
				if IsValid(k) then
					a, b, c, d, e, f, g, h = v(k, ...)
				else
					hookTable[k] = nil
				end
			end

			if a ~= nil then
				return a, b, c, d, e, f, g, h
			end
		end
	end
end

function HookManager.Run(eventName, ...)
	return HookManager.Call(eventName, ...)
end

return HookManager
