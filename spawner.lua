Spawner = class('Spawner')

function Spawner:new()
    
end


---@overload fun(coordinates: table)
---@param coordinates table # table of line coordinates.
---@param color? table # sets color to use when drawing the lines.
---@param width? number # Width of the lines in pixels
---@param lineStyle? string # style used when drawing the lines.
---@param joinStyle? string # style used when joining lines together.
function Spawner:drawWalls(coordinates, color, width, lineStyle, joinStyle)
    gfx.push()
    gfx.setColor(color or {1,1,1})
    gfx.setLineWidth(width or 2)
    gfx.setLineStyle(lineStyle or 'smooth')
    gfx.setLineJoin(joinStyle or 'none')
    gfx.line(coordinates)
    gfx.pop()
    gfx.setColor(colors.white)
end

function Spawner:draw()
    local enemy_spawn_gate = {
        grid.x[13], grid.y[13] + 3;
        grid.x[16], grid.y[13] + 3;
    }
    self:drawWalls(enemy_spawn_gate, colors.white)
end