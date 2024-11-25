local controls = require "controls"
local rectangle = require "math/rectangle"
require "settings"
local utils = require "utils"

local BUTTON_HEIGHT = 50
local BUTTON_WIDTH = CANVAS_WIDTH
focusedButton = 1

local buttonlist = {}

function buttonlist.draw(buttons, topMargin)
    if topMargin == nil then
        topMargin = 0
    end
    if focusedButton < 1 then
        focusedButton = 1
    end 

    if focusedButton > #buttons then
        focusedButton = #buttons
    end

    if controls.isMenuSelectPressed() then
        buttons[focusedButton].action()
    end

    if controls.isDownClicked() then
        if focusedButton < #buttons then
            focusedButton = focusedButton + 1
        end
    end

    if controls.isUpClicked() then
        if focusedButton > 1 then
            focusedButton = focusedButton - 1
        end
    end

    for i=1, #buttons do
        love.graphics.setColor(0,0,0)
        local x = 0
        local y = topMargin +  i*BUTTON_HEIGHT

        love.graphics.printf(buttons[i].text, x+5, y+5, BUTTON_WIDTH, "center")

        if i == focusedButton then
            if math.sin(love.timer.getTime()*30) > 0.5 then
                love.graphics.setColor(0,1,1)
            else
                love.graphics.setColor(1,0,1)
            end
        else
            love.graphics.setColor(1,1,1)
        end
      
        love.graphics.printf(buttons[i].text, x, y, BUTTON_WIDTH, "center")
    end
end


return buttonlist