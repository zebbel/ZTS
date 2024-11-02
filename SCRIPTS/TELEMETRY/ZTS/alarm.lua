
alarmActiv = false
batAlarmArmed = true
tempAlarmArmed = true

function alarmInit()
    -- get cell count
    if settingEnabled(settings.zts, {"batIndicator", "alarm"}) then
        cell = math.ceil((getValue('RxBt') / 4.37) - 0.4)
        cell = cell == (5 or 7) and cell + 1 or cell
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
        batValues[batFilterPos] = getValue('RxBt') / cell
        batFilterPos = batFilterPos + 1
        batFilterLastTime = getTime()
    elseif getTime() > batFilterLastTime + 10 then
        batFilterLastTime = getTime()
        batValues[batFilterPos] = getValue('RxBt') / cell
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
        if settingEnabled(settings.zts, {"batIndicator", "alarm"}) then
            if getBatValue() <= settings.zts.batIndicator.minCell then
                if batAlarmArmed == true then
                    alarmActiv = true
                    playHaptic(10, 500)
                    drawWarnPopup(9, 9, "Battery low")
                    if event == EVT_VIRTUAL_ENTER then
                        batAlarmArmed = false
                        alarmActiv = false
                    end
                end
            elseif not alarmActiv then
                alarmActiv = false
                batAlarmArmed = true
            end
        end

        if settingEnabled(settings.ztm, {"sensorReplace", "enable"}) then
            if getValue(settings.ztm.sensorReplace.sensors.temp.id) > settings.ztm.sensorReplace.sensors.temp.maxTemp then
                if tempAlarmArmed == true then
                    alarmActiv = true
                    playHaptic(10, 500)
                    drawWarnPopup(9, 9, "Temperatur high")
                    if event == EVT_VIRTUAL_ENTER then
                        tempAlarmArmed = false
                        alarmActiv = false
                    end
                end
            elseif not alarmActiv then
                alarmActiv = false
                tempAlarmArmed = true
            end
        end
    end
end