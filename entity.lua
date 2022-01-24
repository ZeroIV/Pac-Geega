Entity = class('Entity')

function Entity:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.xspeed = 0
    self.yspeed = 0
    self.idleTimer = 1
    World:add(self, self.x, self.y, self.width, self.height)
end

function Entity:update(dt)
    if self.xspeed == 0 and self.yspeed == 0 then
        self.idleTimer = self.idleTimer - dt
    else
        self.idleTimer = 1
    end
    World:update(self, self.x, self.y)
end

function Entity:draw()
    gfx.setColor(colors.green)
    gfx.rectangle('line', self.x, self.y, self.width, self.height)
    gfx.setColor(colors.white)
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
        self.x = WindowWidth
        World:update(self, self.x, self.y)
    elseif self.x > WindowWidth then
        self.x = 0 - self.width
        World:update(self, 0 - self.width, self.y)
    end
end