

function printSettings(settingsTable, offset)
    local offsetString = ""
    if offset > 0 then
        for i=0, offset-1, 1 do
            offsetString = offsetString .. "   "
        end
    end

    for k,v in pairs(settingsTable) do
        if(type(v) == "table") then
            if type(k) == "number" then
                print(offsetString .. "-", k)
            else
                print(offsetString .. k .. ":")
            end
            printSettings(v, offset + 1)
        else
            print(offsetString .. k .. ":" .. v)
        end
    end
end

function fileExists(path)
    if fstat(path) ~= nil then
        return true
    else
        return false
    end
end

function settingEnabled(settingTable, setting)
    --if settingTable ~= nil and settingTable[setting] == 1 then return true end
    if settingTable ~= nil then
        if type(setting) == "string" then
            if settingTable[setting] == 1 then return true end
        elseif type(setting) == "table" then
            for k,v in pairs(setting) do
                settingTable = settingTable[v]
            end
            if settingTable == 1 then return true end
        end
    end
    return false
end

local function copyTable(k, v, settingTable, sourceTable)
    if type(v) == "table" then
        local subTable = v
        local subSourceTable = sourceTable[k]
        for x,y in pairs(subTable) do
            copyTable(x, y, settingTable[k], sourceTable[k])
        end
    else
        settingTable[k] = sourceTable[k]
    end
end

function getSettings(settingsTable, filePath, toNumber)
    local zstFile = {}
    zstFile = readSettingsFile(zstFile, filePath, toNumber)

    for k,v in pairs(settingsTable) do
        copyTable(k, v, settingsTable, zstFile)
    end

    return settingsTable
end

local function ymlToList(settingsTable, yml, toNumber)
    local sub = {}
    local lastDepth = 0
    local depthOffset = 0
    local listNum = 0

    local line
    local depth

    for lineNum=0, #yml, 1 do
        if string.find(yml[lineNum], "\t") ~= nil then
            line, depth = string.gsub(yml[lineNum], "\t", "")
            line = string.gsub(line, "\t", "")
        else
            line, depth = string.gsub(yml[lineNum], " ", "")
            line = string.gsub(line, " ", "")
            depth = math.floor(depth / 3)
            if string.sub(line, #line) == "-" then
                depth = depth + 1
                if depthOffset > 0 then
                    depthOffset = depthOffset - 1
                end
            end
        end

        if depth == 0 then 
            sub = {}
            depthOffset = 0
            listNum = 0
        else
            depth = depth + depthOffset
            for i=0, lastDepth-depth-1, 1 do
                sub[#sub] = nil
            end
        end

        local testLine = string.gsub(line, ":", "")

        if string.sub(line, #line) == "-" or string.match(testLine, "^%d+$") then
            if string.sub(line, #line) == "-" then
                depthOffset = 1
            end

            if string.match(testLine, "^%d+$") then
                sub[depth] = tonumber(testLine)
            else
                sub[depth] = listNum
                listNum = listNum + 1
            end

            local settingTable = settingsTable
            for index=0, #sub, 1 do
                if settingTable[sub[index]] == nil then
                    settingTable[sub[index]] = {}
                else
                    settingTable = settingTable[sub[index]]
                end
            end

        elseif string.sub(line, #line) == ":" then
            value = string.gsub(line, ":", "")
            sub[depth] = value

            local settingTable = settingsTable
            for index=0, #sub, 1 do
                if settingTable[sub[index]] == nil then
                    settingTable[sub[index]] = {}
                else
                    settingTable = settingTable[sub[index]]
                end
            end

        else
            local settingTable = settingsTable
            for index=0, #sub, 1 do
                if settingTable[sub[index]] ~= nil then
                    settingTable = settingTable[sub[index]]
                end
            end

            x, y = string.match(line, "(.+):(.+)")
            if toNumber == false or tonumber(y) == nil then
                settingTable[x] = y
            else
                settingTable[x] = tonumber(y)
            end

        end

        lastDepth = depth
    end

    return settingsTable
end

local function readFile(file, seek, lines, linectr)
    io.seek(file, seek)
    local buffer = io.read(file, 1024)

    for line in string.gmatch(buffer, "([^\n]+)\n") do
        seek = seek + #line+1
        line = string.gsub(line, "\r", "")
        lines[linectr] = string.gsub(line, "\n", "")
        lines[linectr] = line
        linectr = linectr + 1
    end

    return seek, lines, linectr, #buffer
end

function readSettingsFile(settingsTable, filePath, toNumber)
    local file = io.open(filePath, "r")
    local seek = 0
    local lines = {}
    local linectr = 0

    while true do
        seek, lines, linectr, fileEnd = readFile(file, seek, lines, linectr)
        if fileEnd < 1024 then break end
    end

    io.close(file)

    return ymlToList(settingsTable, lines, toNumber)
end

local function writeSettings(file, settingTable, depth)
    local string = ""
    for i=0, depth-1, 1 do
        string = string .. "   "
    end

    for k,v in pairs(settingTable) do
        if type(v) == "table" then
            if type(k) == "number" then
                io.write(file, string .. "-" .. "\n")
            else
                io.write(file, string .. k .. ":\n")
            end
            writeSettings(file, v, depth+1)
        else
            io.write(file, string .. k .. ": " .. v .. "\n")
        end
    end
end

function saveSettings(filePath, settingTable)
    local file = io.open(filePath, "w")
    --printSettings(settingTable, 0)
    writeSettings(file, settingTable, 0)
    io.close(file)
end
