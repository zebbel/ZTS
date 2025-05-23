loadScript("/SCRIPTS/helper/ztsSettings.lua", 'tc')()
local ztsSettings = {}
local modelSettings = {}
local modelFileName = model.getInfo().filename

-- script constants
local steeringInput = 0
local throttelInput = 1
local escBrakeInput = 2
local brakeServoInput = 3

local function settingEnabled(settingTable, setting)
    if settingTable ~= nil and settingTable[setting] == 1 then return true end
    return false
end

local function setModuls()
    local modulTabel = {}
    if settingEnabled(ztsSettings.model, "modul") and ztsSettings.model.modul == 1 then
        modulTabel.Type = 5
        model.setModule(0, modulTabel)
    end
end

local function setLogicSwitches()
    local logicSwitchTabel = {}

    if settingEnabled(ztsSettings.esc, "arm") then

        logicSwitchTabel["func"] = LS_FUNC_AND
        logicSwitchTabel["v1"] = 196
        logicSwitchTabel["v2"] = -124
        logicSwitchTabel["and"] = 0
        model.setLogicalSwitch(0, logicSwitchTabel)

        logicSwitchTabel["func"] = LS_FUNC_AND
        logicSwitchTabel["v1"] = ztsSettings.esc.armSwitch
        logicSwitchTabel["v2"] = 196
        logicSwitchTabel["and"] = 0
        model.setLogicalSwitch(1, logicSwitchTabel)

        logicSwitchTabel["func"] = LS_FUNC_OR
        logicSwitchTabel["v1"] = ztsSettings.esc.armSwitch
        logicSwitchTabel["v2"] = -196
        logicSwitchTabel["and"] = 124
        model.setLogicalSwitch(2, logicSwitchTabel)

        logicSwitchTabel["func"] = LS_FUNC_STICKY
        logicSwitchTabel["v1"] = 122
        logicSwitchTabel["v2"] = 123
        logicSwitchTabel["and"] = 0
        model.setLogicalSwitch(3, logicSwitchTabel)
    end

    if settingEnabled(ztsSettings.steering, "fourWS") then
        logicSwitchTabel["func"] = LS_FUNC_STICKY
        logicSwitchTabel["v1"] = ztsSettings.steering.crabSteerSwitch
        logicSwitchTabel["v2"] = ztsSettings.steering.crabSteerSwitch
        logicSwitchTabel["and"] = ztsSettings.steering.awsSteerSwitch
        model.setLogicalSwitch(0, logicSwitchTabel)
    end
end

local function checkGlobalVariable(gv, dm, value)
    actualValue = model.getGlobalVariable(gv, dm)

    if actualValue == 0 then
        model.setGlobalVariable(gv, dm, value)
    end
end

local function setSpecialFunction(switch, value, gvar, functionNum)
    local customFunctionTable = {switch = 185, func = FUNC_ADJUST_GVAR, name = nil, value = 94, mode = 1, param = 0, active = 1}
    customFunctionTable.switch = switch
    customFunctionTable.value = value
    customFunctionTable.param = gvar
    model.setCustomFunction(functionNum, customFunctionTable)
end

local function deleteSpecialFunction(functionNum)
    local customFunctionTable = {switch = 0, func = 0, name = nil, value = 0, mode = 0, param = 0, active = 0}
    model.setCustomFunction(functionNum, customFunctionTable)
end

local function setSpecialFunctions()
    local specialFunctionNum = 0
    local customFunctionTable = {switch = 185, func = FUNC_ADJUST_GVAR, name = nil, value = 94, mode = 1, param = 0, active = 1}

    -- steering
    if settingEnabled(ztsSettings.steering, "limit") then
        setSpecialFunction(185, ztsSettings.steering.limitSwitch, 0, specialFunctionNum)
        specialFunctionNum = specialFunctionNum + 1
        checkGlobalVariable(0, 0, 100)
    else
        deleteSpecialFunction(0)
    end
    if settingEnabled(ztsSettings.steering, "DR") then
        setSpecialFunction(185, ztsSettings.steering.drSwitch, 1, specialFunctionNum)
        specialFunctionNum = specialFunctionNum + 1
    else
        deleteSpecialFunction(1)
    end

    -- brake
    if settingEnabled(ztsSettings.brake, "limit") then
        setSpecialFunction(185, ztsSettings.brake.limitSwitch, 2, specialFunctionNum)
        specialFunctionNum = specialFunctionNum + 1
        checkGlobalVariable(2, 0, 100)
    else
        deleteSpecialFunction(2)
    end
    if settingEnabled(ztsSettings.brake, "balance") then
        setSpecialFunction(185, ztsSettings.brake.balanceSwitch, 3, specialFunctionNum)
        specialFunctionNum = specialFunctionNum + 1
    else
        deleteSpecialFunction(3)
    end

    --telemtry screen autostart
    if settingEnabled(ztsSettings.zts.telemetryAuto, "enable") then
        customFunctionTable["switch"] = 124
        customFunctionTable["func"] = 22
        customFunctionTable["value"] = 1
        model.setCustomFunction(specialFunctionNum, customFunctionTable)
        specialFunctionNum = specialFunctionNum + 1
    end

    --arm
    if settingEnabled(ztsSettings.esc, "arm") then
        customFunctionTable["switch"] = -196
        customFunctionTable["func"] = 24
        customFunctionTable["name"] = "red"
        customFunctionTable["value"] = nil
        customFunctionTable["mode"] = nil
        customFunctionTable["param"] = nil
        customFunctionTable["repetition"] = 1
        model.setCustomFunction(specialFunctionNum, customFunctionTable)
        specialFunctionNum = specialFunctionNum + 1

        customFunctionTable["switch"] = 121
        customFunctionTable["func"] = 24
        customFunctionTable["name"] = "orange"
        model.setCustomFunction(specialFunctionNum, customFunctionTable)
        specialFunctionNum = specialFunctionNum + 1

        customFunctionTable["switch"] = 124
        customFunctionTable["func"] = 24
        customFunctionTable["name"] = "green"
        model.setCustomFunction(specialFunctionNum, customFunctionTable)
        specialFunctionNum = specialFunctionNum + 1
    end

    deleteSpecialFunction(specialFunctionNum)
end

local function setFlightModes()
    local flightModeTable = {}
    if settingEnabled(ztsSettings.steering, "fourWS") then
        flightModeTable.name = "front"
        flightModeTable.switch = 0
        model.setFlightMode(0, flightModeTable)

        flightModeTable.name = "rear"
        flightModeTable.switch = ztsSettings.steering.rearSteerSwitch
        model.setFlightMode(1, flightModeTable)

        flightModeTable.name = "crab"
        flightModeTable.switch = 121
        model.setFlightMode(2, flightModeTable)

        flightModeTable.name = "4WS"
        flightModeTable.switch = ztsSettings.steering.fourWS
        model.setFlightMode(3, flightModeTable)
    end
end

local function setTimer()
    local timerTable = {}
    if settingEnabled(ztsSettings.zts.timer, "enable") then
        timerTable.mode = 1
        timerTable.switch = 124
        timerTable.persistent = 2
        model.setTimer(0, timerTable)
    end
end

local function setCurves()
    curveTable = {}
    curveTable["smooth"] = false
    curveTable["type"] = 1

    if settingEnabled(ztsSettings.brake, "limit") or settingEnabled(ztsSettings.brake, "balance") then
        curveTable["name"] = "TH"
        curveTable["x"] = {-100, -50, 0, 50, 100}
        curveTable["y"] = {0, 0, 0, 50, 100}
        model.setCurve(0, curveTable)

        curveTable["name"] = "RBR"
        curveTable["x"] = {-100, -50, 0, 50, 100}
        curveTable["y"] = {-100, -50, 0, 0, 0}
        model.setCurve(1, curveTable)
    end

    if settingEnabled(ztsSettings.brake, "servo") then
        curveTable["name"] = "FBK"
        curveTable["x"] = {-100, -50, 0, 4, 5, 100}
        curveTable["y"] = {-100, -50, 0, 0, 25, 25}
        model.setCurve(2, curveTable)
    end
end

local function setInputs()
    local inputTable = {name="", inputName="", source=75, weight=100, offset=0, switch=0, curveType=1, curveValue=0, carryTrim=0, flightModes=0}

    -- G1 = 1254, G2 = 1255, G3 = 1256, G4 = 1257
    -- -G1 = -1254, -G2 = -1255, -G3 = -1256, -G4 = -1257
    -- curveType: 0 = DIFF, 1 = EXPO

    model.deleteInputs()

    inputTable.inputName = "St"
    inputTable.source = 75
    if settingEnabled(ztsSettings.steering, "limit") then
        inputTable.weight = 1254
    else
        inputTable.weight = 100
    end
    if settingEnabled(ztsSettings.steering, "DR") then
        inputTable.curveType = 1
        inputTable.curveValue = 1255
    else
        inputTable.curveType = 0
        inputTable.curveValue = 0
    end
    model.insertInput(steeringInput, 0, inputTable)

    if settingEnabled(ztsSettings.brake, "limit") or settingEnabled(ztsSettings.brake, "balance") then
        inputTable.inputName = "Th"
        inputTable.source = 76
        inputTable.weight = 100
        inputTable.curveType = 0
        inputTable.curveValue = 0
        model.insertInput(throttelInput, 0, inputTable)

        inputTable.inputName = "RBR"
        inputTable.source = 76
        if settingEnabled(ztsSettings.brake, "limit") then
            inputTable.weight = 1256
        else
            inputTable.weight = 100
        end
        inputTable.curveType = 0
        if settingEnabled(ztsSettings.brake, "balance") then
            inputTable.curveValue = 1257
        else
            inputTable.curveValue = 0
        end
        model.insertInput(escBrakeInput, 0, inputTable)
    else
        inputTable.inputName = "Th"
        inputTable.source = 76
        inputTable.weight = 100
        inputTable.curveType = 0
        inputTable.curveValue = 0
        model.insertInput(throttelInput, 0, inputTable)
    end

    if settingEnabled(ztsSettings.brake, "servo") then
        inputTable.inputName = "FBR"
        inputTable.source = 76
        inputTable.weight = 1256
        inputTable.curveType = 0
        inputTable.curveValue = -1257
        model.insertInput(brakeServoInput, 0, inputTable)
    end
end

local function setMixers()
    local mixTabel = {name="", source=0, weight=100, offset=0, switch=0, multiplex=0, curveType=0, curveValue=0, flightModes=0, carryTrim=0, mixWarn=0, delayUp=0, delayDown=0, speedUp=0, speedDown=0}

    model.deleteMixes()

    mixTabel.source = 1
    model.insertMix(0, 0, mixTabel)
    
    mixTabel.source = 2
    if settingEnabled(ztsSettings.brake, "limit") or settingEnabled(ztsSettings.brake, "balance") then
        mixTabel.curveType = 3
        mixTabel.curveValue = 1
    else
        mixTabel.curveType = 0
        mixTabel.curveValue = 0
    end

    if settingEnabled(ztsSettings.esc, "arm") then
        mixTabel.switch = 124
    end
    model.insertMix(1, 0, mixTabel)

    if settingEnabled(ztsSettings.brake, "limit") or settingEnabled(ztsSettings.brake, "balance") then
        mixTabel.source = 3
        mixTabel.curveType = 3
        mixTabel.curveValue = 2
        mixTabel.switch = 0
        model.insertMix(1, 1, mixTabel)
    end

    if settingEnabled(ztsSettings.brake, "servo") then
        mixTabel.source = 4
        mixTabel.curveType = 3
        mixTabel.curveValue = 3
        mixTabel.switch = 0
        model.insertMix(2, 0, mixTabel)
    end
end

local function setOutputs()
    local outputTable = {}

    outputTable = model.getOutput(ztsSettings.steering.output)
    outputTable.name = "STR"
    model.setOutput(0, outputTable)

    outputTable = model.getOutput(ztsSettings.esc.output)
    outputTable.name = "ESC"
    model.setOutput(1, outputTable)

    if settingEnabled(ztsSettings.brake, "servo") then
        outputTable = model.getOutput(ztsSettings.brake.servoOutput)
        outputTable.name = "FBR"
        outputTable.curve = 2
        model.setOutput(2, outputTable)
    end
end

local function init()
end

local modelCreated = false

local function run(event)
    print("setSettings")
    collectgarbage()

    ztsSettings = readSettingsFile(ztsSettings, "/MODELS/ZTS/" .. string.gsub(modelFileName, ".yml", "") .. ".txt", true)

    setModuls()
    setLogicSwitches()
    setSpecialFunctions()
    setFlightModes()
    setTimer()
    setCurves()
    setInputs()
    setMixers()
    setOutputs()

    --return "/SCRIPTS/WIZARD/car/setModel.lua"
    return 2
end

return {init = init, run = run}