love.graphics.setDefaultFilter("nearest", "nearest")
local STI = require("sti")
local Player = require("player")
local Camera = require("camera")
local Collectable = require("collectable")
local Spike = require("spike")

function love.load()
	Map = STI("map/1.lua", {"box2d"})
	World = love.physics.newWorld(0,0)
	World:setCallbacks(beginContact, endContact)
	Map:box2d_init(World)
	Map.layers.solid.visible = false
	MapWidth = Map.layers.ground.width * 16
	background = love.graphics.newImage("assets/background-1200x720.png")
	Player:load()
	---carregar coletaveis
	Collectable.new(100, 200)
	Spike.new(100,100)
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
	Collectable.updateAll(dt)
	Spike.updateAll(dt)
	Camera:setPosition(Player.x, 0)
end

function love.draw()
	love.graphics.draw(background)
	Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
	Camera:apply()
	Player:draw()
	Collectable.drawAll()
	Spike.drawAll()
	Camera:clear()
end

function love.keypressed(key)
	if key == "w" then
		Player:jump()
	end
end

function beginContact(a, b, collision)
	if Collectable.beginContact(a, b, collision) then return end
	if Spike.beginContact(a, b, collision) then return end
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end