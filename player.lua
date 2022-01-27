Player = Entity:extend('Player')

local startx, starty

local sprites = {
    L = { gfx.newImage('sprites/Geeg/geeg_left_1.png'), 
            gfx.newImage('sprites/Geeg/geeg_left_2.png'), 
            gfx.newImage('sprites/Geeg/geeg_left_3.png')
        },

    R = { gfx.newImage('sprites/Geeg/geeg_right_1.png'),
            gfx.newImage('sprites/Geeg/geeg_right_2.png'),
            gfx.newImage('sprites/Geeg/geeg_right_3.png')
        },
}
local sounds = {
    -- death = Sound('sounds/player_death.wav'), 
    eat_1 = Sound('sounds/geeg_diechild.mp3', 75/100),
    eat_2 = Sound('sounds/geeg_disgusting.mp3', 75/100),
    munch_1 = Sound('sounds/munch_1.wav', 30/100),
    munch_2 = Sound('sounds/munch_2.wav', 30/100),
}

local r = 0
local currentFacing = 0 -- used in sprite animations
local callbacks = {}

local playerFilter = function(item, other)
    if     other.isEnemy then return 'cross'
    elseif other.isWall   then return 'slide'
    elseif other.isSpawner then return 'slide'
    elseif other.isPellet   then return 'cross'
    end
    -- else return nil
end

-- #region Local Player methods

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

local function MoveUp(e)
    e:stop()
    e.yspeed = -e.speed
end

local function MoveDown(e)
    e:stop()
    e.yspeed = e.speed
end

local function MoveLeft(e)
    e:stop()
    e.xspeed = -e.speed
end

local function MoveRight(e)
    e:stop()
    e.xspeed = e.speed
end



PlayerDeathAnim = function()
    gfx.translate(25, 25)
    local t = love.timer.getTime()
    gfx.shear(math.cos(t), math.cos(t * 1.3))
end

-- #endregion

function Player:init(x, y, width, height)
    self.isPlayer = true
    self.speed = 120
    startx, starty = x + 4, y + 4
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.lives = 2
    -- Player.super.init(self, x + 6, y + 6, width - 12, height - 12)
    Player.super.init(self, x +4, y + 4, width - 8, height -8)
    self.aFrame = 1
    self.mesh = CreateTexturedCircle(sprites.R[1])
end

function Player:getSprites() return sprites end

function Player:update(dt)
    self:Warp()
    self:move(dt)

    for k, call in pairs(callbacks) do
        if (self.x == call.x * 32 and self.y == call.y * 32) then
            
        end
    end

    if not (self.xspeed == 0 and self.yspeed == 0) then
        if self.aFrame == 4 then
            sounds.munch_1:play()
        elseif self.aFrame == 11 then
            sounds.munch_2:play()
        end
        if self.aFrame < 14 then
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
        elseif frame <= 8 and frame > 3 then
            self.mesh:setTexture(sprite[2])
        elseif frame <= 14 and frame > 8 then
            self.mesh:setTexture(sprite[3])
        end
    end
    if Debugger:getStatus() then
        Player.super.draw(self)
    end
    for i = 1, self.lives do
        gfx.draw(sprites.L[1], cellSize * (8 + (i-1)), cellSize * 23 + 5, 0, 0.25)
    end

    gfx.draw(self.mesh, x, y, math.rad(r), cellSize/2)
end


function Player:move(dt)
    local goalX, goalY = self.x + self.xspeed * dt, self.y + self.yspeed * dt
    local actualX, actualY, cols, len = World:move(player, goalX, goalY, playerFilter)
    self.x, self.y = actualX, actualY
    -- deal with the collisions

    for i=1,len do
        local other = cols[i].other
        if other.isPellet then
            other:onCollect()
        end
        if other.isEnemy then
            if other.state == 3 then
                if math.random(8) > 4 then
                    sounds.eat_2:play()
                else
                    sounds.eat_1:play()
                end
                event.push('eatEnemy', other.id)
            elseif other.state == 4 then
                return
            else
                event.push('onDeath')
            end
        end
        if other.isWall or other.isSpawner then
            self:stop()
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

function Player:changeDirection(dir, align)
    if type(dir) == 'string' then
        local speed = self.speed
        self:stop(align)
        World:update(self, self.x, self.y)

        if dir == 'up' or dir == 'left' then
            speed = -self.speed
        end

        setSpeed(self, dir, speed)
        setFacing(dir)
        setRotation(dir)
    end
end