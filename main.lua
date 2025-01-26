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
local SmallShot = require("smallShot") -- awww
local BigShot = require("bigShot") -- awww
local Button, Screens = require("button")

function love.load()
	Bullet.loadAssets()
	SmallShot.loadAssets()
	BigShot.loadAssets()
	SmallShooter.loadAssets()
	BigShooter.loadAssets()
	Walker.loadAssets()
	Flyer.loadAssets()
	Jumper.loadAssets()
	Bubble.loadAssets()
	Button.load()
	Player:loadAssets()
	Map:load()
	background = love.graphics.newImage("assets/background-1200x720.png")
	Player:load()
	---carregar coletaveis
	GUI:load()
	-- spawnEntities() -- awww
end

function love.update(dt)
	if Screens.current == "game" then
		updateGame(dt)
		World:update(dt)
		Player:update(dt)
		Collectable.updateAll(dt)
		Spike.updateAll(dt)
		Bullet.updateAll(dt)
		SmallShot.updateAll(dt)
		BigShot.updateAll(dt)
		SmallShooter.updateAll(dt)
		BigShooter.updateAll(dt)
		Walker.updateAll(dt)
		Flyer.updateAll(dt)
		Jumper.updateAll(dt)
		Bubble.updateAll(dt)
		Camera:setPosition(Player.x, 0)
		GUI:update(dt)
		Map:update(dt)
		print(Map.progress)
	end
end

function love.draw()
	if Screens.current == "game" then
		love.graphics.draw(background)
		Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
		Camera:apply()
		Player:draw()
		Collectable.drawAll()
		Spike.drawAll()
		Bullet.drawAll()
		SmallShot.drawAll()
		BigShot.drawAll()
		SmallShooter.drawAll()
		BigShooter.drawAll()
		Walker.drawAll()
		Flyer.drawAll()
		Jumper.drawAll()
		Bubble.drawAll()
		Camera:clear()
		GUI:draw()
	end
	Button.draw()
end

function love.keypressed(key)
	if key == "space" then
		Player:jump()
	elseif key == "1" then
		Player:castBubble(1)
	elseif key == "2" then
		Player:castBubble(2)
	elseif key == "3" then
		Player:castBubble(3)	
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
	if SmallShot.beginContact(a, b, collision) then return end
	if BigShot.beginContact(a, b, collision) then return end
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end

function changeScreen()

end

