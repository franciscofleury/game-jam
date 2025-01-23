
-- PARAMS
local player_speed = 100

-- PLAYER VARIABLES
local initial_player_position = {x=400,y=400}
local player_position = {x=400, y=400}

-- GAME VARIABLES
local level1 = {}
local pressed_keys = {a=false,w=false,s=false,d=false}

function newMapObj(x, y, w, h)
    local position = {x=x,y=y}

    local obj = {}

    obj.draw = function ()
        love.graphics.rectangle("fill", position.x - (player_position.x - initial_player_position.x), position.y - (player_position.y - initial_player_position.y), w, h)
    end

    obj.update = function ()
        position = position + 5
    end

    return obj
end

function love.load()
    table.insert(level1, newMapObj(50,50,20,20))
    table.insert(level1, newMapObj(200,70, 500, 300))
end

function love.update(dt)
    for key, pressed in pairs(pressed_keys) do
        if key == "a" and pressed then
            player_position.x = player_position.x - (player_speed * dt)
        elseif key == "d" and pressed then
            player_position.x = player_position.x + (player_speed * dt)
        elseif key == "w" and pressed then
            player_position.y = player_position.y - (player_speed * dt)
        elseif key == "s" and pressed then
            player_position.y = player_position.y + (player_speed * dt)
        end
    end
end

function love.draw()
    love.graphics.circle("fill", initial_player_position.x, initial_player_position.y, 20)

    for idx, obj in ipairs(level1) do
        obj.draw()
    end
end

function love.keypressed(key)
    if pressed_keys[key] ~= nil then
        pressed_keys[key] = true
    end
end

function love.keyreleased(key)
    if pressed_keys[key] ~= nil then
        pressed_keys[key] = false
    end
end