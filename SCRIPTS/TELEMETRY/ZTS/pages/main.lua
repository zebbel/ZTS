local shared = ...

local modelName = model.getInfo().name

local function fourWheelSteering()
    local driveMode, _ = getFlightMode()

    if driveMode == 0 then
        lcd.drawPixmap(10, 40, "/SCRIPTS/TELEMETRY/ZTS/images/FWS.bmp")
    elseif driveMode == 1 then
        lcd.drawPixmap(10, 40, "/SCRIPTS/TELEMETRY/ZTS/images/RWS.bmp")
    elseif driveMode == 2 then
        lcd.drawPixmap(10, 40, "/SCRIPTS/TELEMETRY/ZTS/images/crab.bmp")
    elseif driveMode == 3 then
        lcd.drawPixmap(10, 40, "/SCRIPTS/TELEMETRY/ZTS/images/4WS.bmp")
    end
end

function shared.init()
    if settingEnabled(settings.zts, {"sensorReplace", "enable"}) then
        if settingEnabled(settings.zts, {"sensorReplace", "sensors", "temp", "enable"})then
            sensorName = model.getSensor(settings.zts.sensorReplace.sensors.temp.allocation).name
            settings.zts.sensorReplace.sensors.temp.id = getFieldInfo(sensorName).id
        end
    end
end

function shared.background()

end

function shared.run(event)
    drawTitle(modelName, settings.esc.armSwitch)
    drawLink(2, 12)
    drawDriveMode(47, 12, CENTER + BOLD)

    if settingEnabled(settings.zts, "batIndicator") then drawVoltageImage(110, 11, 10) end
    if settingEnabled(settings.steering, "fourWS") then fourWheelSteering() end

    if settingEnabled(settings.zts, {"sensorReplace", "enable"}) then
        lcd.drawNumber(35, 42, getValue(settings.zts.sensorReplace.sensors.temp.id) * 10, DBLSIZE + RIGHT + PREC1)
        lcd.drawText(35, 42, "°C", LEFT)
    end
  
    if event == 100 then
        shared.changeScreen(1)
    elseif event == 101 then
        shared.changeScreen(-1)
    end
end