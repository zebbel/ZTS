
if zstSettings.model.language ~= nil then
    if zstSettings.model.language == 0 then
        loadScript("/SCRIPTS/WIZARD/ZTW/language/en.lua")()
    elseif zstSettings.model.language == 1 then
        loadScript("/SCRIPTS/WIZARD/ZTW/language/de.lua")()
    end
end

modelSetup = {
    pageName = language.setupPage,
    page = {
        --{enable=1, name = "test", type=TEST, settingTable="test", value="testValue"},
        {enable=1, name = language.language, type=COMBO, settingTable="model", value="language", options={"english", "Deutsch"}, reinit=1},
        {enable=1, name = language.modelType, type=COMBO, settingTable="model", value="type", options={language.car, language.bike, language.crawler}, reinit=1},
        {enable=1, name=language.ztsOption, type=CHECKBOX, settingTable="model", value="ZTS", reinit=1}
    },
    subpage = {
        {enable=1, name=language.switchWarning, type=CHECKBOX, settingTable="model", value="sWarning"},
        {enable=1, name=language.modul, type=COMBO, settingTable="model", value="modul", options={"---", "CRSF"}}
    }
}

confirmPage = {
    pageName = language.confirmPage,
    page = {
        {enable=1, name="", type=TEXT},
        {enable=1, name=language.confirm1, type=TEXT},
        {enable=1, name=language.confirm2, type=TEXT},
        {enable=1, name=language.confirm, type=FUNCTION, key=EVT_VIRTUAL_ENTER_LONG, value="createModel"}
    }
}

--print("pages.lua")
--printSettings(zstSettings, 0)

if zstSettings.model.type == 0 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/carPage.lua")()
    startPage = {modelSetup, steeringPage, escPage, brakeServoPage}
elseif zstSettings.model.type == 1 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/bikePage.lua")()
    startPage = {modelSetup, steeringPage, escPage, brakeServoPage}
elseif zstSettings.model.type == 2 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/crawlerPage.lua")()
    startPage = {modelSetup, steeringPage, escPage}
end

if zstSettings.model.ZTS == 1 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/zts.lua")()
    startPage[#startPage+1] = ztsPage
end
startPage[#startPage+1] = confirmPage

