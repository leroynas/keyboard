local config = require('keyboard._config')
local render = require('keyboard._render')

local function copyIdToClipboard()
    local bundleId = hs.application.frontmostApplication():bundleID()
    hs.pasteboard.setContents(bundleId)
end

local function capitalizeFirstLetter(str)
    return str:sub(1, 1):upper() .. str:sub(2)
end

local function showApplicationHotkeys()
    local text = ''

    for index, app in ipairs(config.HYPER_APPS) do
        local key, _, appName = table.unpack(app)
        text = text .. 'Hyper + ' .. key .. ' - ' .. capitalizeFirstLetter(appName)

        if index < #config.HYPER_APPS then
            text = text .. '\n'
        end
    end

    render.message(text, 250)
end

local function toggleApplication(app)
    return function()
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
    for _, mapping in ipairs(config.HYPER_APPS) do
        local key = mapping[1]
        local app = mapping[2]

        hs.hotkey.bind(config.HYPER_KEY, key, toggleApplication(app))
    end

    hs.hotkey.bind(config.HYPER_KEY, 'e', nil, showApplicationHotkeys)
    hs.hotkey.bind(config.HYPER_KEY, '\\', nil, showApplicationHotkeys)
    hs.hotkey.bind(config.HYPER_KEY, 'a', nil, copyIdToClipboard)
end

init()
