
sensor = {}
local connected = false

local function lowPassFilter(value, rawSensor, lpfBeta)
    value = value - (lpfBeta * (value - rawSensor))
    return value
end

function sensorsInit()
    if settingEnabled({"zts", "batIndicator", "enable"}) then
        settings.zts.batIndicator.sensor = string.sub(settings.zts.batIndicator.sensor, 0, string.find(settings.zts.batIndicator.sensor, "_")-1)

        sensor.batValue = 0
        if not settingEnabled({"zts", "batIndicator", "filterEnable"}) then
            settings.zts.batIndicator.lpfBeta = 1
        end

        if settings.zts.batIndicator.mode == 0 then
            settings.zts.batIndicator.cells = math.ceil((getValue(settings.zts.batIndicator.sensor) / 4.37) - 0.4)
            if getValue(settings.zts.batIndicator.sensor) / settings.zts.batIndicator.cells < 4.3 then settings.zts.batIndicator.type = 0
            else settings.zts.batIndicator.type = 1 end
        end

        settings.zts.batIndicator.minVoltage = settings.zts.batIndicator.minCell * settings.zts.batIndicator.cells

        if settings.zts.batIndicator.type == 0 then settings.zts.batIndicator.maxVoltage = 4.2 * settings.zts.batIndicator.cells
        else settings.zts.batIndicator.maxVoltage = 4.35 * settings.zts.batIndicator.cells end
    end

    if settingEnabled({"ztm", "sensorReplace", "enable"}) then
        settings.ztm.sensorReplace.sensors.temp.sensor = string.sub(settings.ztm.sensorReplace.sensors.temp.sensor, 0, string.find(settings.ztm.sensorReplace.sensors.temp.sensor, "_")-1)
        sensor.temp = 0
    end
end

function sensorsRun()
    if settingEnabled({"zts", "batIndicator", "enable"}) then
        if not connected then
            sensor.batValue = getValue(settings.zts.batIndicator.sensor)
        else
            sensor.batValue = lowPassFilter(sensor.batValue, getValue(settings.zts.batIndicator.sensor), settings.zts.batIndicator.lpfBeta)
        end
    end

    if settingEnabled({"ztm", "sensorReplace", "enable"}) then
        sensor.temp = getValue(settings.ztm.sensorReplace.sensors.temp.sensor)
    end

    if getRSSI() ~= 0 then
        connected = true
    else
        connected = false
    end
end