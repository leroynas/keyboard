local config = require('keyboard._config')
local workspace = require('keyboard._workspace')

local function reload() hs.eventtap.keyStroke(config.HYPER_KEY, 'r') end
local function toggleDarkMode() hs.eventtap.keyStroke(config.HYPER_KEY, 'f') end
local function snapWindows() hs.eventtap.keyStroke(config.HYPER_KEY, 'w') end
local function focusWindows() hs.eventtap.keyStroke(config.HYPER_KEY, 'e') end
local function copyAppId() hs.eventtap.keyStroke(config.HYPER_KEY, '/') end
local function copyPreset() hs.eventtap.keyStroke(config.HYPER_KEY, 's') end
local function copyScreenId() hs.eventtap.keyStroke(config.HYPER_KEY, 'd') end
local function hyperKeys() hs.eventtap.keyStroke(config.HYPER_KEY, '\\') end

local function render()
    if Menubar then
        Menubar:delete()
    end

    Menubar = hs.menubar.new()
    Menubar:setIcon(hs.image.imageFromPath("keyboard/assets/icons/hyper.png"):setSize({ w = 20, h = 20 }))

    local menuData = {
        { title = "-" },
        { title = 'Reload',           shortcut = 'r',  fn = reload },
        { title = "-" },
        { title = 'Toggle dark mode', shortcut = 'f',  fn = toggleDarkMode },
        { title = "-" },
        { title = 'Snap windows',     shortcut = 'w',  fn = snapWindows },
        { title = 'Focus windows',    shortcut = 'e',  fn = focusWindows },
        { title = "-" },
        { title = 'Copy app id',      shortcut = 'a',  fn = copyAppId },
        { title = 'Copy preset',      shortcut = 's',  fn = copyPreset },
        { title = 'Copy screen id',   shortcut = 'd',  fn = copyScreenId },
        { title = "-" },
        { title = 'Hyper app list',   shortcut = '\\', fn = hyperKeys },
    }

    for ws, _ in pairs(config.WORKSPACE_ITEMS) do
        table.insert(menuData, 1, {
            title = "Switch to " .. ws,
            fn = function()
                workspace.set(ws)
                render()
                snapWindows()
            end,
            checked = workspace.get() == ws,
            disabled = workspace.get() == ws,
        })
    end

    Menubar:setMenu(menuData)
end

local function init()
    render()
end

init()
