
alarmActiv = false
batAlarmArmed = true
tempAlarmArmed = true

function alarmInit()
    -- get cell count
    if settingEnabled(settings.zts, {"batIndicator", "alarm"}) then
        if settings.zts.batIndicator.mode == 0 then
            settings.zts.batIndicator.cells = math.ceil((getValue('RxBt') / 4.37) - 0.4)
        end
    end

    if settingEnabled(settings.ztm, {"sensorReplace", "enable"}) then
        if settingEnabled(settings.ztm, {"sensorReplace", "sensors", "temp", "enable"})then
            sensorName = model.getSensor(settings.ztm.sensorReplace.sensors.temp.allocation).name
            settings.ztm.sensorReplace.sensors.temp.id = getFieldInfo(sensorName).id
        end
    end
end

local batValues = {}
local batFilterPos = 1
local batFilterLastTime = 0
local function getBatValue()
    if #batValues < 10 then
        batValues[batFilterPos] = getValue('RxBt') / settings.zts.batIndicator.cells
        batFilterPos = batFilterPos + 1
        batFilterLastTime = getTime()
    elseif getTime() > batFilterLastTime + 10 then
        batFilterLastTime = getTime()
        batValues[batFilterPos] = getValue('RxBt') / settings.zts.batIndicator.cells
        batFilterPos = batFilterPos + 1
        if batFilterPos > #batValues then
            batFilterPos = 1
        end
    end

    local value = 0
    for i=1, #batValues, 1 do
        value = value + batValues[i]
    end
    return value / #batValues
end

function alarmRun(event)
    if getRSSI() ~= 0 then
        if settingEnabled({"zts", "batIndicator", "alarm"}) then
            if getBatValue() <= settings.zts.batIndicator.minCell then
                if batAlarmArmed == true then
                    if not alarmActiv and settingEnabled({"zts", "batIndicator", "alarmSound"}) then playFile("lowbat.wav") end
                    playHaptic(10, 500)
                    drawWarnPopup(9, 9, "Battery low")
                    alarmActiv = true
                    if event == EVT_VIRTUAL_ENTER then
                        batAlarmArmed = false
                        alarmActiv = false
                    end
                    return
                end
            else
                batAlarmArmed = true
            end
        end

        if settingEnabled({"ztm", "sensorReplace", "enable"}) then
            if getValue(settings.ztm.sensorReplace.sensors.temp.id) > settings.ztm.sensorReplace.sensors.temp.maxTemp then
                if tempAlarmArmed == true then
                    if not alarmActiv and settingEnabled({"ztm","sensorReplace","sensors","temp", "alarmSound"}) then playFile("tohigh.wav") end
                    playHaptic(10, 500)
                    drawWarnPopup(9, 9, "Temperatur high")
                    alarmActiv = true
                    if event == EVT_VIRTUAL_ENTER then
                        tempAlarmArmed = false
                        alarmActiv = false
                    end
                    return
                end
            else
                tempAlarmArmed = true
            end
        end
    end

    alarmActiv = false
end