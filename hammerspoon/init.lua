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