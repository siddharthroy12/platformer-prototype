-- Handle keyboard, mouse and controller controls


local controls = {}

local jumpButtonWasDownInPreviousFrame = false
local dashButtonWasDownInPreviousFrame = false
local joystick = nil

function love.joystickadded(newjoystick)
    if joystick == nil then
        joystick = newjoystick
    end
end

controls.isLeftDown = function()
    if joystick ~= nil then
        if joystick:getGamepadAxis("leftx") < -0 or joystick:isGamepadDown("dpleft") then
            return true
        end
    end

    if love.keyboard.isDown("a") then
        return true
    end

    return false
end

controls.isRightDown = function()
    if joystick ~= nil then
        if joystick:getGamepadAxis("leftx") > 0 or joystick:isGamepadDown("dpright") then
            return true
        end
    end

    if love.keyboard.isDown("d") then
        return true
    end

    return false
end

controls.isUpDown = function()
    if joystick ~= nil then
        if joystick:getGamepadAxis("lefty") < -0 or joystick:isGamepadDown("dpup") then
            return true
        end
    end

    if love.keyboard.isDown("w") then
        return true
    end

    return false
end

controls.isDownDown = function()
    if joystick ~= nil then
        if joystick:getGamepadAxis("lefty") > 0 or joystick:isGamepadDown("dpdown") then
            return true
        end
    end

    if love.keyboard.isDown("s") then
        return true
    end

    return false
end

controls.isGrabDown = function()
    if joystick ~= nil then
        if joystick:getGamepadAxis("triggerleft") > 0 or joystick:getGamepadAxis("triggerright") > 0.2 then
            return true
        end
    end

    if love.keyboard.isDown("q") or love.keyboard.isDown("e") then
        return true
    end

    return false
end

controls.isLeftClicked = function()
    local joystickLeftDown = false
    local keyboardLeftDown = false

    if joystick ~= nil then
        if joystick:getGamepadAxis("leftx") < -0 or joystick:isGamepadDown("dpleft") then
            joystickLeftDown = true
        end
    end

    if love.keyboard.isDown("a") then
        keyboardLeftDown = true
    end

    if joystickLeftDown or keyboardLeftDown then
        if not controls.leftWasDownInPreviousFrame then
            controls.leftWasDownInPreviousFrame = true
            return true
        end
        controls.leftWasDownInPreviousFrame = true
    else
        controls.leftWasDownInPreviousFrame = false
    end

    return false
end

controls.isRightClicked = function()
    local joystickRightDown = false
    local keyboardRightDown = false

    if joystick ~= nil then
        if joystick:getGamepadAxis("leftx") > 0 or joystick:isGamepadDown("dpright") then
            joystickRightDown = true
        end
    end

    if love.keyboard.isDown("d") then
        keyboardRightDown = true
    end

    if joystickRightDown or keyboardRightDown then
        if not controls.rightWasDownInPreviousFrame then
            controls.rightWasDownInPreviousFrame = true
            return true
        end
        controls.rightWasDownInPreviousFrame = true
    else
        controls.rightWasDownInPreviousFrame = false
    end

    return false
end

controls.isPausePressed = function()
    local keyboardPauseDown = false
    local controllerPauseDown = false

    if love.keyboard.isDown("escape") then
        keyboardPauseDown = true
    end

    if joystick ~= nil then
        if joystick:isGamepadDown("start") then
            controllerPauseDown = true
        end
    end

    if keyboardPauseDown or controllerPauseDown then
        if not controls.pauseWasDownInPreviousFrame then
            controls.pauseWasDownInPreviousFrame = true
            return true
        end
        controls.pauseWasDownInPreviousFrame = true
    else
        controls.pauseWasDownInPreviousFrame = false
    end

    return false
end

controls.isUpClicked = function()
    local joystickUpDown = false
    local keyboardUpDown = false

    if joystick ~= nil then
        if joystick:getGamepadAxis("lefty") < -0 or joystick:isGamepadDown("dpup") then
            joystickUpDown = true
        end
    end

    if love.keyboard.isDown("w") then
        keyboardUpDown = true
    end

    if joystickUpDown or keyboardUpDown then
        if not controls.upWasDownInPreviousFrame then
            controls.upWasDownInPreviousFrame = true
            return true
        end
        controls.upWasDownInPreviousFrame = true
    else
        controls.upWasDownInPreviousFrame = false
    end

    return false
end

controls.isDownClicked = function()
    local joystickDownDown = false
    local keyboardDownDown = false

    if joystick ~= nil then
        if joystick:getGamepadAxis("lefty") > 0 or joystick:isGamepadDown("dpdown") then
            joystickDownDown = true
        end
    end

    if love.keyboard.isDown("s") then
        keyboardDownDown = true
    end

    if joystickDownDown or keyboardDownDown then
        if not controls.downWasDownInPreviousFrame then
            controls.downWasDownInPreviousFrame = true
            return true
        end
        controls.downWasDownInPreviousFrame = true
    else
        controls.downWasDownInPreviousFrame = false
    end

    return false
end


controls.isJumpPressed = function()
    local joystickJumpDown = false
    local keyboardJumpDown = false

    if joystick ~= nil then
        if joystick:isGamepadDown("a") or joystick:isGamepadDown("y") then
            joystickJumpDown =  true
        end
    end
  

    if love.keyboard.isDown("space") then
       keyboardJumpDown = true
    end

    if joystickJumpDown or keyboardJumpDown then
        if not controls.jumpButtonWasDownInPreviousFrame then
            controls.jumpButtonWasDownInPreviousFrame = true
            return true
        end
        controls.jumpButtonWasDownInPreviousFrame = true
    else
        controls.jumpButtonWasDownInPreviousFrame = false
    end

    return false
end

controls.isMenuSelectPressed = function()
    local joystickSelectDown = false
    local keyboardSelectDown = false
    local mouseSelectDown = false

    if joystick ~= nil then
        if joystick:isGamepadDown("a") then
            joystickSelectDown =  true
        end
    end

    if love.mouse.isDown(1) then
        mouseSelectDown = true
    end

    if love.keyboard.isDown("return") then
        keyboardSelectDown = true
    end

    if joystickSelectDown or keyboardSelectDown or mouseSelectDown then
        if not controls.selectButtonDownInPreviousFrame then
            controls.selectButtonDownInPreviousFrame = true
            return true
        end
    else
        controls.selectButtonDownInPreviousFrame = false
    end

    return false
end

controls.isDashPressed = function()
    local joystickDashDown = false
    local keyboardDashDown = false

    if joystick ~= nil then
        if joystick:isGamepadDown("b") or joystick:isGamepadDown("x") then
            joystickDashDown =  true
        end
    end
  

    if love.keyboard.isDown("c") then
       keyboardDashDown = true
    end

    if joystickDashDown or keyboardDashDown then
        if not controls.dashButtonWasDownInPreviousFrame then
            controls.dashButtonWasDownInPreviousFrame = true
            return true
        end
        controls.dashButtonWasDownInPreviousFrame = true
    else
        controls.dashButtonWasDownInPreviousFrame = false
    end

    return false
end


return controls