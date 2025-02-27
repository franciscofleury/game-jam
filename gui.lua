local GUI = {}

local Player = require("player")

function GUI:load()
    self.fuel = {}
    self.fuel.scale = 1
    self.fuel.x = 20 --61 e 18
    self.fuel.y = 20
    self.fuel.container = love.graphics.newImage("assets/gui/fuel_container.png")
    self.fuel.container_full = love.graphics.newImage("assets/gui/fuel_container_full.png")
    self.fuel.fuel_bar = love.graphics.newImage("assets/gui/fuel_bar.png")
    self.fuel.init_width = 293 * Player.fuel/Player.max_fuel
    self.fuel.current_width = self.fuel.init_width
    self.fuel.quad_fuel_bar = love.graphics.newQuad(62, 0, self.fuel.current_width, 67, 372, 67)
    self.fuel.width = self.fuel.container:getWidth()
    self.fuel.height = self.fuel.container:getHeight()

end

function lerp(a, b, t)
    return a + (b - a) * t
end


function GUI:update(dt)
    local target_width = 293 * Player.fuel / Player.max_fuel
    self.fuel.current_width = lerp(self.fuel.current_width, target_width, dt * 5)
    self.fuel.quad_fuel_bar:setViewport(62, 0, self.fuel.current_width, 67, 372, 67)
end

function GUI:draw() 
    love.graphics.draw(self.fuel.fuel_bar, self.fuel.quad_fuel_bar, 20 + (62) * 1.2, self.fuel.y, 0, 1.2, 1.2, 0, 0)
    if Player.fuel == 1000 then
        love.graphics.draw(self.fuel.container_full, self.fuel.x, self.fuel.y, 0, 1.2, 1.2, 0, 0)
    else
        love.graphics.draw(self.fuel.container, self.fuel.x, self.fuel.y, 0, 1.2, 1.2, 0, 0)
    end
end

return GUI