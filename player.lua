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
    death = { gfx.newImage('sprites/Geeg/geeg_death_1.png'),
             gfx.newImage('sprites/Geeg/geeg_death_2.png'),
             gfx.newImage('sprites/Geeg/geeg_death_3.png'),
             gfx.newImage('sprites/Geeg/geeg_death_4.png'),
             gfx.newImage('sprites/Geeg/geeg_death_5.png'),
             gfx.newImage('sprites/Geeg/geeg_death_6.png'),
        }
}
local sounds = {
    death_voice = Sound('sounds/geeg_death.wav'),
    death_noise_1 = Sound('sounds/death_1.wav', 80/100),
    death_noise_2 = Sound('sounds/death_2.wav'),
    eat_1 = Sound('sounds/geeg_diechild.mp3', 75/100),
    eat_2 = Sound('sounds/geeg_disgusting.mp3', 75/100),
    eat_3 = Sound('sounds/geeg_square-up.wav', 75/100),
    powerPellet = Sound('sounds/geeg_ooh_high.mp3'),
    munch_1 = Sound('sounds/munch_1.wav', 30/100),
    munch_2 = Sound('sounds/munch_2.wav', 30/100),
}

local r = 0
local currentFacing = 0 -- used in sprite animations
local playDeathAnim = false
local animFrame = 0

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

local PlayerDeathAnim = function(e)
    local sprites = sprites.death
    local frame = animFrame
    local keyframe = 25
    if frame >= keyframe * 6 then
        e.mesh:setTexture(sprites[1])
    elseif frame >= keyframe * 5 then
        e.mesh:setTexture(sprites[2])
    elseif frame >= keyframe * 4 then
        e.mesh:setTexture(sprites[3])
    elseif frame >= keyframe * 3 then
        e.mesh:setTexture(sprites[4])
    elseif frame >= keyframe * 2 then
        e.mesh:setTexture(sprites[5])
    elseif frame >= keyframe then
        e.mesh:setTexture(sprites[6])
    end
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

    Player.super.init(self, x + 4, y + 4, width - 8, height - 8)
    
    self.aFrame = 1
    self.mesh = CreateTexturedCircle(sprites.R[1])
end

function Player:getSprites() return sprites end
function Player:getAnimStatus() return playDeathAnim end

function Player:update(dt)
    self:Warp()
    self:move(dt)
    if playDeathAnim then
        if animFrame > 0 then
            animFrame = animFrame - 1
        else
            sounds.death_noise_2:play()
            event.push('PlayerDeath')
        end
    elseif not (self.xspeed == 0 and self.yspeed == 0) then
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

    for i = 1, self.lives do
        gfx.draw(sprites.L[1], cellSize * (8 + (i-1)), cellSize * 23 + 5, 0, 0.25)
    end

    if playDeathAnim then
        PlayerDeathAnim(self)
    elseif not (self.xspeed == 0 and self.yspeed == 0) then
        if frame <= 3 then
            self.mesh:setTexture(sprite[1])
        elseif frame <= 8 and frame > 3 then
            self.mesh:setTexture(sprite[2])
        elseif frame <= 14 and frame > 8 then
            self.mesh:setTexture(sprite[3])
        end
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
            other:onCollect(sounds.powerPellet)
        end
        if other.isEnemy then
            if other.state == 3 then
                local x = math.random(9)
                if x <= 3 then
                    sounds.eat_3:play()
                elseif x <= 6 and x > 3 then
                    sounds.eat_2:play()
                elseif x > 6 then
                    sounds.eat_1:play()
                end
                event.push('eatEnemy', other.id)
            elseif other.state == 4 then
                return
            elseif not playDeathAnim then
                self:stop()
                animFrame = 175
                r = 0
                sounds.death_voice:play()
                sounds.death_noise_1:play()
                playDeathAnim = true
            end
        end
        if other.isWall or other.isSpawner then
            self:stop()
        end
    end
end

function Player:respawn()
    playDeathAnim = false
    self.x, self.y = startx, starty
    self.aFrame = 1
    currentFacing = 1
    self.mesh:setTexture(sprites.L[1])
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