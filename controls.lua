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
        if joystick:getGamepadAxis("leftx") < -0.2 or joystick:isGamepadDown("dpleft") then
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
        if joystick:getGamepadAxis("leftx") > 0.2 or joystick:isGamepadDown("dpright") then
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
        if joystick:getGamepadAxis("lefty") < -0.2 or joystick:isGamepadDown("dpup") then
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
        if joystick:getGamepadAxis("lefty") > 0.2 or joystick:isGamepadDown("dpdown") then
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
        if joystick:getGamepadAxis("triggerleft") > 0.2 or joystick:getGamepadAxis("triggerright") > 0.2 then
            return true
        end
    end

    if love.keyboard.isDown("q") or love.keyboard.isDown("e") then
        return true
    end

    return false
end

controls.isLeftClicked = function()
end

controls.isRighClicked = function()
end

controls.isUpClicked = function()
end

controls.inDownClicked = function()
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
        if not jumpButtonWasDownInPreviousFrame then
            jumpButtonWasDownInPreviousFrame = true
            return true
        end
        jumpButtonWasDownInPreviousFrame = true
    else
        jumpButtonWasDownInPreviousFrame = false
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
        if not dashButtonWasDownInPreviousFrame then
            dashButtonWasDownInPreviousFrame = true
            return true
        end
        dashButtonWasDownInPreviousFrame = true
    else
        dashButtonWasDownInPreviousFrame = false
    end

    return false
end


return controls