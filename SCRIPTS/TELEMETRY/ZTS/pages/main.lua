shared = ...

local showMenuFlag = false
local subMenu = 0
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

function shared.init()
    if settingEnabled({"zts","timer","enable"}) then
        if settings.zts.timer.reset == 1 then
            model.resetTimer(0)
        elseif settings.zts.timer.reset == 2 then
            if getValue(settings.zts.batIndicator.sensor) / settings.zts.batIndicator.maxVoltage * 100 > 98 then model.resetTimer(0) end
        end
    end
end

function shared.background()
    
end

local function showMenu(event)
    if subMenu == 0 then
        fieldMax = 1

        lcd.drawFilledRectangle(6, 18, 116, 20, ERASE + CENTER)
        lcd.drawRectangle(6, 18, 116, 20, CENTER)

        lcd.drawText(64, 25, "Reset Timer", getFieldFlags(0) + CENTER)

        if event == EVT_VIRTUAL_ENTER then
            if field == 0 then
                edit = false
                if event == EVT_VIRTUAL_ENTER then
                    model.resetTimer(0)
                    showMenuFlag = false
                end
            elseif field == 1 then subMenu = 1
            end
        elseif event == EVT_VIRTUAL_EXIT then 
            showMenuFlag = false
        else
            navigate(event, fieldMax, 0, 0)
        end
    end
end

function secondsToClock(seconds)
    local seconds = tonumber(seconds)
  
    if seconds <= 0 then
        return "00:00"
        --return "00:00:00"
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
        return mins..":"..secs
        --return hours..":"..mins..":"..secs
    end
end

function shared.run(event)
    drawLink(2, 12)
    drawDriveMode(47, 12, CENTER + BOLD)

    if settingEnabled({"zts", "batIndicator", "enable"}) then drawVoltageImage(110, 11, 10, sensor.batValue, settings.zts.batIndicator.minVoltage, settings.zts.batIndicator.maxVoltage) end
    if settingEnabled({"steering", "fourWS"}) then fourWheelSteering() end

    if settingEnabled({"zts", "timer", "enable"}) then
        lcd.drawText(50, 42, secondsToClock(model.getTimer(0).value), DBLSIZE)
        lcd.drawText(68, 55, "m", SMALL)
        lcd.drawText(90, 55, "s", SMALL)
    end

    if settingEnabled({"ztm", "sensorReplace", "enable"}) then
        lcd.drawNumber(32, 42, sensor.temp * 10, DBLSIZE + RIGHT + PREC1)
        lcd.drawText(32, 42, "°C", LEFT)
    end

    if not alarmActiv then
        if event == 100 then
            shared.changeScreen(1)
        elseif event == 101 then
            shared.changeScreen(-1)
        end

        if not showMenuFlag and event == EVT_VIRTUAL_ENTER then
            showMenuFlag = true
            edit = false
        elseif showMenuFlag then
            showMenu(event)
        end
    else
        showMenuFlag = false
    end
end