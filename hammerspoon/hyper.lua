local default = require('keyboard.hyper-apps-default')
local magento = require('keyboard.hyper-apps-magento')

hs.application.enableSpotlightForNameSearches(true)

function mapKeyBindings (hyperModeAppMappings, name)
  if name then
    hs.notify.new({title='Hammerspoon', informativeText='Mapping: ' .. name}):send()
  end

  for i, mapping in ipairs(hyperModeAppMappings) do
    local key = mapping[1]
    local app = mapping[2]

    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, function()
      if (type(app) == 'string') then
        local application = hs.application.get(app)
        
        
        if (application) then
          if (application:isFrontmost()) then
            application:hide()
          else
            hs.application.open(app)
          end
        else
          hs.application.open(app)
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
  mapKeyBindings(magento, 'magento')
end)

hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, '0', nil, function()
  local bundleID = hs.application.frontmostApplication():bundleID()
  hs.pasteboard.setContents(bundleID)
end)
