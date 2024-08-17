
local toolName = "TNS|car Wizard|TNE"

local function init() 
end

local function run(event)    
    chdir("/SCRIPTS/WIZARD/ZTW")
    return "/SCRIPTS/WIZARD/ZTW/ztw.lua"
end

return {init = init, run = run}
