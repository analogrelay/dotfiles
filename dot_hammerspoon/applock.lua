local M = {}

function getSettingName(bundleId)
    return "applock_app_" .. bundleId
end

function updateLockBindings()
    local locked = hs.settings.get("applock_locked")
    if locked then
        for k, v in pairs(hs.settings.getKeys()) do
            if string.find(k, "applock_app_") then
                local bundleId = string.sub(k, 13)
                local cfg = hs.settings.get(k)
                if cfg.locked then
                    local app = hs.application.get(bundleId)
                    if app ~= nil then
                        app:hide()
                    end
                end
            end
        end
        hs.alert.show("App lock enabled")
    else
        for k, v in pairs(hs.settings.getKeys()) do
            if string.find(k, "applock_app_") then
                local bundleId = string.sub(k, 13)
                local cfg = hs.settings.get(k)
                if cfg.locked then
                    local app = hs.application.get(bundleId)
                    if app ~= nil then
                        app:unhide()
                    end
                end
            end
        end
        hs.alert.show("App lock disabled")
    end
end
M.watcher = hs.application.watcher.new(function(appName, event, appObject)
    if event == hs.application.watcher.unhidden then
        if hs.settings.get("applock_locked") then
            local cfg = hs.settings.get(getSettingName(appObject:bundleID()))
            if cfg ~= nil and cfg.locked then
                hs.alert.show("Tsk tsk tsk. App " .. appObject:bundleID() .. " is locked.")
                appObject:hide()
            end
        end
    end
end)

function M.start(keyPrefix)
    M.watcher:start()

    hs.hotkey.bind(keyPrefix, "=", function()
        local win = hs.window.focusedWindow()
        local app = win:application()
        local bundleID = app:bundleID()

        -- Create an app config for this application that marks it as locked out
        hs.settings.set(getSettingName(bundleID), {
            locked = true
        })
        hs.alert.show("App " .. bundleID .. " is now locked.")
    end)

    hs.hotkey.bind(keyPrefix, "-", function()
        local win = hs.window.focusedWindow()
        local app = win:application()
        local bundleID = app:bundleID()

        -- Create an app config for this application that marks it as locked out
        local settingName = "applock_app_" .. bundleID
        hs.settings.set(getSettingName(bundleID), {
            locked = false
        })
        hs.alert.show("App " .. bundleID .. " is now unlocked.")
    end)

    hs.hotkey.bind(keyPrefix, 0x2c, function()
        local win = hs.window.focusedWindow()
        local app = win:application()
        local bundleID = app:bundleID()
        
        local settingName = "applock_" .. bundleID
        local cfg = hs.settings.get(getSettingName(bundleID))
        if cfg == nil then
            hs.alert.show("App " .. bundleID .. " is not tracked.")
        else
            hs.alert.show("App " .. bundleID .. " is " .. (cfg.locked and "locked" or "unlocked"))
        end
    end)

    hs.hotkey.bind(keyPrefix, "L", function()
        hs.settings.set("applock_locked", true)
        updateLockBindings()
    end)

    hs.hotkey.bind(keyPrefix, "U", function()
        hs.settings.set("applock_locked", false)
        updateLockBindings()
    end)

    updateLockBindings()
end

return M