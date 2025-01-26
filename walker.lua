local Walker = {}
Walker.__index = Walker
local Player = require("player")
local Bullet = require("bullet")
local Bubble = require("bubble")
local STI = require("sti")

local ActiveWalkers = {}

function Walker.removeAll()
   for i,v in ipairs(ActiveWalkers) do
      v.physics.body:destroy()
   end

   ActiveWalkers = {}
end

function Walker.new(x,y, x_speed, map)
   local instance = setmetatable({}, Walker)
   instance.x = x
   instance.y = y

   instance.state = "walk"
   instance.hp = 2
   if x_speed < 0 then
      instance.side = -1
   else
      instance.side = 1
   end

   instance.x_vel = x_speed

   instance.animation = {timer = 0, rate = 0.3}
   instance.animation.walk = {total = 6, current = 1, img = Walker.walkAnim}
   instance.animation.die = {total = 11, current = 1, img = Walker.dieAnim}
   instance.animation.draw = instance.animation.walk.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)

   instance.map = map

   table.insert(ActiveWalkers, instance)
end

function Walker.loadAssets()
   Walker.walkAnim = {}
   for i=1,6 do
      Walker.walkAnim[i] = love.graphics.newImage("assets/enemies/walker/walking/walking"..i..".png")
   end

   Walker.dieAnim = {}
   for i=1,11 do
      Walker.dieAnim[i] = love.graphics.newImage("assets/enemies/walker/dying/dying"..i..".png")
   end

   Walker.width = Walker.walkAnim[1]:getWidth()
   Walker.height = Walker.walkAnim[1]:getHeight()
end

function Walker:update(dt)
   self:animate(dt)
   if self.state == "walk" then
      self:syncPhysics()
   end
end

function Walker:changeSide()
   --confere se o walker bate em algum dos sensores do tiled
   for _, sensor in ipairs(Walker.map.layers.sensors.objects) do
      if sensor.type == "walker_sensor" then
         if self.x + self.width > sensor.x and self.x < sensor.x + sensor.width then
            if self.y + self.height > sensor.y and self.y < sensor.y + sensor.height then
               self.side = self.side * -1
            end
         end
      end
   end
end

function Walker:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self:changeSide()
   self.physics.body:setLinearVelocity(self.x_vel * self.side, 100)
end

function Walker:changeAnimationConfigs(new_state, new_current)
   self.state = new_state
   self.animation[new_state].current = new_current
end

function Walker:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Walker:setNewFrame()
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

function Walker:remove()
    for i, instance in ipairs(ActiveWalkers) do
        if instance == self then
            table.remove(ActiveWalkers, i)
        end
    end
end

function Walker:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.side, 1, self.width / 2, self.height / 2)
end

function Walker.updateAll(dt)
    for i,instance in ipairs(ActiveWalkers) do
        instance:update(dt)
    end
end

function Walker.drawAll()
   for i,instance in ipairs(ActiveWalkers) do
      instance:draw()
   end
end

function Walker:takeDamage()
   self.hp = self.hp - 1
   if self.hp == 0 then
      self:die()
   end
end

function Walker:die()
   self.state = "die"
   self.animation.rate = 0.05
   self.physics.body:destroy()
end


function Walker.beginContact(a, b, collision)
   -- Check if collision involves Walker
   for i, instance in ipairs(ActiveWalkers) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            -- Player collided with Walker
            Player:takeDamage(1)
         end
      end
   end

   -- Check if collision involves Bullet and Walker
   for i, bullet in ipairs(Bullet.ActiveBullets) do
      if a == bullet.physics.fixture or b == bullet.physics.fixture then
         for i, instance in ipairs(ActiveWalkers) do
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
         for i, instance in ipairs(ActiveWalkers) do
            if a == instance.physics.fixture or b == instance.physics.fixture then
               bubble:destroy()
               break
            end
         end
      end
   end
end


return Walker