Entity = class('Entity')

function Entity:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.xspeed = 0
    self.yspeed = 0
    World:add(self, self.x, self.y, self.width, self.height)
end

function Entity:getCenter()
    return self.x + (self.width/2), self.y + (self.height/2)
end

function Entity:update(dt)
    World:update(self, self.x, self.y)
end

function Entity:draw(mesh)
    if mesh then
        gfx.draw(mesh, self.x, self.y, math.rad(0), 20)
    else
        gfx.setColor(colors.green)
        gfx.rectangle('line', self.x, self.y, self.width, self.height)
        gfx.setColor(colors.white)
    end
end

function Entity:switchDirection(dir)
    if type(dir) ~= 'string' then
        dir = tostring(dir)
    end

    if dir == 'x' then
        self.xspeed = -self.xspeed
    elseif dir == 'y' then
        self.yspeed = -self.yspeed
    end
end

function Entity:stop(align)
    self.xspeed = 0
    self.yspeed = 0
    if align then
        self.x, self.y = SnapToGrid(self)
    end
end

function Entity:Warp()
    if self.x <= - 40 then
        self.x = WindowWidth + cellSize
        World:update(self, self.x, self.y)
    elseif self.x > WindowWidth + cellSize then
        self.x = 0 - self.width
        World:update(self, 0 - self.width, self.y)
    end
end