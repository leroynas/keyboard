local config = require('keyboard._config')

local function get()
    return Current
end

local function set(name)
    Current = name
end

local function reset()
    local mainScreen = hs.screen.mainScreen():name()

    for workspace, situation in pairs(config.WORKSPACE_ITEMS) do
        if mainScreen == situation.mainScreen then
            return set(workspace)
        end
    end

    return set(config.WORKSPACE_DEFAULT)
end

local function init()
    reset()
end

init()

return {
    get = get,
    set = set,
    reset = reset,
}
