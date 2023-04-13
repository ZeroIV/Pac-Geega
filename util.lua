local dt = love.timer.getDelta()
gfx = love.graphics
event = love.event
WindowWidth, WindowHeight = gfx.getDimensions()
FloatingTextTimer = 1.5

-- ***************************************************
-- #region  Maze Building + Pathfinding Functions
-- ***************************************************

-- 22 x 23 Map representing game maze where
-- 0 = open, 1 = wall
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

local maxX = #map

-- used for enemy pathfinding
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
    local temp = {}
    for i = 1, #walls do
        for k, w in pairs(walls[i]) do
            table.insert(temp, w)
        end
    end
    walls = temp
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

-- included for compatability with Lua versions earlier than 5.2
function table.pack(...)
    return { n = select('#', ...), ... }
end

function DoDelta(x, vel)
    return x + (vel * dt)
end

-- Returns the closest multiple of 'size' (defaulting to 10).
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end
-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

--- finds the grid point nearest the center of the passed object
---@param e table # the entity that is being passed
---@return number x # nearest x coordinate
---@return number y # nearest y coordinate
function SnapToGrid(e)
    if e then
        local x, y = math.multiple(e.x, 32), math.multiple(e.y, 32)
        
        x = x + 4
        y = y + 4
        return x,y
    end
end

---resets the game maze
---@param partial boolean # true if only entities should be reset
function ResetLevel(partial)

    player:respawn()

    for i = 1, #enemies do
        enemies[i]:respawn()
    end

    if not partial then
        for i = 1, #pellets do
            pellets[i]:addToWorld()
        end
        PelletsCollected = 0
    end
    game.readyTimer = 4
end

function CreateTexturedCircle(image, segments)
	segments = segments or 40
	local vertices = {}
	
	table.insert(vertices, {0, 0, 0.5, 0.5, 1, 1, 1})
	
	-- Create the vertices at the edge of the circle.
	for i=0, segments do
		local angle = (i / segments) * math.pi * 2

		-- Unit-circle.
		local x = math.cos(angle)
		local y = math.sin(angle)
		
		-- Our position is in the range of [-1, 1] but we want the texture coordinate to be in the range of [0, 1].
		local u = (x + 1) * 0.5
		local v = (y + 1) * 0.5
		
		-- The per-vertex color defaults to white.
		table.insert(vertices, {x, y, u, v})
	end
	
	-- The "fan" draw mode is perfect for our circle.
	local mesh = love.graphics.newMesh(vertices, "fan")
    mesh:setTexture(image)
    return mesh
end

--#endregion

-- ***************************************************
-- #region       CUSTOM EVENT HANDLERS
-- ***************************************************

function love.handlers.levelComplete()
    Level = Level + 1
    love.audio.stop()
    ResetLevel(false)
end

function love.handlers.eatEnemy(id)
    local e = enemies[id]
    local transform = love.math.newTransform(e.x,e.y + 16, 0, 1)

    floatingText:set(tostring(200 * Level))
    game.textTransform = transform
    FloatingTextTimer = 1
    e:setState(4)
    Score = Score + 200 * Level
end

function love.handlers.powerPelletCollected()
    local time
    local mt = 5 * (Level/5) -- shorten time based on level
    time = 40
    
    time = (time - mt)
    for k, e in pairs(enemies) do
        e:setVunerable(time)
    end
end

function love.handlers.playerDirectionChange(dir)
    local e = player
    local x, y = e.x, e.y
    local goalX, goalY = x, y
    local align = true
    local canMove = false
    
    if (e.xspeed < 0 and dir == 'left') or (e.xspeed > 0 and dir == 'right') or
            (e.yspeed < 0 and dir == 'up') or (e.yspeed > 0 and dir == 'down') then
        return
    else
        if (e.xspeed == 0 and (dir == 'up' or dir == 'down')) or
            (e.yspeed == 0 and (dir == 'left' or dir == 'right')) then
            align = false
        end

        goalX, goalY = math.multiple(x, 32) / 32, math.multiple(y, 32) / 32

        if dir == 'up' then
            goalY = goalY -1
        elseif dir == 'left' then
            goalX = goalX -1
        elseif dir == 'down' then
            goalY = goalY + 1
        elseif dir == 'right' then
            goalX = goalX + 1
        end

        if goalY == 11 and (goalX <= 0 or goalX >=22) then
            canMove = true
        elseif posIsOpen(goalX, goalY) then
            canMove = true
        end

        if canMove then
            e:changeDirection(dir, align)
        end
    end
end

function love.handlers.PlayerDeath()
    local e = player
    if e.lives >= 1 then
        e.lives = e.lives - 1
        e:respawn()
        ResetLevel(true)
    else
        game.gameOver.open = true
    end
end

--#endregion
