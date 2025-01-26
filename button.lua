local Button = {}
Button.__index = Button

local last = false
local now = false

local screens = {start = {}, levels = {}, game = {}, gameover = {}, current = "start"}

function Button.new(screen, x, y, action, parameter, file)
    local instance = setmetatable({}, Button)
    instance.action = action
    instance.parameter = parameter
    instance.img = love.graphics.newImage("assets/buttons/"..file..".png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.x = x
    instance.y = y
    instance.color = {
        red = 1,
        green = 1,
        blue = 1,
        opacity = 1
    }
    table.insert(screens[screen], instance)
end

Button.screens = screens

function Button.load()
    Button.new("start", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 100, changeScreen, "levels", "play_button")
    Button.new("start", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 100, quitGame, "quit", "quit_button")
    Button.new("levels", love.graphics.getWidth() / 2 - 200, love.graphics.getHeight() / 2, changeScreen, "game", "1_button")
    Button.new("levels", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, changeScreen, "game", "2_button")
    Button.new("levels", love.graphics.getWidth() / 2 + 200, love.graphics.getHeight() / 2, changeScreen, "game", "3_button")
    --Button.new("gameover", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, changeScreen, "start", "start")
end

function changeScreen(parameter)
    print("Changing screen to "..parameter)
    screens.current = parameter
end

function startGame(parameter)
    print("Starting game")
    screens.current = "game"
    
end

function quitGame()
    love.event.quit()
end

function Button.update(dt)
    last = now
    now = love.mouse.isDown(1)
end

function Button.draw() 
   for i, button in ipairs(screens[screens.current]) do
        local mx, my = love.mouse.getPosition()
        local hot = mx > button.x - button.width / 2 and mx < button.x + button.width / 2 and my > button.y - button.height / 2 and my < button.y + button.height / 2
        if hot then
            button.color = {
                red = 0.8,
                green = 0.8,
                blue = 0.8,
                opacity = 1,
            }
        end
        love.graphics.setColor(button.color.red, button.color.green, button.color.blue, button.color.opacity)
        love.graphics.draw(button.img, button.x, button.y, 0, 1, 1, button.width/2, button.height/2)
        love.graphics.setColor(1, 1, 1, 1)
        button.color = {
            red = 1,
            green = 1,
            blue = 1,
            opacity = 1,
        }

        if hot and now and not last then
            print("Button pressed", button.parameter)
            button.action(button.parameter)
        end
   end
end

return Button
