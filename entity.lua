Entity = Object:extend()

function Entity:new(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.xspeed = 0
    self.yspeed = 0
end

function Entity:update(dt)
    self.x = self.x + self.xspeed * dt
    self.y = self.y + self.yspeed * dt
    self.xOrigin = self.x + self.width / 2
    self.yOrigin = self.y - self.height / 2

    -- if self.y <= 0 then
    --     self.y = 0
    --     self.yspeed = -self.yspeed
    -- elseif self.y + self.height >= WINDOW_HEIGHT then
    --     self.y = WINDOW_HEIGHT - self.height
    --     self.yspeed = -self.yspeed
    -- end

end

function Entity:getDimensions()
    return self.x, self.y, self.width, self.height
end

function Entity:stop()
    self.xspeed = 0
    self.yspeed = 0
end

function Entity:Warp()
    if self.x <= - 40 then
        self.x = WINDOW_WIDTH
    elseif self.x > WINDOW_WIDTH then
        self.x = 0 - self.width
    end
end

function Entity:draw()
    gfx.rectangle('fill', self.x, self.y, self.width, self.height)
end