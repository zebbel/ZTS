-- cache model settings
local zstModelSettings = ztsSettings.model
-- clear ztsSettings in case model type was changed
ztsSettings = {}
-- reload model settings and init all other settings needed for model type bike
ztsSettings["model"] = zstModelSettings
ztsSettings["steering"] = {output = 0, DR = 0, drSwitch = 94, limit = 0, limitSwitch = 93}
ztsSettings["esc"] = {output = 1, arm = 0, armSwitch = 12}
ztsSettings["brake"] = {servo = 0, servoOutput = 2, limit = 1, limitSwitch = 95, balance = 0, balanceSwitch = 92}

-- steering page
steeringPage = {
    pageName = language.steeringPage,
    page = {
        {enable=1, name=language.assignChanel, type=CHANNEL, setting={"steering","output"}},
        {enable=1, name=language.drOption, type=CHECKBOX, setting={"steering","DR"}},
        {enable={"steering", "DR"}, name=language.drSwitch, type=TRIM, setting={"steering","drSwitch"}},
        {enable=1, name=language.limitOption, type=CHECKBOX, setting={"steering","limit"}},
        {enable={"steering", "limit"}, name=language.limitSwitch, type=TRIM, setting={"steering","limitSwitch"}}
    }
}

-- esc page
escPage = {
    pageName = language.escPage,
    page = {
        {enable=1, name=language.assignChanel, type=CHANNEL, setting={"esc","output"}},
        {enable=1, name=language.armOption, type=CHECKBOX, setting={"esc","arm"}},
        {enable={"esc", "arm"}, name=language.armSwitch, type=SWITCH, setting={"esc","armSwitch"}},
    }
}

-- brake servo page
brakeServoPage = {
    pageName = language.brakePage,
    page = {
        {enable=1, name=language.brakeServoOption, type=CHECKBOX, setting={"brake","servo"}},
        {enable={"brake", "servo"}, name=language.assignChanel, type=CHANNEL, setting={"brake","servoOutput"}},
        {enable=1, name=language.limitOption, type=CHECKBOX, setting={"brake","limit"}},
        {enable={"brake", "limit"}, name=language.limitSwitch, type=TRIM, setting={"brake","limitSwitch"}},
        {enable=1, name=language.brakeBalanceOption, type=CHECKBOX, setting={"brake","balance"}},
        {enable={"brake", "balance"}, name=language.brakeBalanceSwitch, type=TRIM, setting={"brake","balanceSwitch"}}
    }
}