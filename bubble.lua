

local Bubble = {imgs = {love.graphics.newImage("assets/bubble/bubble.png"), 
	love.graphics.newImage("assets/bubble/bubble.png"), 
	love.graphics.newImage("assets/bubble/bigbubble.png")}}
Bubble.__index = Bubble

local ActiveBubbles = {}
local Player = require("player")

function Bubble.new(x,y, bubbleSize)
   local instance = setmetatable({}, Bubble)
   instance.x = x
   instance.y = y
   instance.img = Bubble.imgs[bubbleSize]
   instance.width = instance.img:getWidth() 
   instance.height = instance.img:getHeight()
   instance.x_vel = 0
   instance.y_vel = -30

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(1)
   instance.physics.fixture:setFriction(0.1)
   table.insert(ActiveBubbles, instance)
end

function Bubble:update(dt)
	self:syncPhysics()
	self:applyUpwardForce()
end

function Bubble:applyUpwardForce()
    self.physics.body:setLinearVelocity(self.x_vel, self.y_vel)
end

function Bubble:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
end

function Bubble:draw()
   love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
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
            if a == Player.physics.fixture or b == Player.physics.fixture then
                local playerX, playerY = Player.physics.body:getPosition()
                local bubbleX, bubbleY = instance.physics.body:getPosition()
                local forceX = bubbleX - playerX
                local forceY = bubbleY - playerY

				local magnitude = math.sqrt(forceX * forceX + forceY * forceY)
                forceX = forceX / magnitude
                forceY = forceY / magnitude

                local forceMagnitude = 500 
                instance.physics.body:applyForce(forceX * forceMagnitude, forceY * forceMagnitude)

                return true
            end
        end
    end
end

return Bubble