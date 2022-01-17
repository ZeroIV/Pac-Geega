Player = Entity:extend('Player')

local startx, starty
-- local playerImage = nil
-- local playerSprites = gfx.newSpriteBatch(playerImage, 1)

local playerFilter = function(item, other)
    if     other.isEnemy then return 'cross'
    elseif other.isWall   then return 'slide'
    elseif other.isSpawner then return 'slide'
    elseif other.isPellet   then return 'cross'
    end
    -- else return nil
end

function Player:init(x, y, width, height)
    self.isPlayer = true
    self.speed = 125
    startx, starty = x + 4, y + 4
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.lives = 1
    Player.super.init(self, x + 4, y + 4, width - 8, height - 8)
end

function Player:update(dt)
    self:Warp()
    self:move(dt)
    Player.super.update(self, dt)
end

function Player:draw()
    local x = self.x + self.width /2
    local y = self.y + self.height /2
    gfx.circle('fill', x, y, math.round(self.width/2))
    if Debugger:getStatus() then
        Player.super.draw(self)
    end
    for i = 1, self.lives do
        gfx.circle('fill', cellSize * (8 + (i-1)), cellSize * 24 - cellSize/3, self.width/2)
    end
end

function Player:move(dt)
    local goalX, goalY = self.x + self.xspeed * dt, self.y + self.yspeed * dt
    local actualX, actualY, cols, len = World:move(player, goalX, goalY, playerFilter)
    self.x, self.y = actualX, actualY
    -- deal with the collisions

    for i=1,len do
        local other = cols[i].other
        if other.isEnemy then
            if other.state == 3 then
                event.push('enemyKilled', other.id)
            elseif other.state == 4 then
                return
            else
                event.push('onDeath')
            end
        end
        if other.isWall or other.isSpawner then
            self:stop()
        end
        if other.isPellet then
            other:onCollect()
        end
    end
end

function Player:respawn()
    self:stop()
    self.x, self.y = startx, starty
    World:update(self, self.x, self.y)
end

function Player:changeDirection(dir)
    local speed = self.speed
    self:stop()
    World:update(self, self.x, self.y)
    if dir == 'up' or dir == 'left' then
        speed = -self.speed
    end
    if dir == 'left' or dir == 'right' then
        self.xspeed = speed
    elseif dir == 'up' or dir == 'down' then
        self.yspeed = speed
    end
end

function love.handlers.directionChange(dir)

    local e = player
    local x, y, w, h, filter = e.x, e.y, e.width, e.height, e.colFilter
    local vel = e.speed
    local goalX, goalY = x, y
    local canMove = true
    
    if (e.xspeed < 0 and dir == 'left') or (e.xspeed > 0 and dir == 'right') or
            (e.yspeed < 0 and dir == 'up') or (e.yspeed > 0 and dir == 'down') then
        return
    else
        if dir == 'up' then
            goalY = DoDelta(y, -vel)
        elseif dir == 'left' then
            goalX = DoDelta(x, -vel)
        elseif dir == 'down' then
            goalY = DoDelta(y, vel)
        elseif dir == 'right' then
            goalX = DoDelta(x, vel)
        end

        local cols, len = World:project(e, x, y, w, h, goalX, goalY, filter)
        for i = 1, len do
            local other = cols[i].other
            if other.isWall or other.isSpawner then
                canMove = false
            end
        end

        if canMove then
            e:changeDirection(dir)
        end
        return canMove
    end
end

function love.handlers.onDeath()
    local e = player
    -- gfx.translate(100, 100)
    -- local t = love.timer.getTime()
    -- gfx.shear(math.cos(t), math.cos(t * 1.3))
    -- e:draw()

    if e.lives >= 1 then
        e.lives = e.lives - 1
        e:respawn()
        game:resetLevel(true)
    else
        event.push('gameover')
    end
    -- end
end


