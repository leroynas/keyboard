local config = require('keyboard.config')

local count = 0
local previousRssi = 0
local countSameRssi = 0

local function getRssiValue(input)
    local pattern = config.AUTOLOCK_DEVICE_ADDRESS .. "%s*.-RSSI:%s*-(%d+)"
    local rssiValue = input:match(pattern)
    return rssiValue and math.abs(tonumber(rssiValue))
end

local function getIsLocked()
    local result = hs.execute('ps ax | grep [S]creenSaverEngine')
    return result ~= '' and result ~= nil and result:match('ScreenSaverEngine') ~= nil
end

local function typeString(str)
    hs.eventtap.keyStrokes(str)
end

local function unlockSystem()
    hs.eventtap.keyStroke({}, "space")

    hs.timer.doAfter(config.AUTOLOCK_UNLOCK_DELAY, function()
        typeString(config.AUTOLOCK_USER_PASSWORD)
        hs.eventtap.keyStroke({}, "return")
        count = 0
    end)
end

local function run()
    if not config.AUTOLOCK_ENABLED then
        return
    end

    local isLocked = getIsLocked()
    local result = hs.execute("system_profiler SPBluetoothDataType")
    local rssi = getRssiValue(result)

    hs.logger.new('debug'):e(rssi, count)
    
    if rssi then
        countSameRssi = (previousRssi == rssi) and (countSameRssi + 1) or 0
        previousRssi = rssi

        if isLocked then
            count = rssi < config.AUTOLOCK_RSSI_THRESHOLD and (count + 1) or 0
            
            if count > config.AUTOLOCK_COUNT_THRESHOLD and countSameRssi < 10 then
                count = 0
                unlockSystem()
            end
        else
            count = rssi > config.AUTOLOCK_RSSI_THRESHOLD and (count + 1) or 0
            
            if count > config.AUTOLOCK_COUNT_THRESHOLD or countSameRssi > 10 then
                count = 0
                hs.caffeinate.startScreensaver()
            end
        end
    end
end

local function init()
    interval = hs.timer.new(config.AUTOLOCK_INTERVAL, run)
    interval:start()
end

init()