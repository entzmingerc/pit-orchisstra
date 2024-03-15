-- ~ pit orchisstra ~
-- the game of snake
-- a group of snakes is a pit
-- live loooong and prosper
-- 
-- E1: select snake
-- E2: speed 
-- E3: turn snake
-- K2: toggle food view
-- K3: cycle snake behaviors
--
-- FOODVIEW:
-- E2: < down, > up 
-- E3: < left, > right
-- K3: place food
--
-- if two player mode is on
-- E2 turns next snake (+1)
--
-- DIRECTIONS
-- turn left, right, or forward
-- eat food and play a note
-- snakes die if eating snakes
-- place food
-- make food immortal
-- make snake immortal
-- make many snakes
-- make snake fast
-- food sequenced snake pathing
-- high velocity whimsy
-- nb voice per snake
-- keyboard controls
-- grid controls
--
-- ~SNAKE BEHAVIORS~
-- 1 none, turn with ENC3 only
-- 2 random snake turn (whimsy)
-- 3 turn towards closest food
-- 4 seek food in order placed
--
-- 1 1 2 2 2 2 2 2 2 3 3 3 3 1 1 1
-- 1 1 1 2 2 2 2 2 3 3 3 3 3 1 1 1
-- 1 1 1 1 2 2 2 3 3 3 3 3 3 1 1 1
-- 1 1 1 1 1 H 3 3 3 3 3 3 3 1 1 1
-- 1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1
-- 1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1
-- 1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1
-- 1 2 2 2 2 2 2 2 2 2 3 3 3 1 1 1


--[[
1   select snake 1
2   select snake 2
3   select snake 3
4   select snake 4
TAB   toggle foodView ON/OFF

selected snake controls:
W   increase speed
A   turn left
S   decrease speed
D   turn right
SPACE   cycle snake behaviors
Q   toggle slithering (TURN ON THE SNAKE)
E   toggle immortality
R   toggle quantize
F   decrease whimsy
G   increase whimsy
SHIFT + W   increase transpose
SHIFT + A   decrease max length
SHIFT + S   decrease transpose
SHIFT + D   increase max length

foodView controls:
W   move up
A   move left
S   move down
D   move right
SPACE   place food
cursor spawns inside the top left square initially
other snake controls remain the same in foodView

global controls:
8   toggle food spawn
9   toggle food immortality
0   toggle strict food order
BACKSPACE   clear food grid
Z   decrement noteRowOffset (-1)
X   increment noteRowOffset (+1)
C   decrement scale (-1)
V   increment scale (+1)
/   toggle two player mode


SNAKE SETTINGS
nb snake 1-4: select the nb voice for the snake
selected snake: selects snake 1, 2, 3, or 4
slithering: 0 removes snake, 1 spawns snake
behavior: defines the movement of the snake (see more details below)
speed: 1-70, syncs to norns clock tempo
immortal: 0 can be killed, 1 all hail immortal snek
whimsy: 0-10, 0-100% chance to flip a coin to turn left or right
transpose: midi note offset for nb voices
quantize: 0/1, controls if note is quantized to scale of the grid

FOOD SETTINGS
food spawn: 0/1, spawns new food if food is eaten
food immortal: 0/1, deletes/keeps food if food is eaten
strict food order:
    0: append any eaten food to the end of foodOrder
    1: append only destination food to the end of foodOrder
clear food grid: (TRIGGER) clear all food and foodOrder
two player mode: changes ENC2 to turn the next snake
    if snake 1 is selected, it turns next snake, snake 2
note row offset: transpose offset per row of the grid
    if this is 5, then if a pad is note 3, the next pad down is 3+5
scale: 1-8
    "Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"

SNAKE BEHAVIORS
This controls what direction the snake steps to each update loop.
For each behavior, you can always turn the snake with ENC3.
Note that upon dying and spawning, snakes preserve their direction. 

1 none, snake moves forward, turn with ENC3
    Good to actually play the game snake with
    Good for having a snake wrap the grid in a straight predictable line
    Repeating melodies, drums, etc. 

2 random, snake turns randomly, whimsy controls randomness
    whimsy at 0 means it always steps forward
    whimsy at 3 means each step there's a 30% chance to flip a coin (turn left, turn right)
    whimsy at 10 means each step it flips a coin to turn left or turn right
    high speed & whimsy is really fun to watch!

3 wander, snake turns towards the food closest to it that it can "see"
    Each square, the snake looks left, forward, and right in a straight line
    If it sees food in its sight line, it turns in the direction of closest food
    Slightly unpredictable in a complex environment of many snakes and foods.
    Results in emergent stabilizing paths and loops with immortal food.
    Pseudorandom pathing with foodSpawn on. 
    
4 sequence, snake seeks out food in order (see below)
    When you place a food, it tracks the order of foods placed.
    For example, placing down 3 foods will give an order 1, 2, 3.
    The snake will go to food 1 first, eat it, then go to 2.
    Use the options "food immortal", "food spawn", "strict food order" to get different slithering paths. 

    If food 2 is eaten on the way to food 1, it is removed from the order, 1, 3.
    If "food immortal" is ON, then any food eaten is not deleted and moved to the end of the food sequence. 
    If food 2 is eaten on the way to food 1, it is removed from the order, and moved to the end 1, 3, 2.
    If "strict food order" is ON, only the head of food sequence (food 1 in this case) is moved to the end if eaten.

    There is only one food sequence shared among the 4 snakes. 
    If snake 1 gets to the food before snake 2 does, then they'll both turn towards the next food in the sequence.
    All snake behaviors affect food sequence, so sometimes repeating sequences can get broken up with high whimy snaking.

    This is a pretty wiggling style.
    I had a vision of placing my hand on the grid and watching a snake slither around my fingertips.
    This was the attempt to realize that daydream.
    Try placing immortal foods one at a time and build up a melody.
    Placing one immortal food results in the snake to spiral around the food in a 3x3 clover pattern.
    Placing two foods will get the snake to loop back and forth.
    Placing a few foods nearby might make a repeating melody.
    And so on.
    
--]]

-- get libraries ----------------------------------------
engine.name = "RudimentsSnek"
libutil = require 'util'
mutil = require 'musicutil'
nb = include("lib/nb/lib/nb")
-- local grid = util.file_exists(_path.code.."midigrid") and include "midigrid/lib/mg_128" or grid
g = grid.connect()

-- CONSTANTS --------------------------------------------
kDisplayWidth = 16 -- synthstrom deluge variable name
kDisplayHeight = 8 -- synthstrom deluge variable name
SNAKE_MAX_LENGTH = 128 -- I guess if the snake is 16 * 8 = 128 it'd fill the screen???
SNAKE_MIN_LENGTH = 1 -- can't get smaller than 1 pad, right?
SNAKE_UP = 1
SNAKE_RIGHT = 2
SNAKE_DOWN = 3
SNAKE_LEFT = 4
SNAKE_MAX_SPEED = 70 -- dimishing aesthetic differences above 70, but could go higher :)
SNAKE_MIN_SPEED = 1 -- currently integer speed so this is min, could rewrite to allow decimals?
SNAKE_BEHAVIORS = 4
initBody = {}
initBody[1] = {x = 1, y = 1}
-- for i = 1,SNAKE_MAX_LENGTH do
--     initBody[i] = {x = 0, y = 0}
-- end
-- initBody[1].x = 1
-- initBody[1].y = 1
foodGrid = {}
foodOrder = {}
snakes = {}
SNAKE_MAX_COUNT = 4
foodView = 0
foodCursorX = 1
foodCursorY = 1
scaleNames = {"Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"}
noteArray = mutil.generate_scale(0, "major", 10)
imageQueue = {}
popUpSelect = 0
popUpBehavior = 0
popUpKeyboard = 0
popUpKeyboardText = ""
keeb = {}
BAD_CODE = "CAW!"

-- SNAKE PARAMS -----------------------------------------
-- settings for each snake
-- slithering determines if it can walk
-- behavior (none, randomTurn, wander, foodSequence)
snake_specs = {
    {
        id = 'slithering',
        name = 'slithering',
        min = 0,
        max = 1,
        default = 1
    },   
    {
        id = 'behavior',
        name = 'behavior',
        min = 1,
        max = 4,
        default = 1
    },
    {
        id = 'speed',
        name = 'speed',
        min = SNAKE_MIN_SPEED,
        max = SNAKE_MAX_SPEED,
        default = 3
    },  
    {
        id = 'immortal',
        name = 'immortal',
        min = 0,
        max = 1,
        default = 0
    },  
    {
        id = 'maxLength',
        name = 'maxLength',
        min = 0,
        max = SNAKE_MAX_LENGTH,
        default = 10
    },  
    {
        id = 'whimsy',
        name = 'whimsy',
        min = 0,
        max = 10,
        default = 2
    },      
    {
        id = 'transpose',
        name = 'transpose',
        min = 0,
        max = 128,
        default = 24
    },    
    {
        id = 'quantize',
        name = 'quantize',
        min = 0,
        max = 1,
        default = 1
    },
}

-- SNAKE CLASS ------------------------------------------
SnakeClass = {}

function SnakeClass:new (properties)
    local obj = properties or {}
    setmetatable(obj, self) -- creates a metatable of self
    self.__index = self -- inheret from self using metamethod __index
    return obj -- returns new SnakeClass object
end

function SnakeClass:checkBehavior ()
    -- if self.behavior == 1 then nothing
    -- self.turnRight and self.turnLeft are both false

    if self.behavior == 2 then
        randomTurn = math.random()
        if randomTurn < (self.whimsy * 0.1) then
            randomTurn = math.random()
            if randomTurn > 0.5 then
                self.turnRight = true
            else
                self.turnLeft = true
            end
        end
        
    -- search
    elseif self.behavior == 3 then
        -- look left, forward, right, if food calculate distance to it
        -- priority center, left, right if distance is equal
        -- if food, turn toward food 

        -- get head coordinates
        local headx = self.body[1].x
        local heady = self.body[1].y

        -- sight wraps around the grid so we can see food "behind" us

        -- check up
        local upDistance = 100 -- arbitrarily large number to be distinct
        -- iterate through each square "up"
        for i = 1, (kDisplayHeight - 1) do
            -- going up, so subtract i from heady position
            -- monome grid positive y value is "down" from top left corner
            if (heady - i) >= 1 then
                -- above head
                if foodGrid[heady - i][headx] == 1 then
                    upDistance = i
                    break
                end
            else
                -- wrap top boundary of grid
                -- i = 5 should be like newY = 3 if heady = 6
                newY = kDisplayHeight + (heady - i)
                if foodGrid[newY][headx] == 1 then
                    upDistance = i
                    break
                end
            end
        end

        -- check right
        local rightDistance = 100 -- arbitrarily large number
        for i = 1, (kDisplayWidth - 1) do
            -- going right, so add i to headx
            if (headx + i) <= kDisplayWidth then
                -- right of head
                if foodGrid[heady][headx + i] == 1 then
                    rightDistance = i
                    break
                end
            else
                -- wrap right boundary of grid
                -- i = 5 should be like newX = 3 if headx = 14
                newX = i - (kDisplayWidth - headx)
                if foodGrid[heady][newX] == 1 then
                    rightDistance = i
                    break
                end
            end
        end

        -- check down
        local downDistance = 100 -- arbitrarily large number
        for i = 1, (kDisplayHeight - 1) do
            -- going down, so subtract i from heady
            if (heady + i) <= kDisplayHeight then
                -- below head
                if foodGrid[heady + i][headx] == 1 then
                    downDistance = i
                    break
                end
            else
                -- wrap bottom boundary of grid
                -- i = 5 should be like newY = 6 if heady = 3
                newY = (heady + i) - kDisplayHeight
                if foodGrid[newY][headx] == 1 then
                    downDistance = i
                    break
                end
            end
        end
          
        -- check left
        local leftDistance = 100 -- arbitrarily large number
        for i = 1, (kDisplayWidth - 1) do
            -- going left, so subtract i from head
            if (headx - i) >= 1 then
                -- left of head
                if foodGrid[heady][headx - i] == 1 then
                    leftDistance = i
                    break
                end
            else
                -- wrap lefthand boundary of grid
                -- i = 7 should be like newX = 12 if headx = 3
                newX = kDisplayWidth - (i - headx)
                if foodGrid[heady][newX] == 1 then
                    leftDistance = i
                    break
                end
            end
        end

        -- calculated distances! which direction? depends on current direction
        -- 3 distance ties = no turning
        -- prioritize moving forward, then turning left, then turning right
        -- what are vectors?!
        local minDist = 100
        if self.direction == SNAKE_UP then
            minDist = math.min(leftDistance, upDistance, rightDistance)
            if minDist == 100 or upDistance == minDist then
                -- also do nothing
            elseif leftDistance == minDist then
                self.turnLeft = true
            elseif rightDistance == minDist then
                self.turnRight = true
            end

        elseif self.direction == SNAKE_RIGHT then
            minDist = math.min(upDistance, rightDistance, downDistance)
            if minDist == 100 or rightDistance == minDist then
                -- also do nothing
            elseif upDistance == minDist then
                self.turnLeft = true
            elseif downDistance == minDist then
                self.turnRight = true
            end

        elseif self.direction == SNAKE_DOWN then
            minDist = math.min(rightDistance, downDistance, leftDistance)
            if minDist == 100 or downDistance == minDist then
                -- also do nothing
            elseif rightDistance == minDist then
                self.turnLeft = true
            elseif leftDistance == minDist then
                self.turnRight = true
            end

        elseif self.direction == SNAKE_LEFT then
            minDist = math.min(downDistance, leftDistance, upDistance)
            if minDist == 100 or leftDistance == minDist then
                -- also do nothing
            elseif downDistance == minDist then
                self.turnLeft = true
            elseif upDistance == minDist then
                self.turnRight = true
            end

        else
            print("HOW DID YOU GET HERE? 3")
        end

    
    -- sequence
    elseif self.behavior == 4 and foodOrder[1] ~= nil then

        -- BUG: for some reason foodGrid can be 0 while foodOrder thinks there should be a food there, not sure, food spawning incorrectly?
        -- not a "fix": just remove it from foodOrder if this happens?
        if foodGrid[foodOrder[1].y][foodOrder[1].x] ~= 0 then
            -- whichever is the greater x or y distance, prioritize minimizing that
            -- if we're on a grid, we can turn left, straight, right
            -- if (H)ead direction is ^up^ there are 4 decisions
            -- next food to go for is at any of the locations, not H
            -- 1 1 2 2 2 2 2 2 2 3 3 3 3 1 1 1
            -- 1 1 1 2 2 2 2 2 3 3 3 3 3 1 1 1
            -- 1 1 1 1 2 2 2 3 3 3 3 3 3 1 1 1
            -- 1 1 1 1 1 H 3 3 3 3 3 3 3 1 1 1
            -- 1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1
            -- 1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1
            -- 1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1
            -- 1 2 2 2 2 2 2 2 2 2 3 3 3 1 1 1
            -- okay forward or "ahead" is the current direction
            -- calculate the relative directional distances based on each current direction 
            -- each distance absolute value, can each be 0 - 16
            -- then "turn" depending on where the food is relative to direction


            local foodx = foodOrder[1].x
            local foody = foodOrder[1].y
            headx = self.body[1].x
            heady = self.body[1].y
            local squaresAhead = 0
            local squaresRight = 0
            local squaresBehind = 0
            local squaresLeft = 0

            if self.direction == SNAKE_UP then
                -- ahead is -y, behind is +y coordinate
                -- behind is if y coordinate of food > than y coordinate of head
                local yDifference = (foody - heady)
                if yDifference > 0 then
                    -- behind us
                    squaresAhead = kDisplayHeight - yDifference
                    squaresBehind = yDifference
                    -- squaresAhead = yDifference
                    -- squaresBehind = kDisplayHeight - yDifference
                elseif yDifference < 0 then
                    -- ahead of us
                    squaresAhead = math.abs(yDifference)
                    squaresBehind = kDisplayHeight - math.abs(yDifference)
                    -- squaresAhead = kDisplayHeight - math.abs(yDifference)
                    -- squaresBehind = math.abs(yDifference)
                end

                -- left is -x, right is +x coordinate
                local xDifference = (foodx - headx)
                if xDifference < 0 then
                    squaresRight = kDisplayWidth - math.abs(xDifference)
                    squaresLeft = math.abs(xDifference)
                elseif xDifference > 0 then
                    squaresRight = xDifference
                    squaresLeft = kDisplayWidth - xDifference
                end
                
    
            elseif self.direction == SNAKE_RIGHT then
                -- ahead is +x, behind is -x
                local xDifference = (foodx - headx)
                if xDifference < 0 then
                    squaresAhead = kDisplayWidth - math.abs(xDifference)
                    squaresBehind = math.abs(xDifference)
                elseif xDifference > 0 then
                    squaresAhead = xDifference
                    squaresBehind = kDisplayWidth - xDifference
                end

                -- left is if food less y coordinate than heady
                local yDifference = (foody - heady)
                -- wrapping top
                if yDifference > 0 then
                    squaresLeft = kDisplayHeight - yDifference
                    squaresRight = yDifference
                -- no wrapping
                elseif yDifference < 0 then
                    squaresLeft = math.abs(yDifference)
                    squaresRight = kDisplayHeight - math.abs(yDifference)
                end
    
            elseif self.direction == SNAKE_DOWN then
                -- ahead is +y, behind is -y
                local yDifference = (foody - heady)
                if yDifference > 0 then
                    squaresBehind = kDisplayHeight - yDifference
                    squaresAhead = yDifference
                    -- squaresBehind = kDisplayHeight - math.abs(yDifference)
                    -- squaresAhead = math.abs(yDifference)
                elseif yDifference < 0 then
                    squaresBehind = math.abs(yDifference)
                    squaresAhead = kDisplayHeight - math.abs(yDifference)
                    -- squaresBehind = yDifference
                    -- squaresAhead = kDisplayHeight - yDifference
                end

                -- left is +x, right is -x
                local xDifference = (foodx - headx)
                if xDifference < 0 then
                    squaresLeft = kDisplayWidth - math.abs(xDifference)
                    squaresRight = math.abs(xDifference)
                elseif xDifference > 0 then
                    squaresLeft = xDifference
                    squaresRight = kDisplayWidth - xDifference
                end


            elseif self.direction == SNAKE_LEFT then
                -- ahead is -x, behind is +x
                local xDifference = (foodx - headx)
                if xDifference < 0 then
                    squaresBehind = kDisplayWidth - math.abs(xDifference)
                    squaresAhead = math.abs(xDifference)
                elseif xDifference > 0 then
                    squaresBehind = xDifference
                    squaresAhead = kDisplayWidth - xDifference
                end
                
                -- left is if food greater y coordinate than heady
                local yDifference = (foody - heady)
                if yDifference > 0 then
                    squaresRight = kDisplayHeight - yDifference
                    squaresLeft = yDifference
                elseif yDifference < 0 then
                    squaresRight = math.abs(yDifference)
                    squaresLeft = kDisplayHeight - math.abs(yDifference)
                end
    
            else
                print("HOW DID YOU GET HERE? 4")
            end

            -- each direction has same logic
            -- we can only decide which direction to turn
            -- if you set both to squaresAhead > squaresLeft in the 3rd if statement it zigzags
            -- but if you use squaresAhead >= squaresLeft it zigzags by 2 squares
                -- and makes a beautiful little clover pattern circling one food 
            -- do we turn left?
            if squaresLeft <= squaresRight then
                if squaresAhead <= squaresBehind then
                    if squaresAhead >= squaresLeft then 
                        -- (if this is > it zigs harder, but >= does a pretty spiral with 1 food)
                        -- nothing, stay current direction
                    else
                        self.turnLeft = true
                    end
                else
                    self.turnLeft = true
                end
                
            -- do we turn right?
            -- squaresRight < squaresLeft
            else
                if squaresAhead <= squaresBehind then
                    if squaresAhead >= squaresRight then
                        -- nothing, stay current direction
                    else
                        self.turnRight = true
                    end
                else
                    self.turnRight = true
                end
            end
        else
            -- foodGrid == 0, but foodOrder thinks there's food
            table.remove(foodOrder, 1) -- get rid of foodOrder head
        end
    end
end

function SnakeClass:checkDirection ()
    if self.turnLeft then
        if self.direction == SNAKE_UP then
            self.direction = SNAKE_LEFT
        else
            self.direction = self.direction - 1
        end
        self.turnLeft = false
    elseif self.turnRight then
        if self.direction == SNAKE_LEFT then
            self.direction = SNAKE_UP
        else
            self.direction = self.direction + 1
        end
        self.turnRight = false
    end
end

-- update Head location move forward one square
function SnakeClass:slither()

    -- update segment positions from tail to adjacent to head
    if self.length >= 2 then
        for i = 0,(self.length - 2) do
            self.body[self.length - i].x = self.body[self.length - i - 1].x
            self.body[self.length - i].y = self.body[self.length - i - 1].y
        end
    end

    -- update head position
    if self.direction == SNAKE_UP then
        if self.body[1].y <= 1 then
            self.body[1].y = kDisplayHeight
        else
            self.body[1].y = self.body[1].y - 1
        end
    elseif self.direction == SNAKE_RIGHT then
        if self.body[1].x >= kDisplayWidth then
            self.body[1].x = 1
        else
            self.body[1].x = self.body[1].x + 1
        end
    elseif self.direction == SNAKE_DOWN then
        if self.body[1].y >= kDisplayHeight then
            self.body[1].y = 1
        else
            self.body[1].y = self.body[1].y + 1 
        end
    elseif self.direction == SNAKE_LEFT then
        if self.body[1].x <= 1 then
            self.body[1].x = kDisplayWidth
        else
            self.body[1].x = self.body[1].x - 1
        end
    else
        self.direction = SNAKE_UP
        print("slither NOWHERE")
    end
end

-- check if head location is at food, eat food
function SnakeClass:grow()
    -- get head coordinates
    local snakex = self.body[1].x
    local snakey = self.body[1].y

    -- we can die and respawn on a food and eat it immediately
    -- check if food is at head
    if foodGrid[snakey][snakex] == 1 then

        -- EAT
        -- if food is not immortal (set foodGrid to 0)
        if params:get("foodImmortal") == 0 then
            foodGrid[snakey][snakex] = 0 -- eat the food
            for i, v in ipairs(foodOrder) do
                if v.x == snakex and v.y == snakey then
                    table.remove(foodOrder, i) -- remove from foodOrder
                    break
                end
            end
        else -- food is immortal on (don't set foodGrid to 0)
            entry = {}
            if params:get("strictFoodOrder") == 1 then -- only remove and append if it's the head of foodOrder
                if foodOrder[1].x == snakex and foodOrder[1].y == snakey then
                    entry = table.remove(foodOrder, 1) -- remove the head of the queue
                    table.insert(foodOrder, entry) -- append it to the end
                end

            else -- remove and append any food we eat to end of foodOrder
                for i, v in ipairs(foodOrder) do
                    if v.x == snakex and v.y == snakey then
                        entry = table.remove(foodOrder, i) -- remove food at i
                        table.insert(foodOrder, entry) -- append it to the end
                    end
                end
            end
        end

        -- GROW
        if self.length < self.maxLength then
            self.length = (self.length + 1)
            -- insert a segment right after head
            table.insert(self.body, 2, {x = snakex, y = snakey})
        end 

        -- SING
        local player = 0 -- get the player, probably should be part of SnakeClass
        if     self.snakeID == 1 then
            player = params:lookup_param("nb_1"):get_player()
        elseif self.snakeID == 2 then
            player = params:lookup_param("nb_2"):get_player()
        elseif self.snakeID == 3 then
            player = params:lookup_param("nb_3"):get_player()
        else
            player = params:lookup_param("nb_4"):get_player()
        end

        snakeNote = (self.body[1].y + 1) * params:get("noteRowOffset") + self.body[1].x + self.transpose
        if self.quantize == 1 then
            snakeNote = mutil.snap_note_to_array(snakeNote, noteArray)
        end

        if params:get("Internal_ON_OFF") == 1 then
            engine.freq(mutil.note_num_to_freq(snakeNote), self.snakeID) -- current freq to midi, add offset, midi to freq, set engine freq
            engine.trigger(self.snakeID) -- triggers internal rudiments SC engine
        end
        player:note_on(snakeNote, 1)
        
        -- PLACE NEW FOOD
        if params:get("foodSpawn") == 1 then
            notOccupied = {}
            numNotOccupied = 0
            for idy = 1,kDisplayHeight do
                for idx = 1,kDisplayWidth do
                    -- check if food is here
                    if foodGrid[idy][idx] == 0 then
                        -- check if snake is here
                        for i = 1,self.length do
                            -- if body segment coordinates not equal to index then
                            -- doesn't check all snakes, it could but I want to fill the grid
                            -- more than I want to not accidentally spawn a food on a square already
                            -- occupied by another snake, it's good enough to spawn on any square that the
                            -- snake that just ate isn't currently occupying
                            if not (self.body[i].x == idx and self.body[i].y == idy) then
                                -- unoccupied!
                                numNotOccupied = numNotOccupied + 1
                                notOccupied[numNotOccupied] = {x = idx, y = idy}
                            end
                        end
                    end 
                end
            end

            -- choose random spot from notOccupied list
            if numNotOccupied ~= 0 then
                -- put a food at a random unoccupied location
                randnum = math.random(1, numNotOccupied)
                idx = notOccupied[randnum].x
                idy = notOccupied[randnum].y
                foodGrid[idy][idx] = 1
                table.insert(foodOrder, {x = idx, y = idy})
            -- else
            --     print("grid full?")
            end
        end
    end
end

function SnakeClass:die()
    -- reset length, randomize coordinates of head
    self.length = SNAKE_MIN_LENGTH
    self.body = {}
    self.body[1] = {x = 0, y = 0}
    -- for i = 1,SNAKE_MAX_LENGTH do
    --     self.body[i] = {x = 0, y = 0}
    -- end
    self.body[1].x = math.random(1,kDisplayWidth)
    self.body[1].y = math.random(1,kDisplayHeight)
    -- print("snake died :(")
end

-- </SNAKE CLASS> ---------------------------------------

-- K2 immortal / dying toggle
-- K3 cycle through snake behaviors
-- press key on norns (n is number 1-3, z is pressed: 1, released: 0)
function key(n,z) 
    local sel = params:get("snake_select")

    if n==2 and z==1 then -- toggle food place mode
        if foodView == 1 then
            foodView = 0
        else
            foodView = 1
        end

    -- snake behavior toggle
    elseif n==3 and z==1 then
        if foodView == 0 then
            snakes[sel].behavior = libutil.wrap(snakes[sel].behavior + 1, 1, SNAKE_BEHAVIORS)
            params:set("behavior_"..sel, snakes[sel].behavior) -- update param menu
            popUpBehavior = 15 -- screen drawing timer (x * 1/15 seconds)

        else -- placing food, call same function as grid?
            g.key(foodCursorX, foodCursorY, z)
        end
    end
end

-- E1 select snake
-- E2 slither speed
-- E3 turn snake clockwise/counterclock
-- turn encoder (number, direction/step)
function enc(n,d)
    local sel = params:get("snake_select") -- get selection

    -- snake_select
    if n==1 then
        if d < 0 then -- left
            sel = sel - 1
        elseif d > 0 then -- right
            sel = sel + 1
        end
        sel = libutil.clamp(sel, 1, SNAKE_MAX_COUNT)
        params:set("snake_select", sel) -- update param menu
        popUpSelect = 15 -- set popUp time (x * 1/15 seconds)

    -- speed, up/down, or player 2 snake turn
    elseif n==2 then
        if foodView == 0 then
            -- turn player 2 snake
            if params:get("twoPlayerMode") == 1 then
                local p2 = libutil.wrap(sel + 1, 1, SNAKE_MAX_COUNT)
                if d < 0 then -- left
                    snakes[p2].turnLeft = true
                    snakes[p2].turnRight = false
                elseif d > 0 then -- right
                    snakes[p2].turnLeft = false
                    snakes[p2].turnRight = true
                end

            -- set snake speed
            else
                if d < 0 then -- left
                    temp = snakes[sel].speed - 1
                elseif d > 0 then -- right
                    temp = snakes[sel].speed + 1
                end
                snakes[sel].speed = libutil.clamp(temp, 1, SNAKE_MAX_SPEED)
                params:set("speed_"..sel, snakes[sel].speed) -- update param menu
            end
        else -- placing food
            if d < 0 then -- left
                foodCursorY = libutil.wrap(foodCursorY + 1, 1, kDisplayHeight)
            elseif d > 0 then -- right
                foodCursorY = libutil.wrap(foodCursorY - 1, 1, kDisplayHeight)
            end
            screen.rect((foodCursorX-1)*8 + 2, (foodCursorY-1)*8 + 2, 2, 2)
            screen.level(15)
            screen.stroke()
            screen.update()
            g:led(foodCursorX, foodCursorY, 1)
            g:refresh() 
        end

    -- turn selected snake, left/right
    elseif n==3 then
        if foodView == 0 then 
            if d < 0 then -- left
                snakes[sel].turnLeft = true
                snakes[sel].turnRight = false
            elseif d > 0 then -- right
                snakes[sel].turnLeft = false
                snakes[sel].turnRight = true
            end
        else -- placing food
            if d < 0 then -- left
                foodCursorX = libutil.wrap(foodCursorX - 1, 1, kDisplayWidth)
            elseif d > 0 then -- right
                foodCursorX = libutil.wrap(foodCursorX + 1, 1, kDisplayWidth)
            end
            screen.rect((foodCursorX-1)*8 + 2, (foodCursorY-1)*8 + 2, 2, 2)
            screen.level(15)
            screen.stroke()
            screen.update()
            g:led(foodCursorX, foodCursorY, 1)
            g:refresh() 
        end
    end
end

function g.key(x, y, z)
    if z > 0 then
        -- place food
        if foodGrid[y][x] == 0 then 
            foodGrid[y][x] = 1
            table.insert(foodOrder, {x = x, y = y})
            g:led(x, y, 3)

        -- delete food
        else
            foodGrid[y][x] = 0
            for i, v in ipairs(foodOrder) do
                -- should just find the food in the foodOrder and delete it
                if v.x == x and v.y == y then
                    table.remove(foodOrder, i) -- remove at i
                end
            end
            g:led(x, y, 0)
        end
        g:refresh()
    end
end

-- check if head is at body segment of any snake
function SnakeClass:killSnake()
    -- snake can die
    if self.immortal == 0 then
        -- check each snake position
        for s = 1, SNAKE_MAX_COUNT do
            -- check self
            if s == self.snakeID then
                for i = 2, self.length do
                    -- if head is at a body segment of self
                    if (self.body[1].x == self.body[i].x) and 
                       (self.body[1].y == self.body[i].y) then
                        -- snake should die
                        self:die()
                        return
                    end
                end

            -- check other snakes
            else
                for i = 1, snakes[s].length do
                    -- if head is at a body segment of other snake
                    if (self.body[1].x == snakes[s].body[i].x) and 
                       (self.body[1].y == snakes[s].body[i].y) then
                        -- snake should die
                        self:die()
                        return
                    end
                end
            end
        end
    end
end

-- local nornsDisplay = { width = 128, height = 64 }
-- x is to the right, y is down from top left corner

function refreshGrid()

    -- light up foods
    for y = 1, kDisplayHeight do
        for x = 1, kDisplayWidth do
            if foodGrid[y][x] == 0 then
                g:led(x, y, 0)
            else
                g:led(x, y, 3)
            end
        end
    end

    -- light up cursor
    if foodView == 1 then
        g:led(foodCursorX, foodCursorY, 1)
    end

    -- light up snakes
    for s = 1, SNAKE_MAX_COUNT do
        if snakes[s].slithering == 1 then
            for i = 1, snakes[s].length do -- used to be #snakes[s].body, idk if that mattered
                if (snakes[s].body[i].x > 0) and (snakes[s].body[i].y > 0) then -- do we need to check this?
                    g:led(snakes[s].body[i].x, snakes[s].body[i].y, 15)
                end
            end
        end
    end
    g:refresh()
end

function redraw()
    screen.clear()
    -- draw grid
    for idy = 1, kDisplayHeight do
        for idx = 1, kDisplayWidth do
            screen.rect((idx-1)*8 + 1, (idy-1)*8 + 1, 4, 4) -- x, y, width, height
            l = 1
            if foodGrid[idy][idx] == 1 then
                l = 6
            end
            for s = 1, SNAKE_MAX_COUNT do
                for i = 1, snakes[s].length do
                    if snakes[s].body[i].x == idx and snakes[s].body[i].y == idy then
                        l = 15
                    end
                end
            end
            screen.level(l)
            screen.stroke()
        end
    end

    -- draw cursor
    if foodView == 1 then
        screen.rect((foodCursorX-1)*8 + 2, (foodCursorY-1)*8 + 2, 2, 2)
        screen.level(15)
        screen.stroke()
    end

    -- temporary popup text messages
    if popUpSelect > 0 then
        screen.move(20,20)
        screen.font_size(15)
        screen.level(15)
        screen.text(params:get("snake_select"))
        screen.stroke()
        popUpSelect = popUpSelect - 1
    end
    if popUpBehavior > 0 then
        screen.move(108,20)
        screen.font_size(15)
        screen.level(15)
        screen.text(snakes[params:get("snake_select")].behavior)
        screen.stroke()
        screen.update()
        popUpBehavior = popUpBehavior - 1
    end
    if popUpKeyboard > 0 then
        screen.move(108,44)
        screen.font_size(15)
        screen.level(15)
        screen.text(popUpKeyboardText)
        screen.stroke()
        screen.update()
        popUpKeyboard = popUpKeyboard - 1
    end
        
    screen.update()
end

function clearFoodGridAction()
    for y = 1,kDisplayHeight do
        for x = 1,kDisplayWidth do
            foodGrid[y][x] = 0
            foodOrder = {}
        end
    end
end

function setupKeyboardControls()
    -- https://github.com/monome/norns/blob/main/lua/core/keymap/us.lua

    keeb[BAD_CODE] = function() end -- do nothing

    -- snakeView / foodView
    keeb["SPACE"] = function() key(3,1) end -- place cycle behavior / place food
    keeb["TAB"] = function() key(2,1) end -- toggle snakeView / foodView
    keeb["W"] = function() -- SNAKE: speed up, FOOD: move up, or SHIFT: snake transpose up
        if keyboard.shift() == true then
            local sel = params:get("snake_select")
            snakes[sel].transpose = util.clamp(snakes[sel].transpose + 1, 0, 128)
            params:set("transpose_"..sel, snakes[sel].transpose)
        else
            enc(2,1)
        end
    end 
    keeb["A"] = function() -- SNAKE: turn left, FOOD: move left, or SHIFT: snake maxLength down
        if keyboard.shift() == true then
            local sel = params:get("snake_select")
            snakes[sel].maxLength = util.clamp(snakes[sel].maxLength - 1, 1, SNAKE_MAX_LENGTH)
            params:set("maxLength_"..sel, snakes[sel].maxLength)
        else  
            enc(3,-1)
        end
    end
    keeb["S"] = function() -- SNAKE: speed down, FOOD: move down, or SHIFT: snake transpose down
        if keyboard.shift() == true then
            local sel = params:get("snake_select")
            snakes[sel].transpose = util.clamp(snakes[sel].transpose - 1, 0, 128)
            params:set("transpose_"..sel, snakes[sel].transpose)
        else
            enc(2,-1)
        end
    end
    keeb["D"] = function() -- SNAKE: turn right, FOOD: move right, or SHIFT: snake maxLength up
        if keyboard.shift() == true then
            local sel = params:get("snake_select")
            snakes[sel].maxLength = util.clamp(snakes[sel].maxLength + 1, 1, SNAKE_MAX_LENGTH)
            params:set("maxLength_"..sel, snakes[sel].maxLength)
        else  
            enc(3,1) 
        end
    end

    -- selected snake controls
    keeb["Q"] = function() -- toggle snake slithering
        local sel = params:get("snake_select")
        if params:get("slithering_"..sel) == 0 then
            params:set("slithering_"..sel, 1)
            snakes[sel].slithering = 1
        else
            params:set("slithering_"..sel, 0)
            snakes[sel].slithering = 0
        end
    end
    keeb["E"] = function() -- toggle snake immortality
        local sel = params:get("snake_select")
        if params:get("immortal_"..sel) == 0 then
            params:set("immortal_"..sel, 1)
            snakes[sel].immortal = 1
        else
            params:set("immortal_"..sel, 0)
            snakes[sel].immortal = 0
        end
    end
    keeb["F"] = function() -- increase snake whimsy
        local sel = params:get("snake_select")
        snakes[sel].whimsy = util.clamp(snakes[sel].whimsy - 1, 0, 10)
        params:set("transpose_"..sel, snakes[sel].whimsy)
    end
    keeb["G"] = function() -- decrease snake whimsy
        local sel = params:get("snake_select")
        snakes[sel].whimsy = util.clamp(snakes[sel].whimsy + 1, 0, 10)
        params:set("transpose_"..sel, snakes[sel].whimsy)
    end
    keeb["R"] = function() -- toggle snake quantize
        local sel = params:get("snake_select")
        if snakes[sel].quantize == 0 then
            snakes[sel].quantize = 1
            params:set("quantize_"..sel, 1)
        else
            snakes[sel].quantize = 0
            params:set("quantize_"..sel, 0)
        end
    end

    -- select snake
    keeb["1"] = function() 
        params:set("snake_select", 1) 
        popUpSelect = 15
    end
    keeb["2"] = function() 
        params:set("snake_select", 2) 
        popUpSelect = 15
    end
    keeb["3"] = function() 
        params:set("snake_select", 3) 
        popUpSelect = 15
    end
    keeb["4"] = function() 
        params:set("snake_select", 4) 
        popUpSelect = 15
    end

    -- global settings
    keeb["Z"] = function() params:set("noteRowOffset", util.clamp(params:get("noteRowOffset") - 1, 1, 16)) end
    keeb["X"] = function() params:set("noteRowOffset", util.clamp(params:get("noteRowOffset") + 1, 1, 16)) end
    keeb["C"] = function() params:set("scaleGrid", util.clamp(params:get("scaleGrid") - 1, 1, 8)) end
    keeb["V"] = function() params:set("scaleGrid", util.clamp(params:get("scaleGrid") + 1, 1, 8)) end
    keeb["BACKSPACE"] = function() clearFoodGridAction() end
    keeb["8"] = function()
        if params:get("foodSpawn") == 0 then
            params:set("foodSpawn", 1)
        else
            params:set("foodSpawn", 0)
        end
    end
    keeb["9"] = function()
        if params:get("foodImmortal") == 0 then
            params:set("foodImmortal", 1)
        else
            params:set("foodImmortal", 0)
        end
    end
    keeb["0"] = function()
        if params:get("strictFoodOrder") == 0 then
            params:set("strictFoodOrder", 1)
        else
            params:set("strictFoodOrder", 0)
        end
    end
    keeb["/"] = function() -- put this away from the other controls lol
        if params:get("twoPlayerMode") == 0 then
            params:set("twoPlayerMode", 1)
        else
            params:set("twoPlayerMode", 0)
        end
    end
end

-- typing keyboard support
function keyboard.code(code,value)
    if value == 1 then
        (keeb[code] or keeb[BAD_CODE])()
        popUpKeyboard = 3 -- set popUpTimer
        popUpKeyboardText = code
    end
end

function setup_params()
    -- copying oilcan interface style for timbres

    -- snake settings
    params:add_number("Internal_ON_OFF", "Internal ON/OFF", 0, 1, 1)
    params:add_separator("Snake Settings", "Snake Settings")
    params:add_number("snake_select", "selected snake", 1, SNAKE_MAX_COUNT, 1)
    -- per snake
    for j = 1, SNAKE_MAX_COUNT do
        for _, v in ipairs(snake_specs) do
            local snakeParamID = v.id..'_'..j
            local snakeParamName = v.name

            -- make a new param in the param menu
            params:add{
                id = snakeParamID
            ,	name = snakeParamName
            ,	type = 'number'
            ,	min = v.min
            ,	max = v.max
            ,	default = v.default
            ,	k = v.k and v.k or 1
            ,	units = v.units and v.units or ''
            }

            -- update the table of snake objects when you change param value
            if snakeParamName == "slithering" then
                -- action for "slithering"
                params:set_action(snakeParamID, function(val)
                    if val == 1 then
                        snakes[j].body[1].x = math.random(1,kDisplayWidth)
                        snakes[j].body[1].y = math.random(1,kDisplayHeight)
                        snakes[j][snakeParamName] = val
                    else -- val == 0
                        snakes[j]:die()
                        snakes[j].body[1].x = 0
                        snakes[j].body[1].y = 0
                        snakes[j][snakeParamName] = val
                        refreshGrid()
                    end
                end)
            else
                -- action for each param that isn't "slithering"
                params:set_action(snakeParamID, function(val)
                    snakes[j][snakeParamName] = val
                end)
            end

            -- show the first snake, hide the others
            if j ~= 1 then
                params:hide(snakeParamID)
            end
        end
        -- OSC
        params:add_control("shape" .. j, "osc " .. j .. " shape", controlspec.new(0, 1, 'lin', 1, 0, ''))
        params:set_action("shape" .. j, function(x) engine.shape(x, j) end)
        params:add_control("freq" .. j, "osc " .. j .. " freq", controlspec.new(20, 10000, 'lin', 1, 120, 'hz'))
        params:set_action("freq" .. j, function(x) engine.freq(x, j) end)
        -- ENV
        params:add_control("decay" .. j, "env " .. j .. " decay", controlspec.new(0.05, 1, 'lin', 0.01, 0.25, 'sec'))
        params:set_action("decay" .. j, function(x) engine.decay(x, j) end)
        params:add_control("sweep" .. j, "env " .. j .. " sweep", controlspec.new(0, 2000, 'lin', 0.5, 0, ''))
        params:set_action("sweep" .. j, function(x) engine.sweep(x, j) end)
        -- LFO
        params:add_control("lfoFreq" .. j, "lfo " .. j .. " freq", controlspec.new(1, 1000, 'lin', 0.25, 11, 'hz'))
        params:set_action("lfoFreq" .. j, function(x) engine.lfoFreq(x, j) end)
        params:add_control("lfoShape" .. j, "lfo " .. j .. " shape", controlspec.new(0, 1, 'lin', 1, 0, ''))
        params:set_action("lfoShape" .. j, function(x) engine.lfoShape(x, j) end)
        params:add_control("lfoSweep" .. j, "lfo " .. j .. " sweep", controlspec.new(0, 2000, 'lin', 0.25, 0, ''))
        params:set_action("lfoSweep" .. j, function(x) engine.lfoSweep(x, j) end)

        if j ~= 1 then
            params:hide("shape" .. j)
            params:hide("freq" .. j)
            params:hide("decay" .. j)
            params:hide("sweep" .. j)
            params:hide("lfoFreq" .. j)
            params:hide("lfoShape" .. j)
            params:hide("lfoSweep" .. j)
        end


    end
    -- show selected snake params, hide the others
    params:set_action("snake_select", function()
        local t = params:get("snake_select")
        for j=1,SNAKE_MAX_COUNT do
            for _,v in ipairs(snake_specs) do
                local snakeParamID = v.id..'_'..j
                if j == t then
                    params:show(snakeParamID)
                else
                    params:hide(snakeParamID)
                end
            end
            if j == t then            
                params:show("shape" .. j)
                params:show("freq" .. j)
                params:show("decay" .. j)
                params:show("sweep" .. j)
                params:show("lfoFreq" .. j)
                params:show("lfoShape" .. j)
                params:show("lfoSweep" .. j)
            else
                params:hide("shape" .. j)
                params:hide("freq" .. j)
                params:hide("decay" .. j)
                params:hide("sweep" .. j)
                params:hide("lfoFreq" .. j)
                params:hide("lfoShape" .. j)
                params:hide("lfoSweep" .. j)
            end
        end

        _menu.rebuild_params()
    end)

    -- food settings
    params:add_separator("Food Settings", "Food Settings")
    params:add_number("foodSpawn", "food spawn", 0, 1, 1)
    params:add_number("foodImmortal", "food immortal", 0, 1, 0)
    params:add_number("strictFoodOrder", "strict food order", 0, 1, 0)
    params:add_trigger("clearGrid", "clear food grid")
    params:set_action("clearGrid", clearFoodGridAction)
    params:add_number("twoPlayerMode", "two player mode", 0, 1, 0)
    params:add_number("noteRowOffset", "note row offset", 1, 16, 5)
    params:add_number("scaleGrid", "scale", 1, 8, 1)
    params:set_action("scaleGrid", function(val)
        noteArray = mutil.generate_scale(0, scaleNames[val], 10)
    end)
end
  
-- TO DO OPTIMIZATIONS??
-- me from the future: never optimize, it didn't help
function startGame (snek)
    while true do
        clock.sync(1/snakes[snek].speed)
        if snakes[snek].slithering == 1 then
            snakes[snek]:checkBehavior() -- selects turn signal (left, forward, or right)
            snakes[snek]:checkDirection() -- sets direction given turn signal 
            snakes[snek]:slither() -- steps given a direction 
            snakes[snek]:killSnake() -- checks if snake should be dead
            snakes[snek]:grow() -- if died, new spot, check if should grow, otherwise check if should grow
            -- print("frame complete")
        end
    end
end

function refreshGridTimer()
    while true do
        clock.sleep(1/20)
        refreshGrid()
    end
end

function refreshScreenTimer()
    while true do
        clock.sleep(1/15)
        redraw()
    end
end

function init()
    -- initialize nb
    params:add_separator("nb Settings", "nb Settings")
    nb.voice_count = 1
    nb:init()
    nb:add_param("nb_1","nb snake 1")
    nb:add_param("nb_2","nb snake 2")
    nb:add_param("nb_3","nb snake 3")
    nb:add_param("nb_4","nb snake 4")
    nb:add_player_params()

    -- clear grid
    g:all(1)
    g:refresh()

    -- initialize foodGrid
    for y = 1,kDisplayHeight do
        foodGrid[y] = {}
        for x = 1,kDisplayWidth do
            foodGrid[y][x] = 0
        end
    end

    -- initialize snakes
    for i = 1, SNAKE_MAX_COUNT do
        snakes[i] = SnakeClass:new(
            {
                snakeID = i,
                slithering = 1,
                direction = SNAKE_UP,
                speed = 3,
                length = 1,
                body = initBody,
                turnLeft = true,
                trunRight = true,
                behavior = 1,
                immortal = 0,
                maxLength = 10,
                whimsy = 2,
                transpose = 24,
                quantize = 1
            }
        )
    end

    -- init params
    setup_params()

    -- disable the other snakes to start
    for i = 2, SNAKE_MAX_COUNT do
        params:set("slithering_"..i, 0)
        snakes[i].slithering = 0
        snakes[i]:die()
        snakes[i].body[1].x = 0
        snakes[i].body[1].y = 0
    end

    -- random starting food
    idx = math.random(1,kDisplayWidth)
    idy = math.random(1,kDisplayHeight)
    foodGrid[idy][idx] = 1
    table.insert(foodOrder, {x = idx, y = idy})

    -- draw grid and screen
    refreshGrid()
    redraw()
    setupKeyboardControls()

    -- start slithering
    clock.run(startGame, 1)
    clock.run(startGame, 2)
    clock.run(startGame, 3)
    clock.run(startGame, 4)
    clock.run(refreshGridTimer)
    clock.run(refreshScreenTimer)
end