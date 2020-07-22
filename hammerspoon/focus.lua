function drawCanvas (text)
  local screen = hs.screen.mainScreen()
  local max = screen:frame()

  local width = max.w
  local height = max.h + 45
  local textSize = 100

  local rect = hs.canvas.new({
    x = (max.w - width) / 2,
    y = (max.h - height) / 2,
    h = height,
    w = width
  })

  rect[#rect+1] = {
    action = "build",
    type = "rectangle",
    fillColor = { alpha = 1 },
    action = "fill",
  }

  rect[#rect+1] = {
    action = "build",
    type = "text",
    text = text,
    frame = {
      h = textSize,
      w = width,
      x = 0,
      y = (height - textSize) / 2
    },
    textAlignment = "center",
    textSize = textSize,
    textFont = "Gotham Rounded Medium"
  }

  rect:show()

  hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, 'return', function()
    rect:delete()
  end)
end