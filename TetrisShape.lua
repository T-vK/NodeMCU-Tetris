-- Tetris Shape Class
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
        baseCoords = SHAPES[type];
        color = COLORS[type];
        coordOffsets = { 0, 0};
        getCoords = function(this)
            
        end;
        getBaseCoords = function(this,i)
            return this.baseCoords[i][1], this.baseCoords[i][2]
        end;
        getColor = function(this)
            return this.color[1], this.color[2], this.color[3]
        end;
        rotateRight = function(this)
            -- 90 degrees clockwise rotation: (x|y) =>  (-y|x)
            for i = 1, #this.baseCoords do
                local x = this.baseCoords[i][1]
                local y = this.baseCoords[i][2]
                this.baseCoords[i][1] = -y
                this.baseCoords[i][2] = x
            end
        end;
        rotateLeft = function(this)
            -- 90 degrees counter-clockwise rotation: (x|y) => (y|-x)
            for i = 1, #this.baseCoords do
                local x = this.baseCoords[i][1]
                local y = this.baseCoords[i][2]
                this.baseCoords[i][1] = y
                this.baseCoords[i][2] = -x
            end
        end;
    }
end