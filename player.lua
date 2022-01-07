Player = Entity:extend()

local action_buffer

function Player:new(x, y, width, height)
    self.speed = 125
    Player.super.new(self, x, y, width, height)
end

function Player:spawn()
    self.x = grid.x[14] 
    self.y = grid.y[23] + cellSize / 4
    self.width = (cellSize + 10)
    self.height = (cellSize + 10)
end

function Player:changeDirection(axis, change)
    local speed = self.speed
    player:stop()
    if change < 0 then
        speed = -player.speed
    end
    if axis == 'x' then
        self.xspeed = speed
    elseif axis == 'y' then
        self.yspeed = speed
    end
end

function Player:update(dt)

    self:Warp()
    for k, v in pairs(walls) do
        if CheckCollision(self.x, self.y, self.width, self.height,
                                             v.x, v.y, v.width, v.height) then
            love.event.push('onCollide')
            break
        end
    end
    Player.super.update(self, dt)
end