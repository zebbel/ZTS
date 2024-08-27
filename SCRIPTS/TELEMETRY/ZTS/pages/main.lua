local shared = ...

local showMenuFlag = false
edit = false
field = 0
fieldMax = 1
dirty = false

loadScript("/SCRIPTS/helper/guiFunctions.lua")()

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

local function showMenu(event)
    local height = 30

    lcd.drawFilledRectangle(9, 15, 110, height, ERASE + CENTER)
    lcd.drawRectangle(9, 15, 110, height, CENTER)
end

function shared.init()
    if settingEnabled(settings.ztm, {"sensorReplace", "enable"}) then
        if settingEnabled(settings.ztm, {"sensorReplace", "sensors", "temp", "enable"})then
            sensorName = model.getSensor(settings.ztm.sensorReplace.sensors.temp.allocation).name
            settings.ztm.sensorReplace.sensors.temp.id = getFieldInfo(sensorName).id
        end
    end
end

function shared.background()
    if getRSSI() ~= 0 then
        if settingEnabled(settings.zts, {"batIndicator", "alarm"}) then
            cell = math.ceil((getValue('RxBt') / 4.37) - 0.4)
            cell = cell == (5 or 7) and cell + 1 or cell

            if getValue('RxBt') / cell <= settings.zts.batIndicator.minCell then
                playHaptic(10, 500)
            end
        end

        if settingEnabled(settings.ztm, {"sensorReplace", "sensors", "temp",     "alarm"}) then
            if getValue(settings.ztm.sensorReplace.sensors.temp.id) > settings.ztm.sensorReplace.sensors.temp.maxTemp then
                playHaptic(10, 500)
            end
        end
    end
end

function shared.run(event)
    drawLink(2, 12)
    drawDriveMode(47, 12, CENTER + BOLD)

    if settingEnabled(settings.zts, {"batIndicator", "enable"}) then drawVoltageImage(110, 11, 10) end
    if settingEnabled(settings.steering, "fourWS") then fourWheelSteering() end

    if settingEnabled(settings.ztm, {"sensorReplace", "enable"}) then
        lcd.drawNumber(35, 42, getValue(settings.ztm.sensorReplace.sensors.temp.id) * 10, DBLSIZE + RIGHT + PREC1)
        lcd.drawText(35, 42, "°C", LEFT)
    end

    -- Menu
    if showMenuFlag == true then
        showMenu(event)
    end
  
    if event == 100 then
        shared.changeScreen(1)
    elseif event == 101 then
        shared.changeScreen(-1)
    end

    if not showMenuFlag and event == EVT_VIRTUAL_ENTER then
        showMenuFlag = true
        edit = false
    elseif showMenuFlag and event == EVT_VIRTUAL_EXIT then
        showMenuFlag = false
    elseif showMenuFlag then
        navigate(event, fieldMax, 0, 0)
    end
end