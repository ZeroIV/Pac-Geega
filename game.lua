Game = Object:extend()
WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
grid = { x = {}, y ={} }
cellSize = 25
gridLines = {}

function Game:new()

    self:buildGrid()
    walls =
    {
        --top left warp
        Wall(-cellSize, grid.y[13], cellSize * 7, cellSize),
        Wall(grid.x[5], grid.y[10], cellSize, cellSize * 4),
        Wall(-cellSize, grid.y[10], cellSize * 7, cellSize),
        --top border wall
        Wall(0, 0, cellSize, cellSize * 11),
        Wall(0, 0, cellSize * 29, cellSize),
        Wall(grid.x[14], 0, cellSize, cellSize * 5),
        Wall(grid.x[28],0, cellSize, cellSize * 11),
        --top right warp
        Wall(grid.x[23], grid.y[10], cellSize * 7, cellSize),
        Wall(grid.x[23], grid.y[10], cellSize, cellSize * 4),
        Wall(grid.x[23], grid.y[13], cellSize * 7, cellSize),
        --bottom left warp
        Wall(-cellSize, grid.y[16], cellSize * 7, cellSize),
        Wall(grid.x[5], grid.y[16], cellSize, cellSize * 4),
        Wall(-cellSize, grid.y[19], cellSize * 7, cellSize),
        --bottom border
        Wall(0,grid.y[19], cellSize, cellSize * 13),
        Wall(0,grid.y[25], cellSize * 3, cellSize),
        Wall(0, grid.y[31], cellSize * 29, cellSize),
        Wall(grid.x[26],grid.y[25], cellSize * 3, cellSize),
        Wall(grid.x[28], grid.y[19], cellSize, cellSize * 13),
        --bottom right warp
        Wall(grid.x[23], grid.y[19], cellSize * 7, cellSize),
        Wall(grid.x[23], grid.y[16], cellSize, cellSize * 4),
        Wall(grid.x[23], grid.y[16], cellSize * 7, cellSize),
        --inner walls
        Wall(grid.x[3], grid.y[3], cellSize * 3, cellSize * 2),
        Wall(grid.x[3], grid.y[7], cellSize * 3, cellSize),
        Wall(grid.x[3], grid.y[22], cellSize * 3, cellSize),
        Wall(grid.x[3], grid.y[28], cellSize * 9, cellSize),
        Wall(grid.x[5],grid.y[22], cellSize, cellSize * 4),
        Wall(grid.x[8], grid.y[3], cellSize * 4, cellSize * 2),
        Wall(grid.x[8], grid.y[7], cellSize, cellSize * 7),
        Wall(grid.x[8], grid.y[10], cellSize * 4 , cellSize),
        Wall(grid.x[8], grid.y[16], cellSize, cellSize * 4),
        Wall(grid.x[8], grid.y[22], cellSize * 4, cellSize),
        Wall(grid.x[8], grid.y[25], cellSize, cellSize * 4),
        Wall(grid.x[11], grid.y[7], cellSize * 7, cellSize),
        Wall(grid.x[11], grid.y[19], cellSize * 7, cellSize),
        Wall(grid.x[11], grid.y[25], cellSize * 7, cellSize),
        Wall(grid.x[14], grid.y[7], cellSize , cellSize * 4),
        Wall(grid.x[14], grid.y[19], cellSize , cellSize * 4),
        Wall(grid.x[14], grid.y[25], cellSize , cellSize * 4),
        Wall(grid.x[17], grid.y[3], cellSize * 4, cellSize * 2),
        Wall(grid.x[17], grid.y[10], cellSize * 4 , cellSize),
        Wall(grid.x[17], grid.y[22], cellSize * 4, cellSize),
        Wall(grid.x[17], grid.y[28], cellSize * 9, cellSize),
        Wall(grid.x[20], grid.y[7], cellSize, cellSize * 7),
        Wall(grid.x[20], grid.y[16], cellSize, cellSize * 4),
        Wall(grid.x[20], grid.y[25], cellSize, cellSize * 4),
        Wall(grid.x[23], grid.y[3], cellSize * 3, cellSize * 2),
        Wall(grid.x[23], grid.y[7], cellSize * 3, cellSize),
        Wall(grid.x[23], grid.y[22], cellSize * 3, cellSize),
        Wall(grid.x[23],grid.y[22], cellSize, cellSize * 4),
    }
    spawner = Spawner()
    for x = cellSize, WINDOW_WIDTH, cellSize do
        local line = {x, 0, x, WINDOW_HEIGHT}
        table.insert(gridLines, line)
    end
    -- Horizontal lines.
    for y = cellSize, WINDOW_HEIGHT, cellSize do
        local line = {0, y, WINDOW_WIDTH, y}
        table.insert(gridLines, line)
    end
--[[
    --import resources
    xMenuOrigin = (WINDOW_WIDTH / 2) - 50
    yMenuOrigin = WINDOW_HEIGHT / 2
    
    --build menu items
    gameTitle = love.graphics.newText(gameFont, 'Weega-Pac')
    startOne = love.graphics.newText(gameFont,'1-player')
    menuQuit = love.graphics.newText(gameFont,'Quit')
    menuOptions = 
    {
        [1] = startOne,
        [2] = menuQuit
    }
--]]
    --initialize start screen
    --self.start = Start(10)
    self.userSelection = 1

    --initialize game entities
    player = Player()
    player:spawn()
    --has user made a selection?
    self.startGame = false

    self.buffer = 0
end

function Game:buildGrid() 
    for x = 0, WINDOW_WIDTH, cellSize do
        table.insert(grid.x, x / cellSize, x)
    end
    for y = 0, WINDOW_HEIGHT, cellSize do
        table.insert(grid.y, y / cellSize, y)
    end
end
--initializes game settings based on userSelection value
function Game:setOptions()
    
end

function Game:update(dt)
    player:update(dt)
    --self.start:update(dt)
    if self.startGame then
        for k, v in ipairs(walls) do
            
        end
    end
end

function Game:keypressed(key)
    if key == 'space' then
        if not showGrid then
            showGrid = true
        else
            showGrid = false
        end
    end
    if key == 'up' or key == 'w' then
        -- player:changeDirection('y', -1)
        love.event.push('directionChange','y', -1)
    elseif key == 'left' or key == 'a' then
        -- player:changeDirection('x', -1)
        love.event.push('directionChange','x', -1)
    elseif key == 'down' or key == 's' then
        -- player:changeDirection('y', 1)
        love.event.push('directionChange','y', 1)
    elseif key == 'right' or key == 'd' then
        -- player:changeDirection( 'x', 1)
        love.event.push('directionChange','x', 1)
    end
    --[[
    if key == 'kp+' then
        Sound:raiseVolume()
    elseif key == 'kp-' then
        Sound:lowerVolume()
    end

    if not self.startGame then
        if self.userSelection > 1 and (key == 'up' or key == 'w') then
            self.userSelection = self.userSelection - 1
        elseif self.userSelection < 2 and (key == 'down' or key == 's') then
            self.userSelection = self.userSelection + 1
        end

        if key == 'space' then
            if self.userSelection == 1 then
                self:setOptions()
                self.startGame = true
            else
                love.event.quit()
            end
        end
    end
    --]]
    --immediately exits and restarts the program
    if key == 'escape' then
        love.event.quit()
    end
end

function Game:draw()
	--gfx.setLineWidth(2)
    if showGrid then
        for i, line in ipairs(gridLines) do
            love.graphics.line(line)
        end
    end
    gfx.setColor(colors.blue)
    for k, v in pairs(walls) do
        v:draw()
    end
    Spawner:draw()
    gfx.setColor(colors.white)
    player:draw()
    --[[
    if not self.startGame then
        self.start.draw()
        local ymenuItemOffset = 50
        love.graphics.draw(gameTitle, WINDOW_WIDTH * 0.35 , 100, 0, 3,3)

        for k, v in pairs(menuOptions) do
            love.graphics.draw(menuOptions[k], xMenuOrigin, yMenuOrigin + (50 * (k-1)), 0 , 3, 2)
        end

        --displays which option is currently selected
        if self.userSelection == 1 then
            love.graphics.rectangle('line', xMenuOrigin -10, yMenuOrigin, startOne:getWidth() * 3 + 20, startOne:getHeight() * 2 + 5)
        end
        if self.userSelection == 2 then
            love.graphics.rectangle('line', xMenuOrigin -10, yMenuOrigin + ymenuItemOffset, startTwo:getWidth() * 3 + 20, startTwo:getHeight() * 2 + 5)
        end
    end
    --]]
end

