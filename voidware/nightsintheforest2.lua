--[[
██╗   ██╗ ██████╗ ██╗██████╗ ██╗    ██╗ █████╗ ██████╗ ███████╗
██║   ██║██╔═══██╗██║██╔══██╗██║    ██║██╔══██╗██╔══██╗██╔════╝
██║   ██║██║   ██║██║██║  ██║██║ █╗ ██║███████║██████╔╝█████╗
╚██╗ ██╔╝██║   ██║██║██║  ██║██║███╗██║██╔══██║██╔═══╝ ██╔══╝
 ╚████╔╝ ╚██████╔╝██║██████╔╝╚███╔███╔╝██║  ██║██║     ███████╗
  ╚═══╝   ╚═════╝ ╚═╝╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚══════╝

                🚀 VOIDWARE — 99 Nights In The Forest 🚀
]]
if not game:IsLoaded() then return end
local CheatEngineMode = false
if (not getgenv) or (getgenv and type(getgenv) ~= "function") then CheatEngineMode = true end
if getgenv and not getgenv().shared then CheatEngineMode = true; getgenv().shared = {}; end
if getgenv and not getgenv().debug then CheatEngineMode = true; getgenv().debug = {traceback = function(string) return string end} end
if getgenv and not getgenv().require then CheatEngineMode = true; end
if getgenv and getgenv().require and type(getgenv().require) ~= "function" then CheatEngineMode = true end
local debugChecks = {
    Type = "table",
    Functions = {
        "getupvalue",
        "getupvalues",
        "getconstants",
        "getproto"
    }
}
local function checkExecutor()
    if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
        local suc, res = pcall(function()
            return identifyexecutor()
        end)
        --local blacklist = {'appleware', 'cryptic', 'delta', 'wave', 'codex', 'swift', 'solara', 'vega'}
        local blacklist = {'solara', 'cryptic', 'xeno', 'ember', 'ronix'}
        local core_blacklist = {'solara', 'xeno'}
        if suc then
            for i,v in pairs(blacklist) do
                if string.find(string.lower(tostring(res)), v) then CheatEngineMode = true end
            end
            for i,v in pairs(core_blacklist) do
                if string.find(string.lower(tostring(res)), v) then
                    pcall(function()
                        getgenv().queue_on_teleport = function() warn('queue_on_teleport disabled!') end
                    end)
                end
            end
            if string.find(string.lower(tostring(res)), "delta") then
                getgenv().isnetworkowner = function()
                    return true
                end
            end
        end
    end
end
task.spawn(function() pcall(checkExecutor) end)
local function checkDebug()
    if CheatEngineMode then return end
    if not getgenv().debug then
        CheatEngineMode = true
    else
        if type(debug) ~= debugChecks.Type then
            CheatEngineMode = true
        else
            for i, v in pairs(debugChecks.Functions) do
                if not debug[v] or (debug[v] and type(debug[v]) ~= "function") then
                    CheatEngineMode = true
                else
                    local suc, res = pcall(debug[v])
                    if tostring(res) == "Not Implemented" then
                        CheatEngineMode = true
                    end
                end
            end
        end
    end
end
--if (not CheatEngineMode) then checkDebug() end
shared.CheatEngineMode = shared.CheatEngineMode or CheatEngineMode
shared.ForcePlayerGui = true

if game.PlaceId == 79546208627805 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Voidware | 99 Nights In The Forest",
            Text = "Go In Game for Voidware to load :D [You are in lobby currently]",
            Duration = 10
        })
    end)
    return
end

task.spawn(function()
    pcall(function()
        local Services = setmetatable({}, {
            __index = function(self, key)
                local suc, service = pcall(game.GetService, game, key)
                if suc and service then
                    self[key] = service
                    return service
                else
                    warn(`[Services] Warning: "{key}" is not a valid Roblox service.`)
                    return nil
                end
            end
        })

        local Players = Services.Players
        local TextChatService = Services.TextChatService
        local ChatService = Services.ChatService
        repeat
            task.wait()
        until game:IsLoaded() and Players.LocalPlayer ~= nil
        local chatVersion = TextChatService and TextChatService.ChatVersion or Enum.ChatVersion.LegacyChatService
        local TagRegister = shared.TagRegister or {}
        if not shared.CheatEngineMode then
            --if chatVersion == Enum.ChatVersion.TextChatService then
                TextChatService.OnIncomingMessage = function(data)
                    TagRegister = shared.TagRegister or {}
                    local properties = Instance.new("TextChatMessageProperties", game:GetService("Workspace"))
                    local TextSource = data.TextSource
                    local PrefixText = data.PrefixText or ""
                    if TextSource then
                        local plr = Players:GetPlayerByUserId(TextSource.UserId)
                        if plr then
                            local prefix = ""
                            if TagRegister[plr] then
                                prefix = prefix .. TagRegister[plr]
                            end
                            if plr:GetAttribute("__OwnsVIPGamepass") and plr:GetAttribute("VIPChatTag") ~= false then
                                prefix = prefix .. "<font color='rgb(255,210,75)'>[VIP]</font> "
                            end
                            local currentLevel = plr:GetAttribute("_CurrentLevel")
                            if currentLevel then
                                prefix = prefix .. string.format("<font color='rgb(173,216,230)'>[</font><font color='rgb(255,255,255)'>%s</font><font color='rgb(173,216,230)'>]</font> ", tostring(currentLevel))
                            end
                            local playerTagValue = plr:FindFirstChild("PlayerTagValue")
                            if playerTagValue and playerTagValue.Value then
                                prefix = prefix .. string.format("<font color='rgb(173,216,230)'>[</font><font color='rgb(255,255,255)'>#%s</font><font color='rgb(173,216,230)'>]</font> ", tostring(playerTagValue.Value))
                            end
                            prefix = prefix .. PrefixText
                            properties.PrefixText = string.format("<font color='rgb(255,255,255)'>%s</font>", prefix)
                        end
                    end
                    return properties
                end
            --[[elseif chatVersion == Enum.ChatVersion.LegacyChatService then
                ChatService:RegisterProcessCommandsFunction("CustomPrefix", function(speakerName, message)
                    TagRegister = shared.TagRegister or {}
                    local plr = Players:FindFirstChild(speakerName)
                    if plr then
                        local prefix = ""
                        if TagRegister[plr] then
                            prefix = prefix .. TagRegister[plr]
                        end
                        if plr:GetAttribute("__OwnsVIPGamepass") and plr:GetAttribute("VIPChatTag") ~= false then
                            prefix = prefix .. "[VIP] "
                        end
                        local currentLevel = plr:GetAttribute("_CurrentLevel")
                        if currentLevel then
                            prefix = prefix .. string.format("[%s] ", tostring(currentLevel))
                        end
                        local playerTagValue = plr:FindFirstChild("PlayerTagValue")
                        if playerTagValue and playerTagValue.Value then
                            prefix = prefix .. string.format("[#%s] ", tostring(playerTagValue.Value))
                        end
                        prefix = prefix .. speakerName
                        return prefix .. " " .. message
                    end
                    return message
                end)
            end--]]
        end
    end)
end)

local commit = shared.CustomCommit and tostring(shared.CustomCommit) or shared.StagingMode and "staging" or "7da6700e64d07a15c8327df690ebe81a18138513"
local scriptUrl = "https://code.sarris.dev/voidware/"..tostring(commit).."/newnightsintheforest.lua"

local httpOk, httpBody = pcall(function() return game:HttpGet(scriptUrl, true) end)
if not httpOk then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Voidware | 99 Nights Error",
            Text = "HTTP request failed: " .. tostring(httpBody) .. "\nURL: " .. scriptUrl,
            Duration = 15
        })
    end)
    warn("[Voidware] Failed to fetch script: " .. tostring(httpBody) .. " | URL: " .. scriptUrl)
    return
end
if httpBody == nil or httpBody == "" then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Voidware | 99 Nights Error",
            Text = "Script returned empty response\nURL: " .. scriptUrl,
            Duration = 15
        })
    end)
    warn("[Voidware] Empty response from: " .. scriptUrl)
    return
end

local loadFunc, loadErr = loadstring(httpBody)
if type(loadFunc) ~= "function" then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Voidware | 99 Nights Error",
            Text = "loadstring failed: " .. tostring(loadErr) .. "\nURL: " .. scriptUrl,
            Duration = 15
        })
    end)
    warn("[Voidware] loadstring failed: " .. tostring(loadErr) .. " | URL: " .. scriptUrl)
    return
end

local runOk, runErr = pcall(loadFunc)
if not runOk then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Voidware | 99 Nights Runtime Error",
            Text = tostring(runErr or "Unknown error"),
            Duration = 15
        })
    end)
    warn("[Voidware] Runtime error in 99 Nights script: " .. tostring(runErr))
end
