--Wall = Object:extend()
Wall = class('Wall')

function Wall:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function Wall:getOrigin()
    return self.x, self.y
end

function Wall:getDimensions()
    local top = self.y
    local left = self.x
    local bottom = self.y + self.height
    local right = self.x + self.width
    return top, left, bottom, right
end

function Wall:draw()
    gfx.rectangle('fill', self.x, self.y, self.width, self.height, 10)
end