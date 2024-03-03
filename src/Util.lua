function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetWidth = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spriteSheet = {}
    
    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spriteSheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spriteSheet
end

function table.slice(table1, first, last, step)
    local sliced = {}
    for i = first or 1, last or #table1, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

function GenerateQuadsPaddles(atlas)

    local x = 0
    local y = 64

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        
        quads[counter] = love.graphics.newQuad(x, y, 32, 16,
            atlas:getDimensions())
        counter = counter + 1
        
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16,
            atlas:getDimensions())
        counter = counter + 1
       
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16,
            atlas:getDimensions())
        counter = counter + 1
        
        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16,
            atlas:getDimensions())
        counter = counter + 1

        -- prepare X and Y for the next set of paddles
        x = 0
        y = y + 32
    end

    return quads
end