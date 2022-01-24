Game = class('Game')
require 'debugger'

cellSize = 32
World = bump.newWorld(cellSize)
Level = 1
Score = 0
Debugger = Debugger:new()
gridLines = {}

local sounds = {
    mainTheme = Sound('sounds/music/good-mood-theme-8-bit.mp3', 50/100),
    level_start = Sound('sounds/game_start.wav')
}

local pause = false

function Game:init()

    TotalPellets = 0
    walls = GenWall()
    pellets = GenPellets()
    PelletsCollected = 0
    spawner = Spawner()
    --create grid lines
    -- vertical lines.
    for x = cellSize, WindowWidth, cellSize do
        local line = {x, 0, x, WindowHeight}
        table.insert(gridLines, line)
    end
    -- horizontal lines.
    for y = cellSize, WindowHeight, cellSize do
        local line = {0, y, WindowWidth, y}
        table.insert(gridLines, line)
    end

    -- initialize menu items & text
    local overTitle = gfx.newText(gameFont, 'Game Over')
    self.gameOver = GameOver(overTitle, {gfx.newText(gameFont, 'Restart'),
                                         gfx.newText(gameFont, 'Quit')})

    gameTitle = gfx.newText(gameFont, 'Pac-Geega')
    self.menuMain = MainMenu(gameTitle, {gfx.newText(gameFont,'Start'),
                                         gfx.newText(gameFont,'Quit'),})

    volumeText = gfx.newText(gameFont, string.format('Volume %d',
                                                     love.audio.getVolume() * 100))
    self.menuMain.open = true
    sounds.mainTheme:play(true)

    -- initialize game entities
    player = nil
    enemies = {}
    self:start()
    self.readyTimer = 4
    self.textTransform = nil
end

function Game:update(dt)

    if love.window.hasFocus() and love.window.isVisible() then
        if self.menuMain.open then
            -- menu animations here
            self.menuMain:update(dt)
        elseif self.gameOver.open then
            self.gameOver:update(dt)
        else
            if self.readyTimer > 0 then
                self.readyTimer = self.readyTimer - dt
            else
                if PelletsCollected < TotalPellets then
                    for i = 1, #enemies do
                        enemies[i]:update(dt)
                    end
                    if TextTimer > 0 then
                        TextTimer = TextTimer - dt
                    else
                        TextTimer = 0
                    end
                    player:update(dt)
                else
                    event.push('levelCompleted')
                end
            end
        end
    end
end

function Game:draw()
local main_menu = self.menuMain
local game_over = self.gameOver

    if main_menu.open then
        main_menu:draw()
    elseif game_over.open then
        game_over:draw()
    else 
        if self.readyTimer > 0 then 
            sounds.level_start:play()
            gfx.print('Level: ' .. Level, cellSize * 11, cellSize * 13, 0, 2, 2)
        end
        if Debugger:getStatus() then
            for i, line in ipairs(gridLines) do
                gfx.line(line)
            end
        end
        for i, w in ipairs(walls) do
            w:draw()
        end
        Spawner:draw()
        for i, p in ipairs(pellets) do
            p:draw()
        end
        for i = 1, #enemies do
            enemies[i]:draw()
        end
        player:draw()
        if TextTimer > 0 then
            gfx.draw(floatingText, self.textTransform)
        end
        gfx.print('Score: ' .. Score, cellSize * 12, cellSize * 23 + 8, 0, 1, 1)
    end
    gfx.draw(volumeText, cellSize * 19, cellSize / 2, 0, 1)
end

function Game:start()
    player = Player(cellSize * 12, cellSize * 17, cellSize, cellSize)
    enemies = {
        Enemy(cellSize * 10, cellSize * 11, cellSize, cellSize, 1),
        Enemy(cellSize * 11, cellSize * 11, cellSize, cellSize, 2),
        Enemy(cellSize * 13, cellSize * 11, cellSize, cellSize, 3),
        Enemy(cellSize * 14, cellSize * 11, cellSize, cellSize, 4),
    }
end

function Game:keypressed(k)
    local menu = self.menuMain
    local game_over = self.gameOver
    local selection = nil

    if k == 'kp+' then
        Sound:raiseVolume()
        volumeText:set(string.format('Volume %d', love.audio.getVolume()* 100))
    elseif k == 'kp-' then
        Sound:lowerVolume()
        volumeText:set(string.format('Volume %d', love.audio.getVolume()* 100))
    end

    if menu.open then
        menu:keypressed(k)
        if k == 'space' or k == 'return' then
            -- get selected option
            menu.sfx.select:play()
            selection = menu:getUserSelection()
            menu.open = false
            sounds.mainTheme:stop()
            if selection == 1 then
                --sounds.level_start:play()
            end
        end
    elseif game_over.open then
        game_over:keypressed(k)
        if k == 'space' or k == 'return' then
            -- get selected option
            selection = game_over:getUserSelection()
        end
        if selection == 1 then
               love.event.push('restart') 
        end
    else
        if k == 'tab' then
            Debugger:toggle()
        end
        -- for debugging
        if k == 'space' or k == 'return' then

        end

        if k == 'up' or k == 'w' then
            love.event.push('directionChange', 'up', -1)
        elseif k == 'left' or k == 'a' then
            love.event.push('directionChange', 'left', -1)
        elseif k == 'down' or k == 's' then
            love.event.push('directionChange', 'down', 1)
        elseif k == 'right' or k == 'd' then
            love.event.push('directionChange', 'right', 1)
        end
    end

    if  k == 'escape' then
        -- local title = 'Confirm Exit'
        -- local msg = 'Are you sure you want to quit the game'
        -- local msgbuttons = {'Yes', 'No'}
        -- local confirm = love.window.showMessageBox(title, msg, msgbuttons, 'warning')
        -- if confirm == 1 then
            love.event.quit()
        -- end
    end

    -- immediately exits the program
    if selection == 2 then
        love.event.quit()
    end
end