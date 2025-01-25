local GUI = {}

local Player = require("player")

function GUI:load()
    self.fuel = {}
    self.fuel.scale = 1
    self.fuel.x = 20
    self.fuel.y = 20
end

function GUI:update(dt)

end

function GUI:draw()
    love.graphics.setColor({0,0,0})
    self.fuel.img = love.graphics.rectangle("fill", self.fuel.x, self.fuel.y, 300, 40)
    love.graphics.setColor({1,1,1})
    self.fuel.img = love.graphics.rectangle("fill", self.fuel.x, self.fuel.y, 300 * Player.fuel/1000, 40)
end

return GUI