-- Paste the Matrix Class and LED MAtrix Class here.
-- You can find it here: https://github.com/T-vK/LedMatrix

function newTetrisBoard(ledMatrixInstance,fps)
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
                    for i = 1, #this.currentShape.coords do -- spawn the form centered
                        local x = this.currentShape.coords[i][1]
                        local y = this.currentShape.coords[i][2]
                        x = x + math.floor(this.ledMatrix.width/2)
                        this.currentShape.coords[i][1] = x
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
                    if red ~= 0 or blue ~= 0 or green ~= 0 then
                        rowMissingBlocks = true
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
            for i = 1, #this.currentShape.coords do -- unset (old) shape pixels; set potentially new coords
                local x = this.currentShape.coords[i][1]
                local y = this.currentShape.coords[i][2]
                this.ledMatrix:set(x,y,0,0,0)
                if action == "down" then
                    y = y+1
                elseif action == "left" then
                    x = x-1
                elseif action == "right" then
                    x = x+1
                elseif action == "up" then
                    y = y-1
                elseif action == "rotateLeft" then
                    this.currentShape.rotateLeft()
                    x = this.currentShape.coords[i][1]
                    y = this.currentShape.coords[i][2]
                elseif action == "rotateRight" then
                    this.currentShape.rotateRight()
                    x = this.currentShape.coords[i][1]
                    y = this.currentShape.coords[i][2]
                end
                
                this.currentShape.coords[i][1] = x
                this.currentShape.coords[i][2] = y
            end
            local wouldCollide = false

            for i = 1, #this.currentShape.coords do -- check if new coords would collide
                local x = this.currentShape.coords[i][1]
                local y = this.currentShape.coords[i][2]
                if y>0 then
                    local red,green,blue = this.ledMatrix:get(x,y)
                    if red ~= 0 or blue ~= 0 or green ~= 0 then -- nil for wall collision; >0 for block collision
                        wouldCollide = true
                        break
                    end
                end
            end
            
            for i = 1, #this.currentShape.coords do -- set new shape pixels if no collision is expected; set old pixels otherwise 
                local x = this.currentShape.coords[i][1]
                local y = this.currentShape.coords[i][2]
                local red = this.currentShape.color[1]
                local green = this.currentShape.color[2]
                local blue = this.currentShape.color[3]
                
                if wouldCollide then -- reverse move
                    if action == "down" then
                        y = y-1
                    elseif action == "left" then
                        x = x+1
                    elseif action == "right" then
                        x = x-1
                    elseif action == "up" then
                        y = y+1
                    elseif action == "rotateLeft" then
                        this.currentShape.rotateRight()
                        x = this.currentShape.coords[i][1]
                        y = this.currentShape.coords[i][2]
                    elseif action == "rotateRight" then
                        this.currentShape.rotateLeft()
                        x = this.currentShape.coords[i][1]
                        y = this.currentShape.coords[i][2]
                    end
                    this.currentShape.coords[i][1] = x
                    this.currentShape.coords[i][2] = y
                end
                
                this.ledMatrix:set(x,y,red,green,blue)
                print("x: " .. x .. " y: " .. y .. " red: " .. red .. " green: " .. green .. " blue: " .. blue)
            end
            
            if wouldCollide and action == "down" then
                this.currentShape = nil
            end

        end;
        reset = function(this)
            this.currentShape = nil
            this.frameTimer:unregister()
            this.dropTimer:unregister()
            this.ledMatrix.ledBuffer:fill(0,0,0)
            this.ledMatrix:show()
        end;
    }
end

function newTetrisShape(type)
    local SHAPES = {
        I = {
            {-2, 0}, {-1, 0}, { 0, 0}, { 1, 0}
        },
        L = {
                              { 1,-1},
            {-1, 0}, { 0, 0}, { 1, 0}
        },
        J = {
            {-1,-1},
            {-1, 0}, { 0, 0}, { 1, 0}
        },
        O = {
            {-1, 0},{ 0, 0}, 
            {-1, 1},{ 0, 1}
        },
        T = {
                     { 0,-1},
            {-1, 0}, { 0, 0}, { 1, 0}
        },
        S = {
            {-1, 0}, { 0, 0},
                     { 0, 1}, { 1, 1}
        },
        Z = {
                     { 0, 0}, { 1, 0},
            {-1, 1}, { 0, 1}
        }
    }
    local COLORS = {
        I = {0,255,255},
        L = {255,99,0},
        J = {0,0,255},
        O = {255,255,0},
        T = {128,0,128},
        S = {0,255,0},
        Z = {255,0,0},
    }
    local AVAILABLE_TYPES = {"I","L","J","O","T","S","Z"}
    
    if type == nil then
        math.randomseed(tmr.now()) -- the default random seed didn't seem to be random
        type = AVAILABLE_TYPES[math.random(7)]
    end
    return {
        coords = SHAPES[type];
        color = COLORS[type];
        rotateR = function(this)
            -- 90° clockwise rotation: (x|y) =>  (-y|x)
            for i = 1, #this.coords do
                local x = this.coords[i][1]
                local y = this.coords[i][2]
                this.coords[i][1] = -y
                this.coords[i][2] = x
            end
        end;
        rotateL = function(this)
            -- 90° counter-clockwise rotation: (x|y) => (y|-x)
            for i = 1, #this.coords do
                local x = this.coords[i][1]
                local y = this.coords[i][2]
                this.coords[i][1] = y
                this.coords[i][2] = -x
            end
        end;
    }
end