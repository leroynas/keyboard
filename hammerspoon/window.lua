local config = require('keyboard._config')

local workspace = '🏠';
local menubar = nil

local function roundToTwoDecimals(number)
    return math.floor(number * 100 + 0.5) / 100
end

local function getIpAddress()
    local _, result = hs.http.get('https://ipinfo.io/ip')

    if _ == 200 then
        return result:match("%S+")
    else
        return nil
    end
end

local function getWorkspaceForIPAddress()
    local ipAddress = getIpAddress();

    for workspace, ip in pairs(config.WINDOW_WORKSPACES) do
        if ipAddress == ip then
            return workspace
        end
    end

    return '🏠';
end

local function copyPresetToClipboard()
    local window = hs.window.focusedWindow()
    local frame = window:frame()
    local screen = window:screen():frame()

    local x = roundToTwoDecimals((frame.x - screen.x) / screen.w)
    local y = roundToTwoDecimals((frame.y - screen.y) / screen.h)
    local w = roundToTwoDecimals(frame.w / screen.w)
    local h = roundToTwoDecimals(frame.h / screen.h)

    local screenIndex = window:screen():id() - 1;
    local screenString =  screenIndex == 1 and '' or ', screen = ' .. screenIndex;

    hs.pasteboard.setContents('{ x = ' .. x .. ', y = ' .. y .. ', w = ' .. w .. ', h = ' .. h .. screenString .. ' }')
end 

local function getApplicationName(bundleID)
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


local function getWindowLocation(key)
    local locations = config.WINDOW_LOCATIONS[workspace]
    return locations and locations[key] or nil
end

local function getApplicationLocationKey(name)
    local presets = config.WINDOW_PRESETS[workspace]

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
    window:focus()

    hs.window.animationDuration = 1
end

local function snapWorkspaceWindow(key, application)
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

local function windowCreated(window)
    local application = window:application()

    local name = getApplicationName(application:bundleID())
    local key = getApplicationLocationKey(name)

    snapWorkspaceWindow(key, application)();
end

local function initMenu()
    if menubar then
        menubar:delete();
    end

    menubar = hs.menubar.new()
    menubar:setIcon(hs.image.imageFromPath("keyboard/assets/icons/hyper.png"):setSize({ w = 20, h = 20 }))

    local menuData = {
        { title = 'Snap windows (w)', fn = function() hs.eventtap.keyStroke({'shift', 'ctrl', 'alt', 'cmd'}, 'w') end },
        { title = 'Hyper keys (9)', fn = function() hs.eventtap.keyStroke({'shift', 'ctrl', 'alt', 'cmd'}, '?') end },
        { title = 'Copy ID (0)', fn = function() hs.eventtap.keyStroke({'shift', 'ctrl', 'alt', 'cmd'}, '0') end },
        { title = 'Copy preset (e)', fn = function() hs.eventtap.keyStroke({'shift', 'ctrl', 'alt', 'cmd'}, 'e') end },
    }

    for icon, _ in pairs(config.WINDOW_WORKSPACES) do
        if icon ~= workspace then
            table.insert(menuData, {
                title = "Switch to " .. icon,
                fn = function()
                    workspace = icon
                    initMenu()
                    snapAllWindows()
                end
            })
        end
    end

    menubar:setMenu(menuData)
end

local function init()
    workspace = getWorkspaceForIPAddress()
    snapAllWindows();
    initMenu();

    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'w', nil, snapAllWindows)
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'e', nil, copyPresetToClipboard)

    for key, _ in pairs(getWindowLocationsKeys()) do
        hs.hotkey.bind({ 'shift', 'ctrl', 'alt', 'cmd' }, key, nil, snapWorkspaceWindow(key))
    end

    WindowFilter = hs.window.filter.new()
    WindowFilter:subscribe(hs.window.filter.windowCreated, windowCreated)
end

init()

hs.caffeinate.watcher.new(function(eventType)
    if eventType == hs.caffeinate.watcher.screensDidUnlock then
        init()
    end
end):start()