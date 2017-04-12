# Tetris-like game that runs on the NodeMCU firmware on ESP8266 chips

This project is not fully finished yet. Game controls are not implements yet.

## Requirements  

 - The game is dependent on an LED matrix. (LEDs can be WS2812, WS2812b, APA104, SK6812 and possibly even others)
 - It also requires the two classes from the [Led Matrix project](https://github.com/T-vK/LedMatrix).
 - Your NodeMCU firmware needs to have the ws2812 module
 
## Set up

 - Connect your LED matrix to GPIO pin 2
 - Paste the contents of [ledMatrix.lua](https://github.com/T-vK/LedMatrix/blob/master/ledMatrix.lua) into game.lua
 - Make sure to call `ws2812.init()` before calling `newLedMatrix(...)`
 
## Example

```
ws2812.init()
local ledMatrix = newLedMatrix(13, 13, true, true, false, true, true)
local tetris = newTetrisBoard(ledMatrix,60)
tetris:start()
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