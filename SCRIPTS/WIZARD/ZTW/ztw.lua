version = "V0.0.2"
-- ZTS settings
zstSettings = {}
zstSettings["model"] = {language = 0, type = 0, ZTS = 0, sWarning = 1, modul = 0, ZTM = 0}

modelSettings = {}

loadScript("/SCRIPTS/helper/ztsSettings.lua", 'tc')()

local function init()
    settingFilePath = "/MODELS/ZTS/" .. string.gsub(model.getInfo().filename, ".yml", "") .. ".txt"

    if fileExists("/MODELS/ZTS") then
        folderExists = true
        if fileExists(settingFilePath) then
            zstSettings = readSettingsFile(zstSettings, settingFilePath, true)
        end
    end

    print("car.lua")
    --printSettings(zstSettings, 0)

    loadScript("/SCRIPTS/helper/widgets.lua", 'tc')()
    loadScript("/SCRIPTS/WIZARD/ZTW/ui.lua", 'tc')()
    loadScript("/SCRIPTS/WIZARD/ZTW/pages.lua", 'tc')()

    --print("car.lua after pages")
    --printSettings(zstSettings, 0)

    if fileExists("/MODELS/ZTS") then
        folderExists = true
        if fileExists(settingFilePath) then
            zstSettings = getSettings(zstSettings, settingFilePath, true)
        end
    end

    --print("car.lua befor initUI")
    --printSettings(zstSettings, 0)

    initUI(startPage)
end

local result = 0
local function run(event)
    result = runUI(event)

    return result
end

return { init=init, run=run }