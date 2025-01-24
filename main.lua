local STI = require("sti")
require("player")
love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
	Map = STI("map/1.lua", {"box2d"})
	World = love.physics.newWorld(0,0)
	World:setCallbacks(beginContact, endContact)
	Map:box2d_init(World)
	Map.layers.solid.visible = false
	background = love.graphics.newImage("assets/background-1200x720.png")
	Player:load()
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
end

function love.draw()
	love.graphics.draw(background)
	Map:draw(0, 0, 3.5, 3.5)
	love.graphics.push()
	love.graphics.scale(3.5,3.5)
	Player:draw()

	love.graphics.pop()
end

function love.keypressed(key)
	if key == "w" then
		Player:jump()
	end
end

function beginContact(a, b, collision)
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end