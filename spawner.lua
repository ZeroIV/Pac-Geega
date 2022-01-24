Spawner = class('Spawner')

function Spawner:new()
    self.isSpawner = true
    self.x = cellSize * 10
    self.y = cellSize * 10
    self.width = cellSize * 5
    self.height = cellSize * 2
    World:add(self, self.x, self.y, self.width, self.height)
end

function Spawner:draw()
    local enemy_spawn_gate = {
        cellSize * 10, cellSize * 10 + (cellSize / 2);
        cellSize * 15, cellSize * 10 + (cellSize / 2);
    }
    DrawLines(enemy_spawn_gate, colors.white)
end

function Spawner:remove()
    World:remove(self)
end