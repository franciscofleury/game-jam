local Map = {}
local STI = require("sti")
local Spike = require("spike")
local Collectable = require("collectable")
local SmallShooter = require("smallShooter")
local BigShooter = require("bigShooter")
local Bubble = require("bubble")
local Walker = require("walker")
local Flyer = require("flyer")
local Jumper = require("jumper")
local Player = require("player")
local Bullet = require("bullet")
local SmallShot = require("smallShot")
local BigShot = require("bigShot")

function Map:load()
    self.current_level = 1
	World = love.physics.newWorld(0,2000)
	World:setCallbacks(beginContact, endContact)
    self:init()
end

function Map:init()
    self.level = STI("map/"..self.current_level..".lua", {"box2d"})
	self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity
	self.solidLayer.visible = false
	self.entityLayer.visible = false
	MapWidth = self.groundLayer.width * 16
    self:spawnEntities()
end

function Map:next()
    self:clean()
	self.current_level = self.current_level + 1
    self:init()
    Player:resetPosition()
end

function Map:clean()
    self.level:box2d_removeLayer("solid")
    BigShooter.removeAll()
    Bubble.removeAll()
    Bullet.removeAll()
    Collectable.removeAll()
    Flyer.removeAll()
    Jumper.removeAll()
    SmallShooter.removeAll()
    SmallShot.removeAll()
    Spike.removeAll()
    Walker.removeAll()
    -- BigShot.removeAll()
end

function Map:update()
    if Player.x > MapWidth - 16 then
        self:next()
    end
end

function Map:spawnEntities()
	for i,v in ipairs(self.entityLayer.objects) do
		if v.type == "spike" then
			Spike.new(v.x - v.width/2, v.y - v.height/2)
		elseif v.type == "fuel" then
			Collectable.new(v.x - v.width/2, v.y - v.height/2)
		elseif v.type == "small_shooter" then
			SmallShooter.new(v.x - v.width/2, v.y - v.height/2, 5, 1)
		elseif v.type == "big_shooter" then
			BigShooter.new(v.x - v.width/2, v.y - v.height/2, 5, 1)
		elseif v.type == "walker" then
			Walker.new(v.x - v.width/2, v.y - v.height/2, 30)
		elseif v.type == "flyer" then
			Flyer.new(v.x - v.width/2, v.y - v.height/2, v.properties.x_vel, v.properties.y_vel)
		-- elseif v.type == "jumper" then
		-- 	Jumper.new(v.x - v.width/2, v.y - v.height/2, 6, -30)
		end
	end
end


return Map