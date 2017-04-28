-- Tetris Class
function newTetris(ledMatrixInstance,fps)
    -- TODO: find out if a rendering mutex is necessary
    return {
        ledMatrix = ledMatrixInstance;
        fps = fps;
        currentShape = nil;
        frameTimer = nil;
        dropTimer = nil;
        score = 0;
        
        start = function(this)
            this.ledMatrix.ledBuffer:fill(0,0,0)
            this.frameTimer = tmr.create()
            this.frameTimer:register(1000/this.fps, tmr.ALARM_AUTO, function (t)
                this.ledMatrix:show()
            end)
            this.dropTimer = tmr.create()
            this.dropTimer:register(500, tmr.ALARM_AUTO, function (t) 
                if this.currentShape == nil then
                    this:lineCheck()
                    this.currentShape = newTetrisShape()
                    local xOffset = math.floor(this.ledMatrix.width/2+0.5)
                    this.currentShape.coordOffsets[1] = xOffset
                    this:action("down") -- TODO: find a better way
                    if this.currentShape == nil then
                        this:reset()
                        local timer = tmr.create()
                        timer:alarm(50, tmr.ALARM_AUTO, function (t)
                            this.ledMatrix.ledBuffer:fade(2)
                            this.ledMatrix:show()
                        end)
                        tmr.create():alarm(3000, tmr.ALARM_SINGLE, function(t) 
                            timer:unregister()
                            this:start()
                        end)
                    end
                else
                    this:action("down")
                end
            end)

            this.frameTimer:start()
            this.dropTimer:start()
        end;
        stop = function(this)
            this.frameTimer:stop()
            this.dropTimer:stop()
        end;
        lineCheck = function(this)
            for y = this.ledMatrix.height, 1, -1 do -- check rows starting from bottom TODO: check if syntax correct
                local rowMissingBlocks = false
                for x = 1, this.ledMatrix.width do
                    local red,green,blue = this.ledMatrix:get(x,y)
                    if red == 0 and blue == 0 and green == 0 then
                        rowMissingBlocks = true
                        break
                    end
                end
                if not rowMissingBlocks then
                    for x = 1, this.ledMatrix.width do -- remove row
                        this.ledMatrix:set(x,y,0,0,0)
                        this.score = this.score+1
                    end
                    for y2 = y-1, 1, -1 do
                        for x = 1, this.ledMatrix.width do -- drop everything above by 1 row
                            local red,green,blue = this.ledMatrix:get(x,y2)
                            this.ledMatrix:set(x,y2+1,red,green,blue)
                        end
                    end
                end
            end
        end;
        action = function(this,action)
            if this.currentShape == nil then
                return
            end

            local xOffsetOld = this.currentShape.coordOffsets[1]
            local yOffsetOld = this.currentShape.coordOffsets[2]

            for i = 1, #this.currentShape.baseCoords do -- unset (old) shape pixels; set potentially new coordOffsets
                local x = this.currentShape.baseCoords[i][1]+xOffsetOld
                local y = this.currentShape.baseCoords[i][2]+yOffsetOld
                this.ledMatrix:set(x,y,0,0,0)
            end

            local xOffsetNew = xOffsetOld
            local yOffsetNew = yOffsetOld

            if action == "down" then
                yOffsetNew = yOffsetNew+1
            elseif action == "left" then
                xOffsetNew = xOffsetNew-1
            elseif action == "right" then
                xOffsetNew = xOffsetNew+1
            elseif action == "up" then
                yOffsetNew = yOffsetNew-1
            elseif action == "rotateRight" then
                this.currentShape:rotateRight()
            elseif action == "rotateLeft" then
                this.currentShape:rotateLeft()
            end
            
            local baseCoords = this.currentShape.baseCoords

            local wouldCollide = false

            for i = 1, #baseCoords do -- check if new coords would collide
                local x = baseCoords[i][1]+xOffsetNew
                local y = baseCoords[i][2]+yOffsetNew
                if y>0 then
                    local red,green,blue = this.ledMatrix:get(x,y)
                    if red ~= 0 or blue ~= 0 or green ~= 0 then -- nil for wall collision; >0 for block collision
                        wouldCollide = true
                        break
                    end
                end
            end
        
            for i = 1, #baseCoords do -- set new shape pixels if no collision is expected; set old pixels otherwise 
                local red, green, blue = this.currentShape:getColor(i)
                local xOffset = 0
                local yOffset = 0

                if wouldCollide then
                    xOffset = xOffsetOld
                    yOffset = yOffsetOld
                else
                    xOffset = xOffsetNew
                    yOffset = yOffsetNew
                end

                local x = baseCoords[i][1]+xOffset
                local y = baseCoords[i][2]+yOffset

                this.currentShape.coordOffsets[1] = xOffset
                this.currentShape.coordOffsets[2] = yOffset

                this.ledMatrix:set(x,y,red,green,blue)
                print("x: " .. x .. " y: " .. y .. " red: " .. red .. " green: " .. green .. " blue: " .. blue)
            end

            if wouldCollide and action == "down" then
                this.currentShape = nil
            end

        end;
        reset = function(this)
            this.currentShape = nil
            this.score = 0
            this.frameTimer:unregister()
            this.dropTimer:unregister()
            this.frameTimer = tmr.create()
            --this.ledMatrix.ledBuffer:fill(255,0,0) 
            --this.ledMatrix:show()
        end;
    }
end