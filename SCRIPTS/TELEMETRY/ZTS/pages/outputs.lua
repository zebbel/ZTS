local shared = ...

local driveMode = 0
local showTrimFlag = false
edit = false
field = 0
fieldMax = 1
dirty = false

loadScript("/SCRIPTS/helper/guiFunctions.lua")()

local function drawSteering()
    local yPos = 12
    local stearLimit

    if settingEnabled(settings.steering, "limit") then stearLimit = model.getGlobalVariable(0, driveMode)
    else stearLimit = 100 end

    lcd.drawText(2, yPos, "Steering", SMLSIZE)

    if settingEnabled(settings.steering, "DR") then
        lcd.drawNumber(70, yPos, model.getGlobalVariable(1, driveMode), SMLSIZE + RIGHT)
        lcd.drawText(70, yPos, "%", SMLSIZE)
        lcd.drawText(78, yPos, "DR", SMLSIZE)
    end

    local stearVal = math.ceil((getOutputValue(0) / 10.24) * settings.steering.invert)
    lcd.drawText(2, yPos+8, "L", BOLD)
    drawLimitOffsetGauge(12, yPos+8, 104, 7, -100, 100, stearLimit, 0, stearVal)
    lcd.drawText(120, yPos+8, "R", BOLD)

    lcd.drawNumber(18, yPos+17, getOutputValue(0) / 10.24, SMLSIZE + RIGHT)
    lcd.drawText(19, yPos+17, "%", SMLSIZE)

    if settingEnabled(settings.steering, "limit") then
        lcd.drawNumber(70, yPos+17, stearLimit, SMLSIZE + RIGHT)
        lcd.drawText(70, yPos+17, "%", SMLSIZE)
        lcd.drawText(78, yPos+17, "limit", SMLSIZE)
    end
end

local function drawBrake()
    local yPos = 41
    local brakeLimit = 100
    local brakeBalance = 0

    if settingEnabled(settings.brake, "limit") then brakeLimit = model.getGlobalVariable(2, driveMode) end

    lcd.drawText(2, yPos, "Brake", SMLSIZE)

    if settingEnabled(settings.brake, "balance") then
        brakeBalance = model.getGlobalVariable(3, driveMode)
        drawRelationNumber(50, yPos, -100, 100, brakeBalance)
        lcd.drawText(82, yPos, "balance", SMLSIZE)
    end

    if settingEnabled(settings.brake, "servo") then
        lcd.drawText(2, yPos+8, "R", BOLD)
        lcd.drawText(120, yPos+8, "F", BOLD)
    end

    drawLimitOffsetGauge(12, yPos+8, 104, 7, -100, 100, brakeLimit, brakeBalance, 0)

    if settingEnabled(settings.brake, "limit") then
        lcd.drawNumber(70, yPos+17, brakeLimit, SMLSIZE + RIGHT)
        lcd.drawText(70, yPos+17, "%", SMLSIZE)
        lcd.drawText(78, yPos+17, "limit", SMLSIZE)
    end

    local rearBrakeOutput = math.min(getOutputValue(1) / 10.24, 0)
    lcd.drawNumber(18, yPos+17, rearBrakeOutput, SMLSIZE + RIGHT)
    lcd.drawText(19, yPos+17, "%", SMLSIZE)

    if settingEnabled(settings.brake, "servo") then
        local brakeValue
        if settingEnabled(settings.brake, "invert") then
            brakeValue = (getOutputValue(2) / 10.24) * settings.brake.invert
        else
            brakeValue = (getOutputValue(2) / 10.24)
        end
        lcd.drawNumber(120, yPos+17, brakeValue, SMLSIZE + RIGHT)
        lcd.drawText(120, yPos+17, "%", SMLSIZE)
    end
end

function shared.init()
    if model.getOutput(settings.steering.output).revert == 0 then settings["steering"]["invert"] = 1
    else settings["steering"]["invert"] = -1 end

    if settingEnabled(settings.brake, "servoOutput") then
        if model.getOutput(settings.brake.servoOutput).revert == 0 then settings["brake"]["invert"] = 1
        else settings["brake"]["invert"] = -1 end
    end
end

local function showTrim(event)
    if settingEnabled(settings.brake, "servo") then height = 50
    else height = 30 end

    lcd.drawFilledRectangle(9, 9, 110, height, ERASE + CENTER)
    lcd.drawRectangle(9, 9, 110, height, CENTER)

    -- steering center
    lcd.drawText(64, 12, "Steering Center", CENTER + BOLD)
    steeringOutputTable = model.getOutput(settings.steering.output)
    if steeringOutputTable.revert == 0 then steeringCenter = steeringOutputTable.ppmCenter
    else steeringCenter = steeringOutputTable.ppmCenter * -1 end
    drawCenterGauge(25, 22, 80, 5, 100, steeringCenter)
    lcd.drawNumber(55, 30, 1500 + steeringOutputTable.ppmCenter, getFieldFlags(0))

    if field==0 then
        steeringOutputTable.ppmCenter = valueIncDec(event, steeringOutputTable.ppmCenter, -100, 100)
        model.setOutput(settings.steering.output, steeringOutputTable)
    end

    if settingEnabled(settings.brake, "servo") then
        -- brake servo center
        lcd.drawText(64, 39, "Brake Servo Center", CENTER + BOLD)
        brakeOutputTable = model.getOutput(settings.brake.servoOutput)
        lcd.drawNumber(55, 48, 1500 + brakeOutputTable.ppmCenter, getFieldFlags(1))

        if field==1 then
            brakeOutputTable.ppmCenter = valueIncDec(event, brakeOutputTable.ppmCenter, -500, 500)
            model.setOutput(settings.brake.servoOutput, brakeOutputTable)
        end
    else
        fieldMax = 0
    end
end

function shared.background()
    driveMode = getFlightMode()
end

function shared.run(event)
    drawSteering()
    -- seperator
    local yPos = 38
    lcd.drawLine(0, yPos, 128, yPos, SOLID, FORCE)
    drawBrake()

    if not alarmActiv then
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
        elseif showTrimFlag and event == EVT_VIRTUAL_EXIT then
            showTrimFlag = false
        elseif showTrimFlag then
            navigate(event, fieldMax, 0, 0)
        end
    else
        showTrimFlag = false
    end
end