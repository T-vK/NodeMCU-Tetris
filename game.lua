-- Paste the Matrix Class and LED MAtrix Class here.
-- You can find it here: https://github.com/T-vK/LedMatrix

function newTetrisBoard(ledMatrixInstance,fps)
    local droppingShape = nil
    
    local frameTimer = tmr.create()
    frameTimer:register(1000/fps, tmr.ALARM_AUTO, function (t)
        ledMatrixInstance:show()
    end)
    
    local controlTimer = tmr.create()
    controlTimer:register(10, tmr.ALARM_AUTO, function (t) 
        --if button 1 pressed
        --if button 2 pressed 
        --blablabla ...
    end)
    
    local dropTimer = tmr.create()
    dropTimer:register(500, tmr.ALARM_AUTO, function (t) 
        if droppingShape == nil then
            droppingShape = newTetrisShape()
            for i = 1, #droppingShape.coords do -- spawn the form centered
                local x = droppingShape.coords[i][1]
                local y = droppingShape.coords[i][2]
                x = x + math.floor(ledMatrixInstance.width/2)
                droppingShape.coords[i][1] = x
            end
        else
            for i = 1, #droppingShape.coords do -- unset old shape pixels
                local x = droppingShape.coords[i][1]
                local y = droppingShape.coords[i][2]
                ledMatrixInstance:set(x,y,0,0,0)
                y = y+1 -- drop by 1
                droppingShape.coords[i][2] = y
            end

            local willCollide = false
            for i = 1, #droppingShape.coords do -- simulate drop for collision detection
                local x = droppingShape.coords[i][1]
                local y = droppingShape.coords[i][2]
                if y>0 then
                    local red,green,blue = ledMatrixInstance:get(x,y)
                    if red ~= 0 or blue ~= 0 or green ~= 0 then -- nil for bottom collision
                        willCollide = true
                        break
                    end
                end
            end 
                      
            for i = 1, #droppingShape.coords do -- set new shape pixels in separate loop to prevent set/unset interfering
                local x = droppingShape.coords[i][1]
                local y = droppingShape.coords[i][2]
                local red = droppingShape.color[1]
                local green = droppingShape.color[2]
                local blue = droppingShape.color[3]
                
                if willCollide then
                    y = y-1
                    droppingShape.coords[i][2] = y
                end
                
                ledMatrixInstance:set(x,y,red,green,blue)
            end
            
            if willCollide then
                droppingShape = nil
            end
        end
    end)
    
    
    return {
        frameTimer = frameTimer;
        controlTimer = controlTimer;
        dropTimer = dropTimer;
        start = function(this)
            ledMatrixInstance.ledBuffer:fill(0,0,0)
            this.frameTimer:start()
            this.dropTimer:start()
        end;
        stop = function(this)
            this.frameTimer:stop()
            this.dropTimer:stop()
        end;
        destroy = function(this)
            this.frameTimer:unregister()
            this.controlTimer:unregister()
            this.dropTimer:unregister()
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
        math.randomseed(tmr.now())
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