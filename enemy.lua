

local SmallShooter = {}
SmallShooter.__index = SmallShooter
local Player = require("player")

local ActiveSmallShooters = {}

function SmallShooter.removeAll()
   for i,v in ipairs(ActiveSmallShooters) do
      v.physics.body:destroy()
   end

   ActiveSmallShooters = {}
end

function SmallShooter.new(x,y)
   local instance = setmetatable({}, SmallShooter)
   instance.x = x
   instance.y = y
   instance.offsetY = -8
   instance.r = 0

   instance.speed = 100
   instance.speedMod = 1
   instance.xVel = instance.speed

   instance.rageCounter = 0
   instance.rageTrigger = 3

   instance.damage = 1

   instance.state = "still"

   instance.animation = {timer = 0, rate = 0.1}
   instance.animation.still = {total = 4, current = 1, img = SmallShooter.stillAnim}
   instance.animation.shoot = {total = 4, current = 1, img = SmallShooter.shootAnim}
   instance.animation.draw = instance.animation.shoot.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveSmallShooters, instance)
end

function SmallShooter.loadAssets()
   SmallShooter.stillAnim = {}
   for i=1,4 do
      SmallShooter.stillAnim[i] = love.graphics.newImage("assets/enemies/cactus_small_shooter/cactus_standard"..i..".png")
   end

   SmallShooter.walkAnim = {}
   for i=1,4 do
      SmallShooter.walkAnim[i] = love.graphics.newImage("assets/enemies/shoot/"..i..".png")
   end

   SmallShooter.width = SmallShooter.stillAnim[1]:getWidth()
   SmallShooter.height = SmallShooter.stillAnim[1]:getHeight()
end

function SmallShooter:update(dt)
   self:syncPhysics()
   self:animate(dt)
end

function SmallShooter:incrementRage()
   self.rageCounter = self.rageCounter + 1
   if self.rageCounter > self.rageTrigger then
      self.state = "still"
      self.speedMod = 3
      self.rageCounter = 0
   else
      self.state = "shoot"
      self.speedMod = 1
   end
end

function SmallShooter:flipDirection()
   self.xVel = -self.xVel
end

function SmallShooter:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function SmallShooter:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function SmallShooter:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel * self.speedMod, 100)
end

function SmallShooter:draw()
   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function SmallShooter.updateAll(dt)
   for i,instance in ipairs(ActiveSmallShooters) do
      instance:update(dt)
   end
end

function SmallShooter.drawAll()
   for i,instance in ipairs(ActiveSmallShooters) do
      instance:draw()
   end
end

function SmallShooter.beginContact(a, b, collision)
   for i,instance in ipairs(ActiveSmallShooters) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(instance.damage)
         end
         instance:incrementRage()
         instance:flipDirection()
      end
   end
end

return SmallShooter