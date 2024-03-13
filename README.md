pit orchisstra  
the game of snake  
a group of snakes is a pit  
live loooong and prosper  

E1: select snake  
E2: speed  
E3: turn snake  
K2: toggle food view  
K3: cycle snake behaviors  

FOODVIEW:  
E2: < down, > up  
E3: < left, > right  
K3: place food  

if two player mode is on  
E2 turns next snake (+1)  

DIRECTIONS  
turn left, right, or forward  
eat food and play a note  
snakes die if eating snakes  
place food  
make food immortal  
make snake immortal  
make many snakes  
make snake fast  
food sequenced snake pathing  
high velocity whimsy  
nb voice per snake  
keyboard controls  
grid controls  

SNAKE BEHAVIORS  
1 none, turn with ENC3 only  
2 random snake turn (whimsy)  
3 turn towards closest food  
4 seek food in order placed  

1 1 2 2 2 2 2 2 2 3 3 3 3 1 1 1  
1 1 1 2 2 2 2 2 3 3 3 3 3 1 1 1  
1 1 1 1 2 2 2 3 3 3 3 3 3 1 1 1  
1 1 1 1 1 H 3 3 3 3 3 3 3 1 1 1  
1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1  
1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1  
1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1  
1 2 2 2 2 2 2 2 2 2 3 3 3 1 1 1  


KEYBOARD CONTROLS  
Q   decrement snake selection (-1)  
E   increment snake selection (+1)  

selected snake:  
W   increase speed  
A   turn left  
S   decrease speed  
D   turn right  
F   cycle through snake behaviors of the selected snake (1,2,3,4) (wraps)  
R   toggle immortality  

SPACE   toggle foodView ON/OFF  
foodView overwrites some snake controls (F, W, A, S, D)  
You're in foodView if a cursor spawns inside a square.  
The first time you enter foodView, the cursor will spawn inside the top left square.  
W   move up  
A   move left  
S   move down  
D   move right  
F   place food  

global controls:  
1   toggle snake 1  
2   toggle snake 2  
3   toggle snake 3  
4   toggle snake 4  
5   toggle food spawn  
6   toggle food immortality  
7   toggle strict food order  
Z   decrement noteRowOffset (-1)  
X   increment noteRowOffset (+1)  
C   decrement scale (-1)  
V   increment scale (+1)  


SNAKE SETTINGS  
nb snake 1-4: select the nb voice for the snake  
selected snake: selects snake 1, 2, 3, or 4  
slithering: 0 removes snake, 1 spawns snake  
behavior: defines the movement of the snake (see more details below)  
speed: 1-20, syncs to norns clock tempo  
immortal: 0 can be killed, 1 all hail immortal snek  
whimsy: 0-10, 0-100% chance to flip a coin to turn left or right  
transpose: midi note offset for nb voices  
quantize: 0/1, controls if note is quantized to scale of the grid  

CHECK OUT THE SCRIPT RUDIMENTS FOR THE SYNTH DOCUMENTATION
https://github.com/cfdrake/rudiments

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
