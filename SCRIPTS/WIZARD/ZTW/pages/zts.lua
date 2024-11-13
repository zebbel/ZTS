-- init zts settings
ztsSettings["zts"] = {
    batIndicator = {
        enable = 0,
        sensor = "RxBt",
        filterEnable = 1,
        lpfBeta = 0.5,
        mode = 0,
        type = 0,
        cells = 1,
        alarm = 0,
        minCell = 3.4,
        alarmSound = 0
    },
    timer = {
        enable = 0,
        reset = 0
    },
    pages = {
        output = 0
    }
}

-- lipo filter submenu
lipoFilterMenu = {
    {enable=1, name="enable filter", type=CHECKBOX, setting={"zts","batIndicator","filterEnable"}},
    {enable={"zts","batIndicator","filterEnable"}, name="lpfBeta", type=VALUE, min=0.01, max=1, step=0.01, setting={"zts","batIndicator","lpfBeta"}}
}

-- lipo type submenu
lipoTypeMenu = {
    {enable=1, name=language.batIndicatorMode, type=COMBO, setting={"zts","batIndicator", "mode"}, options={"auto", "manual"}},
    {enable={"zts","batIndicator","mode"}, name=language.batIndicatorType, type=COMBO, setting={"zts","batIndicator", "type"}, options={"lipo", "lipo hv"}},
    {enable={"zts","batIndicator", "mode"}, name=language.batIndicatorCells, type=VALUE, min=1, max=6, step=1, setting={"zts","batIndicator", "cells"}}
}

-- bat alarm
batAlarmMenu = {
    {enable=1, name=language.alarm, type=CHECKBOX, setting={"zts","batIndicator","alarm"}},
    {enable={"zts","batIndicator","alarm"}, name=language.batIndicatorMinCell, type=VALUE, min=3.0, max=4.5, step=0.1, setting={"zts","batIndicator","minCell"}},
    {enable={"zts","batIndicator","alarm"}, name=language.playSound, type=CHECKBOX, setting={"zts","batIndicator","alarmSound"}}
}

-- batIndicator submenu
batIndicatorMenu = {
    {enable=1, name=language.batIndicator, type=CHECKBOX, setting={"zts","batIndicator","enable"}},
    {enable={"zts","batIndicator","enable"}, name=language.sensor, type=COMBOTEXT, setting={"zts","batIndicator","sensor"}, options=getSensorTable()},
    {enable={"zts","batIndicator","enable"}, name="filter", type=SUBMENU, submenu=lipoFilterMenu},
    {enable={"zts","batIndicator","enable"}, name="lipo type", type=SUBMENU, submenu=lipoTypeMenu},
    {enable={"zts","batIndicator","enable"}, name="lipo alarm", type=SUBMENU, submenu=batAlarmMenu},
}

timerMenu = {
    {enable=1, name=language.enable, type=CHECKBOX, setting={"zts","timer","enable"}},
    {enable={"zts","timer","enable"}, name=language.ztmTimerAutoReste, type=COMBO, setting={"zts","timer","reset"}, options={"never", "boot", "bat > 98%"}}
}

-- ztsPages sub menu
ztsPages = {
    {enable=1, name=language.ztsOutputPage, type=CHECKBOX, setting={"zts", "pages", "output"}}
}

-- zts page
ztsPage = {
    pageName = language.ztsOptions,
    page = {
        {enable=1, name=language.batIndicator, type=SUBMENU, submenu=batIndicatorMenu},
        {enable={"esc","arm"}, name=language.ztmTimer, type=SUBMENU, submenu=timerMenu},
        {enable=1, name=language.ztsPages, type=SUBMENU, submenu=ztsPages}
    }
}