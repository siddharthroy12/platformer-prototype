local Solid = {}
local rectangle = require "math/rectangle"

function Solid:new(position)
    local o = {
        position = position or {x=0, y=0},
        hitbox = {x = 32, y = 32},
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Solid:getRect()
    return rectangle.new(self.position.x, self.position.y, self.hitbox.x, self.hitbox.y)
end

function Solid:move(dest)
    self.position.x = math.floor(dest.x)
    self.position.y = math.floor(dest.y)
end
 

return Solid