Enemy = Entity:extend('Enemy')

local enemySprites = {
    {
        gfx.newImage('sprites/mobs/monster/monster_idle.png'),
        gfx.newImage('sprites/mobs/monster/monster_up.png'),
        gfx.newImage('sprites/mobs/monster/monster_down.png'),
        gfx.newImage('sprites/mobs/monster/monster_left.png'),
        gfx.newImage('sprites/mobs/monster/monster_right.png'),
        gfx.newImage('sprites/mobs/monster/monster_vul.png'),
        gfx.newImage('sprites/mobs/monster/monster_dead.png')
    },

    {
        gfx.newImage('sprites/mobs/undead/undead_idle.png'),
        gfx.newImage('sprites/mobs/undead/undead_up.png'),
        gfx.newImage('sprites/mobs/undead/undead_down.png'),
        gfx.newImage('sprites/mobs/undead/undead_left.png'),
        gfx.newImage('sprites/mobs/undead/undead_right.png'),
        gfx.newImage('sprites/mobs/undead/undead_vul.png'),
        gfx.newImage('sprites/mobs/undead/undead_dead.png')
    },

    {
        gfx.newImage('sprites/mobs/creature/creature_idle.png'),
        gfx.newImage('sprites/mobs/creature/creature_up.png'),
        gfx.newImage('sprites/mobs/creature/creature_down.png'),
        gfx.newImage('sprites/mobs/creature/creature_left.png'),
        gfx.newImage('sprites/mobs/creature/creature_right.png'),
        gfx.newImage('sprites/mobs/creature/creature_vul.png'),
        gfx.newImage('sprites/mobs/creature/creature_dead.png')
    },

    {
        gfx.newImage('sprites/mobs/waffles/waffles_idle.png'),
        gfx.newImage('sprites/mobs/waffles/waffles_up.png'),
        gfx.newImage('sprites/mobs/waffles/waffles_down.png'),
        gfx.newImage('sprites/mobs/waffles/waffles_left.png'),
        gfx.newImage('sprites/mobs/waffles/waffles_right.png'),
        gfx.newImage('sprites/mobs/waffles/waffles_vul.png'),
        gfx.newImage('sprites/mobs/waffles/waffles_dead.png')
    },
}

local sounds ={
    ghost = Sound('sounds/retreating.wav', 30/100),
    vulnerable = Sound('sounds/power_pellet.wav', 50/100)
}

local vul_timer = 0
local base_speed = 90
local vframes = 10

local enemyFilter = function(item, other)
    if other.isPlayer then return 'cross' end
    -- else return nil
end

local function reset_path(e)
    e.path = nil
    e.step = 1
end

local function getSprites(x)
    return enemySprites[x]
end

function Enemy:init(x, y, width, height, id)
    self.isEnemy = true
    self.id = id
    self.state = 0 -- 0 = roam, 1 = pursuit, 2 = guard, 3 = vunerable, 4 = dead
    self.speed = base_speed + (Level * 10)
    self.startx = x
    self.starty = y
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.path = nil
    self.playerDistance = nil
    self.pursuitTimer = 0
    self.step = 1
    self.sprites = enemySprites[id]
    self.activeSprite = self.sprites[1]
    self.sounds = sounds
    Enemy.super.init(self, x, y, width, height)
end

function Enemy:update(dt)
    self:Warp()
    self.playerDistance = self:getPlayerDistance() or math.huge

    if self.playerDistance >= 0 and self.playerDistance < 4 and
                                not (self.state == 1 or self.state == 3 or self.state == 4) then
        self:setState(1)
    elseif self.playerDistance > 6 and self.state == 1 then
        self:setState(0)
        self.pursuitTimer = 5
    end

    if self.pursuitTimer > 0 and self.state == 0 then
        self.pursuitTimer = self.pursuitTimer - dt
    end

    if vul_timer > 0 then
        vul_timer = vul_timer - dt 
    elseif (vul_timer <= 0 and self.state == 3) or
                (self.pursuitTimer <= 0 and self.state == 0) then
        vul_timer = 0
        self.sounds.vulnerable:stop()
        self:setState(2)
    end

    if self.path then
        self:checkPath(self.step, dt)
    else
        self:requestPath()
    end

    Enemy.super.update(self, dt)
end

function Enemy:draw()
    local sprites = self.sprites
    if Debugger:getStatus() then
        Enemy.super.draw(self)
    end

    if self.state == 4 then
        self.activeSprite = sprites[7]
    elseif (self.state == 3 and vul_timer < 10 and math.round(vul_timer % 2) == 0) or
                                            (vul_timer > 10 and self.state == 3)  then
        self.activeSprite = sprites[6]
    elseif self.yspeed < 0 then
        self.activeSprite = sprites[2]
    elseif self.yspeed > 0 then
        self.activeSprite = sprites[3]
    elseif self.xspeed < 0 then
        self.activeSprite = sprites[4]
    elseif self.xspeed > 0 then
        self.activeSprite = sprites[5]
    end

    gfx.draw(self.activeSprite, self.x, self.y, 0, 0.25)
end

-- generates path based on current state
function Enemy:requestPath()
    local mapsize = #map
    local start = { x = math.round(self.x / cellSize), y = math.round(self.y / cellSize) }
    local goal
    if self.state == 0 or self.state == 3 then -- roam map aimlessly
        goal = { x = math.random(2, mapsize), y = math.random(2, mapsize) }
    elseif self.state == 1 then -- pursue player
        goal = { x = math.round(player.x / cellSize), y = math.round(player.y / cellSize) }
    elseif self.state == 2 then -- navigate respective corner
        if self.id == 1 then
            goal = { x = math.random(1, 11), y = math.random(2, 7) }
        elseif self.id == 2 then
            goal = { x = math.random(13, 22), y = math.random(2, 7) }
        elseif self.id == 3 then
            goal = { x = math.random(1, 11), y = math.random(15, 21) }
        else
            goal = { x = math.random(13, 22), y = math.random(15, 21) }
        end
    elseif self.state == 4 then -- after being eaten rushes back to respawn
        local speed = self.speed
        self.sounds.ghost:play(true)
        goal = { x = self.startx / cellSize, y = self.starty / cellSize }
        self.speed = speed * 1.25
    end
    self.path = luastar:find(mapsize, mapsize - 1, start, goal, posIsOpen, true, true)
end

-- navigate to next node in path
function Enemy:checkPath(i, dt)
    local x = math.round(self.x/cellSize, 1)
    local y = math.round((self.y)/cellSize, 1)
    local speed = self.speed
    local path = self.path
    if (#path >= 5 or self.state == 1 or self.state == 4) then -- don't bother with short sporatic paths
        local goalx = path[i].x
        local goaly = path[i].y
        if y < goaly then
            self:stop()
            self.yspeed = speed
        elseif y > goaly then
            self:stop()
            self.yspeed = -speed
        elseif x < goalx then
            self:stop()
            self.xspeed = speed
        elseif x > goalx then
            self:stop()
            self.xspeed = -speed
        elseif x == goalx and y == goaly and self.step < #path then
            self:stop()
            self.step = self.step + 1
        end
        self:move(dt)
    else
        self:requestPath()
    end
end

function Enemy:move(dt)
    if self.step < #self.path then
        local goalX, goalY = self.x + self.xspeed * dt, self.y + self.yspeed * dt
        local actualX, actualY, cols, len = World:move(self, goalX, goalY, enemyFilter)
        self.x, self.y = actualX, actualY

        for i=1,len do
            local other = cols[i].other
            if other.isPlayer then
                if not self.state == 4 then
                    self:stop()
                    reset_path(self)
                end
            end
        end

    elseif self.step == #self.path then -- path completed
        if self.state == 4 then
            self:respawn()
        end
        reset_path(self)
    end
end

-- finds the players distance in relation to the grid
function Enemy:getPlayerDistance()
    local mapsize = #map
    local start = { x = math.round(self.x / cellSize), y = math.round(self.y / cellSize) }
    local goal
    local distMap
    local dist

    goal = { x = math.round(player.x / cellSize), y = math.round(player.y / cellSize) }
    distMap = luastar:find(mapsize, mapsize - 1, start, goal, posIsOpen, true, true)
    if distMap then
        dist = #distMap
    end
    
    return dist
end

function Enemy:respawn()
    self.speed = base_speed + (Level * 10)
    self.state = 2
    self.step = 1
    self.path = nil
    self.sounds.ghost:stop()
    self.x, self.y = self.startx, self.starty
    World:update(self, self.x, self.y)
end

function Enemy:setState(x)
    self.state = x
    if self.pursuitTimer > 0 then
        self.pursuitTimer = 0
    end
    reset_path(self)
end

function Enemy:setVunerable(time)
    vul_timer = time
    self.sounds.vulnerable:play(true)
    self:setState(3)
end