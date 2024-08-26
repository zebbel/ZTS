zstSettings["zts"] = {
    batIndicator = 0, 
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

ztsPages = {
    {enable=1, name=language.ztsOutputPage, type=CHECKBOX, settingTable={"zts", "pages"}, value="output"}
}

ztsPage = {
    pageName = language.ztsOptions,
    page = {
        {enable=1, name=language.batIndicator, type=CHECKBOX, settingTable="zts", value="batIndicator"},
        {enable=1, name=language.ztsPages, type=SUBMENU, value=0, submenu=ztsPages}
    }
}