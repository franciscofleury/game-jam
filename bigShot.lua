local Player = require("player")

local BigShot = {}
BigShot.__index = BigShot

local ActiveBigShots = {}

function BigShot.new(x, y, direction)
   local instance = setmetatable({}, BigShot)
   instance.x = x
   instance.y = y
   instance.life = 5

   if direction == "right" then
      instance.x = x + 21
      instance.x_vel = 100
      instance.y_vel = 0
   elseif direction == "left" then
      instance.x = x - 15
      instance.x_vel = -100
      instance.y_vel = 0
   elseif direction == "up" then
      instance.y = y - 10
      instance.x_vel = 0
      instance.y_vel = -100
   elseif direction == "down" then
      instance.y = y + 40
      instance.x_vel = 0
      instance.y_vel = 100
   end

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(10)
   instance.physics.fixture:setRestitution(0.8)
   instance.physics.body:setGravityScale(0)

   table.insert(ActiveBigShots, instance)
end

BigShot.ActiveBigShots = ActiveBigShots

function BigShot:loadAssets()
   BigShot.animation = {timer = 0, rate = 0.3}
   
   BigShot.animation.shoot = {total = 3, current = 1, img = {}}
   for i=1, BigShot.animation.shoot.total do
      BigShot.animation.shoot.img[i] = love.graphics.newImage("assets/enemies/big_shooter/projectile/projectile" .. i .. ".png")
   end
   
   BigShot.animation.draw = BigShot.animation.shoot.img[1]
   BigShot.width = BigShot.animation.draw:getWidth()
   BigShot.height = BigShot.animation.draw:getHeight()
end

function BigShot.removeAll()
   for i,v in ipairs(ActiveBigShots) do
      v.physics.body:destroy()
   end

   ActiveBigShots = {}
end

function BigShot:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function BigShot:setNewFrame()
   local anim = self.animation.shoot
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function BigShot:update(dt)
   self:animate(dt)
   self:syncPhysics()
   self.physics.body:setLinearVelocity(self.x_vel, self.y_vel)
   self.life = self.life - dt
   if self.life <= 0 then
      self:destroy()
   end
end

function BigShot:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
end

function BigShot:destroy()
   for i, BigShot in ipairs(ActiveBigShots) do
      if BigShot == self then
         table.remove(ActiveBigShots, i)
         self.physics.body:destroy()
         break
      end
   end
end

function BigShot:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
end

function BigShot.updateAll(dt)
   for i, instance in ipairs(ActiveBigShots) do
      instance:update(dt)
   end
end

function BigShot.drawAll()
   for i, instance in ipairs(ActiveBigShots) do
      instance:draw()
   end
end

function BigShot.beginContact(a, b, collision)
   for i, instance in ipairs(ActiveBigShots) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage()
         end
         instance:destroy()
         return true
      end
   end
end

return BigShot