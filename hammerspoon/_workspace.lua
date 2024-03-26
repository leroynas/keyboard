local config = require('keyboard._config')

local function get()
    return Current
end

local function set(name)
    Current = name
end

local function reset()
    local primaryScreen = hs.screen.primaryScreen():name()

    hs.logger.new('workspace'):e('Primary screen: ', primaryScreen)

    for workspace, situation in pairs(config.WORKSPACE_ITEMS) do
        if primaryScreen == situation.primaryScreen then
            hs.logger.new('workspace'):e('Workspace: ', workspace)
            return set(workspace)
        end
    end

    hs.logger.new('workspace'):e(config.WORKSPACE_DEFAULT)
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
