Player = Entity:extend('Player')



local startx, starty
local sprites = {
    L = { gfx.newImage('sprites/Geeg/geeg_left_1.png'), 
            gfx.newImage('sprites/Geeg/geeg_left_2.png'), 
            gfx.newImage('sprites/Geeg/geeg_left_3.png') },

    R = { gfx.newImage('sprites/Geeg/geeg_right_1.png'),
            gfx.newImage('sprites/Geeg/geeg_right_2.png'),
            gfx.newImage('sprites/Geeg/geeg_right_3.png') },
}
local r = 0
local currentFacing = 0 -- used to determine sprite to use for animations

local playerFilter = function(item, other)
    if     other.isEnemy then return 'cross'
    elseif other.isWall   then return 'slide'
    elseif other.isSpawner then return 'slide'
    elseif other.isPellet   then return 'cross'
    end
    -- else return nil
end

-- #region Local methods

local function setSpeed(e, dir, speed)
    if dir == 'left' or dir == 'right' then
        e.xspeed = speed
    elseif dir == 'up' or dir == 'down' then
        e.yspeed = speed
    end
end

local function setFacing(dir)
    if dir == 'left' then
        currentFacing = -1
    elseif dir == 'right' then
        currentFacing = 1
    end
end

local function setRotation(dir)
    if (currentFacing < 0 and dir == 'up') or (currentFacing > 0 and dir == 'down') then
        r = 90
    elseif (currentFacing < 0 and dir == 'down') or (currentFacing > 0 and dir == 'up') then
        r = -90
    else
        r = 0
    end
end

-- #endregion

function Player:init(x, y, width, height)
    self.isPlayer = true
    self.speed = 125
    startx, starty = x + 4, y + 4
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.lives = 2
    Player.super.init(self, x + 4, y + 4, width - 8, height - 8)
    self.aFrame = 1
    self.mesh = CreateTexturedCircle(sprites.R[1])
end

function Player:update(dt)
    self:Warp()
    self:move(dt)
    if not (self.xspeed == 0 and self.yspeed == 0) then
        if self.aFrame < 10 then
            self.aFrame = self.aFrame + 1
        else
            self.aFrame = 1
        end
    end
    Player.super.update(self, dt)
end

function Player:draw()
    local x = self.x + self.width /2
    local y = self.y + self.height /2
    local frame = self.aFrame
    local sprite

    if currentFacing == -1 then
        sprite = sprites.L
    else
        sprite = sprites.R
    end

    if not (self.xspeed == 0 and self.yspeed == 0) then
        if frame <= 3 then
            self.mesh:setTexture(sprite[1])
        elseif frame <= 6 and frame > 3 then
            self.mesh:setTexture(sprite[2])
        elseif frame <= 10 and frame > 6 then
            self.mesh:setTexture(sprite[3])
        end
    end

    gfx.draw(self.mesh, x, y, math.rad(r), cellSize/2)
    if Debugger:getStatus() then
        Player.super.draw(self)
    end
    for i = 1, self.lives do
        gfx.draw(sprites.L[1], cellSize * (8 + (i-1)), cellSize * 23 + 5, 0, 0.25)
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
    self.aFrame = 1
    currentFacing = 1
    World:update(self, self.x, self.y)
end

function Player:changeDirection(dir)
    if type(dir) == 'string' then
        local speed = self.speed
        self:stop()
        World:update(self, self.x, self.y)

        if dir == 'up' or dir == 'left' then
            speed = -self.speed
        end

        setSpeed(self, dir, speed)
        setFacing(dir)
        setRotation(dir)
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
    end
end