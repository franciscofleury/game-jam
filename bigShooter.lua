local BigShooter = {}
BigShooter.__index = BigShooter
local Player = require("player")
local Bullet = require("bullet") 

local ActiveBigShooters = {}

function BigShooter.removeAll()
   for i,v in ipairs(ActiveBigShooters) do
      v.physics.body:destroy()
   end

   ActiveBigShooters = {}
end

function BigShooter.new(x,y, cooldown, shot_speed, side)
   local instance = setmetatable({}, BigShooter)
   instance.x = x
   instance.y = y

   instance.state = "still"
   instance.hp = 1
   instance.side = side

   instance.animation = {timer = 0, rate = 0.3}
   instance.animation.still = {total = 6, current = 1, img = BigShooter.stillAnim}
   instance.animation.shoot = {total = 6, current = 1, img = BigShooter.shootAnim}
   instance.animation.die = {total = 11, current = 1, img = BigShooter.dieAnim}
   instance.animation.draw = instance.animation.still.img[1]

   instance.cooldown = cooldown
   instance.cooldown_timer = cooldown - (instance.animation.rate * instance.animation.shoot.total + 0.1)
   instance.shot_speed = shot_speed --n foi implementado ainda

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveBigShooters, instance)
end

function BigShooter.loadAssets()
   BigShooter.stillAnim = {}
   for i=1,6 do
      BigShooter.stillAnim[i] = love.graphics.newImage("assets/enemies/big_shooter/standard/standard"..i..".png")
   end

   BigShooter.shootAnim = {}
   for i=1,6 do
      BigShooter.shootAnim[i] = love.graphics.newImage("assets/enemies/big_shooter/shooting/shooting"..i..".png")
   end

   BigShooter.dieAnim = {}
   for i=1,11 do
      BigShooter.dieAnim[i] = love.graphics.newImage("assets/enemies/big_shooter/dying/dying"..i..".png")
   end

   BigShooter.width = BigShooter.stillAnim[1]:getWidth()
   BigShooter.height = BigShooter.stillAnim[1]:getHeight()
end

function BigShooter:update(dt)
   self:animate(dt)
   self:manageCooldown(dt)
end

function BigShooter:manageCooldown(dt)
   if self.cooldown_timer >= self.cooldown - self.animation.rate * self.animation.shoot.total then
      if self.state == "still" then
         self:changeAnimationConfigs("shoot", 1)
      end
   end
   self.cooldown_timer = self.cooldown_timer + dt
end

function BigShooter:changeAnimationConfigs(new_state, new_current)
   self.state = new_state
   self.animation[new_state].current = new_current
end

function BigShooter:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function BigShooter:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      if self.state == "shoot" then
         self.cooldown_timer = 0
         --Bullet.new(x, y, side)
         self.state = "still"
      elseif self.state == "die" then
         self:remove()
      end
      anim = self.animation[self.state]
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function BigShooter:remove()
   for i, instance in ipairs(ActiveBigShooters) do
      if instance == self then
         table.remove(ActiveBigShooters, i)
      end
   end
end

function BigShooter:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.side, 1, self.width / 2, self.height / 2)
end

function BigShooter.updateAll(dt)
   for i,instance in ipairs(ActiveBigShooters) do
      instance:update(dt)
   end
end

function BigShooter.drawAll()
   for i,instance in ipairs(ActiveBigShooters) do
      instance:draw()
   end
end

function BigShooter:takeDamage()
   self.hp = self.hp - 1
   if self.hp == 0 then
      self:die()
   end
end

function BigShooter:die()
   self.state = "die"
   self.animation.rate = 0.05
   self.physics.body:destroy()
end


function BigShooter.beginContact(a, b, collision)
   -- Check if collision involves BigShooter
   for i, instance in ipairs(ActiveBigShooters) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            -- Player collided with BigShooter
            Player:takeDamage(1)
         end
      end
   end

   -- Check if collision involves Bullet and BigShooter
   for i, bullet in ipairs(Bullet.ActiveBullets) do
      if a == bullet.physics.fixture or b == bullet.physics.fixture then
         for i, instance in ipairs(ActiveBigShooters) do
            if a == instance.physics.fixture or b == instance.physics.fixture then
               bullet:destroy()
               instance:takeDamage(1)
               break
            end
         end
      end
   end
end


return BigShooter