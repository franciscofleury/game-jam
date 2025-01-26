local Bullet = {}
Bullet.__index = Bullet

local ActiveBullets = {}

function Bullet.new(x, y, direction)
   local instance = setmetatable({}, Bullet)
   instance.x = x
   instance.y = y
   instance.life = 5

   if direction == "right" then
      instance.x = x + 21
      instance.x_vel = 125
      instance.y_vel = 0
   elseif direction == "left" then
      instance.x = x - 15
      instance.x_vel = -125
      instance.y_vel = 0
   elseif direction == "up" then
      instance.y = y - 10
      instance.x_vel = 0
      instance.y_vel = -125
   elseif direction == "down" then
      instance.y = y + 40
      instance.x_vel = 0
      instance.y_vel = 125
   end

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(10)
   instance.physics.fixture:setRestitution(0.8)
   instance.physics.body:setGravityScale(0)

   table.insert(ActiveBullets, instance)
end

Bullet.ActiveBullets = ActiveBullets

function Bullet:loadAssets()
   Bullet.animation = {timer = 0, rate = 0.3}
   
   Bullet.animation.shoot = {total = 4, current = 1, img = {}}
   for i=1, Bullet.animation.shoot.total do
      Bullet.animation.shoot.img[i] = love.graphics.newImage("assets/bolho/projectile/projectile" .. i .. ".png")
   end
   
   Bullet.animation.draw = Bullet.animation.shoot.img[1]
   Bullet.width = Bullet.animation.draw:getWidth()
   Bullet.height = Bullet.animation.draw:getHeight()
end

function Bullet.removeAll()
   for i,v in ipairs(ActiveBullets) do
      v.physics.body:destroy()
   end

   ActiveBullets = {}
end

function Bullet:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Bullet:setNewFrame()
   local anim = self.animation.shoot
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function Bullet:update(dt)
   self:animate(dt)
   self:syncPhysics()
   self.physics.body:setLinearVelocity(self.x_vel, self.y_vel)
   self.life = self.life - dt
   if self.life <= 0 then
      self:destroy()
   end
end

function Bullet:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
end

function Bullet:destroy()
   for i, bullet in ipairs(ActiveBullets) do
      if bullet == self then
         table.remove(ActiveBullets, i)
         self.physics.body:destroy()
         break
      end
   end
end

function Bullet:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
end

function Bullet.updateAll(dt)
   for i, instance in ipairs(ActiveBullets) do
      instance:update(dt)
   end
end

function Bullet.drawAll()
   for i, instance in ipairs(ActiveBullets) do
      instance:draw()
   end
end

function Bullet.beginContact(a, b, collision)
   for i, instance in ipairs(ActiveBullets) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         instance:destroy()
         return true
      end
   end
end

return Bullet