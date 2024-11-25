require "player"
require "settings"
require "background"
local buttonlist = require "ui/buttonlist"
local Solid = require "physics/solid"
local vector = require "math/vector"
local ldtk = require 'ldtk'
local scenemanager = require "scenemanager"
local physicsworld = require "physics/phyiscsworld"
local controls = require "controls"
local transition = require "transition"

-- Game state variables
local currentLevel = nil
local gamescene = {}
local paused = false


local buttons = {
    {
        text = "Resume",
        action = function ()
            paused = false
            controls.jumpButtonWasDownInPreviousFrame = true
        end
    },
    {
        text = "Restart",
        action = function ()
            transition.start(function () 
                scenemanager:changeScene(gamescene)
            end)
        end
    },
    {
        text = "Exit",
        action = function ()
            transition.start(function () 
                local mainscene = require "scenes/mainscene"
                scenemanager:changeScene(mainscene)
            end)
        end
    },
}

function ldtk.onEntity(entity)
end

function ldtk.onLayer(layer)
    currentLevel = layer
    for i=1, #currentLevel.tiles do
        table.insert(physicsworld.solids, Solid:new(vector.new( currentLevel.tiles[i]['px'][1]*2, currentLevel.tiles[i]['px'][2]*2)))
    end
end

function ldtk.onLevelLoaded(level)
end

function ldtk.onLevelCreated(level)
end

function gamescene.init()
    ldtk:load('data/map/levels.ldtk')
    ldtk:goTo(1)
    paused = false
    player.init()
end

function gamescene.loadLevel()
end

function gamescene.restartLevel()
end

function gamescene.goToNextLevel()
end


function gamescene.update()
    if controls.isPausePressed() then
        paused = not paused
    end

    if paused then

    else
        player.update()
    end
end

function gamescene.draw()
    drawAnimatedBackground()
    currentLevel:draw()
    player.draw()

    if paused then
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0,0, CANVAS_WIDTH, CANVAS_HEIGHT)
        buttonlist.draw(buttons, 100)
    end
   
end

return gamescene