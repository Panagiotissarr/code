--[[
██╗   ██╗ ██████╗ ██╗██████╗ ██╗    ██╗ █████╗ ██████╗ ███████╗
██║   ██║██╔═══██╗██║██╔══██╗██║    ██║██╔══██╗██╔══██╗██╔════╝
██║   ██║██║   ██║██║██║  ██║██║ █╗ ██║███████║██████╔╝█████╗
╚██╗ ██╔╝██║   ██║██║██║  ██║██║███╗██║██╔══██║██╔═══╝ ██╔══╝
 ╚████╔╝ ╚██████╔╝██║██████╔╝╚███╔███╔╝██║  ██║██║     ███████╗
  ╚═══╝   ╚═════╝ ╚═╝╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚══════╝

                🚀 VOIDWARE — Loader 🚀
----------------------------------------------------------------------------
  IMPORTANT:
  You must copy and use the FULL script below. Do NOT press on the link.:

  loadstring(game:HttpGet("https://code.sarris.dev/voidware/loader.lua", true))()

----------------------------------------------------------------------------
  For support head over to discord.gg/voidware
----------------------------------------------------------------------------
]]
repeat task.wait() until game:IsLoaded()
local meta = {
    [7326934954] = {
        title = "99 Nights In The Forest",
        dev = "vwdev/nightsintheforest.lua",
        script = "https://code.sarris.dev/voidware/nightsintheforest.lua"
    }
}
local data = meta[game.GameId]
pcall(function()
    shared.ACTIVE_LOADER:Destroy()
end)
local timedFunction = function(call, timeout, resFunction, ...)
	local suc, err
	local args = {}
	if call ~= nil and call == true then
		call = timeout
		timeout = 5
		args = {resFunction, ...}
	end
	task.spawn(function()
		suc, err = pcall(function()
			return call(unpack(args))
		end)
	end)
	timeout = timeout or 5
	local start = tick()
    repeat task.wait() until suc ~= nil or tick() - start >= timeout
	if suc == nil then
		suc = false
		err = "TIMEOUT_EXCEEDED"
	end
	if not suc then
		warn(debug.traceback(err))
	end
	if resFunction ~= nil and type(resFunction) == "function" then
		return resFunction(suc, err)
	end
	return suc, err
end
local __def_table = setmetatable({}, {
    __index = function(self) return self end,
    __call = function(self) return self end,
    __newindex = function(self) return self end
})
local loaderFile
if data ~= nil and data.no then
    loaderFile = __def_table
end
loaderFile = loaderFile or timedFunction(function()
    local httpOk, httpBody = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWExtra/3ec1c4abde539b3587265577e5c3dfe94d2f1b30/libraries/loader.lua", true)
    end)
    if not httpOk then
        error("Failed to fetch loader library: " .. tostring(httpBody))
    end
    if httpBody == nil or httpBody == "" then
        error("Loader library returned empty response from GitHub")
    end
    timedFunction(function()
        if not isfolder("voidware_libraries") then makefolder("voidware_libraries") end
        writefile("voidware_libraries/loader.lua", httpBody)
    end, 1)
    local loadSuc, loadErr = pcall(function() return loadstring(httpBody)() end)
    if not loadSuc then
        error("Failed to execute loader library: " .. tostring(loadErr))
    end
    return loadSuc and loadErr
end, 5, function(suc, err)
    return suc and err or timedFunction(function()
        if not isfolder("voidware_libraries") then makefolder("voidware_libraries") end
        if not isfile("voidware_libraries/loader.lua") then
            error("Loader file missing from voidware_libraries/loader.lua - no cached copy available")
        end
        local cachedData = readfile("voidware_libraries/loader.lua")
        if cachedData == nil or cachedData == "" then
            error("Cached loader file is empty or corrupted")
        end
        local loadSuc, loadErr = pcall(function() return loadstring(cachedData)() end)
        if not loadSuc then
            error("Failed to execute cached loader: " .. tostring(loadErr))
        end
        return loadSuc and loadErr
    end, 5, function(suc, err)
        return suc and err or __def_table
    end)
end)
local loader = loaderFile:Loader()
shared.ACTIVE_LOADER = loader
loader:Connect(function(res)
    if shared.VoidDev then
        warn(`LOADER RESULT: {tostring(res)}`)
    end
    shared.ACTIVE_LOADER = nil
end)
loader:Update("Booting Up...", 0)
loader:Update("Fetching Game Data...", 10)

if data and data.staging and not shared.VoidDev then
    data = nil
end
if not data then
    loader:Abort(`Unsupported game :c`)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Voidware | Loader",
        Text = "Unsupported game :c",
        Duration = 15
    })
    return
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Voidware | Loader",
        Text = "Loading for "..tostring(data.title).."...",
        Duration = 15
    })
    loader:Update(`Preparing Voidware {tostring(data.title)}...`, 40)
    local res, err
    local scriptUrl = data.script
    if shared.VoidDev and data.dev ~= nil and pcall(function() return isfile(data.dev) end) then
        res, err = loadstring(readfile(data.dev))
        if type(res) ~= "function" then
            err = "Failed to load dev script from local file: " .. tostring(data.dev) .. " | loadstring error: " .. tostring(err)
        end
    else
        local httpOk, httpBody = pcall(function() return game:HttpGet(scriptUrl, true) end)
        if not httpOk then
            err = "HTTP request failed for URL: " .. tostring(scriptUrl) .. " | Error: " .. tostring(httpBody)
        elseif httpBody == nil or httpBody == "" then
            err = "HTTP request returned empty response from URL: " .. tostring(scriptUrl)
        else
            res, err = loadstring(httpBody)
            if type(res) ~= "function" then
                err = "loadstring failed for script at: " .. tostring(scriptUrl) .. " | Error: " .. tostring(err)
            end
        end
    end
    if type(res) ~= "function" then
        local errorMsg = tostring(err or "Unknown error - nil returned")
        warn("[Voidware Loader] " .. errorMsg)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Voidware Loading Error",
            Text = errorMsg:sub(1, 200),
            Duration = 15
        })
        loader:Abort(`Loading Failed: {errorMsg} :c \n Please try again later\n`)
        task.delay(0.5, function()
            if shared.VoidDev then return end
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Voidware Loading Error",
                Text = "Please report this issue to erchodev#0 \n or in discord.gg/voidware",
                Duration = 15
            })
        end)
    else
        loader:Update(`Loading Voidware...`, 60)
        local suc, runErr = pcall(res)
        if not suc then
            local errorMsg = tostring(runErr or "Unknown runtime error - nil")
            warn("[Voidware Runtime] " .. errorMsg)
            loader:Abort(`Main Loading Error: {errorMsg} :c \n Please try again later\n`)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Voidware Main Error",
                Text = errorMsg:sub(1, 200),
                Duration = 15
            })
            task.delay(0.5, function()
                if shared.VoidDev then return end
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Voidware Main Error",
                    Text = "Please report this issue to erchodev#0 \n or in discord.gg/voidware",
                    Duration = 15
                })
            end)
        else
            loader:Update(`Finishing Up...`, 80)
            shared.ACTIVE_LOADER = nil
            loader:Update(`Successfully loaded Voidware {tostring(data.title)} :D`, 100)
            task.delay(0.5, function()
                pcall(function()
                    loader:Destroy()
                end)
            end)
        end
    end
end
