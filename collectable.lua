local Collectable = {}
Collectable.__index = Collectable
ActiveCollectables = {}
local Player = require("player")

math.randomseed(os.time())

function Collectable.new(x, y)
    local instance = setmetatable({}, Collectable)
    instance.x = x
    instance.y = y
    instance.img = love.graphics.newImage("assets/spike.png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    -- instance.animation = {timer = 0, ratio = 0.1}
    -- local random_num = math.random(1,6)
    -- instance.animation.main_anim = {total = 6, current = random_num, img = {}}
    -- for i=1, self.animation.main_anim.total do
    --     self.animation.main_anim.img[i] = love.graphics.newImage("assets/collectable/main_anim" .. i .. ".png")
    -- end
    instance.to_be_removed = false
    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveCollectables, instance)
end

function Collectable:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
end

function Collectable.drawAll()
    for i,instance in ipairs(ActiveCollectables) do
        instance:draw()
    end
end

function Collectable:update(dt)
    self:checkRemove()
end

function Collectable:animate()
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer >= self.animation.ratio then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Collectable:checkRemove()
    if self.to_be_removed then
        table.remove(ActiveCollectables, self)
    end
end

function Collectable:setNewFrame()
    local anim = self.animation.main_anim
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Collectable.updateAll(dt)
    for i,instance in ipairs(ActiveCollectables) do
        instance:update(dt)
    end
end

function Collectable.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveCollectables) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:collect()
                instance.to_be_removed = true
                return true
            end
        end
    end
    return false
end

return Collectable