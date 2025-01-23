-- object.lua

local Object = {}

function Object.newRectangle(x, y, width, height)
    local rect = {
		type = "rectangle",
        position = {x = x, y = y},
        width = width, 
		height = height
    }

    function rect.draw(player_position, initial_player_position)
        love.graphics.rectangle(
            "fill",
            rect.position.x - (player_position.x - initial_player_position.x),
            rect.position.y - (player_position.y - initial_player_position.y),
            rect.width,
            rect.height
        )
    end

    return rect
end

function Object.newCircle(x, y, radius)
    local circle = {
		type = "circle",
        position = {x = x, y = y},
        radius = radius
    }

    function circle.draw(player_position, initial_player_position)
        love.graphics.circle(
            "fill",
            circle.position.x - (player_position.x - initial_player_position.x),
            circle.position.y - (player_position.y - initial_player_position.y),
            circle.radius
        )
    end

    return circle
end

return Object