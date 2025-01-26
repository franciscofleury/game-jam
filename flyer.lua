local Flyer = {}
Flyer.__index = Flyer
local Player = require("player")
local Bullet = require("bullet") 
local STI = require("sti")

local ActiveFlyers = {}

function Flyer.removeAll()
   for i,v in ipairs(ActiveFlyers) do
      v.physics.body:destroy()
   end

   ActiveFlyers = {}
end

function Flyer.new(x,y, x_speed, y_speed)
   local instance = setmetatable({}, Flyer)
   instance.x = x
   instance.y = y

   instance.state = "fly"
   instance.hp = 2

    if x_speed < 0 then
        instance.side = -1
    else
        instance.side = 1
    end
    instance.x_vel = x_speed

    if y_speed < 0 then
        instance.y_side = -1
    else
        instance.y_side = 1
    end
    instance.y_vel = y_speed

   instance.animation = {timer = 0, rate = 0.3}
   instance.animation.fly = {total = 8, current = 1, img = Flyer.flyAnim}
   instance.animation.die = {total = 12, current = 1, img = Flyer.dieAnim}
   instance.animation.draw = instance.animation.fly.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "kinematic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   table.insert(ActiveFlyers, instance)
end

function Flyer.loadAssets()
   Flyer.flyAnim = {}
   for i=1,8 do
      Flyer.flyAnim[i] = love.graphics.newImage("assets/enemies/flyer/standard/standard"..i..".png")
   end

   Flyer.dieAnim = {}
   for i=1,12 do
      Flyer.dieAnim[i] = love.graphics.newImage("assets/enemies/flyer/dying/dying"..i..".png")
   end

   Flyer.width = Flyer.flyAnim[1]:getWidth()
   Flyer.height = Flyer.flyAnim[1]:getHeight()
   Flyer.map = STI("map/1.lua", {"box2d"})
end

function Flyer:update(dt)
   self:animate(dt)
   if self.state == "fly" then
      self:syncPhysics()
   end
end

function Flyer:changeSide()
   --confere se o Flyer bate em algum dos sensores do tiled
   for _, sensor in ipairs(Flyer.map.layers.sensors.objects) do
      if sensor.type == "flyer_sensor" then
         if self.x + self.width > sensor.x and self.x < sensor.x + sensor.width then
            if self.y + self.height > sensor.y and self.y < sensor.y + sensor.height then
                self.side = self.side * -1
                self.y_side = self.y_side * -1
            end
         end
      end
   end
end

function Flyer:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self:changeSide()
   self.physics.body:setLinearVelocity(self.x_vel * self.side, self.y_vel * self.y_side)
end

function Flyer:changeAnimationConfigs(new_state, new_current)
   self.state = new_state
   self.animation[new_state].current = new_current
end

function Flyer:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Flyer:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        if self.state == "die" then
            self:remove()
        end
    anim = self.animation[self.state]
    anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Flyer:remove()
    for i, instance in ipairs(ActiveFlyers) do
        if instance == self then
            table.remove(ActiveFlyers, i)
        end
    end
end

function Flyer:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.side, 1, self.width / 2, self.height / 2)
end

function Flyer.updateAll(dt)
    for i,instance in ipairs(ActiveFlyers) do
        instance:update(dt)
    end
end

function Flyer.drawAll()
   for i,instance in ipairs(ActiveFlyers) do
      instance:draw()
   end
end

function Flyer:takeDamage()
   self.hp = self.hp - 1
   if self.hp == 0 then
      self:die()
   end
end

function Flyer:die()
   self.state = "die"
   self.animation.rate = 0.05
   self.physics.body:destroy()
end


function Flyer.beginContact(a, b, collision)
   -- Check if collision involves Flyer
   for i, instance in ipairs(ActiveFlyers) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            -- Player collided with Flyer
            Player:takeDamage(1)
         end
      end
   end

   -- Check if collision involves Bullet and Flyer
   for i, bullet in ipairs(Bullet.ActiveBullets) do
      if a == bullet.physics.fixture or b == bullet.physics.fixture then
         for i, instance in ipairs(ActiveFlyers) do
            if a == instance.physics.fixture or b == instance.physics.fixture then
               bullet:destroy()
               instance:takeDamage(1)
               break
            end
         end
      end
   end
end


return Flyer