love.graphics.setDefaultFilter("nearest", "nearest")
local STI = require("sti") -- awww
local Player = require("player")
local Bubble = require("bubble")
local Bullet = require("bullet")
local GUI = require("gui")
local Camera = require("camera")
local Spike = require("spike") -- awww
local Collectable = require("collectable") -- awww
local SmallShooter = require("smallShooter") -- awww
local BigShooter = require("bigShooter") -- awww
local Walker = require("walker") -- awww
local Flyer = require("flyer") -- awww
local Jumper = require("jumper") -- awww
local Map = require("map")

function love.load()
	Bullet.loadAssets()
	SmallShooter.loadAssets()
	BigShooter.loadAssets()
	Walker.loadAssets()
	Flyer.loadAssets()
	Jumper.loadAssets()
	Bubble.loadAssets()
	Map:load()
	-- Map = STI("map/1.lua", {"box2d"}) -- awww
	-- World = love.physics.newWorld(0,2000) -- awww
	-- World:setCallbacks(beginContact, endContact) -- awww
	-- Map:box2d_init(World) -- a
	-- Map.layers.solid.visible = false -- awww
	-- Map.layers.entity.visible = false -- awww
	-- MapWidth = Map.layers.ground.width * 16 -- awww
	background = love.graphics.newImage("assets/background-1200x720.png")
	Player:load()
	---carregar coletaveis
	GUI:load()
	-- spawnEntities() -- awww
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
	Collectable.updateAll(dt)
	Spike.updateAll(dt)
	Bullet.updateAll(dt)
	SmallShooter.updateAll(dt)
	BigShooter.updateAll(dt)
	Walker.updateAll(dt)
	Flyer.updateAll(dt)
	Jumper.updateAll(dt)
	Bubble.updateAll(dt)
	Camera:setPosition(Player.x, 0)
	GUI:update(dt)
	Map:update(dt)
end

function love.draw()
	love.graphics.draw(background)
	Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
	-- Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
	Camera:apply()
	Player:draw()
	Collectable.drawAll()
	Spike.drawAll()
	Bullet.drawAll()
	SmallShooter.drawAll()
	BigShooter.drawAll()
	Walker.drawAll()
	Flyer.drawAll()
	Jumper.drawAll()
	Bubble.drawAll()
	Camera:clear()
	GUI:draw()
end

function love.keypressed(key)
	if key == "w" then
		Player:jump()
	elseif key == "space" then
		Player:castBubble()
	elseif key == "r" then
		Player:shoot()
	elseif key == "c" then
		Player:useShield()
	end
end

function beginContact(a, b, collision)
	if SmallShooter.beginContact(a, b, collision) then return end
	if BigShooter.beginContact(a, b, collision) then return end
	if Walker.beginContact(a, b, collision) then return end
	if Flyer.beginContact(a, b, collision) then return end
	if Jumper.beginContact(a, b, collision) then return end
	if Collectable.beginContact(a, b, collision) then return end
	if Spike.beginContact(a, b, collision) then return end
	if Bubble.beginContact(a, b, collision) then return end
	if Bullet.beginContact(a, b, collision) then return end
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end

-- function spawnEntities()
-- 	for i,v in ipairs(Map.layers.entity.objects) do
-- 		if v.type == "spike" then
-- 			Spike.new(v.x - v.width/2, v.y - v.height/2)
-- 		elseif v.type == "fuel" then
-- 			Collectable.new(v.x - v.width/2, v.y - v.height/2)
-- 		elseif v.type == "small_shooter" then
-- 			SmallShooter.new(v.x - v.width/2, v.y - v.height/2, 5, 1)
-- 		elseif v.type == "big_shooter" then
-- 			BigShooter.new(v.x - v.width/2, v.y - v.height/2, 5, 1)
-- 		elseif v.type == "walker" then
-- 			Walker.new(v.x - v.width/2, v.y - v.height/2, 50)
-- 		elseif v.type == "flyer" then
-- 			Flyer.new(v.x - v.width/2, v.y - v.height/2, v.properties.x_vel, v.properties.y_vel)
-- 		elseif v.type == "jumper" then
-- 			Jumper.new(v.x - v.width/2, v.y - v.height/2, 6, -30)
-- 		end
-- 	end
-- end

