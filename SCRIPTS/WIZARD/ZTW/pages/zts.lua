-- init zts settings
ztsSettings["zts"] = {
    batIndicator = {
        enable = 0,
        alarm = 0,
        minCell = 3.4
    },
    timer = {
        enable = 0
    },
    pages = {
        output = 0
    }
}

-- batIndicator sub menu
batIndicatorMenu = {
    {enable=1, name=language.batIndicator, type=CHECKBOX, setting={"zts","batIndicator","enable"}},
    {enable={"zts","batIndicator","enable"}, name=language.alarm, type=CHECKBOX, setting={"zts","batIndicator","alarm"}},
    {enable={"zts","batIndicator","alarm"}, name=language.minCell, type=VALUE, min=3.0, max=4.5, step=0.1, setting={"zts","batIndicator","minCell"}}
}

timerMenu = {
    {enable=1, name=language.ztmTimer, type=CHECKBOX, setting={"zts","timer","enable"}},
    --{enable={"zts","timer","enable"}, name=language.ztsStartSwitch, type=TEST, setting={"zts","timer","start"}}
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