CHANNEL = 1
SOURCE = 2
SWITCH = 3
COMBO = 4
COMBOBOX = 5
TEXT = 6
VALUE = 7
CHECKBOX = 8
FUNCTION = 9
SUBMENU = 10

TEST = 99



local edit = false
local longEnterPress = false
local page = 1
local savePage = page
local pages = {}
local loadPage = "page"
local pageOffset = 0
local current = 1
local pagesNames = {}
local numberPerPage = 4
local baseAttr = 0
local spacing = 10
local charWidth = 6

local function getFieldValue(field)
    if type(field.settingTable) == "table" then
        local sub = field.settingTable
        value = zstSettings
        for index=1, #sub, 1 do value = value[sub[index]] end
        value = value[field.value]
    elseif field.settingTable ~= nil then
        value = zstSettings[field.settingTable][field.value]
    end

    return value
end

local function setFieldValue(field, value)
    if type(field.settingTable) == "table" then
        local sub = field.settingTable
        local table = zstSettings
        for index=1, #sub, 1 do table = table[sub[index]] end
        table[field.value] = value
    elseif field.settingTable ~= nil then
        zstSettings[field.settingTable][field.value] = value
    end
end

local function fieldEnabled(field)
    local settingTable = zstSettings
    for index=1, #field.enable, 1 do settingTable = settingTable[field.enable[index]] end
    if settingTable == 1 then return true end

    return false
end

local function loadSubmenu(pagesContent, submenuTable)
    for index=1, #submenuTable, 1 do
        local entry = submenuTable[index]
        if (type(entry.enable) == "number" and entry.enable == 1) or (type(entry.enable) == "table" and fieldEnabled(entry)) then
            pagesContent[#pagesContent + 1] = entry
        end
    end
end

local function loadPages(pagesTabel)
    pageOffset = 0
    pages = {}
    local pagesContent = {}
    for index=1, #pagesTabel, 1 do
        if pagesTabel[index][loadPage] ~= nil then
            for contentIndex=1, #pagesTabel[index][loadPage], 1 do
                local entry = pagesTabel[index][loadPage][contentIndex]
                if (type(entry.enable) == "number" and entry.enable == 1) or (type(entry.enable) == "table" and fieldEnabled(entry)) then
                    pagesContent[#pagesContent + 1] = entry

                    if entry.type == SUBMENU and entry.value == 1 then
                        loadSubmenu(pagesContent, entry.submenu)
                    end
                end
            end
            pagesNames[#pages + 1] = pagesTabel[index].pageName
            pages[#pages + 1] = pagesContent
            pagesContent = {}
        end
    end

    if page > #pages then 
        savePage = page
        page = #pages 
    end

    fields = pages[page]

    if fields[current].type == TEXT then
        selectField(1)
    end
end

-- Change display attribute to current field
local function addField(step)
    local field = fields[current]
    local min, max
    if field.type == TEST then
        min = 0
        max = 300
    elseif field.type == TRIM then
        min = 92
        max = 97
    elseif field.type == CHANNEL then
        min = 0
        max = 15
    elseif field.type == SWITCH then
        min = -18
        max = 18
    elseif field.type == COMBO or field.type == COMBOBOX then
        min = 0
        max = #(field.options) - 1
    elseif field.type == VALUE then
        min = field.min
        max = field.max
    end

    local value = getFieldValue(field)
    if (step < 0 and value > min) or (step > 0 and value < max) then
        --print(value+step)
        setFieldValue(field, value + step)
    end
end

-- Select the next or previous editable field
local function selectField(step)
    current = 1 + ((current + step - 1 + #fields) % #fields)

    if current > (numberPerPage-1) + pageOffset then
        pageOffset = current - numberPerPage
    elseif current <= pageOffset then
        pageOffset = current - 1
    end

    if fields[current].type == TEXT then
        selectField(step)
    end
end

-- Select the next or previous page
local function selectPage(step)
    page = 1 + ((page + step - 1 + #pages) % #pages)
    pageOffset = 0
    current = 1
    fields = pages[page]

    if fields[current].type == TEXT then
        selectField(1)
    end
end

-- Redraw the current page
local function redrawFieldPage()
    lcd.clear()
    
    lcd.drawScreenTitle(pagesNames[page], page, #pages)
    lcd.drawText(64, 57, version, CENTER)

    if #fields > numberPerPage and pageOffset > 0 then
        lcd.drawText((LCD_W - charWidth), 9, CHAR_UP, baseAttr)
    end
    if #fields > numberPerPage and (#fields - current) > 0 then
        lcd.drawText((LCD_W - charWidth), 55, CHAR_DOWN, baseAttr)
    end

    for index = math.min(#fields, numberPerPage), 1, -1 do
        local field = fields[pageOffset + index]
        if field == nil then
            break
        end

        local attr = baseAttr
        if current == (pageOffset + index) then
            attr = attr + INVERS
            if edit == true then
                attr = attr + BLINK
            end
        end

        local value = getFieldValue(field)

        local yOffset = 7

        if field.type == TEST then
            lcd.drawSwitch(LCD_W - 29, (spacing * index) + yOffset, value, attr)
        elseif field.type == CHANNEL then
            lcd.drawText(1, (spacing * index) + yOffset, field.name, LEFT + attr)
            lcd.drawSource(LCD_W - 29, (spacing * index) + yOffset, MIXSRC_CH1+value, attr)
        elseif field.type == TRIM then
            lcd.drawText(1, (spacing * index) + yOffset, field.name, LEFT + attr)
            lcd.drawSource(LCD_W - 29, (spacing * index) + yOffset, value, attr)
        elseif field.type == SWITCH then
            lcd.drawText(1, (spacing * index) + yOffset, field.name, LEFT + attr)
            lcd.drawSwitch(LCD_W - 29, (spacing * index) + yOffset, value, attr)
        elseif field.type == COMBO then
            if value > #field.options then value = 0 end
            lcd.drawText(1, (spacing * index) + yOffset, field.name, LEFT + attr)
            width = (#field.options[value + 1] + 1) * charWidth
            lcd.drawText(LCD_W - width, (spacing * index) + yOffset, field.options[value + 1], LEFT + attr)
        elseif field.type == COMBOBOX then
            lcd.drawText(1, (spacing * index) + yOffset, field.name, LEFT + attr)
            lcd.drawCombobox(LCD_W - 30, (spacing * index) + yOffset-2, 30, field.options, value, attr)
        elseif field.type == TEXT then
            lcd.drawText(64, (spacing * index) + yOffset, field.name, CENTER + attr)
        elseif field.type == VALUE then
            lcd.drawText(1, (spacing * index) + yOffset, field.name, LEFT + attr)
            lcd.drawText(LCD_W - 29, (spacing * index) + yOffset, value, LEFT + attr)
        elseif field.type == CHECKBOX then
            lcd.drawText(1, (spacing * index) + yOffset, field.name, LEFT + attr)
            drawCheckbox(LCD_W - 30, ((spacing * index) + yOffset)-1, value, attr)
        elseif field.type == FUNCTION then
            lcd.drawText(64, (spacing * index) + yOffset, field.name, CENTER + attr)
        elseif field.type == SUBMENU then
            lcd.drawText(1, (spacing * index) + yOffset, field.name, LEFT + BOLD + attr)
            if field.value == 1 then lcd.drawText(LCD_W - 10, (spacing * index) + yOffset, CHAR_DOWN, LEFT + attr)
            else lcd.drawText(LCD_W - 10, (spacing * index) + yOffset, CHAR_UP, LEFT + attr) end
        end

    end
end

local function runFieldsPage(event)
    if longEnterPress then
        if event == 34 then longEnterPress = false end
    -- exit script
    elseif event == EVT_VIRTUAL_EXIT then
        if loadPage ~= "page" then 
            loadPage = "page"
            page = savePage
            current = 1
            loadPages(startPage)
        else 
            return 2 
        end
    elseif fields[current].type == FUNCTION and event == fields[current].key then
        if fields[current].value == "createModel" then
            saveSettings("/MODELS/ZTS/" .. string.gsub(model.getInfo().filename, ".yml", "") .. ".txt", zstSettings)

            return "/SCRIPTS/WIZARD/ZTW/setSettings.lua"
        end
    -- toggle editing/selecting current field
    elseif event == EVT_VIRTUAL_ENTER then
        if fields[current].type == CHECKBOX then
            local field = fields[current]
            local value = getFieldValue(field)
            if value == 1 then value = 0
            else value = 1 end
            setFieldValue(field, value)
            loadPages(startPage)
            selectField(0)
        elseif fields[current].type == SUBMENU then
            local field = fields[current]
            if field.value == 1 then field.value = 0
            else field.value = 1 end
            loadPages(startPage)
            selectField(0)
        elseif fields[current].type ~= TEXT then
            edit = not edit
            if edit == false then
                loadPages(startPage)
                selectField(0)
            end
        end
        if fields[current].reinit == 1 then
            loadScript("/SCRIPTS/WIZARD/ZTW/pages.lua", 'tc')()
            initUI(startPage)
        end
    elseif edit then
        if event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
            if fields[current].type == VALUE then addField(fields[current].step)
            else addField(1) end
        elseif event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
            if fields[current].type == VALUE then addField(fields[current].step * -1)
            else addField(-1) end
        end
    else
        if event == EVT_VIRTUAL_NEXT then
            selectField(1)
        elseif event == EVT_VIRTUAL_PREV then
            selectField(-1)
        elseif event == EVT_VIRTUAL_ENTER_LONG then
            if startPage[page].subpage ~= nil then
                longEnterPress = true
                loadPage = "subpage"
                loadPages(startPage)
            end
        end
    end

    redrawFieldPage()

    return 0
end

function initUI(pagesInit)
    loadPages(pagesInit)
end

function runUI(event)
    if event == nil then
        error("Cannot be run as a model script!")
        return 2
    elseif event == EVT_VIRTUAL_NEXT_PAGE and edit == false then
        selectPage(1)
        return runFieldsPage(event)
    elseif event == EVT_VIRTUAL_PREV_PAGE and edit == false then
        selectPage(-1)
        return runFieldsPage(event)
    elseif event == 1541 then
        return 2
    else
        return runFieldsPage(event)
    end
end