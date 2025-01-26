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
    self.progress = self:loadSave()
	World = love.physics.newWorld(0,2000)
	World:setCallbacks(beginContact, endContact)
    self:loadSave()
    self:init(1, 1)
end

function Map:init(current_level, current_sub_level)
    self.current_level = current_level
    self.current_sub_level = current_sub_level
    self.level = STI("map/"..self.current_level.."-"..self.current_sub_level..".lua", {"box2d"})
	self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity
	self.solidLayer.visible = false
	self.entityLayer.visible = false
	MapWidth = self.groundLayer.width * 20
    self:spawnEntities()
end

function Map:next()
    self:clean()
	self.current_sub_level = self.current_sub_level + 1
    if 3 < self.current_sub_level then
        self:endLevel()
        return
    end
    self:init(self.current_level, self.current_sub_level)
    Player:resetPosition()
end

function Map:endLevel()
    self:createSave(self.current_level)
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
    BigShot.removeAll()
end

function Map:update()
    if Player.x > 110*16 - 16 then
        self:next()
    end
end

function Map:createSave(current_level)
    local file = io.open("save.txt", "w")
    if file then
        file:write(current_level)
        file:close()
    else
        print("Erro ao criar o arquivo.")
    end
end

function Map:loadSave()
    local file = io.open("save.txt", "r")
    if file then
        local progress = file:read(1)
        file:close()
        return tonumber(progress)
    else
        return 0
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
			Walker.new(v.x - v.width/2, v.y - v.height/2, 30, self.level)
		elseif v.type == "flyer" then
			Flyer.new(v.x - v.width/2, v.y - v.height/2, v.properties.x_vel, v.properties.y_vel, self.level)
		-- elseif v.type == "jumper" then
		-- 	Jumper.new(v.x - v.width/2, v.y - v.height/2, 6, -30)
		end
	end
end


return Map