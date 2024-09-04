local shared = ...

local driveMode = 0
local showTrimFlag = false
edit = false

local function showTrim(event)
    height = 30

    lcd.drawFilledRectangle(9, 15, 110, height, ERASE + CENTER)
    lcd.drawRectangle(9, 15, 110, height, CENTER)

    -- steering center
    lcd.drawText(64, 18, "Steering Center", CENTER + BOLD)
    steeringOutputTable = model.getOutput(settings.steering.output)
    lcd.drawNumber(55, 28, 1500 + steeringOutputTable.ppmCenter, getFieldFlags(0))

    steeringOutputTable.ppmCenter = valueIncDec(event, steeringOutputTable.ppmCenter, -500, 500)
    model.setOutput(settings.steering.output, steeringOutputTable)
end

local function drawSteering()
    local stearLimit

    if settingEnabled(settings.steering, "limit") then stearLimit = model.getGlobalVariable(0, driveMode)
    else stearLimit = 100 end

    lcd.drawText(64, 12, "Steering", CENTER + BOLD)

    if settingEnabled(settings.steering, "limit") then
        lcd.drawNumber(65, 25, stearLimit, SMLSIZE + RIGHT)
        lcd.drawText(65, 25, "%", SMLSIZE)
        lcd.drawText(74, 25, "limit", SMLSIZE)
    end

    local steerVal = math.ceil((getOutputValue(0) / 10.24) * settings.steering.invert)
    lcd.drawText(2, 40, "L", BOLD)
    drawLimitOffsetGauge(12, 38, 104, 10, -100, 100, stearLimit, 0, steerVal)
    lcd.drawText(120, 40, "R", BOLD)

    if settingEnabled(settings.steering, "DR") then
        lcd.drawNumber(65, 55, model.getGlobalVariable(1, driveMode), SMLSIZE + RIGHT)
        lcd.drawText(65, 55, "%", SMLSIZE)
        lcd.drawText(74, 55, "DR", SMLSIZE)
    end

    --lcd.drawNumber(18, yPos+17, getOutputValue(0) / 10.24, SMLSIZE + RIGHT)
    --lcd.drawText(19, yPos+17, "%", SMLSIZE)
end

function shared.init()
    if model.getOutput(settings.steering.output).revert == 0 then settings["steering"]["invert"] = 1
    else settings["steering"]["invert"] = -1 end
end

function shared.background()
    driveMode = getFlightMode()
end

function shared.run(event)
    drawSteering()

    -- servo trim
    if showTrimFlag == true then
        showTrim(event)
    end


    if event == 100 then
        shared.changeScreen(1)
    elseif event == 101 then
        shared.changeScreen(-1)
    end

    if not showTrimFlag and event == EVT_VIRTUAL_ENTER then
        showTrimFlag = true
        edit = false
    elseif showTrimFlag and event == EVT_VIRTUAL_ENTER then
        edit = not edit
    elseif showTrimFlag and event == EVT_VIRTUAL_EXIT then
        showTrimFlag = false
    end
end