require("hs.ipc")
hs.ipc.cliInstall()

notifiedOfBatteryDrain = false
hs.timer.doEvery(1, function()
  if hs.battery.powerSource() == "AC Power" and (not hs.battery.isCharging()) then
    if not notifiedOfBatteryDrain then
      -- This is the bad thing. We are plugged in but not charging.
      notifiedOfBatteryDrain = true
      hs.alert.show("The battery is unexpectedly draining 😬", hs.screen.allScreens(), 10)
    end
  else
    if notifiedOfBatteryDrain then
      -- Back to normal
      notifiedOfBatteryDrain = false
      hs.alert.show("The battery is charging again 😁", hs.screen.allScreens(), 10)
    end
  end
end)

hs.hotkey.bind({"ctrl", "alt"}, "return", function()
  -- Find the focused window
  local win = hs.window.focusedWindow()
  local frame = win:screen():frame()

  -- Compute the target width/height, which is 95% of the available space
  local targetWidth = frame.w * 0.95
  local targetHeight = frame.h * 0.95

  -- Identify the start point, which is 1/2 the difference between the screen size and the window size
  local startX = frame.x + (frame.w / 2) - (targetWidth / 2)
  local startY = frame.y + (frame.h / 2) - (targetHeight / 2)

  -- Position the window
  win:setFrame({ x = startX, y = startY, w = targetWidth, h = targetHeight })
end)