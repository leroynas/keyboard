local default = require('keyboard.hyper-apps-default')
local mobile = require('keyboard.hyper-apps-mobile')
local magento = require('keyboard.hyper-apps-magento')
tempApplication = ''

hs.application.enableSpotlightForNameSearches(true)

function mapKeyBindings (hyperModeAppMappings, name)
  if name then
    hs.notify.new({title='Hammerspoon', informativeText='Mapping: ' .. name}):send()
  end

  for i, mapping in ipairs(hyperModeAppMappings) do
    local key = mapping[1]
    local apps = mapping[2]

    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, function()
      if (type(apps) == 'table') then
        local anyFrontMost = false;

        for i, app in ipairs(apps) do
          local application = hs.application.get(app)

          if (application) then
            if (application:isFrontmost()) then
              anyFrontMost = true;
            end
          end
        end

        for i, item in ipairs(apps) do
          local app = item == 'temp' and tempApplication or item;
          local application = hs.application.get(app)

          hs.logger.new('hyper'):e(app)

          if (application) then
            if (anyFrontMost) then
              application:hide()
              hs.logger.new('hyper'):e(app, 'hide')
            else
              hs.application.open(app)
              os.execute("sleep " .. 0.001)
              hs.logger.new('hyper'):e(app, 'open')
            end
          else
            hs.application.open(app)
          end
        end
      elseif (type(app) == 'function') then
        app()
      else
        hs.logger.new('hyper'):e('Invalid mapping for Hyper +', key)
      end
    end)
  end
end

mapKeyBindings(default)

-- Use Control+§ to reload Hammerspoon config
hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, '1', nil, function()
  mapKeyBindings(default, 'default')
end)

hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, '2', nil, function()
  mapKeyBindings(mobile, 'mobile')
end)

hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, '3', nil, function()
  mapKeyBindings(magento, 'magento')
end)

hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, '0', nil, function()
  local bundleID = hs.application.frontmostApplication():bundleID()
  hs.pasteboard.setContents(bundleID)
end)

hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, '9', nil, function()
  tempApplication = hs.application.frontmostApplication():bundleID()
end)
