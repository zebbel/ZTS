-- init zts settings
ztsSettings["zts"] = {
    batIndicator = {
        enable = 0,
        alarm = 0,
        minCell = 3.4
    },
    pages = {
        steering = 0,
        esc = 0,
        brake = 0
    }
}

-- batIndicator sub menu
batIndicatorMenu = {
    {name=language.batIndicator, type=CHECKBOX, setting={"zts","batIndicator","enable"}},
    {enable={"zts","batIndicator","enable"}, name=language.alarm, type=CHECKBOX, setting={"zts","batIndicator","alarm"}},
    {enable={"zts","batIndicator","alarm"}, name=language.minCell, type=VALUE, min=3.0, max=4.5, step=0.1, setting={"zts","batIndicator","minCell"}}
}

-- ztsPages sub menu
ztsPages = {
    {name=language.ztsSteering, type=CHECKBOX, setting={"zts", "pages","steering"}},
    {name=language.ztsDrive, type=CHECKBOX, setting={"zts", "pages","esc"}}
}

-- zts page
ztsPage = {
    pageName = language.ztsOptions,
    page = {
        {name=language.batIndicator, type=SUBMENU, submenu=batIndicatorMenu},
        {name=language.ztsPages, type=SUBMENU, submenu=ztsPages}
    }
}