GameOver = Menu:extend('GameOver')

local timer = 3

function GameOver:init(title, options)
    self.title = title
    self.options = options
    GameOver.super.init(self, title, options)
end

function GameOver:draw()
    local final_score = Score
    gfx.print('Total Score: ' .. final_score, cellSize * 11, cellSize * 8, 0, 1)
    self.super.draw(self)
end

