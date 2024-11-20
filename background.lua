require "settings"

ANIMATED_BOX_SIZE = 51
BOXES_IN_X_AXIS = (CANVAS_WIDTH / ANIMATED_BOX_SIZE) + 1
BOXES_IN_Y_AXIS = (CANVAS_HEIGHT / ANIMATED_BOX_SIZE) + 1
SPEED = 70

function drawAnimatedBackground()
    local t = (love.timer.getTime()) * SPEED

    love.graphics.setColor(18/255, 6/255, 14/255)
    love.graphics.rectangle("fill", 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)

    for i=0, BOXES_IN_X_AXIS, 1 do
        for j=0, BOXES_IN_X_AXIS, 1 do
            if (((i+j) % 2 == 0)) then
                love.graphics.setColor(19/255, 7/255, 23/255)
                local x = (i*ANIMATED_BOX_SIZE)+t
                local y = (j*ANIMATED_BOX_SIZE)+t
    
                x = (x % (CANVAS_WIDTH+ANIMATED_BOX_SIZE*2))-ANIMATED_BOX_SIZE
                y = (y % (CANVAS_HEIGHT+ANIMATED_BOX_SIZE*2))-ANIMATED_BOX_SIZE
                love.graphics.rectangle("fill", x, y, ANIMATED_BOX_SIZE, ANIMATED_BOX_SIZE)
            end
        end
    end
end