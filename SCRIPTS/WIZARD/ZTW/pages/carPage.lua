local zstModelSettings = zstSettings.model
zstSettings = {}
zstSettings["model"] = zstModelSettings
zstSettings["steering"] = {output = 0, DR = 0, drSwitch = 94, limit = 0, limitSwitch = 93}
zstSettings["esc"] = {output = 1, arm = 0, armSwitch = 12}
zstSettings["brake"] = {servo = 0, servoOutput = 2, limit = 1, limitSwitch = 95, balance = 0, balanceSwitch = 92}

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

escPage = {
    pageName = language.escPage,
    page = {
        {enable=1, name=language.assignChanel, type=CHANNEL, settingTable="esc", value="output"},
        {enable=1, name=language.armOption, type=CHECKBOX, settingTable="esc", value="arm"},
        {enable={"esc", "arm"}, name=language.armSwitch, type=SWITCH, settingTable="esc", value="armSwitch"},
    }
}

brakeServoPage = {
    pageName = language.brakePage,
    page = {
        {enable=1, name=language.limitOption, type=CHECKBOX, settingTable="brake", value="limit"},
        {enable={"brake", "limit"}, name=language.limitSwitch, type=TRIM, settingTable="brake", value="limitSwitch"}
    }
}