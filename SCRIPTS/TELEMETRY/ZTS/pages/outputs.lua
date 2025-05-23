local shared = ...

local driveMode = 0
local showMenuFlag = false
local subMenu = 0
edit = false
field = 0
fieldMax = 1

loadScript("/SCRIPTS/helper/guiFunctions.lua")()

local function drawSteering()
    local yPos = 12
    local stearLimit

    if settingEnabled({"steering", "limit"}) then stearLimit = model.getGlobalVariable(0, driveMode)
    else stearLimit = 100 end

    lcd.drawText(2, yPos, "Steering", SMLSIZE)

    if settingEnabled({"steering", "DR"}) then
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

    if settingEnabled({"steering", "limit"}) then
        lcd.drawNumber(70, yPos+17, stearLimit, SMLSIZE + RIGHT)
        lcd.drawText(70, yPos+17, "%", SMLSIZE)
        lcd.drawText(78, yPos+17, "limit", SMLSIZE)
    end
end

local function drawBrake()
    local yPos = 41
    local brakeLimit = 100
    local brakeBalance = 0

    if settingEnabled({"brake", "limit"}) then brakeLimit = model.getGlobalVariable(2, driveMode) end

    lcd.drawText(2, yPos, "Brake", SMLSIZE)

    if settingEnabled({"brake", "balance"}) then
        brakeBalance = model.getGlobalVariable(3, driveMode)
        drawRelationNumber(50, yPos, -100, 100, brakeBalance)
        lcd.drawText(82, yPos, "balance", SMLSIZE)
    end

    if settingEnabled({"brake", "servo"}) then
        lcd.drawText(2, yPos+8, "R", BOLD)
        lcd.drawText(120, yPos+8, "F", BOLD)
    end

    drawLimitOffsetGauge(12, yPos+8, 104, 7, -100, 100, brakeLimit, brakeBalance, 0)

    if settingEnabled({"brake", "limit"}) then
        lcd.drawNumber(70, yPos+17, brakeLimit, SMLSIZE + RIGHT)
        lcd.drawText(70, yPos+17, "%", SMLSIZE)
        lcd.drawText(78, yPos+17, "limit", SMLSIZE)
    end

    local rearBrakeOutput = math.min(getOutputValue(1) / 10.24, 0)
    lcd.drawNumber(18, yPos+17, rearBrakeOutput, SMLSIZE + RIGHT)
    lcd.drawText(19, yPos+17, "%", SMLSIZE)

    if settingEnabled({"brake", "servo"}) then
        local brakeValue
        if settingEnabled({"brake", "invert"}) then
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

    if settingEnabled({"brake", "servoOutput"}) then
        if model.getOutput(settings.brake.servoOutput).revert == 0 then settings["brake"]["invert"] = 1
        else settings["brake"]["invert"] = -1 end
    end
end

local function showTrim(event)
    navigate(event, fieldMax, 0, 0)

    if settingEnabled({"brake", "servo"}) then height = 50
    else height = 35 end

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

    if settingEnabled({"brake", "servo"}) then
        fieldMax = 1

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

    if event == EVT_VIRTUAL_EXIT then
        subMenu = 0
        field = 0
    end
end

local function copyTrims(dm)
    -- steering limit
    if settingEnabled({"steering", "limit"}) then
        gv = model.getGlobalVariable(0, driveMode)
        model.setGlobalVariable(0, dm, gv)
    end
    -- steering d/r
    if settingEnabled({"steering", "DR"}) then
        gv = model.getGlobalVariable(1, driveMode)
        model.setGlobalVariable(1, dm, gv)
    end
    -- brake limit
    if settingEnabled({"steering", "limit"}) then
        gv = model.getGlobalVariable(2, driveMode)
        model.setGlobalVariable(2, dm, gv)
    end
    -- brake balance
    if settingEnabled({"steering", "balance"}) then
        gv = model.getGlobalVariable(3, driveMode)
        model.setGlobalVariable(3, dm, gv)
    end

    showMenuFlag = false
end

local function showMenu(event)
    if subMenu == 0 then
        fieldMax = 2

        lcd.drawFilledRectangle(6, 9, 116, 40, ERASE + CENTER)
        lcd.drawRectangle(6, 9, 116, 40, CENTER)

        lcd.drawText(64, 12, "Trims", getFieldFlags(0) + CENTER)

        if driveMode == 0 then
            lcd.drawText(64, 22, "copy Settings to DM1", getFieldFlags(1) + CENTER)
            lcd.drawText(64, 32, "copy Settings to DM2", getFieldFlags(2) + CENTER)
        elseif driveMode == 1 then
            lcd.drawText(64, 22, "copy Settings to DM0", getFieldFlags(1) + CENTER)
            lcd.drawText(64, 32, "copy Settings to DM2", getFieldFlags(2) + CENTER)
        elseif driveMode == 2 then
            lcd.drawText(64, 22, "copy Settings to DM0", getFieldFlags(1) + CENTER)
            lcd.drawText(64, 32, "copy Settings to DM1", getFieldFlags(2) + CENTER)
        end

        if event == EVT_VIRTUAL_ENTER then
            if field == 0 then subMenu = 1
            elseif field == 1 then
                if driveMode == 0 then copyTrims(1)
                elseif driveMode == 1 then copyTrims(0)
                elseif driveMode == 2 then copyTrims(0) end
            elseif field == 2 then
                if driveMode == 0 then copyTrims(2)
                elseif driveMode == 1 then copyTrims(2)
                elseif driveMode == 2 then copyTrims(1) end
            end
        elseif event == EVT_VIRTUAL_EXIT then 
            showMenuFlag = false
        else
            navigate(event, fieldMax, 0, 0)
        end
    elseif subMenu == 1 then
        showTrim(event)
    end
end

function shared.background()
    driveMode = getFlightMode()
end

function shared.run(event)
    drawSteering()
    -- seperator
    lcd.drawLine(0, 38, 128, 38, SOLID, FORCE)
    drawBrake()

    if not alarmActiv then
        if not showMenuFlag and event == EVT_VIRTUAL_ENTER then
            showMenuFlag = true
            edit = false

        elseif showMenuFlag == true then
            showMenu(event)
        end


        if event == 100 then
            shared.changeScreen(1)
        elseif event == 101 then
            shared.changeScreen(-1)
        end
    else
        showMenuFlag = false
    end
end