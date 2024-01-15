local config = require('keyboard._config')

function roundToTwoDecimals(number)
    return math.floor(number * 100 + 0.5) / 100
end

local function copyPresetToClipboard()
    local window = hs.window.focusedWindow()
    local frame = window:frame()
    local screen = window:screen():frame()

    local x = roundToTwoDecimals((frame.x - screen.x) / screen.w)
    local y = roundToTwoDecimals((frame.y - screen.y) / screen.h)
    local w = roundToTwoDecimals(frame.w / screen.w)
    local h = roundToTwoDecimals(frame.h / screen.h)

    hs.pasteboard.setContents('{ x = ' .. x .. ', y = ' .. y .. ', w = ' .. w .. ', h = ' .. h .. ' }')
end 

function getApplicationName(bundleID)
    for _, application in ipairs(config.HYPER_APPS) do
        if application[2] == bundleID then
            return application[3]
        end
    end

    return nil
end

local function getWindowLocationsKeys()
    local keys = {}

    for _, locations in pairs(config.WINDOW_LOCATIONS) do
        for key, _ in pairs(locations) do
            keys[key] = true
        end
    end

    return keys
end

local function getCurrentScreenWidth()
    return hs.screen.mainScreen():frame().w
end

local function getWindowLocations()
    for maxScreenWidth, locations in pairs(config.WINDOW_LOCATIONS) do
        if getCurrentScreenWidth() <= maxScreenWidth then
            return locations
        end
    end

    return nil
end


local function getWindowLocation(key)
    local locations = getWindowLocations()
    return locations and locations[key] or nil
end

local function getWindowPresets()
    for maxScreenWidth, presets in pairs(config.WINDOW_PRESETS) do
        if getCurrentScreenWidth() <= maxScreenWidth then
            return presets
        end
    end

    return nil
end

function getApplicationLocationKey(name)
    local presets = getWindowPresets()

    for key, applications in pairs(presets) do
        for _, application in ipairs(applications) do
            if application == name then
                return key
            end
        end
    end

    return nil
end

local function snapWindow(location, window)
    hs.window.animationDuration = 0

    if not window then
        window = hs.window.focusedWindow()
    end

    if location.screen then
        window:moveToScreen(hs.screen.allScreens()[location.screen])
    else
        window:moveToScreen(hs.screen.primaryScreen())
    end
    
    local frame = window:frame()
    local screen = window:screen():frame()
    
    frame.x = location.x and screen.x + screen.w * location.x or frame.x
    frame.y = location.y and screen.y + screen.h * location.y or frame.y
    frame.w = location.w and screen.w * location.w or frame.w
    frame.h = location.h and screen.h * location.h or frame.h
    
    window:setFrame(frame)

    hs.window.animationDuration = 1
end

local function snapWindowByScreenWidth(key, application)
    return function ()
        local location = getWindowLocation(key)

        if location then
            if application then
                for _, window in ipairs(application:allWindows()) do
                    snapWindow(location, window)
                end
            else
                snapWindow(location)
            end
        end
    end
end


local function maximizeApplication()
    snapWindow({
        x = 0,
        y = 0,
        w = 1,
        h = 1,
    })
end

local function nextScreen()
    local window = hs.window.focusedWindow()
    local screen = window:screen()
    window:moveToScreen(screen:next())
    maximizeApplication()
end

local function previousScreen()
    local window = hs.window.focusedWindow()
    local screen = window:screen()
    window:moveToScreen(screen:previous())
    maximizeApplication()
end

local function snapAllWindows()
    local applications = hs.application.runningApplications()

    for _, application in ipairs(applications) do
        local name = getApplicationName(application:bundleID())
        local key = getApplicationLocationKey(name)

        if key then
            snapWindowByScreenWidth(key, application)()
        end
    end
end

local function windowCreated(window)
    local application = window:application()

    local name = getApplicationName(application:bundleID())
    local key = getApplicationLocationKey(name)

    snapWindowByScreenWidth(key, application)();
end

local function init()
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'left', nil, nextScreen)
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'right', nil, previousScreen)
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'e', nil, copyPresetToClipboard)
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'w', nil, snapAllWindows)

    for key, _ in pairs(getWindowLocationsKeys()) do
        hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, nil, snapWindowByScreenWidth(key))
    end

    windowFilter = hs.window.filter.new()
    windowFilter:subscribe(hs.window.filter.windowCreated, windowCreated)
end

init()