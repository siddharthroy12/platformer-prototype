local vector = require "math/vector"
local Actor = require "physics/actor"
local jumpButtonWasDownInPreviousFrame = false

player = {
    actor = nil
}

player.init = function()
    player.actor = Actor:new(vector.new(32*2,32*2))
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
    player.actor:update()

    if love.keyboard.isDown("right") then
        player.actor:walkLeft()
    end
    if love.keyboard.isDown("left") then
        player.actor:walkRight()
    end

    if love.keyboard.isDown("space") then
        if not jumpButtonWasDownInPreviousFrame then
            player.actor:jump()
        end
        jumpButtonWasDownInPreviousFrame = true
    else
        jumpButtonWasDownInPreviousFrame = false
    end

end