local vector = require "math/vector"
local Actor = require "physics/actor"
local jumpButtonWasDownInPreviousFrame = false
local dashButtonWasDownInPreviousFrame = false

player = {
    actor = nil
}

player.init = function()
    player.actor = Actor:new(vector.new(32*5,32*5))
end


player.draw = function()
    love.graphics.setColor(1,1,1)

    transformed_hitbox = {x= player.actor.hitbox.x, y=player.actor.hitbox.y}
    transformed_hitbox = vector.add(player.actor.hitbox, {y=math.max(1, math.abs(player.actor.velocity.y / 100)), x=-math.max(1, math.abs(player.actor.velocity.y / 100))})
    transformed_hitbox = vector.add(transformed_hitbox, {y=math.max(1, -math.abs(player.actor.velocity.x / 80)), x=math.max(1, math.abs(player.actor.velocity.x / 80))})

    rectangle_pos = (vector.subtract(player.actor.position, vector.divide(transformed_hitbox, 2)))
    love.graphics.rectangle("fill", rectangle_pos.x, rectangle_pos.y,transformed_hitbox.x, transformed_hitbox.y)
end



player.update = function()
    if love.keyboard.isDown("d") then
        player.actor:walkRight()
    end

    if love.keyboard.isDown("a") then
        player.actor:walkLeft()
    end

    if love.keyboard.isDown("w") then
        player.actor:climbUp()
    end

    if love.keyboard.isDown("s") then
        player.actor:climbDown()
    end

    if love.keyboard.isDown("q") then
        player.actor:grabWall()
    else
        player.actor:releaseWall()
    end

    if love.keyboard.isDown("c") then
        if not dashButtonWasDownInPreviousFrame then
            player.actor:dash()
        end
        dashButtonWasDownInPreviousFrame = true
    else
        dashButtonWasDownInPreviousFrame = false
    end


    if love.keyboard.isDown("space") then
        if not jumpButtonWasDownInPreviousFrame then
            player.actor:jump()
        end
        jumpButtonWasDownInPreviousFrame = true
    else
        jumpButtonWasDownInPreviousFrame = false
    end

    player.actor:update()


end