require "background"
require "settings"
local rectangle = require "math/rectangle"
local utils = require "utils"
local controls = require "controls"
local scenemanager = require "scenemanager"
local gamescene = require "scenes/gamescene"
local transition = require "transition"
local buttonlist = require "ui/buttonlist"
local focusedButton = 1
local BUTTON_HEIGHT = 50
local BUTTON_WIDTH = CANVAS_WIDTH
local TOP_PADDING_FOR_BUTTONS = 200

local buttons = {
    {
        text = "Start",
        action = function ()
            transition.start(function () 
                scenemanager:changeScene(gamescene)
            end)
        end
    },
    {
        text = "Custom Maps",
        action = function ()
        end
    },
    {
        text = "Options",
        action = function ()
        end
    },
    {
        text = "Exit",
        action = function ()
            love.event.quit()
        end
    },
}

local mainscene = {}

function mainscene.init()
end

function mainscene.update()
end

function mainscene.draw()
    drawAnimatedBackground()
    love.graphics.setColor(1,1,1)
    buttonlist.draw(buttons, TOP_PADDING_FOR_BUTTONS)
end

return mainscene