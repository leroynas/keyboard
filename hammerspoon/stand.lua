local config = require('keyboard._config')
local render = require('keyboard._render')

Canvas = nil
Timer = nil

local function isEnabled()
    local result = hs.execute("system_profiler SPBluetoothDataType")
    return string.match(result, config.STAND_ENABLED_BLUETOOTH_ADDRESS) ~= nil
end

local function showMessage(message)
    local window = hs.window.focusedWindow()
    local screen = window:screen():frame()

    Canvas = render.renderFullScreen(message)
end

local function startTimer()
    Timer = hs.timer.doAfter(60 * 60 * 2, function ()
        showMessage('Stand up!')
    end)

    return Timer:start()
end

local function hideMessage()
    Canvas:delete()
    startTimer()
end

local function init()
    if not isEnabled() then  
        return
    end

    startTimer()

    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'q', nil, hideMessage)
end

init()
