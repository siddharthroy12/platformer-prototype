require "settings"

local transition = {}

local TILES_IN_BOTH_AXIS = 16
local TILE_SIZE = CANVAS_WIDTH / TILES_IN_BOTH_AXIS
local tile_scale = 0
local go_toward = 0
local onEndCallback = nil
local speed = 4
local blackScreenTime = 0.2

function drawTile(x, y, scale)
    love.graphics.setColor(0,0,0)
    local size = TILE_SIZE * scale
    love.graphics.rectangle("fill", x - (size/2), y - (size/2), size, size)
end

function transition.draw()
    for i = 1, TILES_IN_BOTH_AXIS do
        for j = 1, TILES_IN_BOTH_AXIS do
            drawTile((i * TILE_SIZE)-TILE_SIZE/2, (j * TILE_SIZE)-TILE_SIZE/2, tile_scale)
        end
    end
end

function transition.update()
    if go_toward == 1 then
        tile_scale = tile_scale + love.timer.getDelta() * speed
        if tile_scale > 1 then
            tile_scale = 1
            onEndCallback()
            blackScreenTime = 0.2
            go_toward = 0
        end
    end
    
    if blackScreenTime > 0 then
        blackScreenTime = blackScreenTime - love.timer.getDelta()
        if blackScreenTime < 0 then
            blackScreenTime = 0
        end
    end

    if go_toward == 0 and tile_scale ~= 0 and blackScreenTime == 0 then
        tile_scale = tile_scale - love.timer.getDelta() * speed
        if tile_scale < 0 then
            tile_scale = 0
        end
    end
end

function transition.start(onEnd)
    tile_scale = 0
    go_toward = 1
    blackScreenTime = 0
    onEndCallback = onEnd
end

return transition