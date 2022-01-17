Pellet = class('Pellet')

local value = 10

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
        gfx.circle('fill', self.x, self.y, self.radius)
    end
end

function Pellet:onCollect()
    local pt = value
    if self.collected == false then
        self.collected = true
    end
    if self.collected == true then

        if self.isPowerPellet then
            pt = pt * 2
            event.push('powerPelletCollected')
        end
        Score = Score + pt * Level
        PelletsCollected = PelletsCollected + 1
        World:remove(self)
    end
end

function Pellet:addToWorld() 
    if not World:hasItem(self) then
        World:add(self, self.x, self.y, 1, 1)
        self.collected = false
    end
end