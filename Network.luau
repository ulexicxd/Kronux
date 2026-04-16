local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local Network = {}
Network.__index = Network
Network.Networks = {}

function Network.new(name: string)
	if RunService:IsClient() then
		error("Network.new can only be used on the server")
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = ReplicatedStorage

	local connector = Instance.new("RemoteFunction")
	connector.Name = "NetworkConnect"
	connector.Parent = folder

	local self = setmetatable({
		NetworkId = name,
		NetworkFolder = folder,
		NetworkLocked = false,
		Shared = {},
		Remotes = {},
	}, Network)

	connector.OnServerInvoke = function(player)
		return {
			NetworkId = name
		}
	end

	Network.Networks[name] = self
	return self
end

function Network:CreateBridge(name: string)
	if RunService:IsClient() then
		error("CreateBridge can only be used on the server")
	end

	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = self.NetworkFolder

	self.Remotes[name] = remote

	return function(callback)
		remote.OnServerInvoke = callback
	end
end

function Network.ConnectToNetwork(name: string)
	if RunService:IsServer() then
		error("ConnectToNetwork can only be used on the client")
	end

	local folder = ReplicatedStorage:WaitForChild(name)
	local connector = folder:WaitForChild("NetworkConnect")

	connector:InvokeServer()

	local self = setmetatable({
		NetworkId = name,
		NetworkFolder = folder,
		Shared = {},
	}, Network)

	for _, obj in ipairs(folder:GetChildren()) do
		if obj:IsA("RemoteFunction") and obj.Name ~= "NetworkConnect" then
			self.Shared[obj.Name] = function(_, ...)
				return obj:InvokeServer(...)
			end
		end
	end

	return self
end

return Network