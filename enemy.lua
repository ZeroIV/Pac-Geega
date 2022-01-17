Enemy = Entity:extend('Enemy')

local vunerable_color = {0/255, 0/255, 200/255}
local vunerable_timer = 0
local enemySprites

local enemyFilter = function(item, other)
    if other.isPlayer then return 'cross' end
    -- else return nil
end

local function reset_path(e)
    e.path = nil
    e.step = 1
end

-- local function add_sprite(s)
--     enemySprites = gfx.newSpriteBatch(s, 6)
-- end


function Enemy:init(x, y, width, height, color, id)
    self.isEnemy = true
    self.id = id or 0
    self.state = 0 -- 0 = roam, 1 = pursuit, 2 = guard, 3 = vunerable, 4 = dead
    self.speed = 90 + (Level * 10)
    self.startx = x
    self.starty = y
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.color =  color
    self.path = nil
    self.step = 1
    --self.sprite = gfx.newImage('sprites/mobs/creature_idle.png')
    Enemy.super.init(self, x, y, width, height)
end

function Enemy:update(dt)
    self:Warp()

    if vunerable_timer > 0 then
        vunerable_timer = vunerable_timer - dt
    elseif vunerable_timer <= 0 and self.state == 3 then
        self:changeState(2)
    end
    if self.path then
        self:checkPath(self.step, dt)
    else
        self:requestPath()
    end
    Enemy.super.update(self, dt)
end

function Enemy:draw()
    local x = self.x + self.width / 2
    local y = self.y + self.height / 2
    if Debugger:getStatus() then
        Enemy.super.draw(self)
    end
    if self.state == 3 then
        gfx.setColor(vunerable_color)
    else
        gfx.setColor(colors.red)
    end
    -- gfx.draw(self.sprite, self.x, self.y, 0, 0.25)
    gfx.circle('fill', x, y, math.round(cellSize / 3))
    gfx.setColor(colors.white)
end

-- generates path based on current state
function Enemy:requestPath()
    local mapsize = #map
    local start = { x = math.round(self.x / cellSize), y = math.round(self.y / cellSize) }
    local goal
    if self.state == 0 then
        goal = { x = math.random(2, mapsize), y = math.random(2, mapsize) }
    elseif self.state == 1 then
        goal = { x = math.round(player.x / cellSize), y = math.round(player.y / cellSize) }

    elseif self.state == 2 then
        if self.id == 1 then
            goal = { x = math.random(1, 11), y = math.random(2, 7) }
        elseif self.id == 2 then
            goal = { x = math.random(13, 22), y = math.random(2, 7) }
        elseif self.id == 3 then
            goal = { x = math.random(1, 11), y = math.random(15, 21) }
        else
            goal = { x = math.random(13, 22), y = math.random(15, 21) }
        end
    elseif self.state == 3 then -- vunerable state; should flee from player
        return
    elseif self.state == 4 then -- after being eaten rushes back to respawn
        goal = { x = self.startx / cellSize, y = self.starty / cellSize }
        self.speed = self.speed * 1.5
    end
    self.path = luastar:find(mapsize, mapsize - 1, start, goal, posIsOpen, true, true)
end

-- navigate to next node in path
function Enemy:checkPath(i, dt)
    local x = math.round(self.x/cellSize, 1)
    local y = math.round((self.y)/cellSize, 1)
    local speed = self.speed
    local path = self.path
    if path[i].x and path[i].y and #path >= 6 then -- don't bother with short sporatic paths
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

function Enemy:respawn()
    self.speed = 90 + (Level * 10)
    self.state = 2
    self.step = 1
    self.path = nil
    self.x, self.y = self.startx, self.starty
    World:update(self, self.x, self.y)
end

function Enemy:changeState(x)
    self.state = x
    reset_path(self)
end

function Enemy:makeVunerable(time)
    vunerable_timer = time
    self:changeState(3)
end