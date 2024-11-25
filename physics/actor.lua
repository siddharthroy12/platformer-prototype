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
        grabbingWall = false,
        climbUpSpeed = 100,
        climbDownSpeed = 150,
        timeSinceLastTimeOnGround = 0,
        timeSinceLastJumped = 0,
        wallJumped = false,
        dead = false,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Actor:onKill()
end

function Actor:getRect(half)
    rectangle_pos = (vector.subtract(self.position, vector.divide(self.hitbox, 2)))
    local rect = rectangle.new(rectangle_pos.x, rectangle_pos.y, self.hitbox.x, self.hitbox.y)

    if half then
        rect.height = rect.height / 3 -- Not half I know
    end
    return rect
end

function Actor:canMove(axis, step, halfHitbox, canKill)
    local prevPos = { x = self.position.x, y = self.position.y }
    self.position[axis] = prevPos[axis] + step

    -- Check if there is more wall upward so actor can go up or down
    if axis == "y" and self.grabbingWall and not self.wallJumped and not self.dashing then
        if step > 0 then
            self.position.y = self.position.y - (self.hitbox.y / 2)
        end
        if step < 0 then
            self.position.y = self.position.y - (self.hitbox.y / 2)
        end
        if not self:isTouchingWall() then
            self.position = prevPos
            return false
        end
        self.position[axis] = prevPos[axis] + step
    end


    for i=1, #physicsworld.solids do
        local colliding = rectangle.checkCollision(self:getRect(halfHitbox), physicsworld.solids[i]:getRect())

        if colliding then
            if physicsworld.solids[i].tag == "Hurt" and canKill and not self.dead then
                self.dead = true
                self:onKill()
            end
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
    while (dest.x ~= self.position.x and self:canMove("x", stepX, false, true)) do
        self.position.x = self.position.x + stepX
        moved = true
    end

    if (self.position.x ~= dest.x) then
        self.velocity.x = 0
        collided = true
    end

    -- Move in y axis
    while (dest.y ~= self.position.y and self:canMove("y", stepY, false, true)) do
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
    return (not self:canMove("x", 1, true)) or (not self:canMove("x", -1, true))
end

function Actor:update()
    self.wantToGo = vector.new(0, 0)
    local collided = self:moveAndCollide(vector.add(self.position, vector.scale(self.velocity, love.timer.getDelta())))

    self.timeSinceLastTimeOnGround = love.timer.getTime() - self.lastTimeIsOnGround
    self.timeSinceLastJumped = love.timer.getTime() - self.lastTimeJumped

    if (not self.dashing and not self.grabbingWall or self.wallJumped) then
        -- Gravity Acceleration
        if vector.length(vector.subtract(self.velocity, self.gravity)) > self.maxgravitypull then
            self.velocity = vector.add(self.velocity, vector.scale(self.gravity, love.timer.getDelta()))
        end

        -- Resistance
        self.velocity.x = self.velocity.x / (1+love.timer.getDelta()*100)
    end

    if self.velocity.y >=0  then
        self.wallJumped = false
    end

    if self.dashing then
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

    if not self:isTouchingWall() then
        self.grabbingWall = false
    end

end

function Actor:jump()
    self.jumpPressedOn = love.timer.getTime()
    if (self.timeSinceLastTimeOnGround < self.cayote_time and self.timeSinceLastJumped > self.cayote_time and not self.dashing) or self.grabbingWall then
        if self.dashing then
            self.dashing = false
        end
        self.lastTimeJumped = love.timer.getTime()

        if self.grabbingWall then
            self.wallJumped = true
            if self.wantToGo.x ~= 0 then
                self:releaseWall()
                if self:canMove("x", self.wantToGo.x, true) then
                    self.velocity = vector.scale(vector.normalize(vector.new(self.wantToGo.x, -1)), self.dashPower)
                else
                    self.velocity = vector.scale(vector.normalize(vector.new(-self.wantToGo.x, -1)), self.dashPower)
                end
                
                return
            end
        end
        self.velocity.y = -self.jumpforce
    end
end

function Actor:walkRight()
    self.wantToGo.x = 1

    if self.velocity.x < self.maxwalkvel and not self.dashing and not self.grabbingWall then
        self.velocity.x = self.velocity.x + self.walkaccel
    end
end

function Actor:walkLeft()
    self.wantToGo.x = -1

    if self.velocity.x > -self.maxwalkvel and not self.dashing and not self.grabbingWall then
        self.velocity.x = self.velocity.x - self.walkaccel
    end
end

function Actor:climbUp()
    self.wantToGo.y = -1

    if (self.grabbingWall and not self.dashing) then
        self.velocity.y = -self.climbUpSpeed
    end
end

function Actor:climbDown()
    self.wantToGo.y = 1

    local canGoDown = false
    self.position.y = self.position.y + self.hitbox.y

    canGoDown = self:isTouchingWall()

    self.position.y = self.position.y - self.hitbox.y

    if (self.grabbingWall and not self.dashing) then
        self.velocity.y = self.climbDownSpeed
    end
end

function Actor:dash()
    if self.onGroundAfterDash and (self.wantToGo.x ~= 0 or self.wantToGo.y ~= 0) then
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
    if self:isTouchingWall() then
        if not self.dashing and self.wantToGo.y == 0 and not self.wallJumped then
            self.velocity = vector.new(0,0)
        end
        self.grabbingWall = true
    end
end

function Actor:releaseWall()
    self.grabbingWall = false
end

return Actor