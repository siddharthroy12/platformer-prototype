require "player"
require "settings"
local Solid = require "physics/solid"

local vector = require "math/vector"
local ldtk = require 'ldtk'
local physicsworld = require "physics/phyiscsworld"

-- Game state variables
local currentLevel = nil

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


game = {}

game.load = function()
    ldtk:load('data/map/levels.ldtk')
    ldtk:goTo(1)
    player.init()
end

game.draw = function()
    drawAnimatedBackground()
    currentLevel:draw()
    player.draw()
end

game.update = function()
    player.update()
end
