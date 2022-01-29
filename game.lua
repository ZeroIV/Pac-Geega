Game = class('Game')

cellSize = 32
World = bump.newWorld(cellSize)
Level = 1
Score = 0

local sounds = {
    mainTheme = Sound('sounds/music/good-mood-theme-8-bit.mp3', 50/100),
    level_start = Sound('sounds/game_start.wav')
}

local paused = false
local activeSounds = nil
local animationPause = nil

function Game:init()

    animationPause = Player:getAnimStatus()
    TotalPellets = 0
    walls = GenWall()
    pellets = GenPellets()
    PelletsCollected = 0
    spawner = Spawner()

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

    if love.window.hasFocus() then
        paused = false
    else
        paused = true
    end
    
    if paused then
        return
    elseif self.menuMain.open then
        self.menuMain:update(dt)
    elseif self.gameOver.open then
        self.gameOver:update(dt)
    else
        if self.readyTimer > 0 then
            self.readyTimer = self.readyTimer - dt
        else
            if PelletsCollected < TotalPellets then

                player:update(dt)

                if animationPause then
                    return
                end

                for i = 1, #enemies do
                    enemies[i]:update(dt)
                end

                if FloatingTextTimer > 0 then
                    FloatingTextTimer = FloatingTextTimer - dt
                else
                    FloatingTextTimer = 0
                end
            else
                event.push('levelComplete')
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
        gfx.translate(-cellSize, 0)

        if self.readyTimer > 0 then 
            sounds.level_start:play()
            gfx.print('Level: ' .. Level, cellSize * 11, cellSize * 13, 0, 2, 2)
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

        if FloatingTextTimer > 0 then
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
            menu.sfx.select:play()
            selection = menu:getUserSelection()
            menu.open = false
            sounds.mainTheme:stop()
        end
    elseif game_over.open then
        game_over:keypressed(k)
        if k == 'space' or k == 'return' then
            selection = game_over:getUserSelection()
        end
        if selection == 1 then
               love.event.push('restart')
        end
    else -- game is active
        if not Player:getAnimStatus() then
            if k == 'up' or k == 'w' then
                love.event.push('playerDirectionChange', 'up')
            elseif k == 'left' or k == 'a' then
                love.event.push('playerDirectionChange', 'left')
            elseif k == 'down' or k == 's' then
                love.event.push('playerDirectionChange', 'down')
            elseif k == 'right' or k == 'd' then
                love.event.push('playerDirectionChange', 'right')
            end
        end
    end

    --[[
    if  k == 'escape' then
        local title = 'Confirm Exit'
        local msg = 'Are you sure you want to quit the game'
        local msgbuttons = {'Yes', 'No'}
        local confirm = love.window.showMessageBox(title, msg, msgbuttons, 'warning')
        if confirm == 1 then
        love.event.quit()
        end
    end
    --]]

    -- immediately exits the program
    if k == 'escape' or selection == 2 then
        love.event.quit()
    end
end