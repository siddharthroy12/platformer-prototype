local Solid = {}
local rectangle = require "math/rectangle"

function Solid:new(position)
    local o = {
        position = position or {x=0, y=0},
        hitbox = {x = -16, y = -16, width=32, height=32}, -- Relative to origin
        tag = "Normal"
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Get hitbox rect in global postion
function Solid:getGlobalHitboxRect()
    local hitbox = self.hitbox
    local rectangle_pos = (vector.add(self.position, hitbox))
    local rect = rectangle.new(rectangle_pos.x, rectangle_pos.y, hitbox.width, hitbox.height)

    return rect
end

function Solid:move(dest)
    self.position.x = math.floor(dest.x)
    self.position.y = math.floor(dest.y)
end
 

return Solid