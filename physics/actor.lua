require "settings"
local vector = require "math/vector"
local rectangle = require "math/rectangle"
local physicsworld = require "physics/phyiscsworld"
local Actor = {}

function Actor:new(position)
    local o = {
        position = position or {x=50, y=50}, -- Origin in center
        velocity = {x=0, y=0},
        hitbox = {x = -16, y = -14, width=32, height=28}, -- Relative to origin
        -- To detect wall touch
        leftWallTouchHitbox = {x = -17, y = -14, width=1, height=1},
        rightWallTouchHitbox = {x = 16, y = -14, width=1, height=1},
        gravity = {x = 0, y = 1500},
        jumpforce = 450,
        jumpPressedOn = 0, -- When the jump button was pressed
        earlyJumpTime = 0.2, -- If jump button is pressed this early then jump
        lastTimeJumped = 0, -- When the actor jumped last time
        cayote_time = 0.2, -- If this much seconds or less have passed since leaving the floor then can jump
        walkaccel = 130,
        maxwalkvel = 250, -- Cannot walk faster than this
        maxFallSpeed = 550, -- Cannot fall faster than this
        lastTimeIsOnGround = 0, -- When the actor was on ground last time
        wantToGo = { x = 0, y = 0}, -- Where the controller is pointing at
        dashPower = 550,
        dashDuration = 0.1,
        dashing = false,
        dashStartedAt = 0, -- When the dashing started
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

-- Get hitbox rect in global postion
function Actor:getGlobalHitboxRect(hitbox)
    local rectangle_pos = (vector.add(self.position, hitbox))
    local rect = rectangle.new(rectangle_pos.x, rectangle_pos.y, hitbox.width, hitbox.height)

    return rect
end

-- Check if actor can move in said direction
function Actor:canMove(axis, step, canKill)
    -- First move then actor to the direction then check if colliding if yes then move back
    local prevPos = { x = self.position.x, y = self.position.y }
    self.position[axis] = prevPos[axis] + step

    -- Collide with world border (left and right)
    if (self.position.x - (self.hitbox.x / 2) < 0 or self.position.x + (self.hitbox.x / 2) > CANVAS_WIDTH) then
        self.position = prevPos
        return false
    end

    for i=1, #physicsworld.solids do
        local colliding = rectangle.checkCollision(self:getGlobalHitboxRect(self.hitbox), physicsworld.solids[i]:getGlobalHitboxRect())
        
        -- Spikes kills
        if physicsworld.solids[i].tag == "Hurt" and canKill and not self.dead and colliding then
            self.dead = true
            self:onKill()
        end

        -- If collided with solid blocks then return true
        if colliding and physicsworld.solids[i].tag ~= "Hurt" then
            self.position = prevPos
            return false
        end
    end

    self.position = prevPos

    -- If we are grabbing wall then we also want to check if we can climb up
    if self.grabbingWall and not self.wallJumped and not self.dashing then
        return self:canClimb(step)
    else
        return true
    end
  
end


-- Check if actor can climb in said direction
function Actor:canClimb(step)
    -- First move then actor to the direction then check if colliding if yes then move back
    local prevPos = { x = self.position.x, y = self.position.y }
    self.position['y'] = prevPos['y'] + step

    for i=1, #physicsworld.solids do
        local collidingLeft = rectangle.checkCollision(self:getGlobalHitboxRect(self.leftWallTouchHitbox), physicsworld.solids[i]:getGlobalHitboxRect())
        local collidingRight = rectangle.checkCollision(self:getGlobalHitboxRect(self.rightWallTouchHitbox), physicsworld.solids[i]:getGlobalHitboxRect())
        
        -- If collided with solid blocks then return true
        if (collidingLeft or collidingRight) and physicsworld.solids[i].tag ~= "Hurt" then
            self.position = prevPos
            return true
        end
    end

    self.position = prevPos
    return false
end


-- Move actor in the direction of velocity and collide with walls
function Actor:moveAndCollide(dest)
    -- This calculation is needed because position and velocity is always in integer
    -- and without this the left direction speed will be higher than the right (or maybe the opposite way i don't remember)
    dest.x = math.floor(dest.x+0.5)
    dest.y = math.floor(dest.y+0.5)

    local prevVel = {x=self.velocity.x, y=self.velocity.y}

    local stepX = (dest.x > self.position.x) and 1 or -1
    local stepY = (dest.y > self.position.y) and 1 or -1

    local moved = false
    local collided = false
    
    -- Move in x axis
    while (dest.x ~= self.position.x and self:canMove("x", stepX, true)) do
        self.position.x = self.position.x + stepX
        moved = true
    end

    -- If collided then set x velocity to zero
    if (self.position.x ~= dest.x) then
        self.velocity.x = 0
        collided = true
    end

    -- Move in y axis
    while (dest.y ~= self.position.y and self:canMove("y", stepY, true)) do
        self.position.y = self.position.y + stepY
        moved = true
    end

    -- If collided then set y velocity to zero
    if (self.position.y ~= dest.y) then
        -- If the actor is sandwitched between blocks vertically and tries to jump then it keeps jumping
        -- To fix it this line is needed
        self.jumpPressedOn = 0

        self.velocity.y = 0
        collided = true
    end

    -- If we are inside the block to being with then move freely
    -- Not needed unless the player is placed inside a block which should never happen
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

function Actor:isWallOnLeft()
    for i=1, #physicsworld.solids do
        local colliding = rectangle.checkCollision(self:getGlobalHitboxRect(self.leftWallTouchHitbox), physicsworld.solids[i]:getGlobalHitboxRect())
       
        if colliding and physicsworld.solids[i].tag ~= "Hurt" then
            return true
        end
    end

    return false
end

function Actor:isWallOnRight()
    for i=1, #physicsworld.solids do
        local colliding = rectangle.checkCollision(self:getGlobalHitboxRect(self.rightWallTouchHitbox), physicsworld.solids[i]:getGlobalHitboxRect())
       
        if colliding and physicsworld.solids[i].tag ~= "Hurt" then
            return true
        end
    end

    return false
end

function Actor:isTouchingWall()
    return self:isWallOnLeft() or self:isWallOnRight()
end

function Actor:update()
    -- If dead then not move at all
    if self.dead then
        return
    end

    self.wantToGo = vector.new(0, 0)

    -- Move and check if collided
    local collided = self:moveAndCollide(vector.add(self.position, vector.scale(self.velocity, love.timer.getDelta())))

    self.timeSinceLastTimeOnGround = love.timer.getTime() - self.lastTimeIsOnGround
    self.timeSinceLastJumped = love.timer.getTime() - self.lastTimeJumped

    -- If we are not dashing, grabbing wall or just jumped from wall then we can apply
    -- gravity and resistance
    if (not self.dashing and not self.grabbingWall or self.wallJumped) then
        -- Gravity Acceleration
        self.velocity = vector.add(self.velocity, vector.scale(self.gravity, love.timer.getDelta()))

        if self.velocity.y > self.maxFallSpeed then
            self.velocity.y = self.maxFallSpeed
        end
        
        -- Resistance
        self.velocity.x = self.velocity.x / (1+love.timer.getDelta()*100)
    end

    -- Jump ends when the velocity is downwards
    if self.velocity.y >=0  then
        self.wallJumped = false
    end

    -- Stop dash after certain amout of time
    if self.dashing then
        if (love.timer.getTime() - self.dashStartedAt >= self.dashDuration) then
            self:stopDash()
        end
    end
    
    -- Handle jump
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
                if self:isWallOnLeft() then
                    self.velocity = vector.scale(vector.normalize(vector.new(1, -1)), self.dashPower)
                else
                    self.velocity = vector.scale(vector.normalize(vector.new(-1, -1)), self.dashPower)
                end
            else
                self.velocity.y = -self.jumpforce
            end
        else
            self.velocity.y = -self.jumpforce
        end
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

    if (self.grabbingWall and not self.dashing and not self.wallJumped) then
        self.velocity.y = -self.climbUpSpeed
    end
end

function Actor:climbDown()
    self.wantToGo.y = 1

    if (self.grabbingWall and not self.dashing and not self.wallJumped) then
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