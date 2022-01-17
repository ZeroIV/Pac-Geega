Menu = class('Menu')

function Menu:init(title, items, spacing, xOrigin, yOrigin)
    self.title = title
    self.items = items
    self.itemSpacing = spacing or 50
    self.xMenuOrigin = xOrigin or cellSize * 11
    self.yMenuOrigin = yOrigin or cellSize * 11
    self.selection = 1
    self.maxSelections = #items
    self.open = false
end

function Menu:update(dt)
    
end

function Menu:keypressed(k)
    
    if self.open then
        if (k == 'up' or k == 'w') and self.selection > 1 then
            self.selection = self.selection - 1
        elseif (k == 'down' or k == 's') and self.selection < self.maxSelections then
            self.selection = self.selection + 1
        end
    end
end

function Menu:getUserSelection()
    return self.selection
end

function Menu:draw()
    local items = self.items
    local select = self.selection
    if self.open then

        gfx.draw(self.title, WindowWidth * 0.35 , 100, 0, 3,3)

        for k, v in pairs(items) do
            gfx.draw(items[k], self.xMenuOrigin, self.yMenuOrigin + (self.itemSpacing * (k-1)), 0 , 2, 2)
        end
        --displays which option is currently selected
        gfx.rectangle('line', self.xMenuOrigin -10, self.yMenuOrigin + self.itemSpacing * (select - 1),
                                    items[select]:getWidth() * 2 + 20, items[select]:getHeight() * 2 + 5)
    end
end