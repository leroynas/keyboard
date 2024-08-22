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

local function toggleApplication(apps)
    local currentIndex = 1
    local currentApp = apps[currentIndex]
    local application = hs.application.get(currentApp)

    local function nextApplication()
        if currentIndex == #apps then
            currentIndex = 1
        else
            currentIndex = currentIndex + 1
        end

        currentApp = apps[currentIndex]
        application = hs.application.get(currentApp)

        application:unhide()
        hs.application.open(currentApp)
    end

    return function()
        if application then
            if application:isFrontmost() then
                application:hide()

                if #apps > 1 then
                    nextApplication()
                end
            else
                application:unhide()
                hs.application.open(currentApp)
            end
        end
    end
end

local function init()
    for _, mapping in ipairs(config.HYPER_APPS) do
        local key = mapping[1]
        local apps = {}

        for _, m in ipairs(config.HYPER_APPS) do
            if m[1] == key then
                table.insert(apps, m[2])
            end
        end

        hs.hotkey.bind(config.HYPER_KEY, key, toggleApplication(apps))
    end

    hs.hotkey.bind(config.HYPER_KEY, 'e', nil, showApplicationHotkeys)
    hs.hotkey.bind(config.HYPER_KEY, '\\', nil, showApplicationHotkeys)
    hs.hotkey.bind(config.HYPER_KEY, 'a', nil, copyIdToClipboard)
end

init()
