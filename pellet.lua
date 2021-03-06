Pellet = class('Pellet')

local value = 10
local sprite = gfx.newImage('sprites/the_juice.png')

local function remove(e)
    World:remove(e)
end

function Pellet:init(x, y, power)
    self.isPellet = true
    self.isPowerPellet = power or false
    self.x = x
    self.y = y
    if self.isPowerPellet then
        self.radius = 6
    else
        self.radius = 2
    end
    self.active = true
    self.collected = false
    self:addToWorld()
end

function Pellet:update(dt)

end

function Pellet:draw()
    if not self.collected then
        if self.isPowerPellet and sprite then
            gfx.draw(sprite, self.x - 16, self.y - 16, 0, 0.5)
        else
            gfx.circle('fill', self.x, self.y, self.radius)
        end
    end
end

function Pellet:onCollect(sfx)
    local pt = value
    if self.collected == false then
        self.collected = true
    end
    if self.collected == true then

        if self.isPowerPellet then
            pt = pt * 2
            sfx:play()
            event.push('powerPelletCollected')
        end
        Score = Score + pt * Level
        PelletsCollected = PelletsCollected + 1
        remove(self)
    end
end

function Pellet:addToWorld() 
    if not World:hasItem(self) then
        World:add(self, self.x, self.y, 1, 1)
        self.collected = false
    end
end

