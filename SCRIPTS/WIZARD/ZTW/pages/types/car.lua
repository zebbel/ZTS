-- cache model settings
local zstModelSettings = ztsSettings.model
-- clear ztsSettings in case model type was changed
ztsSettings = {}
-- reload model settings and init all other settings needed for model type car
ztsSettings["model"] = zstModelSettings
ztsSettings["steering"] = {output = 0, DR = 0, drSwitch = 94, limit = 0, limitSwitch = 93}
ztsSettings["esc"] = {output = 1, arm = 0, armSwitch = 12, limit = 0}
ztsSettings["brake"] = {servo = 0, servoOutput = 2, limit = 1, limitSwitch = 95, balance = 0, balanceSwitch = 92}

-- steering page
steeringPage = {
    pageName = language.steeringPage,
    page = {
        {name=language.assignChanel, type=CHANNEL, setting={"steering","output"}},
        {name=language.drOption, type=CHECKBOX, setting={"steering","DR"}},
        {enable={"steering", "DR"}, name=language.drSwitch, type=TRIM, setting={"steering","drSwitch"}},
        {name=language.limitOption, type=CHECKBOX, setting={"steering","limit"}},
        {enable={"steering", "limit"}, name=language.limitSwitch, type=TRIM, setting={"steering","limitSwitch"}}
    }
}

escLimitMenu = {
    {name=language.escLimit, type=CHECKBOX, setting={"esc","limit","enable"}, reload=1},
    {name=language.escLimitMode, type=COMBO, setting={"esc","limit","mode"}, options={"Drive Mode", "Switch"}},
}

-- esc page
escPage = {
    pageName = language.escPage,
    page = {
        {name=language.assignChanel, type=CHANNEL, setting={"esc","output"}},
        {disable={"esc", "limit", "enable"}, name=language.escLimit, type=CHECKBOX, setting={"esc","limit","enable"}},
        {enable={"esc", "limit", "enable"}, name=language.escLimitSettings, type=SUBMENU, submenu=escLimitMenu},
        {name=language.armOption, type=CHECKBOX, setting={"esc","arm"}},
        {enable={"esc", "arm"}, name=language.armSwitch, type=SWITCH, setting={"esc","armSwitch"}},
    }
}

-- brake servo page
brakeServoPage = {
    pageName = language.brakePage,
    page = {
        {name=language.limitOption, type=CHECKBOX, setting={"brake","limit"}},
        {enable={"brake", "limit"}, name=language.limitSwitch, type=TRIM, setting={"brake","limitSwitch"}}
    }
}