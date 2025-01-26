local SmallShooter = {}
SmallShooter.__index = SmallShooter
local Player = require("player")
local Bullet = require("bullet")
local Bubble = require("bubble")

local ActiveSmallShooters = {}

function SmallShooter.removeAll()
   for i,v in ipairs(ActiveSmallShooters) do
      v.physics.body:destroy()
   end

   ActiveSmallShooters = {}
end

function SmallShooter.new(x,y, cooldown, shot_speed, side)
   local instance = setmetatable({}, SmallShooter)
   instance.x = x
   instance.y = y

   instance.state = "still"
   instance.hp = 1
   instance.side = side

   instance.animation = {timer = 0, rate = 0.3}
   instance.animation.still = {total = 4, current = 1, img = SmallShooter.stillAnim}
   instance.animation.shoot = {total = 7, current = 1, img = SmallShooter.shootAnim}
   instance.animation.die = {total = 10, current = 1, img = SmallShooter.dieAnim}
   instance.animation.draw = instance.animation.still.img[1]

   instance.cooldown = cooldown
   instance.cooldown_timer = cooldown - (instance.animation.rate * instance.animation.shoot.total + 0.1)
   instance.shot_speed = shot_speed --n foi implementado ainda

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveSmallShooters, instance)
end

function SmallShooter.loadAssets()
   SmallShooter.stillAnim = {}
   for i=1,4 do
      SmallShooter.stillAnim[i] = love.graphics.newImage("assets/enemies/small_shooter/standard/standard"..i..".png")
   end

   SmallShooter.shootAnim = {}
   for i=1,7 do
      SmallShooter.shootAnim[i] = love.graphics.newImage("assets/enemies/small_shooter/shooting/shooting"..i..".png")
   end

   SmallShooter.dieAnim = {}
   for i=1,10 do
      SmallShooter.dieAnim[i] = love.graphics.newImage("assets/enemies/small_shooter/dying/dying"..i..".png")
   end

   SmallShooter.width = SmallShooter.stillAnim[1]:getWidth()
   SmallShooter.height = SmallShooter.stillAnim[1]:getHeight()
end

function SmallShooter:update(dt)
   self:animate(dt)
   self:manageCooldown(dt)
   if self.state == "still" or self.state == "shot" then
      self:syncPhysics()
   end
end

function SmallShooter:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
end

function SmallShooter:manageCooldown(dt)
   if self.cooldown_timer >= self.cooldown - self.animation.rate * self.animation.shoot.total then
      if self.state == "still" then
         self:changeAnimationConfigs("shoot", 1)
      end
   end
   self.cooldown_timer = self.cooldown_timer + dt
end

function SmallShooter:changeAnimationConfigs(new_state, new_current)
   self.state = new_state
   self.animation[new_state].current = new_current
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

function SmallShooter:remove()
   for i, instance in ipairs(ActiveSmallShooters) do
      if instance == self then
         table.remove(ActiveSmallShooters, i)
      end
   end
end

function SmallShooter:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, 0, side, 1, self.width / 2, self.height / 2)
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

function SmallShooter:takeDamage()
   self.hp = self.hp - 1
   if self.hp == 0 then
      self:die()
   end
end

function SmallShooter:die()
   self.state = "die"
   self.animation.rate = 1.05
   self.physics.body:destroy()
end


function SmallShooter.beginContact(a, b, collision)
   -- Check if collision involves SmallShooter
   for i, instance in ipairs(ActiveSmallShooters) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            -- Player collided with SmallShooter
            Player:takeDamage(1)
         end
      end
   end

   -- Check if collision involves Bullet and SmallShooter
   for i, bullet in ipairs(Bullet.ActiveBullets) do
      if a == bullet.physics.fixture or b == bullet.physics.fixture then
         for i, instance in ipairs(ActiveSmallShooters) do
            if a == instance.physics.fixture or b == instance.physics.fixture then
               bullet:destroy()
               instance:takeDamage(1)
               break
            end
         end
      end
   end

   for i, bubble in ipairs(Bubble.ActiveBubbles) do
      if a == bubble.physics.fixture or b == bubble.physics.fixture then
         for i, instance in ipairs(ActiveSmallShooters) do
            if a == instance.physics.fixture or b == instance.physics.fixture then
               bubble:destroy()
               break
            end
         end
      end
   end
end


return SmallShooter