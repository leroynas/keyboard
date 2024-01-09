local function setSystemDM(state)
    return hs.osascript.javascript(
        string.format(
            "Application('System Events').appearancePreferences.darkMode.set(%s)",
            state
        )
    )
end

local function init()
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'd', nil, function()
        setSystemDM(true)
    end)
    
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'f', nil, function()
        setSystemDM(false)
    end)
end