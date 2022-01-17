Game = class('Game')
require 'debugger'


cellSize = 32
gridLines = {}
World = bump.newWorld(cellSize)
Level = 1
Score = 0
Debugger = Debugger:new()

function Game:init()
    
    TotalPellets = 0
    walls = GenWall()
    pellets = GenPellets()
    PelletsCollected = 0
    player = nil
    spawner = Spawner()
    enemies = {}

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

    -- initialize menu items
    local overTitle = gfx.newText(gameFont, 'Game Over')
    self.gameOver = GameOver(overTitle, {gfx.newText(gameFont, 'Restart'),
                                         gfx.newText(gameFont, 'Quit')})

    gameTitle = gfx.newText(gameFont, 'Pac-Geega')
    self.menuMain = MainMenu(gameTitle, {gfx.newText(gameFont,'Start'),
                                         gfx.newText(gameFont,'Quit'),})
    self.menuMain.open = true

    -- initialize game entities
    self:start()
    self.timer = 1
end

function Game:update(dt)
    if self.menuMain.open then
        -- menu animations here
        self.menuMain:update(dt)
    else
        if self.timer > 0 then
            self.timer = self.timer - dt
        else
            if PelletsCollected < TotalPellets then
                player:update(dt)
                for i = 1, #enemies do
                    enemies[i]:update(dt)
                end
            else
                event.push('levelCompleted')
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
        if self.timer > 0 then 
            gfx.print('Level: ' .. Level, cellSize * 11, cellSize * 13, 0, 2, 2)
        end
        if Debugger:getStatus() then
            for i, line in ipairs(gridLines) do
                gfx.line(line)
            end
        end
        gfx.setColor(colors.blue)
        for x = 1, #walls do
            for i, w in ipairs(walls[x]) do
                w:draw()
            end
        end
        gfx.setColor(colors.white)
        for i, p in ipairs(pellets) do
            p:draw()
        end
        Spawner:draw()

        for i = 1, #enemies do
            enemies[i]:draw()
        end
        player:draw()
        gfx.print('Score: ' .. Score, cellSize * 12, cellSize * 23 + 8, 0, 1, 1)
    end
end

function Game:start()
    player = Player(cellSize * 12, cellSize * 17, cellSize, cellSize)
    enemies = {
        Enemy(cellSize * 10, cellSize * 11, cellSize, cellSize, {80/255, 0, 0}, 1),
        -- Enemy(cellSize * 11, cellSize * 11, cellSize, cellSize, {100/255, 0, 0}, 2),
        -- Enemy(cellSize * 13, cellSize * 11, cellSize, cellSize, {190/255, 0, 0}, 3),
        -- Enemy(cellSize * 14, cellSize * 11, cellSize, cellSize, {240/255, 155/255, 100/255}, 4),
    }
end

function Game:resetLevel(soft)

    player:respawn()

    for i = 1, #enemies do
        enemies[i]:respawn()
    end
    -- if player died then
    -- do soft reset only
    if not soft then
        for i = 1, #pellets do
            pellets[i]:addToWorld()
        end
        PelletsCollected = 0
    end
    self.timer = 1
end

-- initializes game settings based on userSelection value
function Game:setOptions()
    
end

function Game:keypressed(k)
    local menu = self.menuMain
    local game_over = self.gameOver
    local selection = nil

    --[[
    if k == 'kp+' then
        Sound:raiseVolume()
    elseif k == 'kp-' then
        Sound:lowerVolume()
    end
    --]]

    if menu.open then
        menu:keypressed(k)
        if k == 'space' or k == 'return' then
            -- get selected option
            selection = menu:getUserSelection()
            menu.open = false
        end
    elseif game_over.open then
        game_over:keypressed(k)
        if k == 'space' or k == 'return' then
            -- get selected option
            selection = game_over:getUserSelection()
            game_over.open = false
        end
    else
        if k == 'tab' then
            Debugger:toggle()
        end
        -- debug function
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
    -- immediately exits the program
    if k == 'escape' or selection == 2 then
        love.event.quit()
    end
end

function Game:over()
    self.gameOver.open = true
end