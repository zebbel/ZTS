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
        {enable=1, name=language.assignChanel, type=CHANNEL, settingTable="steering", value="output"},
        {enable=1, name=language.drOption, type=CHECKBOX, settingTable="steering", value="DR"},
        {enable={"steering", "DR"}, name=language.drSwitch, type=TRIM, settingTable="steering", value="drSwitch"},
        {enable=1, name=language.limitOption, type=CHECKBOX, settingTable="steering", value="limit"},
        {enable={"steering", "limit"}, name=language.limitSwitch, type=TRIM, settingTable="steering", value="limitSwitch"}
    }
}

-- esc page
escPage = {
    pageName = language.escPage,
    page = {
        {enable=1, name=language.assignChanel, type=CHANNEL, settingTable="esc", value="output"},
        {enable=1, name=language.armOption, type=CHECKBOX, settingTable="esc", value="arm"},
        {enable={"esc", "arm"}, name=language.armSwitch, type=SWITCH, settingTable="esc", value="armSwitch"},
    }
}

-- brake servo page
brakeServoPage = {
    pageName = language.brakePage,
    page = {
        {enable=1, name=language.brakeServoOption, type=CHECKBOX, settingTable="brake", value="servo"},
        {enable={"brake", "servo"}, name=language.assignChanel, type=CHANNEL, settingTable="brake", value="servoOutput"},
        {enable=1, name=language.limitOption, type=CHECKBOX, settingTable="brake", value="limit"},
        {enable={"brake", "limit"}, name=language.limitSwitch, type=TRIM, settingTable="brake", value="limitSwitch"},
        {enable=1, name=language.brakeBalanceOption, type=CHECKBOX, settingTable="brake", value="balance"},
        {enable={"brake", "balance"}, name=language.brakeBalanceSwitch, type=TRIM, settingTable="brake", value="balanceSwitch"}
    }
}