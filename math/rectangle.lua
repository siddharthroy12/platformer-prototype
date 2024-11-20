local rectangle = {}

rectangle.new = function(x, y, width, height)
    return {x = x, y = y, width = width, height = height}
end

rectangle.checkCollision = function(rec1, rec2)
    return rec1.x < rec2.x + rec2.width and rec1.x + rec1.width > rec2.x and
    rec1.y < rec2.y + rec2.height and rec1.y + rec1.height > rec2.y
end

return rectangle
