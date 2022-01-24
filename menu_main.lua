MainMenu = Menu:extend('MainMenu')

local timer = 3
local bgPlayer
local bgEnemy


function MainMenu:init(title, options)
    self.title = title
    self.options = options
    MainMenu.super.init(self, title, options)
end

function MainMenu:update(dt)
    if timer > 0 then
        timer = timer - dt
    else
    end
end

function MainMenu:draw()
    CreateTexturedCircle()
    self.super.draw(self)
end

function MainMenu:resetTimer()
    timer = 10
end

function MainMenu:bgAnim(...)

end
