local config = require('keyboard.config')

local debounceTimer = nil

local function getWindowPresetKeys(table)
    local keys = {}

    for _, presets in pairs(table) do
        for key, _ in pairs(presets) do
            keys[key] = true
        end
    end

    return keys
end

local function debounce(func, delay)
    if debounceTimer then
        debounceTimer:stop()
    end

    debounceTimer = hs.timer.delayed.new(delay, function()
        func()
    end):start()
end

local function getCurrentScreenWidth()
    return hs.screen.mainScreen():frame().w
end

local function snapApplication(preset)
    return function ()
        local window = hs.window.focusedWindow()
        local frame = window:frame()
        local screen = window:screen():frame()
        
        frame.x = preset.x and screen.x + screen.w * preset.x or frame.x
        frame.y = preset.y and screen.y + screen.h * preset.y or frame.y
        frame.w = preset.w and screen.w * preset.w or frame.w
        frame.h = preset.h and screen.h * preset.h or frame.h
        
        window:setFrame(frame)
    end
end

local function snapApplicationByScreenWidth(key)
    return function ()
        local window = hs.window.focusedWindow()

        if window then
            local screenWidth = window:screen():frame().w

            for maxScreenWidth, presets in pairs(config.WINDOW_PRESETS_BY_SCREEN_WIDTH) do
                if screenWidth <= maxScreenWidth then
                    preset = presets[key]
                    break
                end
            end

            if preset then
                snapApplication(preset)()
            end
        end
    end
end


local function maximizeApplication()
    snapApplication({
        x = 0,
        y = 0,
        w = 1,
        h = 1,
    })()
end

local function nextScreen()
    return function ()
        local window = hs.window.focusedWindow()
        local screen = window:screen()
        window:moveToScreen(screen:next())
        maximizeApplication()
    end
end

local function previousScreen()
    return function ()
        local window = hs.window.focusedWindow()
        local screen = window:screen()
        window:moveToScreen(screen:previous())
        maximizeApplication()
    end
end

local function init()
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'left', nil, nextScreen())
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'right', nil, previousScreen())

    for key, preset in pairs(config.WINDOW_PRESETS) do
        hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, nil, snapApplication(preset))
    end

    for key, _ in pairs(getWindowPresetKeys(config.WINDOW_PRESETS_BY_SCREEN_WIDTH)) do
        hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, nil, snapApplicationByScreenWidth(key))
    end
end

init()