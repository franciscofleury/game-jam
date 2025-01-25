local Bullet = {img = love.graphics.newImage("assets/bubble/bubble.png")}
Bullet.__index = Bullet

Bullet.width = Bullet.img:getWidth()
Bullet.height = Bullet.img:getHeight()

local ActiveBullets = {}

function Bullet.new(x, y)
   local instance = setmetatable({}, Bullet)
   instance.x = x
   instance.y = y
   instance.life = 5  

   instance.x_vel = 80
   instance.y_vel = 0

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(1)
   instance.physics.fixture:setSensor(true)

   table.insert(ActiveBullets, instance)
   return instance
end

function Bullet:update(dt)
   self.physics.body:setLinearVelocity(self.x_vel, self.y_vel)
   self.life = self.life - dt
   if self.life <= 0 then
      self:destroy()
   end
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
   love.graphics.draw(self.img, self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
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

return Bullet