local textSize = 30
local padding = 50
local radius = 30

Canvas = nil

local function countLines(str)
    local count = 0
    
    for _ in str:gmatch('\n') do
        count = count + 1
    end
    
    return count
end

local function longestLineLength(str)
    local maxLength = 0
    
    for line in str:gmatch("[^\r\n]+") do
        local length = #line
        if length > maxLength then
            maxLength = length
        end
    end
    
    return maxLength
end

local function message(text)
    local window = hs.window.frontmostWindow()
    local frame = window:screen():frame()

    text = text .. '\n\nHyper + q - close'
    
    local textHeight = countLines(text) * textSize * 1.2
    local longestLine = longestLineLength(text)
    local textWidth = textSize * 0.6;
    
    local height = textHeight + padding * 2;
    local width = longestLine * textWidth + padding * 2;
    
    local x = frame.x + (frame.w - width) / 2
    local y = frame.y + (frame.h - height) / 2
    
    Canvas = hs.canvas.new({ x = x, y = y, w = width, h = height })
    
    Canvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0.05, green = 0.05, blue = 0.05, alpha = 0.85 },
        frame = { x = 0, y = 0, w = width, h = height },
        roundedRectRadii = { xRadius = radius, yRadius = radius },
        withShadow = true,
    })
    
    Canvas:appendElements({
        type = "text",
        text = text,
        textFont = "PT Mono",
        frame = { x = padding, y = padding, w = width, h = textHeight },
        textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
        textSize = textSize,
    })
    
    Canvas:show()
    
    hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'q', function ()
        Canvas:delete()
    end)
end

return {
    message = message,
}
