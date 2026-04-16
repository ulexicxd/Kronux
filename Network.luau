local HTTPService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local VersionGithubURL = "https://raw.githubusercontent.com/ulexicxd/Kronux/main/version.txt"
local CurrentVersion = "1.0"
local Config = {
    WarningsEnabled = true,
    CriticalUpdateStopsExecution = true,
}

--// Updates, remove if none wanted. Note, when removed, critical updates will not be shown. Remove at your own risk.

-- start
local success, LatestVersion = pcall(function()
    return HTTPService:GetAsync(VersionGithubURL)
end)

if success then
    if LatestVersion ~= CurrentVersion then
        if string.find(CurrentVersion, "CRITICAL") then
            local errorMessage = "[Network]: Critical update available. Please update to the latest version immediately."
            
            if Config.CriticalUpdateStopsExecution then
                error(errorMessage)
            else
                warn(errorMessage)
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
-- end

--// Module
local Network = {}
Network.__index = Network

Network.Networks = {}

function Network.new(NetworkName: string)
    local self = setmetatable({}, Network)
    
    local networkFolder = instance.new("Folder")
    networkFolder.Name = NetworkName
    networkFolder.Parent = script
    
    local networkConnect = Instance.new("RemoteFunction")
    networkConnect.Name = "NetworkConnect"
    networkConnect.Parent = networkFolder

    networkConnect.OnServerInvoke = function(player: Player)
        return Network.Shared
    end

    self.NetworkId = NetworkName
    self.NetworkLocked = false

    self.Shared = {}

    network.Networks[self.NetworkId] = self
    return self
end

function Network:CreateBridge(BridgeName: string)
    if not RunService:IsClient() then
        local Bridge = Instance.new("RemoteFunction")
        Bridge.Parent = script:FindFirstChild(self.NetworkId)
        Bridge.Name = BridgeName
        
        Network.Networks[self.NetworkId][BridgeName] = Bridge:InvokeServer

        return function(callback: () -> any)
            Bridge.OnserverInvoke = callback
        end
    end
end

function Network.ConnectToNetwork(networkName: string)
    if RunService:IsClient() then
        local networkFolder = script:FindFirstChild(networkName)

        if networkFolder then
            local networkConnect = networkFolder:FindFirstChild("NetworkConnect")

            if networkConnect then
                return networkConnect:InvokeServer()
            else
                warn("[Network]: 'NetworkConnect' event not found in network '" .. networkName .. "'.")
            end
        else
            warn("[Network]: Network '" .. networkName .. "' not found.")
        end
    else

    end
end

return Network