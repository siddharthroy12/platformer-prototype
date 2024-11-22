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
        jumpforce = 400,
        jumpPressedOn = 0,
        earlyJumpTime = 0.2,
        lastTimeJumped = 0,
        cayote_time = 0.2,
        walkaccel = 130,
        maxwalkvel = 250,
        maxgravitypull = 200,
        lastTimeIsOnGround = 0,
        wantToGo = { x = 0, y = 0},
        dashPower = 500,
        dashDuration = 0.1,
        dashing = false,
        dashStartedAt = 0,
        onGroundAfterDash = true,
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
    self.wantToGo = vector.new(0, 0)
    local collided = self:moveAndCollide(vector.add(self.position, vector.scale(self.velocity, love.timer.getDelta())))

    if (not self.dashing) then
        -- Gravity Acceleration
        if vector.length(vector.subtract(self.velocity, self.gravity)) > self.maxgravitypull then
            self.velocity = vector.add(self.velocity, vector.scale(self.gravity, love.timer.getDelta()))
        end

        -- Resistance
        self.velocity.x = self.velocity.x / (1+love.timer.getDelta()*100)
    else
        if (love.timer.getTime() - self.dashStartedAt >= self.dashDuration) then
            self:stopDash()
        end
    end
  
    if self:isOnGround() then
        if love.timer.getTime() - self.jumpPressedOn < self.earlyJumpTime then
            self:jump()
        end
        self.onGroundAfterDash = true
        self.lastTimeIsOnGround = love.timer.getTime()
    end
end

function Actor:jump()
    self.jumpPressedOn = love.timer.getTime()
    local timeSinceLastTimeOnGround = love.timer.getTime() - self.lastTimeIsOnGround
    local timeSinceLastJumped = love.timer.getTime() - self.lastTimeJumped
    
    if timeSinceLastTimeOnGround < self.cayote_time and timeSinceLastJumped > self.cayote_time and not self.dashing then
        self.lastTimeJumped = love.timer.getTime()
        self.velocity.y = -self.jumpforce
    end
end

function Actor:walkRight()
    self.wantToGo.x = 1

    if self.velocity.x < self.maxwalkvel and not self.dashing then
        self.velocity.x = self.velocity.x + self.walkaccel
    end
end

function Actor:walkLeft()
    self.wantToGo.x = -1

    if self.velocity.x > -self.maxwalkvel and not self.dashing then
        self.velocity.x = self.velocity.x - self.walkaccel
    end
end

function Actor:climbUp()
    self.wantToGo.y = -1
end

function Actor:climbDown()
    self.wantToGo.y = 1
end

function Actor:dash()
    if self.onGroundAfterDash then
        self.onGroundAfterDash = false
        self.dashing = true
        self.dashStartedAt = love.timer.getTime()
        self.velocity = vector.scale(vector.normalize(self.wantToGo), self.dashPower)
    end
end

function Actor:stopDash()
    self.dashing = false
    self.velocity = vector.scale(self.velocity, 0.5)
end

function Actor:grabWall()
end

return Actor