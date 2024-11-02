shared = ...

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

    lcd.drawText(64, 20, "Reset Timer", getFieldFlags(0) + CENTER)

    if field == 0 then
        edit = false
        if event == EVT_VIRTUAL_ENTER then
            model.resetTimer(0)
            showMenuFlag = false
        end
    end
end

function shared.init()
    if settings.zts.batIndicator.mode == 0 then
        settings.zts.batIndicator.cells = math.ceil((getValue('RxBt') / 4.37) - 0.4)
        if getValue('RxBt') / settings.zts.batIndicator.cells < 4.3 then settings.zts.batIndicator.type = 0
        else settings.zts.batIndicator.type = 1 end
    end

    settings.zts.batIndicator.minVoltage = settings.zts.batIndicator.minCell * settings.zts.batIndicator.cells

    if settings.zts.batIndicator.type == 0 then settings.zts.batIndicator.maxVoltage = 4.2 * settings.zts.batIndicator.cells
    else settings.zts.batIndicator.maxVoltage = 4.35 * settings.zts.batIndicator.cells end
end

function shared.background()
    
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

    if settingEnabled(settings.zts, {"batIndicator", "enable"}) then drawVoltageImage(110, 11, 10, getValue('RxBt'), settings.zts.batIndicator.minVoltage, settings.zts.batIndicator.maxVoltage) end
    if settingEnabled(settings.steering, "fourWS") then fourWheelSteering() end

    if settingEnabled(settings.zts, {"timer", "enable"}) then
        lcd.drawText(50, 42, secondsToClock(model.getTimer(0).value), DBLSIZE)
        lcd.drawText(68, 55, "m", SMALL)
        lcd.drawText(90, 55, "s", SMALL)
    end

    if settingEnabled(settings.ztm, {"sensorReplace", "enable"}) then
        lcd.drawNumber(32, 42, getValue(settings.ztm.sensorReplace.sensors.temp.id) * 10, DBLSIZE + RIGHT + PREC1)
        lcd.drawText(32, 42, "°C", LEFT)
    end

    if not alarmActiv then
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
    else
        showMenuFlag = false
    end
end