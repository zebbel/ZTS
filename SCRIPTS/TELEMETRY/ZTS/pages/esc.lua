local shared = ...

local brakeServoLimit = 100

local function drawESC()
    local brakeLimit = 100
    if settingEnabled(settings.brake, "limit") then brakeLimit = model.getGlobalVariable(2, driveMode) end
    local throttleLimit = 100
    if settingEnabled(settings.esc.limit, "enable") then throttleLimit = model.getGlobalVariable(4, driveMode) end

    lcd.drawText(1, 17, "ESC", LEFT + BOLD)

    local escVal = math.ceil(getOutputValue(1) / 10.24)
    local brakeBalance = math.max(model.getGlobalVariable(3, driveMode), 0)
    drawLimitOffsetGaugeSplit(32, 15, 94, 10, brakeLimit, throttleLimit, brakeBalance, 0, escVal)

    if settingEnabled(settings.brake, "limit") then
        lcd.drawNumber(40, 45, brakeLimit, RIGHT)
        lcd.drawText(40, 45, "%")
        lcd.drawText(70, 45, "limit")
    end
end

local function drawBrake()
    local brakeLimit = 100
    if settingEnabled(settings.brake, "limit") then brakeLimit = model.getGlobalVariable(2, driveMode) end

    lcd.drawText(1, 32, "Brake", LEFT + BOLD)

    local brakeVal = math.ceil(getOutputValue(2) / 10.24)
    local brakeBalance = math.min(model.getGlobalVariable(3, driveMode), 0) * -1
    drawLimitOffsetGaugeSplit(32, 30, 94, 10, brakeLimit, brakeServoLimit, brakeBalance, 0, brakeVal)

    if settingEnabled(settings.brake, "balance") then
        brakeBalance = model.getGlobalVariable(3, driveMode)
        drawRelationNumber(30, 55, -100, 100, brakeBalance)
        lcd.drawText(70, 55, "balance")
    end
end

function shared.init()
    if settingEnabled(settings.brake, "servo") then
        if model.getOutput(settings.brake.servoOutput).revert == 0 then settings["brake"]["invert"] = 1
        else settings["brake"]["invert"] = -1 end

        brakeServoLimit = model.getCurve(2).y[5]
    end
end

function shared.background()
    driveMode = getFlightMode()
end

function shared.run(event)
    drawESC()
    if settingEnabled(settings.brake, "servo") then drawBrake() end

    if event == 100 then
        shared.changeScreen(1)
    elseif event == 101 then
        shared.changeScreen(-1)
    end
end