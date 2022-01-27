MainMenu = Menu:extend('MainMenu')

local timer = 8
local aFrame = 1
local entity1Textures = nil
local entity1Mesh = CreateTexturedCircle()
local entity2Mesh = CreateTexturedCircle()

local function MoveEntity(e, dt)
    e.x = e.x + e.xspeed * dt
end

function MainMenu:init(title, options)
    self.title = title
    self.options = options
    self.player = nil
    self.enemy = nil
    self:createAnim()
    MainMenu.super.init(self, title, options)
end

function MainMenu:update(dt)
    if timer > 0 then
        timer = timer - dt
        if aFrame < 14 then
            aFrame = aFrame + 1
        else
            aFrame = 1
        end
        MoveEntity(self.player, dt)
        MoveEntity(self.enemy, dt)
    else
        self:createAnim()
        timer = 8
    end
end

function MainMenu:draw()
    local footerText = gfx.newText(gameFont, 'Music: \'Good Mood Theme\' by Wyver9 on Newgrounds.com')
    if aFrame <= 3 then
        entity1Mesh:setTexture(entity1Textures[1])
    elseif aFrame <= 8 and aFrame > 3 then
        entity1Mesh:setTexture(entity1Textures[2])
    elseif aFrame <= 14 and aFrame > 8 then
        entity1Mesh:setTexture(entity1Textures[3])
    end
    self.player:draw(entity1Mesh)
    self.enemy:draw(entity2Mesh)
    gfx.draw(footerText, cellSize, WindowHeight - cellSize, 0, 1)
    self.super.draw(self)
end

function MainMenu:createAnim()
    local e1 = Entity:create()
    local e2 = Entity:create()
    local spd = 128
    local y1 = math.random(128, WindowHeight - 128)
    local y2 = y1
    local x1, x2 = -120, -50
    local w, h = 32, 32
    local texture1 = Player:getSprites()
    local texture2 = Enemy:getSprites()

    if math.random(8) > 4  then
        x1 = WindowWidth + 120
        x2 = x1 - 70
        spd = -spd
        entity1Textures = texture1.L
    else
        entity1Textures = texture1.R
    end
    entity1Mesh:setTexture(entity1Textures[1])
    entity2Mesh:setTexture(texture2[math.random(4)][6])
    e1.x, e1.y, e1.width, e1.height, e1.xspeed = x1, y1, w, h, spd
    e2.x, e2.y, e2.width, e2.height, e2.xspeed = x2, y2, w, h, spd
    self.player, self.enemy = e1, e2
end
