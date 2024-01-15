local config = require('keyboard._config')

local function lock()
    print('lock')
    hs.caffeinate.lockScreen()
end

local function init()
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, config.LOCK_KEY, nil, lock)
end

init()