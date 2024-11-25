require "settings"

local utils = {}

function utils.getMousePositionOnCanvas()
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local scale = math.min(screenWidth / CANVAS_WIDTH, screenHeight / CANVAS_HEIGHT)
    local offsetX = (screenWidth - (CANVAS_WIDTH * scale)) * 0.5
    local offsetY = (screenHeight - (CANVAS_HEIGHT * scale)) * 0.5

    local mouseX, mouseY = love.mouse.getPosition()
    local canvasX = (mouseX - offsetX) / scale
    local canvasY = (mouseY - offsetY) / scale

    return {x = canvasX, y = canvasY }
end

return utils