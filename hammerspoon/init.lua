local config = require('keyboard._config')

hs.hotkey.bind(config.HYPER_KEY, 'r', nil, function()
    hs.reload()
end)

require('keyboard.dark-mode')
require('keyboard.hyper')
require('keyboard.lock')
require('keyboard.menu')
require('keyboard.window')
