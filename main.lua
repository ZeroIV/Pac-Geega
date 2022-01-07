function love.load()
    Object = require 'classic'
    class = require'./libraries/30log/30log-global' 
    require 'game'
    require 'util'
    require 'entity'
    require 'player'
    require 'pellet'
    require 'wall'
    require 'spawner'
    --gameFont = love.graphics.newFont('fonts/ka1.ttf', 10)
    colors = { ['red'] = {1,0,0}, ['green'] = {0,1,0}, ['blue'] = {0,0,1}, ['white'] = {1,1,1}}
    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.draw()
    --love.graphics.setFont(gameFont)
    game:draw()
end



