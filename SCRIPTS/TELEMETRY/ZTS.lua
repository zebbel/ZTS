
modelName = model.getInfo().name
settings = {}

loadScript("/SCRIPTS/helper/widgets.lua")()
loadScript("/SCRIPTS/helper/zstSettings.lua")()

local shared = {}
shared.screens = {
    "/SCRIPTS/TELEMETRY/ZTS/pages/main.lua"
}

function shared.changeScreen(delta)
    shared.current = shared.current + delta
    if shared.current > #shared.screens then
        shared.current = 1
    elseif shared.current < 1 then
        shared.current = #shared.screens
    end
    local chunk = loadScript(shared.screens[shared.current])
    chunk(shared)
    shared.init()
end

local function init()
    local settingFilePath = "/MODELS/ZTS/" .. string.gsub(model.getInfo().filename, ".yml", "") .. ".txt"
    if fileExists(settingFilePath) then
        settings = readSettingsFile(settings, settingFilePath, true)
    end

    if settings.zts.pages.output == 1 then shared.screens[#shared.screens+1] = "/SCRIPTS/TELEMETRY/ZTS/pages/outputs.lua" end

    shared.current = 1
    shared.changeScreen(0)
end

local function background()
    shared.background()
end

local function run(event)
    lcd.clear()

    shared.run(event)
end

return { run = run, init = init, background = background }