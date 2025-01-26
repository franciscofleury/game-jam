

local Bubble = {"normal","normal","big"}
Bubble.__index = Bubble

local ActiveBubbles = {}
local Bullet = require("bullet")

function Bubble.new(x,y, bubbleSize, direction)
   -- vida e velocidade da bolha variavel com tamanho da bolha
   local instance = setmetatable({}, Bubble)
   instance.x = x
   instance.y = y
   if direction == "right" then
      instance.x = x + 21
   elseif direction == "left" then
      instance.x = x - 15
   elseif direction == "up" then
      instance.y = y - 10
   elseif direction == "down" then
      instance.y = y + 40
   end
   instance.life = 5 * bubbleSize
   instance.state = "still"
   instance.size = Bubble[bubbleSize]
   instance.scale = 1
   if bubbleSize == 1 then instance.scale = 2 end
   instance.width = Bubble.stillAnim[instance.size][1]:getWidth() / instance.scale
   instance.height = Bubble.stillAnim[instance.size][1]:getHeight() / instance.scale
   instance.x_vel = 0
   instance.y_vel = -40 / bubbleSize

   instance.animation = {timer = 0, rate = 0.3}
   instance.animation.still = {total = 17, current = 1, img = Bubble.stillAnim[instance.size]}
   instance.animation.pop = {total = 7, current = 1, img = Bubble.popAnim[instance.size]}
   instance.animation.draw = instance.animation.still.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.shape = love.physics.newRectangleShape(instance.width*0.95, instance.height*0.95)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(1)
   instance.physics.fixture:setFriction(0.1)
   instance.physics.fixture:setRestitution(0.8)
   instance.physics.body:setGravityScale(0)
   table.insert(ActiveBubbles, instance)
end

Bubble.ActiveBubbles = ActiveBubbles

function Bubble.loadAssets()
   Bubble.stillAnim = {normal = {}, big = {}}
   for i=1,17 do
      Bubble.stillAnim.normal[i] = love.graphics.newImage("assets/bubble/normal/flicking/flicking"..i..".png")
      Bubble.stillAnim.big[i] = love.graphics.newImage("assets/bubble/big/flicking/flicking"..i..".png")
   end

   Bubble.popAnim = {normal = {}, big = {}}
   for i=1,4 do
      Bubble.popAnim.normal[i] = love.graphics.newImage("assets/bubble/normal/pop/pop"..i..".png")
      Bubble.popAnim.big[i] = love.graphics.newImage("assets/bubble/big/pop/exploding"..i..".png")
   end
end

function Bubble.removeAll()
   for i,v in ipairs(ActiveBubbles) do
      v.physics.body:destroy()
   end

   ActiveBubbles = {}
end

function Bubble:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer >= self.animation.rate then
       self.animation.timer = 0
       self:setNewFrame()
   end
end

function Bubble:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
       anim.current = anim.current + 1
   else
      if self.state == "pop" then
         for i, bubble in ipairs(ActiveBubbles) do
            if bubble == self then
               table.remove(ActiveBubbles, i)
            end
         end
      end
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function Bubble:destroy()
   for i, bubble in ipairs(ActiveBubbles) do
      if bubble == self and bubble.state ~= "pop" then
         self.animation.rate = 0.05
         self.state = "pop"
         self.physics.body:destroy()
    	   break
      end
   end
end

function Bubble:update(dt)
   self:animate(dt)
   if self.state ~= "pop" then
	   self:syncPhysics()
      self:applyUpwardForce()
   end
   self.life = self.life - dt
   if self.life <= 0 then
      self:destroy()
   end
end

function Bubble:applyUpwardForce()
    self.physics.body:setLinearVelocity(self.x_vel, self.y_vel)
end

function Bubble:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
end

function Bubble:draw()
   if self.animation.draw then
      love.graphics.draw(self.animation.draw, self.x, self.y, 0, 1/self.scale, 1/self.scale, self.width / 2, self.height / 2)
   end
end

function Bubble.updateAll(dt)
   for i,instance in ipairs(ActiveBubbles) do
      instance:update(dt)
   end
end

function Bubble.drawAll()
   for i,instance in ipairs(ActiveBubbles) do
      instance:draw()
   end
end

function Bubble.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveBubbles) do
         if a == instance.physics.fixture or b == instance.physics.fixture then
            for _, bullet in ipairs(Bullet.ActiveBullets) do
               if a == bullet.physics.fixture or b == bullet.physics.fixture then

                   local bulletX, bulletY = bullet.physics.body:getPosition()
                   local bubbleX, bubbleY = instance.physics.body:getPosition()
                   local forceX = bubbleX - bulletX
                   local forceY = bubbleY - bulletY

                   if forceX > 0 then instance.x_vel = 20 else instance.x_vel = -20 end
                   bullet:destroy()
                   return true
               end
           end
         end  
    end
end

return Bubble