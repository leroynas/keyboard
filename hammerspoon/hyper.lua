local config = require('keyboard._config')
local render = require('keyboard._render')

local canvas = nil

local function copyIdToClipboard()
    local bundleID = hs.application.frontmostApplication():bundleID()
    hs.pasteboard.setContents(bundleID)
end

function getApplicationKey(bundleID)
    for _, app in ipairs(config.HYPER_APPS) do
        if app[2] == bundleID then
            return app[1]
        end
    end

    return nil
end

local function showApplicationHotkey() 
    local bundleID = hs.application.frontmostApplication():bundleID()
    local key = getApplicationKey(bundleID)

    canvas = render.renderMessage('SUPER + ' .. key)

    hs.timer.doAfter(0.5, function()
        canvas:delete()
    end)
end

local function toggleApplication(app)
    return function ()
        local application = hs.application.get(app)
        
        if application then
            if application:isFrontmost() then
                application:hide()
            else
                application:unhide()
                hs.application.open(app)
            end 
        else
            hs.application.open(app) 
        end
    end
end

local function init()
    for i, mapping in ipairs(config.HYPER_APPS) do
        local key = mapping[1]
        local app = mapping[2]
        
        hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, toggleApplication(app))
    end
    
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'space', nil, showApplicationHotkey)
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, '0', nil, copyIdToClipboard)
end

init()
