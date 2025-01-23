-- physics.lua

local Physics = {}

local GRAVITY_ACCELERATION = 200

function Physics.collision(list1, list2)
    for _, obj1 in pairs(list1) do
        for _, obj2 in pairs(list2) do
            if Physics.checkCollision(obj1, obj2) then
                return true
            end
        end
    end
    return false
end

function Physics.checkCollision(obj1, obj2)

    if obj1.type == "circle" and obj2.type == "circle" then
        return Physics.circleCircleCollision(obj1, obj2)
    elseif obj1.type == "rectangle" and obj2.type == "rectangle" then
        return Physics.rectangleRectangleCollision(obj1, obj2)
    elseif obj1.type == "circle" and obj2.type == "rectangle" then
        return Physics.circleRectangleCollision(obj1, obj2)
    elseif obj1.type == "rectangle" and obj2.type == "circle" then
        return Physics.circleRectangleCollision(obj2, obj1)
    end

    return false
end

function Physics.circleCircleCollision(circle1, circle2)
    local dx = circle1.position.x - circle2.position.x
    local dy = circle1.position.y - circle2.position.y
    local distance = math.sqrt(dx * dx + dy * dy)

    return distance < (circle1.radius + circle2.radius)
end

function Physics.rectangleRectangleCollision(rect1, rect2)
    return rect1.position.x < rect2.position.x + rect2.width and
           rect1.position.x + rect1.width > rect2.position.x and
           rect1.position.y < rect2.position.y + rect2.height and
           rect1.position.y + rect1.height > rect2.position.y
end

function Physics.circleRectangleCollision(circle, rect)
    local closestX = math.clamp(circle.position.x, rect.position.x, rect.position.x + rect.width)
    local closestY = math.clamp(circle.position.y, rect.position.y, rect.position.y + rect.height)

    local dx = circle.position.x - closestX
    local dy = circle.position.y - closestY

    return (dx * dx + dy * dy) < (circle.radius * circle.radius)
end

function math.clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

function Physics.applyGravity(obj, dt)
	obj.position.y = obj.position.y + GRAVITY_ACCELERATION * obj.mass * dt
end

return Physics