Wall = Object:extend()

local gfx = love.graphics
local grid = {
    x = {},
    y ={}
}
local cellSize = 25

function Wall:new()
    transform = love.math.newTransform()
    transform:translate(cellSize, cellSize)
    Wall:buildGrid()
end

function Wall:update(dt)

end

function Wall:buildGrid() 
    for x = 0, WINDOW_WIDTH, cellSize do
        table.insert(grid.x, x / cellSize, x)
    end
    for y = 0, WINDOW_HEIGHT, cellSize do
        table.insert(grid.y, y / cellSize, y)
    end
end

function Wall:drawInnerWall(x, y, width, height, ...)
    local wall2 = table.pack(...)
    gfx.push()
    gfx.setBlendMode('alpha') --Default blend mode
    gfx.rectangle('fill', x, y, width, height, 10)
    if wall2.n == 4 then
        --gfx.setBlendMode('add', 'alphamultiply')
        gfx.rectangle('fill', wall2[1], wall2[2], wall2[3], wall2[4], 10)
    end
    gfx.pop()
end
function Wall:drawOuterWalls()
    gfx.push()
    gfx.applyTransform(transform)
    local wall_top = {

        --top left warp wall
        0, grid.y[13];
        grid.x[5], grid.y[13];
        grid.x[5], grid.y[9];
        0, grid.y[9];

        --top border wall
        0, 0;
        grid.x[13], 0;
        grid.x[13], grid.y[4];
        grid.x[14], grid.y[4];
        grid.x[14], 0;
        grid.x[27], 0;

        --top right warp wall
        grid.x[27], grid.y[9];
        grid.x[22], grid.y[9];
        grid.x[22], grid.y[13];
        grid.x[27], grid.y[13];
    }
    local wall_bottom = {

        --bottom left warp wall
        0, grid.y[15];
        grid.x[5], grid.y[15];
        grid.x[5], grid.y[19];
        0, grid.y[19];

        --bottom left wall
        0, grid.y[24];
        grid.x[2], grid.y[24];
        grid.x[2], grid.y[25];
        0, grid.y[25];

        --bottom border wall
        0, grid.y[30];
        grid.x[27], grid.y[30];

        --bottom right wall
        grid.x[27], grid.y[25];
        grid.x[25], grid.y[25];
        grid.x[25], grid.y[24];
        grid.x[27], grid.y[24];

        --bottom right warp wall
        grid.x[27], grid.y[19];
        grid.x[22], grid.y[19];
        grid.x[22], grid.y[15];
        grid.x[27], grid.y[15];
    }
    gfx.setLineWidth(2)
    gfx.setLineStyle('smooth')
    gfx.setLineJoin('none')
    gfx.line(wall_top)
    gfx.line(wall_bottom)
    gfx.pop()
end
function Wall:draw()
    Wall:drawOuterWalls()

    gfx.rectangle('line', grid.x[11], grid.y[13], cellSize * 7, cellSize * 4)

    Wall:drawInnerWall(grid.x[3], grid.y[3], cellSize * 3, cellSize * 2)
    Wall:drawInnerWall(grid.x[8], grid.y[3], cellSize * 4, cellSize * 2)

    Wall:drawInnerWall(grid.x[17], grid.y[3], cellSize * 4, cellSize * 2)
    Wall:drawInnerWall(grid.x[23], grid.y[3], cellSize * 3, cellSize * 2)

    Wall:drawInnerWall(grid.x[3], grid.y[7], cellSize * 3, cellSize)
    Wall:drawInnerWall(grid.x[23], grid.y[7], cellSize * 3, cellSize)

    Wall:drawInnerWall(grid.x[8], grid.y[7], cellSize, cellSize * 7,
                        grid.x[8], grid.y[10], cellSize * 4 , cellSize)
    Wall:drawInnerWall(grid.x[20], grid.y[7], cellSize, cellSize * 7,
                        grid.x[17], grid.y[10], cellSize * 4 , cellSize)

    Wall:drawInnerWall(grid.x[8], grid.y[16], cellSize, cellSize * 4)
    Wall:drawInnerWall(grid.x[20], grid.y[16], cellSize, cellSize * 4)

    Wall:drawInnerWall(grid.x[11], grid.y[7], cellSize * 7, cellSize,
                        grid.x[14], grid.y[7], cellSize , cellSize * 4)
    Wall:drawInnerWall(grid.x[11], grid.y[19], cellSize * 7, cellSize,
                        grid.x[14], grid.y[19], cellSize , cellSize * 4)
    Wall:drawInnerWall(grid.x[11], grid.y[25], cellSize * 7, cellSize,
                        grid.x[14], grid.y[25], cellSize , cellSize * 4)

    Wall:drawInnerWall(grid.x[3], grid.y[22], cellSize * 3, cellSize,
                        grid.x[5],grid.y[22], cellSize, cellSize * 4)

    Wall:drawInnerWall(grid.x[23], grid.y[22], cellSize * 3, cellSize,
                        grid.x[23],grid.y[22], cellSize, cellSize * 4)

    Wall:drawInnerWall(grid.x[8], grid.y[22], cellSize * 4, cellSize)
    Wall:drawInnerWall(grid.x[17], grid.y[22], cellSize * 4, cellSize)

    Wall:drawInnerWall(grid.x[3], grid.y[28], cellSize * 9, cellSize,
                        grid.x[8], grid.y[25], cellSize, cellSize * 4)
    Wall:drawInnerWall(grid.x[17], grid.y[28], cellSize * 9, cellSize,
                        grid.x[20], grid.y[25], cellSize, cellSize * 4)
end