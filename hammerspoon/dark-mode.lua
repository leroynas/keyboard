local config = require('keyboard._config')

local function isDarkMode()
    return hs.host.interfaceStyle() == 'Dark'
end

local function toggleDarkMode()
    return hs.osascript.javascript(
        string.format(
            "Application('System Events').appearancePreferences.darkMode.set(%s)",
            not isDarkMode()
        )
    )
end

local function init()
    hs.hotkey.bind(config.HYPER_KEY, 'f', nil, function()
        toggleDarkMode()
    end)
end

init()
