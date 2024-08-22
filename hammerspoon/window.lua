local config = require('keyboard._config')
local workspace = require('keyboard._workspace')

local function roundToTwoDecimals(number)
    return math.floor(number * 100 + 0.5) / 100
end

local function copyMainScreenToClipboard()
    local mainScreen = hs.screen.mainScreen():name()
    hs.pasteboard.setContents(mainScreen)
end

local function copyPresetToClipboard()
    local window = hs.window.focusedWindow()
    local frame = window:frame()
    local screen = window:screen():frame()

    local x = roundToTwoDecimals((frame.x - screen.x) / screen.w)
    local y = roundToTwoDecimals((frame.y - screen.y) / screen.h)
    local w = roundToTwoDecimals(frame.w / screen.w)
    local h = roundToTwoDecimals(frame.h / screen.h)

    local screenIndex = window:screen():id() - 1
    local screenString = screenIndex == 1 and '' or ', screen = ' .. screenIndex

    local clipboardContent = string.format('{ x = %.2f, y = %.2f, w = %.2f, h = %.2f%s }', x, y, w, h, screenString)

    hs.pasteboard.setContents(clipboardContent)
end

local function getApplicationName(bundleId)
    for _, application in ipairs(config.HYPER_APPS) do
        if application[2] == bundleId then
            return application[3]
        end
    end

    return nil
end

local function getApplicationBundleId(name)
    for _, application in ipairs(config.HYPER_APPS) do
        if application[3] == name then
            return application[2]
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


local function getWindowLocation(key)
    local locations = config.WINDOW_LOCATIONS[workspace.get()]
    return locations and locations[key] or nil
end

local function getApplicationLocationKey(name)
    local presets = config.WINDOW_PRESETS[workspace.get()]

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

local function snapWorkspaceWindow(key, application, window)
    return function()
        local location = getWindowLocation(key)
        if location then
            if application then
                for _, window in ipairs(application:allWindows()) do
                    snapWindow(location, window)
                end

                return;
            end

            snapWindow(location, window)
        end
    end
end

local function snapAllWindows()
    local applications = hs.application.runningApplications()

    for _, application in ipairs(applications) do
        local name = getApplicationName(application:bundleID())
        local key = getApplicationLocationKey(name)

        if key then
            snapWorkspaceWindow(key, application)()
        end
    end
end

local function bringToFront()
    local presets = config.WINDOW_PRESETS[workspace.get()]

    for _, applications in pairs(presets) do
        local name = applications[1]
        local bundleId = getApplicationBundleId(name)

        if bundleId then
            local application = hs.application.get(bundleId)

            if application then
                application:activate()
            end
        end
    end

    return nil
end

local function windowCreated(window)
    local application = window:application()

    local name = getApplicationName(application:bundleID())
    local key = getApplicationLocationKey(name)

    snapWorkspaceWindow(key, nil, window)()
end



local function screenWatcher()
    local old = workspace.get()
    workspace.reset()
    local new = workspace.get()

    if old ~= new then
        hs.timer.doAfter(1, snapAllWindows)
    end
end

local function init()
    snapAllWindows()

    hs.hotkey.bind(config.HYPER_KEY, 'w', nil, snapAllWindows)
    hs.hotkey.bind(config.HYPER_KEY, 'e', nil, bringToFront)
    hs.hotkey.bind(config.HYPER_KEY, 's', nil, copyPresetToClipboard)
    hs.hotkey.bind(config.HYPER_KEY, 'd', nil, copyMainScreenToClipboard)

    for key, _ in pairs(getWindowLocationsKeys()) do
        hs.hotkey.bind(config.HYPER_KEY, key, nil, snapWorkspaceWindow(key))
    end

    WindowFilter = hs.window.filter.new()
    WindowFilter:subscribe(hs.window.filter.windowCreated, windowCreated)

    ScreenWatcher = hs.screen.watcher.new(screenWatcher)
    ScreenWatcher:start()
end

init()
