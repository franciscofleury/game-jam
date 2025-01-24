Player = {}

function Player:load()
    self.x = 50
    self.y = 0
    self.width = 11
    self.height = 24
    self.x_vel = 0
    self.y_vel = 100
    -- no tutorial o maluco usava aqui uma maxspeed, uma aceleracao e uma friccao, pra fazer o movimento chegar gradualmente a velocidade de andar e parar
    self.gravity = 1500 
    -- setou pra esse valor no tutorial (acho que no nosso jogo n faz sentido guardar a gravidade em player)
    self.grounded = false
    self.jump_amount = -500
    self.direction = 'right'
    self.state = 'idle'

    self:loadAssests()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Player:loadAssests()
    self.animation = {timer = 0, ratio = 0.1}
    
    self.animation.walk = {total = 6, current = 1, img = {}}
    for i=1, self.animation.walk.total do
        self.animation.walk.img[i] = love.graphics.newImage("assets/bolho/walk" .. i .. ".png")
    end

    self.animation.idle =  {total = 1, current = 1, img = { love.graphics.newImage("assets/bolho/idle.png")}}

    self.animation.air = {total = 1, current = 1, img = { love.graphics.newImage("assets/bolho/air.png")}}

    self.animation.draw = self.animation.walk.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Player:update(dt)
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
end

function Player:setState()
    if not self.grounded then
        self.state = 'air'
    elseif self.x_vel == 0 then
        self.state = 'idle'
    else
        self.state = 'walk'
    end
    --aqui fiquei devendo umas funcionalidades, tem que implementar pulo, tiro parado, tirando andando, tiro pulando, e idle queria que ativasse só depois de um tempo parado
end

function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer >= self.animation.ratio then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Player:setDirection()
    if self.x_vel > 0 then
        self.direction = 'right'
    elseif self.x_vel < 0 then
        self.direction = 'left'
    end
end

function Player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Player:applyGravity(dt)
    if self.grounded == false then
        self.y_vel = self.y_vel + self.gravity * dt
    end
end

function Player:move(dt)
    if love.keyboard.isDown("d") then
        if love.keyboard.isDown("a") then
            self.x_vel = 0
        else
        self.x_vel = 100
        end
    elseif love.keyboard.isDown("a") then
        self.x_vel = -100
    else
        self.x_vel = 0
    end
    self.physics.body:setLinearVelocity(self.x_vel, self.y_vel)
end

function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.x_vel, self.y_vel)
end

function Player:beginContact(a, b, collision)
    if self.grounded then return end --tinha entendido que isso n precisava pq só acionava quando começava o contato
    local nx, ny = collision:getNormal() --por enquanto n uso o nx
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.y_vel = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then
            self.y_vel = 0
        end
    end
end

function Player:land(collision)
    self.current_ground_collision = collision
    self.y_vel = 0
    self.grounded = true

end

function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.current_ground_collision == collision then
            self.grounded = false
        end
    end
end

function Player:jump()
    if self.grounded then
        self.y_vel = self.jump_amount
        self.grounded = false
    end
end

function Player:draw()
    local x_scale = 1
    if self.direction == 'left' then
        x_scale = -1
    end
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, x_scale, 1, self.animation.width/2, self.animation.height/2)
end

