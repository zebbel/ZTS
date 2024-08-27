-- cache model settings
local zstModelSettings = ztsSettings.model
-- clear ztsSettings in case model type was changed
ztsSettings = {}
-- reload model settings and init all other settings needed for model type crawler
ztsSettings["model"] = zstModelSettings
ztsSettings.steering = {output = 0, fourWS = 0, outputRear = 2, rearSteerSwitch = 2, awsSteerSwitch = 3, crabSteerSwitch = 9}
ztsSettings.esc = {output = 1, arm = 0, armSwitch = 3}

-- steering page
steeringPage = {
    pageName = language.steeringPage,
    page = {
        {enable=1, name=language.assignChanel, type=CHANNEL, settingTable="steering", value="output"},
        {enable=1, name=language.fourWS, type=CHECKBOX, settingTable="steering", value="fourWS"},
        {enable={"steering", "fourWS"}, name=language.assignChanelRearSteer, type=CHANNEL, settingTable="steering", value="outputRear"},
        {enable={"steering", "fourWS"}, name=language.rearSteer, type=SWITCH, settingTable="steering", value="rearSteerSwitch"},
        {enable={"steering", "fourWS"}, name=language.awsSteer, type=SWITCH, settingTable="steering", value="awsSteerSwitch"},
        {enable={"steering", "fourWS"}, name=language.crabSteer, type=SWITCH, settingTable="steering", value="crabSteerSwitch"},
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