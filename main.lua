function love.load()
    Object = require 'classic'
    require 'game'
    require 'entity'
    require 'wall'
    --gameFont = love.graphics.newFont('fonts/ka1.ttf', 10)
    game = Game()
end

function table.pack(...)
    return { n = select('#', ...), ... }
end

function love.update(dt)
    game:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    game:keypressed(key, isrepeat)
end

function love.draw()
    --love.graphics.setFont(gameFont)
    game:draw()
end



