clc
clear
close all

%% Example showing playing card faces on a grey background
addpath 'C:\MATLAB\Software Design Project';

spriteFilePath = 'Sprites.png';
spriteSize = [32, 32];
spriteIds = ["Can_1", "Can_2", "Can_3", "Can_4";
    "Letter_S", "Letter_O", "Letter_D", "Letter_A";
    "Letter_P", "Letter_R", "Letter_T", "Letter_Exp";
    "Figure_Ball", "Cup_Near", "Cup_Far", "Wood"];

spriteSheet = SpriteSheet(spriteFilePath, spriteSize, spriteIds);

spriteFilePath = 'Table.png';
spriteSize = [32, 32];
spriteIds = ["Table (1, 1)", "Table (1, 2)", "Table (1, 3)", "Table (1, 4)", "Table (1, 5)", "Table (1, 6)";
    "Table (2, 1)", "Table (2, 2)", "Table (2, 3)", "Table (2, 4)", "Table (2, 5)", "Table (2, 6)";
    "Table (3, 1)", "Table (3, 2)", "Table (3, 3)", "Table (3, 4)", "Table (3, 5)", "Table (3, 6)"];

spriteSheet_table = SpriteSheet(spriteFilePath, spriteSize, spriteIds);

 [y, Fs] = audioread('14 Jumpshot.mp3');
 %sound(y, Fs, 16);

% pause(2);

%[y1, Fs1] = audioread('win.wav');
%sound(y1, Fs1, 16);
%
%pause(5);
%sound(y ./ 5, Fs, 16);
%
%pause(5);

% clear sound;

spriteWidth = 32;
spriteHeight = 32;

gameEngine = GameEngine(spriteSheet, spriteWidth, spriteHeight, 8);

gameEngine.setUseBackgroundColor(false);
gameEngine.setBackgroundSpriteId("Wood");
gameEngine.setUseBackgroundSpriteId(true);

canvasSize = [5, 8];
canvasWidth = canvasSize(2);
canvasHeight = canvasSize(1);

screenPixelWidth = spriteWidth * canvasWidth;
screenPixelHeight = spriteHeight * canvasHeight;

gameEngine.drawCanvas(canvasSize);

topXOffset = 80;
topYOffset = 10;

bottomXOffset = 58;
bottomYOffset = 42;

gameEngine.drawSprite("Letter_S", [topXOffset + 0, topYOffset]);
gameEngine.drawSprite("Letter_O", [topXOffset + 24, topYOffset]);
gameEngine.drawSprite("Letter_D", [topXOffset + 47, topYOffset]);
gameEngine.drawSprite("Letter_A", [topXOffset + 67, topYOffset]);
gameEngine.drawSprite("Letter_S", [bottomXOffset + 0, bottomYOffset]);
gameEngine.drawSprite("Letter_P", [bottomXOffset + 22, bottomYOffset]);
gameEngine.drawSprite("Letter_O", [bottomXOffset + 43, bottomYOffset]);
gameEngine.drawSprite("Letter_R", [bottomXOffset + 64, bottomYOffset]);
gameEngine.drawSprite("Letter_T", [bottomXOffset + 83, bottomYOffset]);
gameEngine.drawSprite("Letter_S", [bottomXOffset + 105, bottomYOffset]);

can_1Coords = [screenPixelWidth / 9, screenPixelHeight / 9];
can_2Coords = [screenPixelWidth - (screenPixelWidth / 9) - spriteWidth, screenPixelHeight / 9];
can_3Coords = [screenPixelWidth / 9, screenPixelHeight - (screenPixelHeight / 9) - spriteHeight];
can_4Coords = [screenPixelWidth - (screenPixelWidth / 9) - spriteWidth, screenPixelHeight - (screenPixelHeight / 9) - spriteHeight];



    gameEngine.drawSprite("Can_1", floor(can_1Coords));
    gameEngine.drawSprite("Can_2", floor(can_2Coords));
    gameEngine.drawSprite("Can_3", floor(can_3Coords));
    gameEngine.drawSprite("Can_4", floor(can_4Coords));
    gameEngine.showFigure();
sound(y ./ 5, Fs, 16);

i = 0;
while true
    if mod(i, 2) == 0
        offset = 2;
    else
        offset = -2;
    end
    
    floor(can_1Coords)
    floor(can_1Coords) + offset
    
    gameEngine.removeSprite("Can_1");
    gameEngine.drawSprite("Can_1", floor(can_1Coords) + offset);
    pause(0.1);
    gameEngine.removeSprite("Can_2");
    gameEngine.drawSprite("Can_2", floor(can_2Coords) - offset);
    pause(0.1);
    gameEngine.removeSprite("Can_3");
    gameEngine.drawSprite("Can_3", floor(can_3Coords) + offset);
    pause(0.1);
    gameEngine.removeSprite("Can_4");
    gameEngine.drawSprite("Can_4", floor(can_4Coords) - offset);
    pause(0.1);
    
    i = i + 1;
end

%pause(5);

%gameEngine.setBackgroundSpriteId(2);
%gameEngine.setUseBackgroundSpriteId(true);

%drawCanvas(gameEngine, 5, 5);

%running = true;
%t = 0;
%increasing = true;

%queueSprite(card_scene1, 32, 0 * 32, 0, 5, "S.1.1");
%queueSprite(card_scene1, 32, 1 * 32, 0, 6, "O.1.1");
%queueSprite(card_scene1, 32, 2 * 32, 0, 7, "D.1.1");
%queueSprite(card_scene1, 32, 3 * 32, 0, 8, "A.1.1");
%
%queueSprite(card_scene1, 32, 0 * 32, 32, 5, "S.2.1");
%queueSprite(card_scene1, 32, 1 * 32, 32, 9, "P.2.1");
%queueSprite(card_scene1, 32, 2 * 32, 32, 6, "O.2.1");
%queueSprite(card_scene1, 32, 3 * 32, 32, 10, "R.2.1");

    %blankScene([1:4;1:4;1:4;1:4]) = 14;
%while running
%    currentT = t;
%    
%    ballId = "Ball";
%    
%    queueSprite(card_scene1, 16, currentT, currentT, 13, ballId);
%    
%    drawScene(card_scene1,blankScene)
%    pause(0.001); 
%    
%    removeSprite(card_scene1, ballId);
%    drawScene(card_scene1,blankScene)
 %   
 %   if t == 25
 %       running = false;
%        increasing = false;
%    elseif t == 0
%        increasing = true;
%    end
 %   
  %  if increasing
   %     t = t + 1;
 %   else
%        t = t - 1;
%    end
%end
% drawCircle(10, 32, 32)

%% Example showing how to use two layers
% the first layer has blank cards and card backs
% the second layer has numbers and card faces
for k = 1:100
    x(k) = k;
    y(k) = sin(x(k));
end
figure(1)
plot(x, y)


%% Example using the simple dice sprite sheet
simple_dice_scene = simpleGameEngine('retro_simple_dice.png', 16, 16, 10, [0,0,0]);
drawScene(simple_dice_scene,[1])

%% Example using the dice sprite sheet, which allows dice of different colors
dice_scene = simpleGameEngine('retro_dice.png', 16, 16, 10, [0,0,0]);
drawScene(dice_scene,[1 2 3 4 5 6 7 8 9 10],[1,11:19])

%% Example of user input from mouse, then keyboard
card_scene1 = simpleGameEngine('retro_cards.png', 16, 16, 5, [207,198,184]);
simple_dice_scene = simpleGameEngine('retro_simple_dice.png', 16, 16, 10, [0,0,0]);

[r,c,b] = getMouseInput(card_scene1)
k = getKeyboardInput(simple_dice_scene)

