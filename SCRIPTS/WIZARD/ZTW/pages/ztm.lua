zstSettings["ztm"] = {
    sensorReplace = {
        enable = 0, 
        sensors = {
            temp = {
                enable = 0, 
                allocation = 22
            }
        }
    }
}

ztmSensors = {
    {enable=1, name=language.temperature, type=CHECKBOX, settingTable={"ztm", "sensorReplace", "sensors", "temp"}, value="enable"}
}

ztmSensorAllocation = {
    {enable={"ztm", "sensorReplace", "sensors", "temp", "enable"}, name=language.temperature, type=COMBO, settingTable={"ztm", "sensorReplace", "sensors", "temp"}, value="allocation", options=getSensorTable()}
}

ztmPage = {
    pageName = language.ztmPage,
    page = {
        {enable=1, name=language.sensorReplace, type=CHECKBOX, settingTable={"ztm", "sensorReplace"}, value="enable"},
        {enable={"ztm", "sensorReplace", "enable"}, name=language.sensors, type=SUBMENU, value=0, submenu=ztmSensors},
        {enable={"ztm", "sensorReplace", "enable"}, name=language.sensorAllocation, type=SUBMENU, value=0, submenu=ztmSensorAllocation}
    }
}