local config = require('keyboard._config')

local function lock()
    hs.caffeinate.lockScreen()
end

local function init()
    hs.hotkey.bind(config.HYPER_KEY, config.LOCK_KEY, nil, lock)
end

init()
