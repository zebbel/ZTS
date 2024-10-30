
timeNow = getDateTime()
tick = math.fmod(getTime() / 100, 2)

radio = getGeneralSettings()
txvoltage = getValue(239)

function time()
    timeNow = getDateTime()
    tick = math.fmod(getTime() / 100, 2)

    txvoltage = getValue(239)
end

function drawCheckbox(x, y, value, flags)
    local size = 9

    if flags == 0 then
        lcd.drawRectangle(x, y, size, size)
    elseif flags == INVERS then
        lcd.drawFilledRectangle(x, y, size, size)
    end

    if value == 1 or value == true then
        if flags == 0 then
            lcd.drawLine(x+1, y+(size/2), x+(size/3)-1, y+size-3, SOLID, 0)
            lcd.drawLine(x+(size/3), y+size-2, x+size-2, y+1, SOLID, 0)
        elseif flags == INVERS then
            --lcd.drawLine(x+1, y+3, x+3, y+5, SOLID, ERASE)
            --lcd.drawLine(x+3, y+4, x+5, y+1, SOLID, ERASE)
            lcd.drawLine(x+1, y+(size/2), x+(size/3)-1, y+size-3, SOLID, ERASE)
            lcd.drawLine(x+(size/3), y+size-2, x+size-2, y+1, SOLID, ERASE)
        end
    end

end

local function drawTime(x, y)
    -- local timeNow = getDateTime()

    -- Clock icon
    lcd.drawLine(x + 1, y + 0, x + 4, y + 0, SOLID, FORCE)
    lcd.drawLine(x + 0, y + 1, x + 0, y + 4, SOLID, FORCE)
    lcd.drawLine(x + 5, y + 1, x + 5, y + 4, SOLID, FORCE)
    lcd.drawLine(x + 2, y + 2, x + 2, y + 3, SOLID, FORCE)
    lcd.drawLine(x + 2, y + 3, x + 3, y + 3, SOLID, FORCE)
    lcd.drawLine(x + 1, y + 5, x + 4, y + 5, SOLID, FORCE)

    -- Time as text, blink on tick
    lcd.drawText(x + 08, y, string.format('%02.0f%s', timeNow.hour, math.ceil(tick) == 1 and '' or ':'), SMLSIZE)
    lcd.drawText(x + 20, y, string.format('%02.0f', timeNow.min), SMLSIZE)
end

-- Tx voltage icon with % indication
local function drawTransmitterVoltage(x, y, w)
    local percent = math.min(math.max(math.ceil((txvoltage - radio.battMin) * 100 / (radio.battMax - radio.battMin)), 0), 100)
    local filling = math.ceil(percent / 100 * (w - 1) + 0.2)

    -- Battery outline
    lcd.drawRectangle(x, y, w + 1, 6, SOLID)
    lcd.drawLine(x + w + 1, y + 1, x + w + 1, y + 4, SOLID, FORCE)

    -- Battery percentage (after battery)
    lcd.drawText(x + w + 4, y, percent .. '%', SMLSIZE + (percent > 20 and 0 or BLINK))

    -- Fill the battery
    lcd.drawRectangle(x, y + 1, filling, 4, SOLID)
    lcd.drawRectangle(x, y + 2, filling, 2, SOLID)
end

function drawTitle(name, armLS)
    --lcd.drawFilledRectangle(0, 0, 128, 10)
    lcd.drawLine(0, 9, 128, 9, SOLID, FORCE)

    if getRSSI() == 0 and math.ceil(getTime()/100) % 2 == 1 then
        lcd.drawText(64, 1, "disconnect", CENTER + BOLD)
    elseif getLogicalSwitchValue(armLS) == true and math.ceil(getTime()/100) % 2 == 1  then
        lcd.drawText(64, 1, "unarmed", CENTER + BOLD)
    else
        lcd.drawText(64, 1, name, CENTER + BOLD)
    end

    drawTime(96, 2)
    drawTransmitterVoltage(2, 2, LCD_W / 10)
end

function drawCenterGauge(x, y, w, h, range, val)
    lcd.drawRectangle(x, y, w, h)
    lcd.drawLine((w/2)+x, y-2, (w/2)+x, y+h+1, SOLID, 0)

    val = math.ceil(100 / range * val)

    local width = math.ceil((w/2) / 100 * val + 0.2)

    if val > 0 then
        lcd.drawFilledRectangle((w/2)+x, y+1, width, h-2)
        lcd.drawText(x+w+1, y-1, ">")
    elseif val < 0 then
        lcd.drawFilledRectangle((w/2)+x+width, y+1, width * -1, h-2)
        lcd.drawText(x-5, y-1, "<")
    end
end

function drawLimitOffsetGauge(x, y, w, h, min, max, limit, offset, val)
    lcd.drawRectangle(x, y, w, h)

    val = math.ceil((w/2) / 100 * val)
    if val > 1 or val < -1 then
        lcd.drawLine((w/2)+x, y-2, (w/2)+x, y+h+1, SOLID, 0)
        if val > 0 then
            val = val -1
        end
    end
    lcd.drawLine((w/2)+x+val, y-2, (w/2)+x+val, y+h+1, SOLID, 0)
    lcd.drawLine(x-1, y-2, x-1, y+h+1, SOLID, 0)
    lcd.drawLine(x+w, y-2, x+w, y+h+1, SOLID, 0)

    local width = w / 100 * limit
    limit = (w - width) / 2
    offset = ((w / 2) - limit) / 100 * offset
    local xStart = x + limit + math.max(offset, 0)
    width = math.ceil(width - math.abs(offset))

    lcd.drawFilledRectangle(xStart, y + 1, width, h - 2)
end

function drawRelationNumber(x, y, min, max, relation)
    if min < 0 then
        max = max + math.abs(min)
        relation = relation + math.abs(min)
    end

    local frontRatio = (100 / max) * relation
    local backRatio = 100 - frontRatio

    lcd.drawNumber(x+10, y, backRatio, SMLSIZE + RIGHT)
    lcd.drawText(x+12, y, "/", SMLSIZE)
    lcd.drawNumber(x+19, y, frontRatio, SMLSIZE)
end

function drawDriveMode(x, y)
    driveModeNum, driveModeName = getFlightMode()

    -- Draw top rectangle
    lcd.drawRectangle(x, y, 55, 10, SOLID)

    lcd.drawText(x+2, y+2, "drive mode", SMLSIZE)

    -- Draw big bottom rectangle
    lcd.drawRectangle(x, y + 9, 55, 15, SOLID)

    if driveModeName == "" then
        lcd.drawText(x+2, y+13, "DM" .. driveModeNum, BOLD)
    else
        lcd.drawText(x+2, y+13, driveModeName, BOLD)
    end
end

local function printLQ(x, y)
    local rssi, alarm_low = getRSSI()
    local lq = getValue('RQly')
    -- Draw lq
    lcd.drawText(x + 2, y + 4, 'LQ' .. ':', SMLSIZE + (lq > alarm_low and 0 or BLINK))
    lcd.drawText(x + 15, y + 4, tostring(lq), SMLSIZE + (lq > alarm_low and 0 or BLINK))

    -- Draw simbol
    if lq > 0 then
        lcd.drawLine(x + 35, y + 3, x + 35, y + 3, SOLID, FORCE)
        lcd.drawLine(x + 36, y + 2, x + 40, y + 2, SOLID, FORCE)
        lcd.drawLine(x + 41, y + 3, x + 41, y + 3, SOLID, FORCE)
        lcd.drawLine(x + 36, y + 5, x + 36, y + 5, SOLID, FORCE)
        lcd.drawLine(x + 37, y + 4, x + 39, y + 4, SOLID, FORCE)
        lcd.drawLine(x + 40, y + 5, x + 40, y + 5, SOLID, FORCE)
        lcd.drawLine(x + 38, y + 7, x + 38, y + 7, SOLID, FORCE)
    end
end

-- Draw RSSI Dbm and Lq--
function drawLink(x, y)
    local rssi, alarm_low = getRSSI()
    local lq = getValue('RQly')

    -- Draw top rectangle
    lcd.drawRectangle(x, y, 44, 10, SOLID)

    --Draw captions and values
    if lq ~= 0 then
        -- Draw small bottom rectangle
        lcd.drawRectangle(x, y + 9, 44, 15, SOLID)
        printLQ(x, y + 9)
    else
        -- Draw big bottom rectangle
        lcd.drawRectangle(x, y + 9, 44, 15, SOLID)
        if rssi > 0 then
            for t = 2, (rssi > 0 and rssi or rssiDraw) + 2, 2 do
                lcd.drawLine(x + 1 + t / 2.5, y + (20 - t / 10), x + 1 + t / 2.5, y + 22, SOLID, FORCE)
            end
        end
    end

    lcd.drawText(x + 2, y + 2, 'RSSI' .. ':', SMLSIZE + ((rssi == 0 or rssi < alarm_low) and BLINK or 0))
    lcd.drawText(x + 24, y + 2, rssi, SMLSIZE + ((rssi == 0 or rssi < alarm_low) and BLINK or 0))
end

function drawVoltageImage(x, y, w, sensor)
    local voltage = getValue(sensor)
    local batt, cell = 0, 0
    
    -- Try to calculate cells count from batt voltage or skip if using Cels telemetry
    -- Don't support 5s and 7s: it's dangerous to detect - empty 8s look like an 7s!
    if (type(voltage) == 'table') then
        for i, v in ipairs(voltage) do
            batt = batt + v
            cell = cell + 1
        end

        voltage = batt
    else
        cell = math.ceil((voltage / 4.37) - 0.4)
        cell = cell == (5 or 7) and cell + 1 or cell

        batt = voltage
    end

    -- Set mix-max battery cell value, also detect HV type
    local voltageHigh = batt > 4.22 * cell and 4.35 or 4.2
    local voltageLow = 3.3

    -- Draw battery outline
    lcd.drawLine(x + 2, y + 1, x + w - 2, y + 1, SOLID, 0)
    lcd.drawLine(x, y + 2, x + w - 1, y + 2, SOLID, 0)
    lcd.drawLine(x, y + 2, x, y + 50, SOLID, 0)
    lcd.drawLine(x, y + 50, x + w - 1, y + 50, SOLID, 0)
    lcd.drawLine(x + w, y + 3, x + w, y + 49, SOLID, 0)

    -- Draw battery markers from top to bottom
    lcd.drawLine(x + w / 4 * 3, y + 08, x + w - 1, y + 08, SOLID, 0)
    lcd.drawLine(x + w / 4 * 2, y + 14, x + w - 1, y + 14, SOLID, 0)
    lcd.drawLine(x + w / 4 * 3, y + 20, x + w - 1, y + 20, SOLID, 0)
    lcd.drawLine(x + 1, y + 26, x + w - 1, y + 26, SOLID, 0)
    lcd.drawLine(x + w / 4 * 3, y + 32, x + w - 1, y + 32, SOLID, 0)
    lcd.drawLine(x + w / 4 * 2, y + 38, x + w - 1, y + 38, SOLID, 0)
    lcd.drawLine(x + w / 4 * 3, y + 44, x + w - 1, y + 44, SOLID, 0)

    -- Place voltage text [top, middle, bottom]
    --lcd.drawText(x + w + 4, y + 00, string.format('%.2fv', voltageHigh), SMLSIZE)
    --lcd.drawText(x + w + 4, y + 24, string.format('%.2fv', (voltageHigh - voltageLow) / 2 + voltageLow), SMLSIZE)
    --lcd.drawText(x + w + 4, y + 45, string.format('%.2fv', voltageLow), SMLSIZE)

    -- Fill the battery
    for offset = 0, 46, 1 do
        if ((offset * (voltageHigh - voltageLow) / 47) + voltageLow) < tonumber(batt / cell) then
            lcd.drawLine(x + 1, y + 49 - offset, x + w - 1, y + 49 - offset, SOLID, 0)
        end
    end
end

function drawWarnPopup(x, y, message)
    lcd.drawFilledRectangle(x, y, 110, 50, ERASE + CENTER)
    lcd.drawRectangle(x, y, 110, 50 , CENTER)

    lcd.drawText(LCD_W/2, y+2, "Warning", CENTER + BOLD + MIDSIZE)

    lcd.drawText(LCD_W/2, y+25, message, CENTER + BLINK)
end