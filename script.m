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
    "Figure_Ball", "Cup_Near", "Cup_Far", "Wood";
    "Start_1", "Start_2", "Start_3", "Black"];

spriteSheet = SpriteSheet(spriteFilePath, spriteSize, spriteIds);

spriteFilePath = 'Table.png';
spriteSize = [32, 32];
spriteIds = ["Table (1, 1)", "Table (1, 2)", "Table (1, 3)", "Table (1, 4)", "Table (1, 5)", "Table (1, 6)";
    "Table (2, 1)", "Table (2, 2)", "Table (2, 3)", "Table (2, 4)", "Table (2, 5)", "Table (2, 6)";
    "Table (3, 1)", "Table (3, 2)", "Table (3, 3)", "Table (3, 4)", "Table (3, 5)", "Table (3, 6)"];

spriteSheet_table = SpriteSheet(spriteFilePath, spriteSize, spriteIds);

spriteSheet.addSpriteSheet(spriteSheet_table);


spriteWidth = 32;
spriteHeight = 32;
gameEngine = GameEngine(spriteSheet, spriteWidth, spriteHeight, 8);
gameEngine.setUseBackgroundColor(true);
gameEngine.setBackgroundColor([0, 0, 0]);

canvasSize = [5, 8];
canvasWidth = canvasSize(2);
canvasHeight = canvasSize(1);

screenPixelWidth = spriteWidth * canvasWidth;
screenPixelHeight = spriteHeight * canvasHeight;

gameEngine.drawCanvas(canvasSize);
gameEngine.setUseBackgroundSpriteId(true);
gameEngine.setBackgroundSpriteId("Wood");

yInput = 96;
xInput = 32;

tableLayout = SpriteLayout('table.txt', "Table");
gameEngine.queueLayout(tableLayout, [xInput, yInput], "Table");

yInput = 86;
xInput = 46;
nearCuplayout = SpriteLayout('nearCups.txt', "Near Cups");
gameEngine.queueLayout(nearCuplayout, [xInput, yInput], "Near Cups");

yInput = 106;
xInput = 160;
farCuplayout = SpriteLayout('farCups.txt', "Far Cups");
gameEngine.queueLayout(farCuplayout, [xInput, yInput], "Far Cups");

yInput = 80;
xInput = 8 + (screenPixelWidth / 2) - (96 / 2);

startLayout = SpriteLayout('start.txt', "Start");
gameEngine.queueLayout(startLayout, [xInput, yInput], "Start");

yInput = 10;
xInput = 59;

titleLayout = SpriteLayout('title.txt', "Title");
gameEngine.queueLayout(titleLayout, [xInput, yInput], "Title");

can_1Coords = [screenPixelWidth / 9, screenPixelHeight / 9];
can_2Coords = [screenPixelWidth - (screenPixelWidth / 9) - spriteWidth, screenPixelHeight / 9];
can_3Coords = [screenPixelWidth / 20, screenPixelHeight - (screenPixelHeight / 2) - spriteHeight];
can_4Coords = [screenPixelWidth - (screenPixelWidth / 20) - spriteWidth, screenPixelHeight - (screenPixelHeight / 2) - spriteHeight];

gameEngine.queueSprite("Can_1", floor(can_1Coords));
gameEngine.queueSprite("Can_2", floor(can_2Coords));
gameEngine.queueSprite("Can_3", floor(can_3Coords));
gameEngine.queueSprite("Can_4", floor(can_4Coords));

gameEngine.loadSoundFile('14 Jumpshot.mp3', 'Theme Song');
gameEngine.playSound('Theme Song', 10);

%gameEngine.drawCanvas(canvasSize);

gameEngine.fadeIn();

yInput = 80;
xInput = 8 + (screenPixelWidth / 2) - (96 / 2);

    figure(gameEngine.my_figure)
while gameEngine.s_waitToStart
    figure(gameEngine.my_figure)
    
    pause(1);
    gameEngine.removeLayout("Start");
    gameEngine.drawCanvas();

    pause(1);
    gameEngine.drawLayout(startLayout, [xInput, yInput], "Start"); 
end
gameEngine.fadeOut();
