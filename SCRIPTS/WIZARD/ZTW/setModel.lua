loadScript("/SCRIPTS/WIZARD/ZTW/modelSettings.lua")()
loadScript("/SCRIPTS/helper/ztsSettings.lua", 'tc')()
local zstSettings = {}
local modelSettings = {}
local modelFileName = model.getInfo().filename

local modelCreated = false
local modelUpdated = false

local function settingEnabled(settingTable, setting)
    if settingTable ~= nil and settingTable[setting] == 1 then return true end
    return false
end

local function entryAvailable(entry, settingsTable)
    for index=1, #entry, 1 do
        if settingsTable[entry[index]] == nil then
            return false
        else
            settingsTable = settingsTable[entry[index]]
        end
    end

    return true
end

local function setSetting(setting, values)
    modelSetting = modelSettings
    for index=1, #setting-1, 1 do
        if modelSetting[setting[index]] == nil then modelSetting[setting[index]] = {} end
        modelSetting = modelSetting[setting[index]]
    end

    modelSetting[setting[#setting]] = values
end

local function setLogicSwitches()
    if settingEnabled(zstSettings.esc, "arm") then
        setSetting({"logicalSw", 0}, {func="FUNC_AND", def='"TELEMETRY_STREAMING,!L4"', andsw='"NONE"', delay="0", duration="0"})
        setSetting({"logicalSw", 1}, {func="FUNC_AND", def='"' .. buttonString[zstSettings.esc.armSwitch+1] .. ',TELEMETRY_STREAMING"', andsw='"NONE"', delay="0", duration="0"})
        setSetting({"logicalSw", 2}, {func="FUNC_OR", def='"SD2,!TELEMETRY_STREAMING"', andsw='"L4"', delay="0", duration="0"})
        setSetting({"logicalSw", 3}, {func="FUNC_STICKY", def='"L2,L3"', andsw='"NONE"', delay="0", duration="0"})
    end
end

local function setSpecialFunctions()
    -- steering
    if settingEnabled(zstSettings.steering, "limit") then
        setSetting({"customFn", 0}, {swtch='"ON"', func="ADJUST_GVAR", def='"0,Src,' .. trimSwitchString[zstSettings.steering.limitSwitch+1] .. ',1"'})
    end
    if settingEnabled(zstSettings.steering, "DR") then
        setSetting({"customFn", 1}, {swtch='"ON"', func="ADJUST_GVAR", def='"1,Src,' .. trimSwitchString[zstSettings.steering.drSwitch+1] .. ',1"'})
    end

    -- brake
    if settingEnabled(zstSettings.brake, "limit") then
        setSetting({"customFn", 2}, {swtch='"ON"', func="ADJUST_GVAR", def='"2,Src,' .. trimSwitchString[zstSettings.brake.limitSwitch+1] .. ',1"'})
    end
    if settingEnabled(zstSettings.brake, "balance") then
        setSetting({"customFn", 3}, {swtch='"ON"', func="ADJUST_GVAR", def='"3,Src,' .. trimSwitchString[zstSettings.brake.balanceSwitch+1] .. ',1"'})
    end

    --arm
    if settingEnabled(zstSettings.esc, "arm") then
        setSetting({"customFn", 4}, {swtch='"!TELEMETRY_STREAMING"', func="RGB_LED", def='"red,1"'})
        setSetting({"customFn", 5}, {swtch='"L1"', func="RGB_LED", def='"orange,1"'})
        setSetting({"customFn", 6}, {swtch='"ON"', func="RGB_LED", def='"green,1"'})
    end
end

local function setInputs()
    setSetting({"expoData", 0}, {mode="3", scale="0", trimSource="0", srcRaw="ST", chn="0", swtch='"NONE"', flightModes="000000000", weight="GV1", name="", offset="0", curve={type="1", value="GV2"}})

    setSetting({"expoData", 1}, {mode="3", scale="0", trimSource="0", srcRaw="TH", chn="1", swtch='"NONE"', flightModes="000000000", weight="100", name="", offset="0", curve={type="1", value="0"}})

    setSetting({"expoData", 2}, {mode="3", scale="0", trimSource="0", srcRaw="TH", chn="2", swtch='"NONE"', flightModes="000000000", weight="GV3", name="", offset="0", curve={type="1", value="GV4"}})

    if settingEnabled(zstSettings.brake, "servo") then
        setSetting({"expoData", 3}, {mode="3", scale="0", trimSource="0", srcRaw="TH", chn="3", swtch='"NONE"', flightModes="000000000", weight="GV3", name="", offset="0", curve={type="1", value="-GV4"}})
    end

    setSetting({"inputNames", 0}, {val='"ST"'})
    setSetting({"inputNames", 1}, {val='"TH"'})
    setSetting({"inputNames", 2}, {val='"RBK"'})
    if settingEnabled(zstSettings.brake, "servo") then
        setSetting({"inputNames", 3}, {val='"FBK"'})
    end
end

local function setMixers()
    setSetting({"mixData", 0}, {weight="100", destCh=zstSettings.steering.output, srcRaw="I0", carryTrim="1", mixWarn="0", mltpx="ADD", speedPrec="0", offset="0", swtch='"NONE"', flightModes="000000000", delayUp="0", delayDown="0", speedUp="0", speedDown="0", name= '""'})
    setSetting({"mixData", 1}, {weight="100", destCh=zstSettings.esc.output, srcRaw="I1", carryTrim="1", mixWarn="0", mltpx="ADD", speedPrec="0", offset="0", swtch='"L4"', flightModes="000000000", delayUp="0", delayDown="0", speedUp="0", speedDown="0", name= '""', curve={type="3", value="1"}})
    setSetting({"mixData", 2}, {weight="100", destCh=zstSettings.esc.output, srcRaw="I2", carryTrim="1", mixWarn="0", mltpx="ADD", speedPrec="0", offset="0", swtch='"NONE"', flightModes="000000000", delayUp="0", delayDown="0", speedUp="0", speedDown="0", name= '""', curve={type="3", value="2"}})

    if settingEnabled(zstSettings.brake, "servo") then
        setSetting({"mixData", 3}, {weight="100", destCh=zstSettings.brake.servoOutput, srcRaw="I3", carryTrim="1", mixWarn="0", mltpx="ADD", speedPrec="0", offset="0", swtch='"NONE"', flightModes="000000000", delayUp="0", delayDown="0", speedUp="0", speedDown="0", name= '""', curve={type="3", value="3"}})
    end
end

local function setOutputs()
    setSetting({"limitData", zstSettings.steering.output}, {min="0", max="0", ppmCenter="0", offset="0", symetrical="0", revert="0", curve="0", name='"STR"'})
    setSetting({"limitData", zstSettings.esc.output}, {min="0", max="0", ppmCenter="0", offset="0", symetrical="0", revert="0", curve="0", name='"ESC"'})

    if settingEnabled(zstSettings.brake, "servo") then
        setSetting({"limitData", zstSettings.brake.servoOutput}, {min="0", max="0", ppmCenter="0", offset="0", symetrical="0", revert="0", curve="3", name='"FBK"'})
    end
end

local function setGlobalVariable(settingsTable, gvar, name, min, max, prec, unit)
    if settingsTable.gvars == nil then
        settingsTable.gvars = {}
        settingsTable.gvars[gvar] = {name=name, min=min, max=max, prec=prec, unit=unit}
        modelUpdated = true
    else
        if settingsTable.gvars[gvar] == nil then
            settingsTable.gvars[gvar] = {name=name, min=min, max=max, prec=prec, unit=unit}
            modelUpdated = true
        else
            local settings = {name=name, min=min, max=max, prec=prec, unit=unit}
            for k, v in pairs(settingsTable.gvars[gvar]) do
                if settingsTable.gvars[gvar].k ~= settings.k then
                    settingsTable.gvars[gvar].k = settings.k
                    modelUpdated = true
                end
            end
        end
    end
end

local function checkGlobalVariable()
    if settingEnabled(zstSettings.steering, "limit") then setGlobalVariable(modelSettings, 0, "STW", 1024, 924, 0, 1) end
    if settingEnabled(zstSettings.steering, "DR") then setGlobalVariable(modelSettings, 1, "STE", 0, 100, 0, 1) end
    if settingEnabled(zstSettings.brake, "limit") then setGlobalVariable(modelSettings, 2, "BRT", 0, 100, 0, 1) end
    if settingEnabled(zstSettings.brake, "balance") then setGlobalVariable(modelSettings, 3, "BBL", -100, 100, 0, 1) end
end

local function setTelemetryScreen()
    if settingEnabled(zstSettings.model, "ZTS") and not entryAvailable({"screens", 0, "u", "script", "file"}, modelSettings) then
        setSetting({"screens", 0}, {type="SCRIPT", u={script={file='"ZTS"'}} })
        modelUpdated = true
    end
end

local function setSwitchWarning()
    if settingEnabled(zstSettings.model, "sWarning") and entryAvailable({"switchWarning"}, modelSettings) then
        modelSettings.switchWarning = nil
        modelUpdated = true
    end
end

local function run(event)
    if not modelCreated then
        print("setModel")
        collectgarbage()

        zstSettings = readSettingsFile(zstSettings, "/MODELS/ZTS/" .. string.gsub(modelFileName, ".yml", "") .. ".txt", true)
        modelSettings = getModelSettings(modelSettings, "/MODELS/" .. modelFileName, false)

        printSettings(modelSettings, 0)
        --while 1 do end

        checkGlobalVariable()
        setTelemetryScreen()
        setSwitchWarning()


        if modelUpdated then
            if not modelCreated then
                saveModelSettings("/BACKUP/ztsModel.yml", modelSettings)
                modelCreated = true
            end

            lcd.clear()
            lcd.drawText(64, 25, "Please restore Model", CENTER + BLINK)
            lcd.drawText(64, 35, "from Backup Folder", CENTER + BLINK)
        else
            return 2
        end
    end


    if event == EVT_VIRTUAL_EXIT then
        return 2
    end


    return 0
end

return {init = init, run = run}