Wall = class('Wall')

function Wall:init(x, y, width, height)
    self.isWall = true
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    World:add(self, self.x, self.y, self.width, self.height)
end

function Wall:draw()
    gfx.setColor(colors.blue)
    gfx.rectangle('fill', self.x, self.y, self.width, self.height)
    gfx.setColor(colors.white)
end