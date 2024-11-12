-- init ztm settings
ztsSettings["ztm"] = {
    sensorReplace = {
        enable = 0, 
        sensors = {
            temp = {
                enable = 0, 
                allocation = 0,
                alarm = 0,
                maxTemp = 60
            }
        }
    }
}

-- get table of availabe sensors
function getSensorTable()
    local sensors = {}
    local x = 0
    while 1 do
        sensorName = model.getSensor(x).name
        if sensorName == nil or sensorName == "" then break end
        sensors[#sensors+1] = sensorName
        x = x + 1
    end

    -- if no sensors are discoverd we need at least one entry
    if sensors[1] == nil then sensors = {"None"} end
    return sensors
end

-- ztmTempSensor sub menu
ztmTempSensorMenu = {
    {enable=1, name=language.enable, type=CHECKBOX, setting={"ztm", "sensorReplace", "sensors", "temp", "enable"}},
    {enable={"ztm","sensorReplace","sensors","temp","enable"}, name=language.sensor, type=COMBO, setting={"ztm","sensorReplace","sensors","temp", "allocation"}, options=getSensorTable()},
    {enable={"ztm","sensorReplace","sensors","temp","enable"}, name=language.alarm, type=CHECKBOX, setting={"ztm","sensorReplace","sensors","temp", "alarm"}},
    {enable={"ztm","sensorReplace","sensors","temp","alarm"}, name=language.maxTemp, type=VALUE, min=0, max=100, step=1, setting={"ztm","sensorReplace","sensors","temp", "maxTemp"}},
    {enable={"ztm","sensorReplace","sensors","temp","alarm"}, name=language.playSound, type=CHECKBOX, setting={"ztm","sensorReplace","sensors","temp", "alarmSound"}}
}

-- ztm page
ztmPage = {
    pageName = language.ztmPage,
    page = {
        {enable=1, name=language.sensorReplace, type=CHECKBOX, setting={"ztm", "sensorReplace", "enable"}},
        {enable={"ztm", "sensorReplace", "enable"}, name=language.ztmTempSensor, type=SUBMENU, submenu=ztmTempSensorMenu}
    }
}