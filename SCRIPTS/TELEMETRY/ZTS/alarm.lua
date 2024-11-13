
alarmActiv = false
batAlarmArmed = true
tempAlarmArmed = true

function alarmInit()

end

function alarmRun(event)
    if getRSSI() ~= 0 then
        if settingEnabled({"zts", "batIndicator", "alarm"}) then
            if sensor.batValue / settings.zts.batIndicator.cells <= settings.zts.batIndicator.minCell then
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
            if settingEnabled({"ztm", "sensorReplace", "sensors", "temp", "alarm"}) then
                if sensor.temp > settings.ztm.sensorReplace.sensors.temp.maxTemp then
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
    end

    alarmActiv = false
end