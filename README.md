# Tetris-like game that runs on the NodeMCU firmware on ESP8266 chips

## Requirements  

 - The game is dependent on an LED matrix. (LEDs can be WS2812, WS2812b, APA104, SK6812 and possibly even others)
 - It also requires the two classes found in [Led Matrix project](https://github.com/T-vK/LedMatrix).
 - Your NodeMCU firmware needs to have the ws2812 module
 
## Set up

 - Connect your LED matrix to GPIO pin 2
 - Make sure to upload all classes to your ESP8266 and include them in your init.lua. Either by including them (e.g. using dofile(...) or by copy pasting them all directly into `init.lua`. 
 - Make sure to call `ws2812.init()` before calling `newLedMatrix(...)`
 
## Example

```
local LEFT_BUTTON = 1   -- GPIO 5
local RIGHT_BUTTON = 2  -- GPIO 4
local ROTATE_BUTTON = 6 -- GPIO 12
local DOWN_BUTTON = 7   -- GPIO 13

ws2812.init()

local ledMatrix = newLedMatrix(13, 13, true, true, false, true, true)
ledMatrix.ledBuffer:fill(0,0,0)
ledMatrix:show()

local tetris = newTetris(ledMatrix,60) -- Run tetris with 60FPS
tetris:start()


-- Enable GPIO interrupts and internal pullup resistors on our button inputs
gpio.mode(LEFT_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(RIGHT_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(DOWN_BUTTON, gpio.INT, gpio.PULLUP)
gpio.mode(ROTATE_BUTTON, gpio.INT, gpio.PULLUP)


-- Connect out buttons to the appropriate tetris actions
local lastAction = 0
local minTimeBetweenActions = 100000 -- This is to prevent buttons from accidental spamming. In microseconds (100000us=0.1s)

gpio.trig(LEFT_BUTTON, "down", function(level, when)
    if when-lastAction < minTimeBetweenActions then
        return
    end
    print("left") 
    tetris:action("left")
    lastAction = when
end)
gpio.trig(RIGHT_BUTTON, "down", function(level, when)
    if when-lastAction < minTimeBetweenActions then
        return
    end
    print("right")
    tetris:action("right")
    lastAction = when
end)
gpio.trig(DOWN_BUTTON, "down", function(level, when)
    print("down")
    tetris:action("down")
    lastAction = when
end)
gpio.trig(ROTATE_BUTTON, "down", function(level, when)
    if when-lastAction < minTimeBetweenActions then
        return
    end
    print("rotateRight")
    tetris:action("rotateRight")
    lastAction = when
end)

```

## User Controls

You can decide on your own what kind of controller you would like to use.  
Be it a web interface, a thumb stick or simple buttons.  

## Controls API

- To move the current shape to the left/right by one pixel

     ```
         tetris:action("left")
         -- or
         tetris:action("right")
     ```
- To move the current shape down by one pixel

     ```
         tetris:action("down")
     ```
     Please note: The shape drops down automatically every 500 milliseconds.  
     You should only call `tetris:action("down")` i you want to speed things up.
     
- To rotate a shape clockwise by 90°:

     ```
         tetris:action("rotateRight")
     ```
     
- To rotate a shape counter-clockwise by 90°:

     ```
         tetris:action("rotateLeft")
     ```
     
- To start the game:

     ```
         tetris:start()
     ```
- To pause the game:

     ```
         tetris:stop()
     ```