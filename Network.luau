--// Dependencies

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables

local VersionGithubURL = "https://raw.githubusercontent.com/ulexicxd/Kronux/main/version.txt"
local CurrentVersion = "1.0"

local Config = {
	WarningsEnabled = true,
	CriticalUpdateStopsExecution = true,
}

--// Updates, remove if none wanted. Note, when removed, critical updates will not be shown. Remove at your own risk.

-- start
if RunService:IsServer() then
	local success, latest = pcall(function()
		return HttpService:GetAsync(VersionGithubURL)
	end)

	if success then
		if latest ~= CurrentVersion then
			if tostring(CurrentVersion):find("CRITICAL") then
				local msg = "[Network]: Critical update available. Please update immediately."

				if Config.CriticalUpdateStopsExecution then
					error(msg)
				else
					warn(msg)
				end
			else
				if Config.WarningsEnabled then
					warn("[Network]: New version available.")
				end
			end
		end
	else
		if Config.WarningsEnabled then
			warn("[Network]: Failed to check for updates.")
		end
	end
end
-- end

--// Module

local Utils = {}

--// Signals

Utils.Signals = {}
Utils.Signals.__index = Utils.Signals

function Utils.Signals.new()
	local self = setmetatable({}, Utils.Signals)

	self._listeners = {}

	return self
end

function Utils.Signals:Connect(callback)
	table.insert(self._listeners, callback)

	return {
		Disconnect = function()
			for i, listener in ipairs(self._listeners) do
				if listener == callback then
					table.remove(self._listeners, i)
					break
				end
			end
		end,
	}
end

function Utils.Signals:Fire(...)
	for _, listener in ipairs(self._listeners) do
		coroutine.wrap(listener)(...)
	end
end

function Utils.Signals:Wait()
	local event = Instance.new("BindableEvent")
	local connection

	connection = self:Connect(function(...)
		event:Fire(...)
		connection:Disconnect()
	end)

	return event.Event:Wait()
end

function Utils.Signals:Destroy()
	self._listeners = {}
	self = nil
end

function Utils.Signals:Once(callback)
	local connection

	connection = self:Connect(function(...)
		callback(...)
		connection:Disconnect()
	end)
end

--// Other

function Utils:MergeTables(t1, t2)
	local merged = {}

	for key, value in pairs(t1) do
		merged[key] = value
	end

	for key, value in pairs(t2) do
		merged[key] = value
	end

	return merged
end

function Utils:DeepCopyTable(tbl)
	local copy = {}

	for key, value in pairs(tbl) do
		if type(value) == "table" then
			copy[key] = self:DeepCopyTable(value)
		else
			copy[key] = value
		end
	end

	return copy
end

function Utils:Lerp(a, b, t)
	return math.lerp(a, b, t)
end

function Utils:MoveForward(part, distance)
	local forwardVector = part.CFrame.LookVector
	part.CFrame = part.CFrame + forwardVector * distance
end

function Utils:MoveRight(part, distance)
	local rightVector = part.CFrame.RightVector
	part.CFrame = part.CFrame + rightVector * distance
end

function Utils:MoveUp(part, distance)
	local upVector = part.CFrame.UpVector
	part.CFrame = part.CFrame + upVector * distance
end

return Utils