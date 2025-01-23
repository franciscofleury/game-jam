-- main.lua
local Player = require("player")
local Physics = require("physics")
local Object =  require("object")

-- GAME VARIABLES
local level1 = {}
local player


function love.load()
    player = Player.new({x = 150, y = 150}, 100)

    table.insert(level1, Object.newRectangle(100, 500, 500, 300))
end

function love.update(dt)
    player:update(dt)

    if Physics.collision({player}, level1) then
        print("Collision detected!")
    end

end

function love.draw()
    player:draw()

    for _, obj in ipairs(level1) do
        obj.draw(player.position, player.initial_position)
    end
end

function love.keypressed(key)
    player:keypressed(key)
end

function love.keyreleased(key)
    player:keyreleased(key)
end