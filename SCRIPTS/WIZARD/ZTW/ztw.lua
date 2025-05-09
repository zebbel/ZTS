version = "V0.0.2"
-- ZTS settings
ztsSettings = {}
-- init ztsSettings with base model settings
ztsSettings["model"] = {language = 0, type = 0, ZTS = 0, sWarning = 1, modul = 0, ZTM = 0}
-- get path of ztsSetting file
settingFilePath = "/MODELS/ZTS/" .. string.gsub(model.getInfo().filename, ".yml", "") .. ".txt"

loadScript("/SCRIPTS/helper/ztsSettings.lua", 'tc')()
loadScript("/SCRIPTS/helper/widgets.lua", 'tc')()
loadScript("/SCRIPTS/WIZARD/ZTW/ui.lua", 'tc')()



local function init()
    -- check if file exist and load settings so pages.lua knows what base settings are used for model
    if fileExists(settingFilePath) then
        ztsSettings = readSettingsFile(ztsSettings, settingFilePath, true)
    end

    -- load pages.lua (inits pages to be shown based on ztsSetting)
    loadScript("/SCRIPTS/WIZARD/ZTW/pages.lua", 'tc')()
    --printSettings(ztsSettings, 0)

    -- reload ztsSettings to overwrite base settings with real settings
    if fileExists(settingFilePath) then
        getSettings(ztsSettings, settingFilePath, true)
    end

    --printSettings(ztsSettings, 0)

    -- init the ui
    initUI(startPage)


    --for k,v in pairs(model.getCustomFunction(5)) do
    --  print(k, v)
    --end

    --for k,v in pairs(model.getInput(3,0)) do
    --    print(k, v)
    --end
end

local function run(event)
    return runUI(event)
end

return { init=init, run=run }