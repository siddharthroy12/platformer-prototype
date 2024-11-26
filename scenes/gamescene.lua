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
local currentLevelNumber = 1
local gamescene = {}
local paused = false
local tileIdToEnum = {}
local startPosition = nil
local topReached = false

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
                gamescene.restartLevel()
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
    if entity['id'] == "Start_position" then
        startPosition = {x=entity.x * 2, y=entity.y*2}
    end
end

function ldtk.onLayer(layer)
    currentLevel = layer
    physicsworld.solids = {}

    for i=1, #ldtk.tilesets[1].enumTags do
        for j=1, #ldtk.tilesets[1].enumTags[i]["tileIds"] do
            tileIdToEnum[ldtk.tilesets[1].enumTags[i]["tileIds"][j]] = ldtk.tilesets[1].enumTags[i]["enumValueId"]
        end
    end
    for i=1, #currentLevel.tiles do
        local solid = Solid:new(vector.new( currentLevel.tiles[i]['px'][1]*2 +16, currentLevel.tiles[i]['px'][2]*2 + 16))
        solid.tag = tileIdToEnum[currentLevel.tiles[i]['t']]
        table.insert(physicsworld.solids, solid)
    end
end

function ldtk.onLevelLoaded(level)
end

function ldtk.onLevelCreated(level)
end

function gamescene.init()
    ldtk:load('data/map/levels.ldtk')

    gamescene.loadLevel(1)
end

function gamescene.loadLevel(level)

    currentLevelNumber = level
    topReached = false
    ldtk:goTo(level)
    paused = false
    player.init(startPosition)
    function player.actor:onKill()
        transition.start(function () 
            gamescene.loadLevel(currentLevelNumber)
        end)
    end
end

function gamescene.restartLevel()
    gamescene.loadLevel(currentLevelNumber)
end

function gamescene.goToNextLevel()
    gamescene.loadLevel(currentLevelNumber+1)
end


function gamescene.update()
    if controls.isPausePressed() then
        paused = not paused
    end

    if paused then

    else
        if (player.actor.position.y - (player.actor.hitbox.y / 2) > CANVAS_HEIGHT) then
            player.actor:onKill()
        end
        if (player.actor.position.y + (player.actor.hitbox.y / 2) < 0) and not topReached then
            topReached = true
            player.actor.velocity = vector.new(0,0)
            player.actor.position.y = -100
            transition.start(function () 
                gamescene.goToNextLevel()
            end)
        end
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