local config = require('keyboard.config')

local function copyIdToClipboard()
    local bundleID = hs.application.frontmostApplication():bundleID()
    hs.pasteboard.setContents(bundleID)
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
    
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, '0', nil, copyIdToClipboard)
end

init()
