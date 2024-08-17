zstSettings["zts"] = {
    batIndicator = 0, 
    sensorReplace = {
        enable = 0, 
        sensors = {
            temp = {
                enable = 0, 
                allocation = 0
            }
        }
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

ztsSensors = {
    {enable=1, name=language.temperature, type=CHECKBOX, settingTable={"zts", "sensorReplace", "sensors", "temp"}, value="enable"},
}

ztsSensorAllocation = {
    {enable={"zts", "sensorReplace", "sensors", "temp", "enable"}, name=language.temperature, type=COMBO, settingTable={"zts", "sensorReplace", "sensors", "temp"}, value="allocation", options=getSensorTable()}
}

ztsPages = {
    {enable=1, name=language.ztsOutputPage, type=CHECKBOX, settingTable={"zts", "pages"}, value="output"}
}

ztsPage = {
    pageName = language.ztsOptions,
    page = {
        {enable=1, name=language.batIndicator, type=CHECKBOX, settingTable="zts", value="batIndicator"},
        {enable=1, name=language.ztsPages, type=SUBMENU, value=0, submenu=ztsPages}
    },
    subpage = {
        {enable=1, name=language.sensorReplace, type=CHECKBOX, settingTable={"zts", "sensorReplace"}, value="enable"},
        {enable={"zts", "sensorReplace", "enable"}, name=language.sensors, type=SUBMENU, value=0, submenu=ztsSensors},
        {enable={"zts", "sensorReplace", "enable"}, name=language.sensorAllocation, type=SUBMENU, value=0, submenu=ztsSensorAllocation}
    }
}