-- player.lua
local Physics = require("physics")

local Player = {}

function Player.new(initial_position, speed)
    local self = {
        position = {x = initial_position.x, y = initial_position.y},
        initial_position = {x = initial_position.x, y = initial_position.y},
        speed = speed,
		radius = 20,
		mass = 1,
        pressed_keys = {a = false, w = false, s = false, d = false},
		type = "circle"
    }
    setmetatable(self, {__index = Player})
    return self
end

function Player:update(dt)
	Physics.applyGravity(self, dt)
    for key, pressed in pairs(self.pressed_keys) do
        if key == "a" and pressed then
            self.position.x = self.position.x - (self.speed * dt)
        elseif key == "d" and pressed then
            self.position.x = self.position.x + (self.speed * dt)
        elseif key == "w" and pressed then
            self.position.y = self.position.y - (self.speed * dt)
        elseif key == "s" and pressed then
            self.position.y = self.position.y + (self.speed * dt)
        end
    end
end

function Player:draw()
    love.graphics.circle("fill", self.initial_position.x, self.initial_position.y, self.radius)
end

function Player:keypressed(key)
    if self.pressed_keys[key] ~= nil then
        self.pressed_keys[key] = true
    end
end

function Player:keyreleased(key)
    if self.pressed_keys[key] ~= nil then
        self.pressed_keys[key] = false
    end
end

return Player