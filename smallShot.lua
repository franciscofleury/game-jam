local Player = require("player")

local SmallShot = {}
SmallShot.__index = SmallShot

local ActiveSmallShots = {}

function SmallShot.new(x, y, direction)
   local instance = setmetatable({}, SmallShot)
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

   table.insert(ActiveSmallShots, instance)
end

SmallShot.ActiveSmallShots = ActiveSmallShots

function SmallShot:loadAssets()
   SmallShot.animation = {timer = 0, rate = 0.3}
   
   SmallShot.animation.shoot = {total = 3, current = 1, img = {}}
   for i=1, SmallShot.animation.shoot.total do
      SmallShot.animation.shoot.img[i] = love.graphics.newImage("assets/enemies/small_shooter/projectile/projectile" .. i .. ".png")
   end
   
   SmallShot.animation.draw = SmallShot.animation.shoot.img[1]
   SmallShot.width = SmallShot.animation.draw:getWidth()
   SmallShot.height = SmallShot.animation.draw:getHeight()
end

function SmallShot.removeAll()
   for i,v in ipairs(ActiveSmallShots) do
      v.physics.body:destroy()
   end

   ActiveSmallShots = {}
end

function SmallShot:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function SmallShot:setNewFrame()
   local anim = self.animation.shoot
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function SmallShot:update(dt)
   self:animate(dt)
   self:syncPhysics()
   self.physics.body:setLinearVelocity(self.x_vel, self.y_vel)
   self.life = self.life - dt
   if self.life <= 0 then
      self:destroy()
   end
end

function SmallShot:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
end

function SmallShot:destroy()
   for i, SmallShot in ipairs(ActiveSmallShots) do
      if SmallShot == self then
         table.remove(ActiveSmallShots, i)
         self.physics.body:destroy()
         break
      end
   end
end

function SmallShot:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
end

function SmallShot.updateAll(dt)
   for i, instance in ipairs(ActiveSmallShots) do
      instance:update(dt)
   end
end

function SmallShot.drawAll()
   for i, instance in ipairs(ActiveSmallShots) do
      instance:draw()
   end
end

function SmallShot.beginContact(a, b, collision)
   for i, instance in ipairs(ActiveSmallShots) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(1)
         end
         instance:destroy()
         return true
      end
   end
end

return SmallShot