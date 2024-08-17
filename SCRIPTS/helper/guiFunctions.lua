-- Common functions
local lastBlink = 0
local function blinkChanged()
  local time = getTime() % 128
  local blink = (time - time % 64) / 64
  if blink ~= lastBlink then
    lastBlink = blink
    return true
  else
    return false
  end
end

function getFieldFlags(position)
    flags = 0
    if field == position then
        flags = INVERS
        if edit then
            flags = INVERS + BLINK
        end
    end
    return flags
end

function fieldIncDec(event, value, max, force)
    if edit or force==true then
        if event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
            value = (value + max)
            dirty = true
        elseif event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
            value = (value + max + 2)
            dirty = true
        end
        value = (value % (max+1))
    end
    return value
end

function valueIncDec(event, value, min, max)
    if edit then
        if event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
            if value < max then
                value = (value + 1)
                dirty = true
            end
        elseif event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
            if value > min then
                value = (value - 1)
                dirty = true
            end
        end
    end
    return value
end

function navigate(event, fieldMax, prevPage, nextPage)
    if event == EVT_VIRTUAL_ENTER then
        edit = not edit
        dirty = true
    elseif edit then
        if event == EVT_VIRTUAL_EXIT then
            edit = false
            dirty = true
        elseif not dirty then
            dirty = blinkChanged()
        end
    else
        if event == EVT_VIRTUAL_NEXT_PAGE then
            page = nextPage
            field = 0
            dirty = true
        elseif event == EVT_VIRTUAL_PREV_PAGE then
            page = prevPage
            field = 0
            killEvents(event);
            dirty = true
        else
            field = fieldIncDec(event, field, fieldMax, true)
        end
    end
end

function channelIncDec(event, value, max)
    if not edit and event==EVT_VIRTUAL_MENU then
        dirty = true
    else
        value = valueIncDec(event, value, 0, max)
    end
    return value
end