function textBlock(text, width, height, textSize)
  local window = hs.window.frontmostWindow()
  local frame = window:screen():frame()

  local x = frame.x + (frame.w - width) / 2
  local y = frame.y + (frame.h - height) / 2

  local canvas = hs.canvas.new({ x = x, y = y, w = width, h = height })

  canvas:appendElements({
    type = "rectangle",
    action = "fill",
    fillColor = { red = 0, green = 0, blue = 0, alpha = 1 },
    frame = { x = 0, y = 0, w = width, h = height },
  })

  canvas:appendElements({
    type = "text",
    text = string.upper(text),
    textFont = "Helvetica",
    textAlignment = "center",
    frame = { x = 0, y = (height - textSize) / 2, w = width, h = textSize },
    textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
    textSize = textSize,
  })

  canvas:show()

  return canvas
end

local function renderFullScreen(text)
  local window = hs.window.frontmostWindow()
  local screen = window:screen():frame()

  return textBlock(text, screen.w, screen.h, 40)
end

local function renderMessage(text)
  return textBlock(text, 200, 70, 20)
end

return {
  textBlock = textBlock,
  renderFullScreen = renderFullScreen,
  renderMessage = renderMessage,
}
