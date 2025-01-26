local Jumper = {}
Jumper.__index = Jumper
local Player = require("player")
local Bullet = require("bullet")
local STI = require("sti")

local ActiveJumpers = {}

function Jumper.removeAll()
   for i,v in ipairs(ActiveJumpers) do
      v.physics.body:destroy()
   end

   ActiveJumpers = {}
end

function Jumper.new(x,y, cooldown, x_speed)
   local instance = setmetatable({}, Jumper)
   instance.x = x
   instance.y = y

   instance.state = "walk"
   instance.hp = 3
   if x_speed < 0 then
      instance.side = -1
   else
      instance.side = 1
   end

   instance.grounded = true
   instance.x_vel = math.abs(x_speed)

   instance.animation = {timer = 0, rate = 0.1}
   instance.animation.walk = {total = 8, current = 1, img = Jumper.walkAnim}
   instance.animation.die = {total = 12, current = 1, img = Jumper.dieAnim}
   instance.animation.jump = {total = 8, current = 1, img = Jumper.jumpAnim}
   instance.animation.air = {total = 2, current = 1, img = Jumper.airAnim}
   instance.animation.draw = instance.animation.walk.img[1]

   instance.cooldown = cooldown
   instance.cooldown_timer = cooldown - (instance.animation.rate * instance.animation.jump.total + 0.1)

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActiveJumpers, instance)
end

function Jumper.loadAssets()
   Jumper.walkAnim = {}
   for i=1,8 do
      Jumper.walkAnim[i] = love.graphics.newImage("assets/enemies/jumper/standard/standard"..i..".png")
   end

   Jumper.dieAnim = {}
   for i=1,12 do
      Jumper.dieAnim[i] = love.graphics.newImage("assets/enemies/jumper/dying/dying"..i..".png")
   end

    Jumper.jumpAnim = {}
    for i=1,8 do
        Jumper.jumpAnim[i] = love.graphics.newImage("assets/enemies/jumper/jumping/jumping"..i..".png")
    end

    Jumper.airAnim = {}
    for i=1,2 do
        Jumper.airAnim[i] = love.graphics.newImage("assets/enemies/jumper/air/air"..i..".png")
    end

   Jumper.width = Jumper.walkAnim[1]:getWidth()
   Jumper.height = Jumper.walkAnim[1]:getHeight()
   Jumper.map = STI("map/1.lua", {"box2d"})
end

function Jumper:update(dt)
   self:animate(dt)
   self:manageCooldown(dt)
   self:applyGravity(dt)
   if self.state == "walk" or self.state == "air" or self.state == "jump" then
      self:syncPhysics()
   end
end

function Jumper:changeSide()
   --confere se o walker bate em algum dos sensores do tiled
   for _, sensor in ipairs(Jumper.map.layers.sensors.objects) do
      if sensor.type == "jumper_sensor" then
         if self.x + self.width > sensor.x and self.x < sensor.x + sensor.width then
            if self.y + self.height > sensor.y and self.y < sensor.y + sensor.height then
               self.side = self.side * -1
            end
         end
      end
   end
end

function Jumper:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self:changeSide()
    if self.state == "air" then
        self.physics.body:setLinearVelocity(self.x_vel * self.side, 100)
    else
        self.physics.body:setLinearVelocity(0, 0)
    end
end

function Jumper:applyGravity(dt)
    if self.grounded == false then
        self.y_vel = self.y_vel + self.gravity * dt
    end
end

function Jumper:changeAnimationConfigs(new_state, new_current)
   self.state = new_state
   self.animation[new_state].current = new_current
end

function Jumper:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Jumper:manageCooldown(dt)
    if self.cooldown_timer >= self.cooldown - self.animation.rate * self.animation.jump.total then
       if self.state == "walk" then
            self:changeAnimationConfigs("jump", 1)
       end
    end
    self.cooldown_timer = self.cooldown_timer + dt
 end

function Jumper:changeAnimationConfigs(new_state, new_current)
    self.state = new_state
    self.animation[new_state].current = new_current
end

function Jumper:jump()
    self.y_vel = -500
    grounded = false
end

function Jumper:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        if self.state == "die" then
            self:remove()
        end
        if self.state == "jump" then
            self:jump()
            self:changeAnimationConfigs("air", 1)
        end
    anim = self.animation[self.state]
    anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Jumper:remove()
    for i, instance in ipairs(ActiveJumpers) do
        if instance == self then
            table.remove(ActiveJumpers, i)
        end
    end
end

function Jumper:draw()
   love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.side, 1, self.width / 2, self.height / 2)
end

function Jumper.updateAll(dt)
    for i,instance in ipairs(ActiveJumpers) do
        instance:update(dt)
    end
end

function Jumper.drawAll()
   for i,instance in ipairs(ActiveJumpers) do
      instance:draw()
   end
end

function Jumper:takeDamage()
   self.hp = self.hp - 1
   if self.hp == 0 then
      self:die()
   end
end

function Jumper:die()
   self.state = "die"
   self.animation.rate = 0.05
   self.physics.body:destroy()
end


function Jumper.beginContact(a, b, collision)
   -- Check if collision involves Jumper
   for i, instance in ipairs(ActiveJumpers) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            -- Player collided with Jumper
            Player:takeDamage(1)
         end
      end
        local nx, ny = collision:getNormal()
        if a == instance.physics.fixture then
            if ny > 0 then
                grounded = true
                instance.state = "walk"
                instance.cooldown_timer = 0
            elseif ny < 0 then
                instance.y_vel = 0
            end
        elseif b == instance.physics.fixture then
            if ny < 0 then
                grounded = true
                instance.state = "walk"
                instance.cooldown_timer = 0
            elseif ny > 0 then
                instance.y_vel = 0
            end
        end
   end

   -- Check if collision involves Bullet and Jumper
   for i, bullet in ipairs(Bullet.ActiveBullets) do
      if a == bullet.physics.fixture or b == bullet.physics.fixture then
         for i, instance in ipairs(ActiveJumpers) do
            if a == instance.physics.fixture or b == instance.physics.fixture then
               bullet:destroy()
               instance:takeDamage(1)
               break
            end
         end
      end
   end
--    for i, bubble in ipairs(Bubble.ActiveBubbles) do
--       if a == bubble.physics.fixture or b == bubble.physics.fixture then
--          for i, instance in ipairs(ActiveJumpers) do
--             if a == instance.physics.fixture or b == instance.physics.fixture then
--                bubble:destroy()
--                break
--             end
--          end
--       end
--    end
end


return Jumper