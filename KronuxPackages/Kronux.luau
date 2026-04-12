local HttpService = game:GetService("HttpService")

local function getVersion()
    local success, result = pcall(function()
        return HttpService:GetAsync("https://raw.githubusercontent.com/ulexicxd/Kronux/main/version.txt")
    end)

    if success then
        return tostring(result)
    else
        warn("Failed to fetch version: " .. tostring(result))
        return "unknown"
    end
end

return {
    require(script.Parent.KronuxCore),
    require(script.Parent.KronuxUI),
    getVersion = getVersion,
}