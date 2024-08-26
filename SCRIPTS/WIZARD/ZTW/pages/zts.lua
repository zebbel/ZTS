zstSettings["zts"] = {
    batIndicator = {
        enable = 0,
        alarm = 0,
        minCell = 3.4
    },
    pages = {
        output = 0
    }
}

function getSensorTable()
    local sensors = {}
    local x = 0
    while 1 do
        sensorName = model.getSensor(x).name
        if sensorName == nil or sensorName == "" then break end
        sensors[#sensors+1] = sensorName
        x = x + 1
    end

    if sensors[1] == nil then sensors = {"None"} end
    return sensors
end

batIndicatorMenu = {
    {enable=1, name=language.batIndicator, type=CHECKBOX, settingTable={"zts","batIndicator"}, value="enable"},
    {enable={"zts","batIndicator","enable"}, name=language.batAlarm, type=CHECKBOX, settingTable={"zts","batIndicator"}, value="alarm"},
    {enable={"zts","batIndicator","alarm"}, name=language.minCell, type=VALUE, min=3.0, max=4.5, step=0.1, settingTable={"zts","batIndicator"}, value="minCell"}
}

ztsPages = {
    {enable=1, name=language.ztsOutputPage, type=CHECKBOX, settingTable={"zts", "pages"}, value="output"}
}

ztsPage = {
    pageName = language.ztsOptions,
    page = {
        {enable=1, name=language.batIndicator, type=SUBMENU, value=0, submenu=batIndicatorMenu},
        {enable=1, name=language.ztsPages, type=SUBMENU, value=0, submenu=ztsPages}
    }
}