Game = Object:extend()

WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()

function Game:new()

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
    self.wall = Wall()
    --has user made a selection?
    self.startGame = false

    self.buffer = 0
end

--initializes game settings based on userSelection value
function Game:setOptions()
    
end

function Game:update(dt)
    --self.start:update(dt)
    if self.startGame then

    end
end

function Game:keypressed(key)

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
    self.wall.draw()
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

