require "background"
require "settings"
require "game"

function love.load()
    love.window.setMode(CANVAS_WIDTH, CANVAS_HEIGHT, {
        resizable = true
    })
    love.graphics.setDefaultFilter("nearest", "nearest")
    canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    game.load()
end

function love.draw()
    -- Rectangle is drawn to the canvas with the regular/default alpha blend mode ("alphamultiply").
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("alpha")
    game.draw()
    love.graphics.setCanvas()

    local scale =  math.min(love.graphics.getWidth()/CANVAS_WIDTH, love.graphics.getHeight()/CANVAS_HEIGHT)
    
    -- The colors for the rectangle on the canvas have already been alpha blended.
    -- Use the "premultiplied" alpha blend mode when drawing the canvas to the screen for proper color blending.
    -- (Also set the color to white so the canvas itself doesn't get tinted.)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, (love.graphics.getWidth() - (CANVAS_WIDTH*scale))*0.5,(love.graphics.getHeight() - (CANVAS_HEIGHT*scale))*0.5, 0, scale, scale)
end

function love.update()
    game.update()
end
