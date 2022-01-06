local collisionBuffer = 5
local dt = love.timer.getDelta()
ERRORSTRING = 'Something went wrong'
gfx = love.graphics

local function Collision_Correction(e)
    local delta_buffer = DoDelta(e.speed)
    delta_buffer = math.round(delta_buffer)
    if e.xspeed < 0 then
        e.x = e.x + delta_buffer
    elseif e.xspeed > 0 then
        e.x = e.x - delta_buffer
    elseif e.yspeed < 0 then
        e.y = e.y + delta_buffer
    elseif e.yspeed > 0 then
        e.y = e.y - delta_buffer
    end
end

--***************************************************
--              GENERAL UTIL FUNCTIONS
--***************************************************
--#region
function table.pack(...)
    return { n = select('#', ...), ... }
end

function DoDelta(x)
    return (x * dt) / 5
end

-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function GetNearestPoint(e)
    local nearestx
    local nearesty
    for k, v in ipairs(grid.x) do
        local dist = math.abs(v - (player.x + player.width / 2))
        dist = math.round(dist)
        if dist <= 13 then
            nearestx = grid.x[k]
            break
        end
    end
    for k, v in ipairs(grid.y) do
        local dist = math.abs(v - (e.y + e.height / 2))
        dist = math.round(dist)
        if dist <= 13 then
            nearesty = grid.y[k]
            break
        end
    end
    nearestx = nearestx - e.width / 2
    nearesty = nearesty - e.height / 2
    return nearestx, nearesty
end
--#endregion
--***************************************************
--              CUSTOM EVENT HANDLERS
--***************************************************
--#region
function love.handlers.onCollide(e) --TODO: breaks game if direction is changed before correction is applied
    Collision_Correction(player)
    player:stop()
    player.x, player.y = GetNearestPoint(player)
end

function love.handlers.directionChange(axis, change)
    local e = player
    local canMove = true
    local nearestx ,nearesty = GetNearestPoint(e) --TODO: breaks if e is outside grid (i.e. warping)

    if axis == 'x' then --movement on x axis
        for k, v in ipairs(grid.y) do
            local distance = math.abs(v - (player.y + player.height / 2))
            distance = math.round(distance)
            if distance <= 13 then
                nearesty = grid.y[k]
                break
            end
        end
        if change < 0 then
            for k, v in ipairs(walls) do
                if CheckCollision(e.x - cellSize, e.y, e.width, e.height,
                                            v.x, v.y - 5, v.width, v.height - 5) then
                    canMove = false
                    break
                end
            end
        else
            for k, v in ipairs(walls) do
                if CheckCollision(e.x + cellSize, e.y, e.width, e.height,
                                            v.x, v.y , v.width, v.height) then
                    canMove = false
                    break
                end
            end
        end
        if canMove then
            player.y = nearesty - player.height / 2
            e:changeDirection(axis, change)
        end
    else -- moving on y axis
        for k, v in ipairs(grid.x) do
            local distance = math.abs(v - (player.x + player.width / 2))
            distance = math.round(distance)
            if distance <= 13 then
                nearestx = grid.x[k]
                break
            end
        end
        if change < 0 then
            for k, v in ipairs(walls) do
                if CheckCollision(e.x, e.y - cellSize, e.width, e.height,
                                            v.x, v.y , v.width, v.height) then
                    canMove = false
                    break
                end
            end
        else --moving down
            for k, v in pairs(walls) do
                if CheckCollision(e.x, e.y + cellSize, e.width - 5, e.height,
                                            v.x, v.y , v.width, v.height) then
                    canMove = false
                    break
                end
            end
        end
        if canMove then
            player.x = nearestx - player.width / 2
            e:changeDirection(axis, change)
        end
    end
end

function love.handlers.onDeath()
    gfx.translate(100, 100)
    local t = love.timer.getTime()
    gfx.shear(math.cos(t), math.cos(t * 1.3))
    self:draw()
end
--#endregion
