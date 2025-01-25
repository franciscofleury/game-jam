

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

function SmallShooter.new(x,y, cooldown, shot_speed)
   local instance = setmetatable({}, SmallShooter)
   instance.x = x
   instance.y = y

   instance.state = "still"

   instance.animation = {timer = 0, rate = 0.3}
   instance.animation.still = {total = 4, current = 1, img = SmallShooter.stillAnim}
   instance.animation.shoot = {total = 7, current = 1, img = SmallShooter.shootAnim}
   instance.animation.draw = instance.animation.still.img[1]

   instance.cooldown = cooldown
   instance.cooldown_timer = cooldown - (instance.animation.rate * instance.animation.shoot.total + 0.1)
   instance.shot_speed = shot_speed

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveSmallShooters, instance)
end

function SmallShooter.loadAssets()
   SmallShooter.stillAnim = {}
   for i=1,4 do
      SmallShooter.stillAnim[i] = love.graphics.newImage("assets/enemies/cactus_small_shooter/cactus_standard"..i..".png")
   end

   SmallShooter.shootAnim = {}
   for i=1,4 do
      SmallShooter.shootAnim[i] = love.graphics.newImage("assets/enemies/cactus_small_shooter/cactus_shooting"..i..".png")
   end

   SmallShooter.width = SmallShooter.stillAnim[1]:getWidth()
   SmallShooter.height = SmallShooter.stillAnim[1]:getHeight()
end

function SmallShooter:update(dt)
   self:animate(dt)
   self:countCooldown(dt)
   print(self.cooldown_timer)
end

function SmallShooter:countCooldown(dt)
   if self.cooldown_timer >= self.cooldown then
      --Bullet.new(x, y, side)
      self.cooldown_timer = 0
   elseif self.cooldown_timer >= self.cooldown - self.animation.rate * self.animation.shoot.total then
      self.state = "shoot"
      self.animation.shoot.current = 1
   end
   self.cooldown_timer = self.cooldown_timer + dt
end


function SmallShooter:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function SmallShooter:shoot()

end

function SmallShooter:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      self.state = "still"
      anim = self.animation[self.state]
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function SmallShooter:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, self.r, scaleX, 1, self.width / 2, self.height / 2)
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
            Player:takeDamage(1)
         end
      end
   end
end

return SmallShooter