function love.load()
    class = require('.libraries.30log.30log-global')
    bump = require('.libraries.bump.bump')
    luastar = require('libraries.lua-star')
    require 'util'
    require 'sound'
    require 'game'
    require 'menu'
    require 'menu_main'
    require 'gameover'
    require 'entity'
    require 'player'
    require 'enemy'
    require 'pellet'
    require 'wall'
    require 'spawner'

    gameFont = gfx.newFont('fonts/ka1.ttf', 10)
    floatingText = gfx.newText(gameFont, '')

    love.audio.setDistanceModel('none')
    love.audio.setPosition(WindowWidth/2, WindowHeight/2, 0)

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
    gfx.setFont(gameFont)
    game:draw()
end

function love.handlers.restart()
    World = bump.newWorld(cellSize)
    Score = 0
    Level = 1
    game = Game()
end


