local Button = {}
Button.__index = Button

local screens = {start = {}, levels = {}, game = {}, gameover = {}, current = "start"}

function Button.new(screen, x, y, action, parameter, file)
    local instance = setmetatable({}, Button)
    instance.font = love.graphics.newFont(32)
    instance.text = text
    instance.action = action
    instance.parameter = parameter
    instance.img = love.graphics.newImage("assets/buttons/"..file..".png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.x = x
    instance.y = y
    instance.last = false
    instance.now = false
    instance.color = {
        red = 1,
        green = 1,
        blue = 1,
        opacity = 1
    }
    table.insert(screens[screen], instance)
end

function Button.load()
    Button.new("start", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, changeScreen, "levels", "start")
    Button.new("start", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 100, quitGame, "quit", "start")
    Button.new("levels", love.graphics.getWidth() / 2 - 200, love.graphics.getHeight() / 2, changeScreen, "game", "start")
    Button.new("levels", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, changeScreen, "game", "start")
    Button.new("levels", love.graphics.getWidth() / 2 + 200, love.graphics.getHeight() / 2, changeScreen, "game", "start")
    Button.new("gameover", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, changeScreen, "start", "start")
end

function changeScreen(screen)
    current_screen = screen
end

function startGame(fase)
    current_screen = "game"
    
end

function quitGame()
    love.event.quit()
end

function Button.update(dt)
end

function Button.draw()
   for i, button in ipairs(screens[self.current]) do
        button.last = button.now

        local mx, my = love.mouse.getPosition()
        hot = mx > button.x - button.width / 2 and mx < button.x + button.width / 2 and my > button.y - button.height / 2 and my < button.y + button.height / 2
        if hot then
            button.color = {
                red = 0.8,
                green = 0.8,
                blue = 0.8,
                opacity = 1,
            }
        end
        button.now = love.mouse.isDown(1)
        love.graphics.setColor(button.color.red, button.color.green, button.color.blue, button.color.opacity)
        love.graphics.draw(button.img, button.x, button.y, 0, 1, 1, button.width/2, button.height/2)
        love.graphics.setColor(1, 1, 1, 1)
        button.color = {
            red = 1,
            green = 1,
            blue = 1,
            opacity = 1,
        }

        if hot and button.now and button.last == false then
            button.color = {
                button.action(button.parameter)
            }
        end
   end
end

return Button, screens