local config = require('keyboard.config')

local debounceTimer = nil

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

local function snapApplication (preset)
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

local initializeWindowPresets = function ()
    for maxWidth, presets in pairs(config.WINDOW_PRESETS_BY_SCREEN_WIDTH) do
        local currentScreenWidth = getCurrentScreenWidth()
        
        if currentScreenWidth < maxWidth then
            for key, preset in pairs(presets) do
                hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, nil, snapApplication(preset))
            end
        end
    end
end


local function init ()
    for key, preset in pairs(config.WINDOW_PRESETS) do
        hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, nil, snapApplication(preset))
    end
    
    initializeWindowPresets()

    screenWatcher = hs.screen.watcher.new(function()
        debounce(initializeWindowPresets, 1)
    end)
    
    screenWatcher:start()
end

init()