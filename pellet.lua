Pellet = class('Pellet')

function Pellet:init(x, y)
    self.x = x
    self.y = y
    self.radius = 2
    self.active = true
end

function Pellet:update(dt)
    if CheckCollision(player.x, player.y, player.width, player.height, self.x, self.y, 5, 5) then
        self.active = false
    end
end

function Pellet:draw()
    gfx.circle('fill', self.x, self.y, self.radius)
end