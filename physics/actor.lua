local vector = require "math/vector"
local rectangle = require "math/rectangle"
local physicsworld = require "physics/phyiscsworld"
local Actor = {}

function Actor:new(position)
    local o = {
        position = position or {x=50, y=50},
        velocity = {x=0, y=0},
        hitbox = {x = 32, y = 32},
        gravity = {x = 0, y = 1500},
        jumpforce = 500,
        walkaccel = 130,
        maxwalkvel = 250,
        maxgravitypull = 200,
        lastTimeIsOnGround = 0
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Actor:getRect()
    rectangle_pos = (vector.subtract(self.position, vector.divide(self.hitbox, 2)))
    return rectangle.new(rectangle_pos.x, rectangle_pos.y, self.hitbox.x, self.hitbox.y)
end

function Actor:canMove(axis, step)
    local prevPos = { x = self.position.x, y = self.position.y }
    self.position[axis] = self.position[axis] + step

    for i=1, #physicsworld.solids do
        local colliding = rectangle.checkCollision(self:getRect(), physicsworld.solids[i]:getRect())

        if colliding then
            self.position = prevPos
            return false
        end
    end

    self.position = prevPos
    return true
end

function Actor:moveAndCollide(dest)
    dest.x = math.floor(dest.x+0.5)
    dest.y = math.floor(dest.y+0.5)

    local prevVel = {x=self.velocity.x, y=self.velocity.y}

    local stepX = (dest.x > self.position.x) and 1 or -1
    local stepY = (dest.y > self.position.y) and 1 or -1

    local moved = false
    local collided = false
    
    -- Move in x axis
    while (dest.x ~= self.position.x and self:canMove("x", stepX)) do
        self.position.x = self.position.x + stepX
        moved = true
    end

    if (self.position.x ~= dest.x) then
        self.velocity.x = 0
        collided = true
    end

    -- Move in y axis
    while (dest.y ~= self.position.y and self:canMove("y", stepY)) do
        self.position.y = self.position.y + stepY
        moved = true
    end

    if (self.position.y ~= dest.y) then
        self.velocity.y = 0
        collided = true
    end

    -- If we are inside the block to being with then move freely
    if (not self:canMove("y", 0)) then
        self.position.x = dest.x
        self.velocity = prevVel
        self.position.y = dest.y
        collided = false
    end

    return collided
end

function Actor:isOnGround()
    return not self:canMove("y", 1)
end

function Actor:isTouchingWall()
    return (not self:canMove("x", 1)) or (not self:canMove("x", -1))
end

function Actor:update()
    self:moveAndCollide(vector.add(self.position, vector.scale(self.velocity, love.timer.getDelta())))

    -- Gravity Acceleration
    if vector.length(vector.subtract(self.velocity, self.gravity)) > self.maxgravitypull then
        self.velocity = vector.add(self.velocity, vector.scale(self.gravity, love.timer.getDelta()))
    end

    -- Resistance
    self.velocity.x = self.velocity.x / (1+love.timer.getDelta()*100)

    if self:isOnGround() then
        self.lastTimeIsOnGround = love.timer.getTime()
    end
end

function Actor:jump()
    if (love.timer.getTime() - self.lastTimeIsOnGround) < 0.08 then
        self.velocity.y = -self.jumpforce
    end
end

function Actor:walkRight()
    if self.velocity.x < self.maxwalkvel then
        self.velocity.x = self.velocity.x + self.walkaccel
    end
end

function Actor:walkLeft()
    if self.velocity.x > -self.maxwalkvel then
        self.velocity.x = self.velocity.x - self.walkaccel
    end
end

function Actor:grabWall()
end

return Actor