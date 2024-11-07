
modelName = model.getInfo().name
settings = {}

loadScript("/SCRIPTS/helper/widgets.lua")()
loadScript("/SCRIPTS/helper/ztsSettings.lua")()
loadScript("/SCRIPTS/TELEMETRY/ZTS/alarm.lua")()

shared = {}
shared.screens = {
    "/SCRIPTS/TELEMETRY/ZTS/pages/main.lua"
}

local settingFileError = false

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
    else
        settingFileError = true
    end

    if settingEnabled({"zts", "pages", "output"}) then shared.screens[#shared.screens+1] = "/SCRIPTS/TELEMETRY/ZTS/pages/outputs.lua" end
    shared.current = 1
    shared.changeScreen(0)

    alarmInit()
end

local function background()
    shared.background()
    alarmRun()
end

local function run(event)
    if settingFileError then
        lcd.clear()
        lcd.drawText(64, 22, "No model setting found", CENTER + BLINK)
        lcd.drawText(64, 32, "Please run ZTW first", CENTER + BLINK)
    else
        lcd.clear()
        drawTitle(modelName, settings.esc.armSwitch)

        shared.run(event)

        alarmRun(event)
    end
end

return { run = run, init = init, background = background }