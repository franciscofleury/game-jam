love.graphics.setDefaultFilter("nearest", "nearest")
local STI = require("sti")
local Player = require("player")
local Camera = require("camera")
local Collectable = require("collectable")
local Spike = require("spike")
local Bubble = require("bubble")
local GUI = require("gui")

function love.load()
	Map = STI("map/1.lua", {"box2d"})
	World = love.physics.newWorld(0,2000)
	World:setCallbacks(beginContact, endContact)
	Map:box2d_init(World)
	Map.layers.solid.visible = false
	Map.layers.entity.visible = false
	MapWidth = Map.layers.ground.width * 16
	background = love.graphics.newImage("assets/background-1200x720.png")
	Player:load()
	---carregar coletaveis
	Bubble.new(100, 300, 3)
	GUI:load()
	spawnEntities()
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
	Collectable.updateAll(dt)
	Spike.updateAll(dt)
	Bubble.updateAll(dt)
	Camera:setPosition(Player.x, 0)
	GUI:update(dt)
end

function love.draw()
	love.graphics.draw(background)
	Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
	Camera:apply()
	Player:draw()
	Collectable.drawAll()
	Spike.drawAll()
	Bubble.drawAll()
	Camera:clear()
	GUI:draw()
end

function love.keypressed(key)
	if key == "w" then
		Player:jump()
	end
end

function beginContact(a, b, collision)
	if Collectable.beginContact(a, b, collision) then return end
	if Spike.beginContact(a, b, collision) then return end
	if Bubble.beginContact(a, b, collision) then return end
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end

function spawnEntities()
	for i,v in ipairs(Map.layers.entity.objects) do
		if v.type == "spike" then
			Spike.new(v.x - v.width/2, v.y - v.height/2)
		elseif v.type == "fuel" then
			Collectable.new(v.x - v.width/2, v.y - v.height/2)
		end
	end
end

