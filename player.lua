local vector = require "math/vector"
local Actor = require "physics/actor"
local controls = require "controls"

player = {
    actor = nil
}

player.init = function(position)
    player.actor = Actor:new(position)
end

player.draw = function()
    love.graphics.setColor(1,1,1)

    transformed_hitbox = {x= player.actor.hitbox.width, y=player.actor.hitbox.height}
    transformed_hitbox = vector.add({x= player.actor.hitbox.width, y=player.actor.hitbox.height}, {y=math.max(1, math.abs(player.actor.velocity.y / 100)), x=-math.max(1, math.abs(player.actor.velocity.y / 100))})
    transformed_hitbox = vector.add(transformed_hitbox, {y=math.max(1, -math.abs(player.actor.velocity.x / 80)), x=math.max(1, math.abs(player.actor.velocity.x / 80))})

    rectangle_pos = (vector.subtract(player.actor.position, vector.divide(transformed_hitbox, 2)))
    love.graphics.rectangle("fill", rectangle_pos.x, rectangle_pos.y,transformed_hitbox.x, transformed_hitbox.y)

end

player.drawHitbox = function()
    love.graphics.setColor(1,0,0)
    local rect = player.actor:getGlobalHitboxRect(player.actor.rightWallTouchHitbox)

    love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height)
end

player.update = function()

    -- Keyboard controls
    if controls.isRightDown() then
        player.actor:walkRight()
    end

    if controls.isLeftDown() then
        player.actor:walkLeft()
    end

    if controls.isUpDown() then
        player.actor:climbUp()
    end

    if controls.isDownDown() then
        player.actor:climbDown()
    end

    if controls.isGrabDown() then
        player.actor:grabWall()
    else
        player.actor:releaseWall()
    end

    if controls.isDashPressed() then
       player.actor:dash()
    end

    if controls.isJumpPressed() then
        player.actor:jump()
    end

    player.actor:update()
end