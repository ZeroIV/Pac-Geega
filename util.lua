local dt = love.timer.getDelta()
ERRORSTRING = 'Something went wrong'
LINESEPERATOR = '\n**********************************************\n'
gfx = love.graphics
event = love.event
WindowWidth, WindowHeight = gfx.getDimensions()
---Draws lines between x, y coordinate sets
---@overload fun(coordinates: table)
---@param coordinates table # table containing line coordinates.
---@param color? table # sets color to use when drawing the lines.
---@param width? number # Width of the lines in pixels
---@param lineStyle? string # style used when drawing the lines.
---@param joinStyle? string # style used when joining lines together.
function DrawLines(coordinates, color, width, lineStyle, joinStyle)
    gfx.push()
    gfx.setColor(color or {1,1,1})
    gfx.setLineWidth(width or 2)
    gfx.setLineStyle(lineStyle or 'smooth')
    gfx.setLineJoin(joinStyle or 'none')
    gfx.line(coordinates)
    gfx.pop()
    gfx.setColor(colors.white)
end

-- ***************************************************
-- #region  Maze Building + Pathfinding Functions
-- ***************************************************

-- 22 x 23 Map representing game maze where
-- 0 = open, 1 = wall
---[[
map = {
    {1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1},
    {1,0,0,0,0,0,0,1,1,1,0,1,1,1,0,0,0,1,0,0,0,1},
    {1,0,1,1,0,1,0,1,1,1,0,1,1,1,0,1,0,1,0,1,0,1},
    {1,0,1,1,0,1,0,1,1,1,0,1,1,1,0,1,0,0,0,1,0,1},
    {1,0,1,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1},
    {1,0,1,1,0,1,1,1,1,1,0,1,1,1,0,1,0,1,1,1,0,1},
    {1,0,1,1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1},
    {1,0,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,0,1,0,1},
    {1,0,1,1,0,1,0,1,0,0,0,1,0,1,0,1,0,1,0,1,0,1},
    {1,0,0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,1},
    {1,1,1,1,0,1,1,1,0,0,0,1,0,1,1,1,0,1,1,1,0,1},
    {1,0,0,0,0,1,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,1},
    {1,0,1,1,0,1,0,1,0,0,0,1,0,1,0,1,0,1,0,1,0,1},
    {1,0,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1,0,1,0,1},
    {1,0,1,1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1},
    {1,0,1,1,0,1,1,1,1,1,0,1,1,1,0,1,0,1,1,1,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1},
    {1,0,1,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,1},
    {1,0,1,1,0,1,0,1,1,1,0,1,1,1,0,1,0,0,0,1,0,1},
    {1,0,1,1,0,1,0,1,1,1,0,1,1,1,0,1,0,1,0,1,0,1},
    {1,0,0,0,0,0,0,1,1,1,0,1,1,1,0,0,0,1,0,0,0,1},
    {1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1}
}
--]]

local maxX = #map

function posIsOpen(x, y)
    -- should return true if the position is open to walk
    local walkable = false
    if map[x][y] == 0 then
        walkable = true
    end
    if walkable then
        return true
    end
end

function GenWall()

    local walls = {}
    for x = 1, maxX do
        local wx
        local wy
        table.insert(walls, x, {})
        for y = 1, #map[x] do
            if map[x][y] == 1 then
                wx, wy = x, y
                table.insert(walls[x], Wall((wx * cellSize), (wy * cellSize), cellSize, cellSize))
            end
        end
    end
    table.insert(walls[1], Wall(0, cellSize * 10, cellSize, cellSize))
    table.insert(walls[1], Wall(0, cellSize * 12, cellSize, cellSize))
    table.insert(walls[23], Wall(WindowWidth - cellSize, cellSize * 10, cellSize, cellSize))
    table.insert(walls[23], Wall(WindowWidth - cellSize, cellSize * 12, cellSize, cellSize))
    return walls
end

function GenPellets()
    local pellets = {}
    for x = 1, maxX do
        local px
        local py
        table.insert(pellets, x, {})
        for y = 1, #map[x] do
            local power = false
            if (y < 9 or y > 14 or x == 6 or x == 18) and
                                    map[x][y] == 0 and not (x == 12 and y ==17) then
                px, py = x, y
                if ((px == 2 or px == 22) and (py == 4 or py == 17)) then
                    power = true
                end
                table.insert(pellets[x], Pellet(px * cellSize + (cellSize / 2), py * cellSize + (cellSize / 2), power))
                TotalPellets = TotalPellets + 1
            end
        end
    end
    local temp = {}
    for i = 1, #pellets do
        for k, p in pairs(pellets[i]) do
            table.insert(temp, p)
        end
    end
    pellets = temp
    return pellets
end

--#endregion

-- ***************************************************
--#region       GENERAL UTIL FUNCTIONS
-- ***************************************************

function table.pack(...)
    return { n = select('#', ...), ... }
end

function DoDelta(x, vel)
    return x + (vel * dt)
end

-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

--- finds the grid point nearest the center of the passed object
---@param e table
---@return number x # nearest x coordinate
---@return number y # nearest y coordinate
function SnapToGrid(e)
    if e then
        return math.round(e.x) + 1, math.round(e.y) + 1
    end
end

--#endregion

-- ***************************************************
-- #region       CUSTOM EVENT HANDLERS
-- ***************************************************

function love.handlers.levelCompleted()
    Level = Level + 1
    game:resetLevel()
end

function love.handlers.enemyKilled(id)
    local e = enemies[id]
    e:changeState(4)
    Score = Score + 200 * Level
end

function love.handlers.powerPelletCollected()
    local time
    local mt = Level -- shorten time based on level
    time = 600

    time = math.round(time / mt)
    for k, e in pairs(enemies) do
        e:makeVunerable(time)
    end
end

function love.handlers.gameover()
    
    game:over()
end

--#endregion
