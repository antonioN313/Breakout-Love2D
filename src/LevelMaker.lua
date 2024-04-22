LevelMaker = Class{}

function LevelMaker.createMap(level)
    local bricks = {}
    local numRows = math.random(1, 5)
    local numCols = math.random(7, 15)

    for yAxis = 1, numRows do
        for xAxis = 1, numCols do
            brick = Brick((xAxis-1) * 32 + 8 + (13 - numCols) * 16, yAxis * 16) 
            table.insert(bricks, brick)
        end
    end 

    return bricks
end