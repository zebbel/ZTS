-- init ztm settings
ztsSettings["ztm"] = {
    sensorReplace = {
        enable = 0, 
        sensors = {
            temp = {
                enable = 0, 
                sensor = "Alt",
                alarm = 0,
                maxTemp = 60,
                alarmSound = 0
            }
        }
    }
}

-- ztmTempSensor sub menu
ztmTempSensorMenu = {
    {enable=1, name=language.enable, type=CHECKBOX, setting={"ztm", "sensorReplace", "sensors", "temp", "enable"}},
    {enable={"ztm","sensorReplace","sensors","temp","enable"}, name=language.sensor, type=COMBOTEXT, setting={"ztm","sensorReplace","sensors","temp", "sensor"}, options=getSensorTable()},
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