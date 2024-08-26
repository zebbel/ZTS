loadScript("/SCRIPTS/helper/ztsSettings.lua", 'tc')()
local zstSettings = {}
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
    if settingEnabled(zstSettings.model, "modul") and zstSettings.model.modul == 1 then
        modulTabel.Type = 5
        model.setModule(0, modulTabel)
    end
end

local function setLogicSwitches()
    local logicSwitchTabel = {}

    if settingEnabled(zstSettings.esc, "arm") then

        logicSwitchTabel["func"] = LS_FUNC_AND
        logicSwitchTabel["v1"] = 196
        logicSwitchTabel["v2"] = -124
        logicSwitchTabel["and"] = 0
        model.setLogicalSwitch(0, logicSwitchTabel)

        logicSwitchTabel["func"] = LS_FUNC_AND
        logicSwitchTabel["v1"] = zstSettings.esc.armSwitch
        logicSwitchTabel["v2"] = 196
        logicSwitchTabel["and"] = 0
        model.setLogicalSwitch(1, logicSwitchTabel)

        logicSwitchTabel["func"] = LS_FUNC_OR
        logicSwitchTabel["v1"] = zstSettings.esc.armSwitch
        logicSwitchTabel["v2"] = -196
        logicSwitchTabel["and"] = 124
        model.setLogicalSwitch(2, logicSwitchTabel)

        logicSwitchTabel["func"] = LS_FUNC_STICKY
        logicSwitchTabel["v1"] = 122
        logicSwitchTabel["v2"] = 123
        logicSwitchTabel["and"] = 0
        model.setLogicalSwitch(3, logicSwitchTabel)
    end

    if settingEnabled(zstSettings.steering, "fourWS") then
        logicSwitchTabel["func"] = LS_FUNC_STICKY
        logicSwitchTabel["v1"] = zstSettings.steering.crabSteerSwitch
        logicSwitchTabel["v2"] = zstSettings.steering.crabSteerSwitch
        logicSwitchTabel["and"] = zstSettings.steering.awsSteerSwitch
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

    if settingEnabled(zstSettings.steering, "limit") then
        setSpecialFunction(185, zstSettings.steering.limitSwitch, 0, specialFunctionNum)
        specialFunctionNum = specialFunctionNum + 1
        checkGlobalVariable(0, 0, 100)
    else
        deleteSpecialFunction(0)
    end
    if settingEnabled(zstSettings.steering, "DR") then
        setSpecialFunction(185, zstSettings.steering.drSwitch, 1, specialFunctionNum)
        specialFunctionNum = specialFunctionNum + 1
    else
        deleteSpecialFunction(1)
    end

    if settingEnabled(zstSettings.brake, "limit") then
        setSpecialFunction(185, zstSettings.brake.limitSwitch, 2, specialFunctionNum)
        specialFunctionNum = specialFunctionNum + 1
        checkGlobalVariable(2, 0, 100)
    else
        deleteSpecialFunction(2)
    end
    if settingEnabled(zstSettings.brake, "balance") then
        setSpecialFunction(185, zstSettings.brake.balanceSwitch, 3, specialFunctionNum)
        specialFunctionNum = specialFunctionNum + 1
    else
        deleteSpecialFunction(3)
    end

    if settingEnabled(zstSettings.esc, "arm") then
        customFunctionTable["switch"] = -196
        customFunctionTable["func"] = 23
        customFunctionTable["name"] = "red"
        model.setCustomFunction(specialFunctionNum, customFunctionTable)
        specialFunctionNum = specialFunctionNum + 1

        customFunctionTable["switch"] = 121
        customFunctionTable["func"] = 23
        customFunctionTable["name"] = "orange"
        model.setCustomFunction(specialFunctionNum, customFunctionTable)
        specialFunctionNum = specialFunctionNum + 1

        customFunctionTable["switch"] = 124
        customFunctionTable["func"] = 23
        customFunctionTable["name"] = "green"
        model.setCustomFunction(specialFunctionNum, customFunctionTable)
        specialFunctionNum = specialFunctionNum + 1
    end
end

local function setFlightModes()
    local flightModeTable = {}
    if settingEnabled(zstSettings.steering, "fourWS") then
        flightModeTable.name = "front"
        flightModeTable.switch = 0
        model.setFlightMode(0, flightModeTable)

        flightModeTable.name = "rear"
        flightModeTable.switch = zstSettings.steering.rearSteerSwitch
        model.setFlightMode(1, flightModeTable)

        flightModeTable.name = "crab"
        flightModeTable.switch = 121
        model.setFlightMode(2, flightModeTable)

        flightModeTable.name = "4WS"
        flightModeTable.switch = zstSettings.steering.fourWS
        model.setFlightMode(3, flightModeTable)
    end
end

local function setCurves()
    curveTable = {}
    curveTable["smooth"] = false
    curveTable["type"] = 1

    if settingEnabled(zstSettings.brake, "limit") or settingEnabled(zstSettings.brake, "balance") then
        curveTable["name"] = "TH"
        curveTable["x"] = {-100, -50, 0, 50, 100}
        curveTable["y"] = {0, 0, 0, 50, 100}
        model.setCurve(0, curveTable)

        curveTable["name"] = "RBR"
        curveTable["x"] = {-100, -50, 0, 50, 100}
        curveTable["y"] = {-100, -50, 0, 0, 0}
        model.setCurve(1, curveTable)
    end

    if settingEnabled(zstSettings.brake, "servo") then
        curveTable["name"] = "FBK"
        curveTable["x"] = {-100, -50, 0, 4, 5, 100}
        curveTable["y"] = {-100, -50, 0, 0, 25, 25}
        model.setCurve(2, curveTable)
    end
end

local function setInputs()
    local inputTable = {name="", inputName="", source=75, weight=100, offset=0, switch=0, curveType=1, curveValue=0, carryTrim=0, flightModes=0}

    -- G1 = -128, G2 = -127, G3 = -126, G4 = -125
    -- -G1 = 127, -G2 = 126, -G3 = 125, -G4 = 124
    -- curveType: 0 = DIFF, 1 = EXPO

    model.deleteInputs()

    inputTable.inputName = "St"
    inputTable.source = 75
    if settingEnabled(zstSettings.steering, "limit") then
        inputTable.weight = -128
    else
        inputTable.weight = 100
    end
    if settingEnabled(zstSettings.steering, "DR") then
        inputTable.curveType = 1
        inputTable.curveValue = -127
    else
        inputTable.curveType = 0
        inputTable.curveValue = 0
    end
    model.insertInput(steeringInput, 0, inputTable)

    if settingEnabled(zstSettings.brake, "limit") or settingEnabled(zstSettings.brake, "balance") then
        inputTable.inputName = "Th"
        inputTable.source = 76
        inputTable.weight = 100
        inputTable.curveType = 0
        inputTable.curveValue = 0
        model.insertInput(throttelInput, 0, inputTable)

        inputTable.inputName = "RBR"
        inputTable.source = 76
        if settingEnabled(zstSettings.brake, "limit") then
            inputTable.weight = -126
        else
            inputTable.weight = 100
        end
        inputTable.curveType = 0
        if settingEnabled(zstSettings.brake, "balance") then
            inputTable.curveValue = -125
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

    if settingEnabled(zstSettings.brake, "servo") then
        inputTable.inputName = "FBR"
        inputTable.source = 76
        inputTable.weight = -126
        inputTable.curveType = 0
        inputTable.curveValue = 124
        model.insertInput(brakeServoInput, 0, inputTable)
    end
end

local function setMixers()
    local mixTabel = {name="", source=0, weight=100, offset=0, switch=0, multiplex=0, curveType=0, curveValue=0, flightModes=0, carryTrim=0, mixWarn=0, delayUp=0, delayDown=0, speedUp=0, speedDown=0}

    model.deleteMixes()

    mixTabel.source = 1
    model.insertMix(0, 0, mixTabel)
    
    mixTabel.source = 2
    if settingEnabled(zstSettings.brake, "limit") or settingEnabled(zstSettings.brake, "balance") then
        mixTabel.curveType = 3
        mixTabel.curveValue = 1
    else
        mixTabel.curveType = 0
        mixTabel.curveValue = 0
    end

    if settingEnabled(zstSettings.esc, "arm") then
        mixTabel.switch = 124
    end
    model.insertMix(1, 0, mixTabel)

    if settingEnabled(zstSettings.brake, "limit") or settingEnabled(zstSettings.brake, "balance") then
        mixTabel.source = 3
        mixTabel.curveType = 3
        mixTabel.curveValue = 2
        mixTabel.switch = 0
        model.insertMix(1, 1, mixTabel)
    end

    if settingEnabled(zstSettings.brake, "servo") then
        mixTabel.source = 4
        mixTabel.curveType = 3
        mixTabel.curveValue = 3
        mixTabel.switch = 0
        model.insertMix(2, 0, mixTabel)
    end
end

local function setOutputs()
    local outputTable = {}

    outputTable = model.getOutput(zstSettings.steering.output)
    outputTable.name = "STR"
    model.setOutput(0, outputTable)

    outputTable = model.getOutput(zstSettings.esc.output)
    outputTable.name = "ESC"
    model.setOutput(1, outputTable)

    if settingEnabled(zstSettings.brake, "servo") then
        outputTable = model.getOutput(zstSettings.brake.servoOutput)
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

    zstSettings = readSettingsFile(zstSettings, "/MODELS/ZTS/" .. string.gsub(modelFileName, ".yml", "") .. ".txt", true)

    setModuls()
    setLogicSwitches()
    setSpecialFunctions()
    setFlightModes()
    setCurves()
    setInputs()
    setMixers()
    setOutputs()

    --return "/SCRIPTS/WIZARD/car/setModel.lua"
    return 2
end

return {init = init, run = run}