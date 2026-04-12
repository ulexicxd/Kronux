local HttpService = game:GetService("HttpService")

local function getVersion()
    local success, result = pcall(function()
        return HttpService:GetAsync("https://raw.githubusercontent.com/ulexic/Kronux/main/version.txt")
    end)

    if success then
        return result
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