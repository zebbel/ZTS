
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
        {name=language.language, type=COMBO, setting={"model","language"}, options={"english", "Deutsch"}, reload=1},
        {name=language.modelType, type=COMBO, setting={"model","type"}, options={language.car, language.bike, language.crawler}, reinit=1},
        {name=language.ztsOption, type=CHECKBOX, setting={"model","ZTS"}, reload=1}
    },
    subpage = {
        {name=language.ztmOption, type=CHECKBOX, setting={"model","ZTM"}, reload=1},
        {name=language.switchWarning, type=CHECKBOX, setting={"model","sWarning"}},
        {name=language.modul, type=COMBO, setting={"model","modul"}, options={"---", "CRSF"}}
    }
}

-- confirme page
confirmPage = {
    pageName = language.confirmPage,
    page = {
        {name=language.confirm1, type=TEXT},
        {name=language.confirm2, type=TEXT},
        {name=language.confirm, type=FUNCTION, key=EVT_VIRTUAL_ENTER_LONG, value="createModel"}
    }
}

-- load pages based on model type
if ztsSettings.model.type == 0 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/types/car.lua")()
    startPage = {modelSetup, steeringPage, escPage, brakeServoPage}
elseif ztsSettings.model.type == 1 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/types/bike.lua")()
    startPage = {modelSetup, steeringPage, escPage, brakeServoPage}
elseif ztsSettings.model.type == 2 then
    loadScript("/SCRIPTS/WIZARD/ZTW/pages/types/crawler.lua")()
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
