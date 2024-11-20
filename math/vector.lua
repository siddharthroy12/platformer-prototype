vector = {}

-- Vector2D structure
vector.new = function(x, y)
    return {x = x, y = y}
end

vector.add = function(v1, v2)
    return {x= v1.x + v2.x, y= v1.y + v2.y}
end

vector.subtract = function(v1, v2)
    return {x= v1.x - v2.x, y= v1.y - v2.y}
end

vector.divide = function(v1, value)
    return {x= v1.x / value, y= v1.y / value}
end

vector.scale = function(v1, value)
    return {x= v1.x * value, y= v1.y * value}
end

vector.length = function (v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

vector.multiply = function(v1, v2)
    return vec2(v1.x * v2.x, v1.y * v2.y)
end

vector.normalize = function(v)
    local length = vec2_length(v)
    if length == 0 then return vec2(0, 0) end
    return vec2_scale(v, 1 / length)
end

return vector