
-- load language file
if ztsSettings.model.language ~= nil then
    if ztsSettings.model.language == 0 then
        loadScript("/SCRIPTS/WIZARD/ZTW/language/en.lua")()
    elseif ztsSettings.model.language == 1 then
        loadScript("/SCRIPTS/WIZARD/ZTW/language/de.lua")()
    end
end

--model setup page
modelSetup = {
    pageName = language.setupPage,
    page = {
        {enable=1, name = language.language, type=COMBO, settingTable="model", value="language", options={"english", "Deutsch"}, reinit=1},
        {enable=1, name = language.modelType, type=COMBO, settingTable="model", value="type", options={language.car, language.bike, language.crawler}, reinit=1},
        {enable=1, name=language.ztsOption, type=CHECKBOX, settingTable="model", value="ZTS", reinit=1}
    },
    subpage = {
        {enable=1, name=language.ztmOption, type=CHECKBOX, settingTable="model", value="ZTM", reinit=1},
        {enable=1, name=language.switchWarning, type=CHECKBOX, settingTable="model", value="sWarning"},
        {enable=1, name=language.modul, type=COMBO, settingTable="model", value="modul", options={"---", "CRSF"}}
    }
}

-- confirme page
confirmPage = {
    pageName = language.confirmPage,
    page = {
        {enable=1, name=language.confirm1, type=TEXT},
        {enable=1, name=language.confirm2, type=TEXT},
        {enable=1, name=language.confirm, type=FUNCTION, key=EVT_VIRTUAL_ENTER_LONG, value="createModel"}
    }
}


-- load pages based on model type
if ztsSettings.model.type == 0 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/carPage.lua")()
    startPage = {modelSetup, steeringPage, escPage, brakeServoPage}
elseif ztsSettings.model.type == 1 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/bikePage.lua")()
    startPage = {modelSetup, steeringPage, escPage, brakeServoPage}
elseif ztsSettings.model.type == 2 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/crawlerPage.lua")()
    startPage = {modelSetup, steeringPage, escPage}
end

-- if ZTS is enbaled load ZTS page
if ztsSettings.model.ZTS == 1 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/zts.lua")()
    startPage[#startPage+1] = ztsPage
end

-- if ZTM is enabled load ZTM page
if ztsSettings.model.ZTM == 1 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/ztm.lua")()
    startPage[#startPage+1] = ztmPage
end

-- add confirme page
startPage[#startPage+1] = confirmPage
