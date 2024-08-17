loadScript("/SCRIPTS/WIZARD/ZTW/modelTable.lua")()

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

function getModelSettings(settingsTable, filePath, toNumber)
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

local function parseModelSettings(file, settingTable, k, v, depth)
    local string = ""
    for i=0, depth-1, 1 do
        string = string .. "   "
    end

    local seperator = nil
    local seperatorCounter = 0

    if type(v) == "string" then
        if settingTable ~= nil and settingTable[v] ~= nil then
            io.write(file, string .. v .. ": " .. settingTable[v] .. "\n")
        end
    elseif type(v) == "table" then
        if type(k) == "string" then
            io.write(file, string .. k .. ":\n")
            settingTable = settingTable[k]
        end

        for k,v in pairs(v) do
            --print(k,v)
            if type(k) == "string" then
                if type(v) == "string" then
                    if settingTable ~= nil then
                        io.write(file, string .. k .. ":\n")
                        parseModelSettings(file, settingTable[k], k, v, depth+1)
                    end
                elseif type(v) == "table" then
                    settingTable = settingTable[k]

                    if settingTable ~= nil then
                        io.write(file, string .. k .. ":\n")
                    end

                    string = string .. "   "
                    depth = depth+1

                    if seperator == nil then
                        for k,v in pairs(v) do
                            --print(k,v)
                            parseModelSettings(file, settingTable, k, v, depth)
                        end

                    elseif seperator == "number" then
                        -- points is special because keys are not in 1, 2, 3... order
                        if k == "points" then
                            if settingTable ~= nil then
                                for key, val in pairs(settingTable) do
                                    --print(k,v)
                                    io.write(file, string .. key .. ":\n")
                                    for k,v in pairs(v) do
                                        --print(k,v)
                                        parseModelSettings(file, settingTable[key], k, v, depth+1)
                                    end
                                end
                            end
                        else
                            if settingTable ~= nil then
                                while settingTable[seperatorCounter] ~= nil do
                                    io.write(file, string .. seperatorCounter .. ":\n")
                                    for k,v in pairs(v) do
                                        --print(k,v)
                                        parseModelSettings(file, settingTable[seperatorCounter], k, v, depth+1)
                                    end
            
                                    seperatorCounter = seperatorCounter + 1
                                end
                            end
                        end
                    elseif seperator == "-" then
                        string = ""
                        for i=0, depth-2, 1 do
                            string = string .. " "
                        end

                        while settingTable[seperatorCounter] ~= nil do
                            io.write(file, string .. " -\n")
                            for k,v in pairs(v) do
                                --print(k,v)
                                parseModelSettings(file, settingTable[seperatorCounter], k, v, depth)
                            end

                            seperatorCounter = seperatorCounter + 1
                        end
                    end
                    seperatorCounter = 0
                end
            elseif type(k) == "number" then
                if v == "$-" then
                    seperator = "-"
                elseif v == "$number" then
                    seperator = "number"
                elseif type(v) == "string" then
                    parseModelSettings(file, settingTable, k, v, depth+1)
                end
            end
        end
    end
end

function saveModelSettings(filePath, settingTable)
    print("moodelSettings.lua / saveModelSettings")
    local file = io.open(filePath, "w")

    for k,v in pairs(modelSettingsOrder) do
        --print(k,v)
        parseModelSettings(file, settingTable, k, v, 0)
    end

    io.close(file)
end