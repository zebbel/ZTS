
local toolName = "TNS|car Wizard|TNE"

local function init() 
end

local function run(event)    
    chdir("/SCRIPTS/WIZARD/car")
    return "/SCRIPTS/WIZARD/car/car.lua"
end

return {init = init, run = run}
