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
local aledMatrixInstance = newLedMatrix(10, 10, true, true, true, true, true)
local tetrisBoardInstance = newTetrisBoard(aledMatrixInstance,60)
tetrisBoardInstance:start()
```