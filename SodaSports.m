%% Clean up environment

% Clear all variables and data
clc
clear

% Close all figures
close all

%% Initialize sprite data

% Store the sprite size 32x32
spriteSize = [32, 32];

% Extract the height and width of the sprite(s)
spriteWidth = 32;
spriteHeight = 32;

%--------------------------------------------------------------------------

% Store the name of the Sprite File
spriteFilePath = 'Sprites.png';

% Label every sprite in the sheet with an ID
spriteIds = ["Can_1", "Can_2", "Can_3", "Can_4";
    "Letter_S", "Letter_O", "Letter_D", "Letter_A";
    "Letter_P", "Letter_R", "Letter_T", "Letter_Exp";
    "Figure_Ball", "Cup_Far", "Cup_Near", "Wood";
    "Start_1", "Start_2", "Start_3", "Black";
    "Slider_LR", "Slider_UD", "Slider_Handle", "Blank"];

% Create a SpriteSheet object with the master sprites
spriteSheet_Sprites = SpriteSheet(spriteFilePath, spriteSize, spriteIds);

%--------------------------------------------------------------------------

% Store the name of the Sprite File
tableFilePath = 'Table.png';

% Label every sprite in the sheet with an ID
tableIds = ["Table (1, 1)", "Table (1, 2)", "Table (1, 3)", "Table (1, 4)", "Table (1, 5)", "Table (1, 6)";
    "Table (2, 1)", "Table (2, 2)", "Table (2, 3)", "Table (2, 4)", "Table (2, 5)", "Table (2, 6)";
    "Table (3, 1)", "Table (3, 2)", "Table (3, 3)", "Table (3, 4)", "Table (3, 5)", "Table (3, 6)"];

% Create a SpriteSheet object with the table sprites
spriteSheet_Table = SpriteSheet(tableFilePath, spriteSize, tableIds);

%--------------------------------------------------------------------------

% Create a sprite container with the master spritesheet
spriteContainer = SpriteContainer(spriteSheet_Sprites);

% Append the table spritesheet to the container
spriteContainer.addSpriteSheet(spriteSheet_Table);

%--------------------------------------------------------------------------

%% Initialize canvas data

% Define the sprite-wise dimensions of the screen
% Ex. 5 sprites by 8 sprites
canvasSize = [5, 8];

% Extract the height and width
canvasWidth = canvasSize(2);
canvasHeight = canvasSize(1);

% Calculate the true screen width & height
screenPixelWidth = spriteWidth * canvasWidth;
screenPixelHeight = spriteHeight * canvasHeight;

%--------------------------------------------------------------------------

%% Initialize the GameEngine object & properties

% Create a GameEngine object with the sprites, size, 
gameEngine = GameEngine(spriteContainer, spriteWidth, spriteHeight);

% Draw the canvas with no objects or background (black)
gameEngine.drawCanvas(canvasSize);

% Ensure the canvas uses no background color
gameEngine.setUseBackgroundColor(false);

% Ensure the canvas will use a background sprite
gameEngine.setUseBackgroundSpriteId(true);

% Define the background sprite as the wood texture
gameEngine.setBackgroundSpriteId("Wood");

%--------------------------------------------------------------------------

%% Draw initial layouts on the screen

% Define the absolute coordinates for the table layout
tableCoords = [32, 96];

% Create a sprite layout for the table
tableLayout = SpriteLayout('table.txt', "Table", spriteContainer);

% Queue the layout to be drawn on the next drawCanvas() call
gameEngine.queueLayout(tableLayout, tableCoords, "Table");

%--------------------------------------------------------------------------

% Define the absolute coordinates for the far cup layout
farCupCoords = [50, 90];

% Create a sprite layout for the far cups
farCuplayout = SpriteLayout('farCups.txt', "Far Cups", spriteContainer);

% Queue the layout to be drawn on the next drawCanvas() call
gameEngine.queueLayout(farCuplayout, farCupCoords, "Far Cups");

%--------------------------------------------------------------------------

% Define the absolute coordinates for the near cup layout
yInput_nearCup = [160, 106];

% Create a sprite layout for the near cups
nearCuplayout = SpriteLayout('nearCups.txt', "Near Cups", spriteContainer);

% Queue the layout to be drawn on the next drawCanvas() call
gameEngine.queueLayout(nearCuplayout, yInput_nearCup, "Near Cups");

%--------------------------------------------------------------------------

% Define the absolute coordinates for the start text layout
startTextCoords = [8 + (screenPixelWidth / 2) - (96 / 2), 80];

% Create a sprite layout for the start text
startLayout = SpriteLayout('start.txt', "Start", spriteContainer);

% Queue the layout to be drawn on the next drawCanvas() call
gameEngine.queueLayout(startLayout, startTextCoords, "Start");

%--------------------------------------------------------------------------

% Define the absolute coordinates for the title text layout
titleTextCoords = [57, 10];

% Create a sprite layout for the title text
titleLayout = SpriteLayout('title.txt', "Title", spriteContainer);

% Queue the layout to be drawn on the next drawCanvas() call
gameEngine.queueLayout(titleLayout, titleTextCoords, "Title");

%--------------------------------------------------------------------------

% Load the theme sound file into our GameEngine object
gameEngine.loadSoundFile('14 Jumpshot.mp3', 'Theme Song');

% Play the theme song at volume 50%
gameEngine.playSound('Theme Song', 5);

%--------------------------------------------------------------------------

% Define the coordinates for the four soda cans in a cell array.
canCoords{1} = [screenPixelWidth / 9, screenPixelHeight / 9];
canCoords{2} = [screenPixelWidth - (screenPixelWidth / 9) - spriteWidth, screenPixelHeight / 9];
canCoords{3} = [screenPixelWidth / 20, screenPixelHeight - (screenPixelHeight / 2) - spriteHeight];
canCoords{4} = [screenPixelWidth - (screenPixelWidth / 20) - spriteWidth, screenPixelHeight - (screenPixelHeight / 2) - spriteHeight];

% Queue the can sprites to be drawn on the next drawCanvas() call
gameEngine.queueSprite("Can_1", "Can_1", floor(canCoords{1}));
gameEngine.queueSprite("Can_2", "Can_2", floor(canCoords{2}));
gameEngine.queueSprite("Can_3", "Can_3", floor(canCoords{3}));
gameEngine.queueSprite("Can_4", "Can_4", floor(canCoords{4}));

%--------------------------------------------------------------------------

% Fade the canvas in from black
gameEngine.fadeIn();

%--------------------------------------------------------------------------

%% Loop through animations while waiting to start

while gameEngine.g_waitToStart
    % Set the focus on the figure (reads keyboard correctly this way)
    figure(gameEngine.g_figure)
    
    % Shift the can coordinates (change the position of the cans)
    canCoords = circshift(canCoords, 1);
    
    % Remove the can sprites from the canvas
    gameEngine.removeSprite("Can_1");
    gameEngine.removeSprite("Can_2");
    gameEngine.removeSprite("Can_3");
    gameEngine.removeSprite("Can_4");
    
    % Queue the can sprites (with new coordinates) to be drawn
    gameEngine.queueSprite("Can_1", "Can_1", floor(canCoords{1}));
    gameEngine.queueSprite("Can_2", "Can_2", floor(canCoords{2}));
    gameEngine.queueSprite("Can_3", "Can_3", floor(canCoords{3}));
    gameEngine.queueSprite("Can_4", "Can_4", floor(canCoords{4}));
    
    % Check if the space bar was pressed during the loop
    if ~gameEngine.g_waitToStart
        % If the space bar was pressed, break out of the loop
        break;
    end
    
    % Pause the loop to ensure all elements get drawn
    pause(0.5);
    
    % Shift the can coordinates (change the position of the cans)
    canCoords = circshift(canCoords, 1);
    
    % Remove the can sprites from the canvas
    gameEngine.removeSprite("Can_1");
    gameEngine.removeSprite("Can_2");
    gameEngine.removeSprite("Can_3");
    gameEngine.removeSprite("Can_4");
    
    % Queue the can sprites (with new coordinates) to be drawn
    gameEngine.queueSprite("Can_1", "Can_1", floor(canCoords{1}));
    gameEngine.queueSprite("Can_2", "Can_2", floor(canCoords{2}));
    gameEngine.queueSprite("Can_3", "Can_3", floor(canCoords{3}));
    gameEngine.queueSprite( "Can_4", "Can_4", floor(canCoords{4}));
    
    % Check if the space bar was pressed during the loop
    if ~gameEngine.g_waitToStart
        % If the space bar was pressed, break out of the loop
        break;
    end
    
    % Remove the start text layout
    gameEngine.removeLayout("Start");
    
    % Draw the canvas without the start text layout
    gameEngine.drawCanvas();

    % Pause the loop to ensure all elements get drawn
    pause(0.5);
    
    % Shift the can coordinates (change the position of the cans)
    canCoords = circshift(canCoords, 1);
    
    % Remove the can sprites from the canvas
    gameEngine.removeSprite("Can_1");
    gameEngine.removeSprite("Can_2");
    gameEngine.removeSprite("Can_3");
    gameEngine.removeSprite("Can_4");
    
    % Queue the can sprites (with new coordinates) to be drawn
    gameEngine.queueSprite("Can_1", "Can_1", floor(canCoords{1}));
    gameEngine.queueSprite("Can_2", "Can_2", floor(canCoords{2}));
    gameEngine.queueSprite("Can_3", "Can_3", floor(canCoords{3}));
    gameEngine.queueSprite("Can_4", "Can_4", floor(canCoords{4}));
    
    % Check if the space bar was pressed during the loop
    if ~gameEngine.g_waitToStart
        % If the space bar was pressed, break out of the loop
        break;
    end
    
    % Pause the loop to ensure all elements get drawn
    pause(0.5);
    
    % Shift the can coordinates (change the position of the cans)
    canCoords = circshift(canCoords, 1);
    
    % Redraw the start text layout one second later (creates a blinking effect)
    gameEngine.drawLayout(startLayout, startTextCoords, "Start"); 
end

%--------------------------------------------------------------------------

%% Prepare scene for the game

% Since the user pressed the spacebar, fade out the current scene so we can
% draw the new elements out of the user's view
gameEngine.fadeOut();

% Remove the near cup layout as it is not used in the game
gameEngine.removeLayout("Near Cups");

% Remove the title text as it is not used in the game
gameEngine.removeLayout("Title");

% Remove the start text as it is not used in the game
gameEngine.removeLayout("Start");

% Remove all four of the cans from the canvas
gameEngine.removeSprite("Can_1");
gameEngine.removeSprite("Can_2");
gameEngine.removeSprite("Can_3");
gameEngine.removeSprite("Can_4");

%--------------------------------------------------------------------------

% Calculate new coordinates for the two visible cans
canCoords1 = [screenPixelWidth / 20, screenPixelHeight - (screenPixelHeight / 2) - spriteHeight];
canCoords2 = [screenPixelWidth - (screenPixelWidth / 20) - spriteWidth, screenPixelHeight - (screenPixelHeight / 2) - spriteHeight];

% Queue the new cans to be drawn
gameEngine.queueSprite("Can_1", "Can_1", floor(canCoords1));
gameEngine.queueSprite("Can_2", "Can_2", floor(canCoords2));

%--------------------------------------------------------------------------

% Define the absolute coordinates for the new title text layout
titleCoords = [10, 10];

% Create a sprite layout for the new title text
titleLayout = SpriteLayout('titleActive.txt', "Title", spriteContainer);

% Queue the layout to be drawn on the next drawCanvas() call
gameEngine.queueLayout(titleLayout, titleCoords, "Title");

%--------------------------------------------------------------------------

% Define the slider sprite's height
spriteHeight = 13;

% Define the absolute coordinates for the left-right alider
sliderCoords1 = [screenPixelWidth / 4, (screenPixelHeight / 3) - spriteHeight / 2];

% Queue the left-right slider to be drawn
gameEngine.queueSprite("Slider_LR", "Slider_LR", sliderCoords1);
gameEngine.queueSprite("Slider_Handle", "Slider_Handle1", sliderCoords1);

% Define the absolute coordinates for the up-down slider
sliderCoords2 = [3 * screenPixelWidth / 4 - 32, (screenPixelHeight / 3) - spriteHeight / 2];

% Queue the up-down slider to be drawn
gameEngine.queueSprite("Slider_UD", "Slider_UD", sliderCoords2);
gameEngine.queueSprite("Slider_Handle", "Slider_Handle2", sliderCoords2);

%--------------------------------------------------------------------------

%% Run the game logic

% Fade the canvas in with the game scen set up
gameEngine.fadeIn();

% Begin the game timer
tic;

% Set the default number of cups
numCups = 10;

% Loop through the game stages while there are still cups present
while numCups > 0
    % Set the "left-right" index starting at zero
    indexLR = 0;
    
    % Set the direction of the slider (+/-)
    deltaLR = 1;

    % Set the furthest left point
    point1 = [94, 90];
    
    % Set the furthest right point
    point2 = [100, 60];

    % Calculate the X & Y distance between these extrema
    distanceY = abs(point1(1) - point2(1));
    distanceX = abs(point1(2) - point2(2));

    % These coordinate values will hold the final point of the L-R slider
    newY = 0;
    newX = 0;

    % Tell the game engine to wait for the spacebar to be pressed
    gameEngine.g_waitToStart = true;

    % Loop until the spacebar is pressed
    while gameEngine.g_waitToStart
        
        % Remove the handle sprite from the canvas
        gameEngine.removeSprite("Slider_Handle1");

        % Check if the handle has reached the furthest left point
        if indexLR == -14
            % If so, begin moving the handle to the right
            deltaLR = 1;
        % Check if the handle has reached the furthest right point
        elseif indexLR == 14
            % If so, begin moving the handle to the left
            deltaLR = -1;
        end

        % Calculate the new coordinate of the handle
        newCoords = minus(sliderCoords1, [indexLR, 0]);

        % Queue the handle to be drawn
        gameEngine.queueSprite("Slider_Handle", "Slider_Handle1", newCoords);

        % Calculate the percentage that the handle falls on the slider
        ratio = (indexLR + 14) / 28;

        % Calculate where to move the projectile ending position
        newX = point1(2) - floor(distanceX * ratio);
        newY = point1(1) + floor(distanceY * ratio);

        % Draw the new path
        gameEngine.drawPath(newX, newY);

        % Adjust the index of the handle
        indexLR = indexLR + deltaLR;
        
        % Pause the loop to ensure everything gets drawn
        % Also sets timing for the slider/projectile
        pause(0.1);
    end
    
    % Set the "up-down" index starting at zero
    indexUD = 0;
    
    % Set the direction of the slider (+/-)
    deltaUD = 1;
    
    % Set the furthest up point
    point1 = [93, 68];
    
    % Set the furthest down point
    point2 = [102, 90];

    % Calculate the midpoint of the range
    midPoint = floor([(point1(1) + point2(1)) / 2, (point1(2) + point2(2)) / 2]);
    
    % Extract the X & Y values of this midpoint
    midPointY = midPoint(1);
    midPointX = midPoint(2);

    % Calculate the X & Y differences from the ending point & the midpoint
    deltaY = newY - midPointY;
    deltaX = newX - midPointX;

    % Calculate the new extrema along the point we ended with
    point1 = point1 + [deltaY, deltaX];
    point2 = point2 + [deltaY, deltaX];

    % Calculate the distance between both points
    distanceY = abs(point1(1) - point2(1));
    distanceX = abs(point1(2) - point2(2));

    % Tell the game engine to wait for the spacebar to be pressed
    gameEngine.g_waitToStart = true;

    % Loop until the spacebar is pressed
    while gameEngine.g_waitToStart
        % Remove the up-down handle from the canvas
        gameEngine.removeSprite("Slider_Handle2");

        % Check if the handle has reached the furthest left point
        if indexUD == -14
            % If so, begin moving the handle to the right
            deltaUD = 1;
        % Check if the handle has reached the furthest right point
        elseif indexUD == 14
            % If so, begin moving the handle to the left
            deltaUD = -1;
        end

        % Calculate the new coordinate of the handle
        newCoords = minus(sliderCoords2, [indexUD, 0]);

        % Queue the handle to be drawn
        gameEngine.queueSprite("Slider_Handle", "Slider_Handle2", newCoords);

        % Calculate the percentage that the handle falls on the slider
        ratio = (indexUD + 14) / 28;

        % Calculate where to move the projectile ending position
        newX = point1(2) + floor(distanceX * ratio);
        newY = point1(1) + floor(distanceY * ratio);

        % Draw the new path
        gameEngine.drawPath( newX, newY);

        % Adjust the index of the handle
        indexUD = indexUD + deltaUD;
        
        % Pause the loop to ensure everything gets drawn
        % Also sets timing for the slider/projectile
        pause(0.1);
    end 
    
    % Calculate if the final coordinates fall into a cup
    [isCup, cupNum] = checkCup(farCuplayout, newY, newX);
    
    % Check if the final coordinates fall into a cup
    if isCup
        % Clear the far cup layout
        gameEngine.removeLayout("Far Cups");
        
        % Define the absolute coordinates for the up-down slider
        farCupCoords = [50, 90];
        
        % Remove the hit cup from the layout
        farCuplayout.c_spriteLayout(cupNum) = [];
        
        % Draw the adjusted cup layout on the canvas
        gameEngine.drawLayout(farCuplayout, farCupCoords, "Far Cups");
        
        % Adjust the number of cups
        numCups = numCups - 1;
    end
end

% Record the time it took to complete the game
time = toc;

% Print the ending message
fprintf("Congrats! It took you " + time + " seconds to finish!");

% Fade out the canvas as the game is over
gameEngine.fadeOut();

% Hide the figure
gameEngine.hideFigure();

% Define a function to check if the cup was hit, and if so which cup
function [isCup, cupNum] = checkCup(cupLayout, yPos, xPos)
    % Define the absolute coordinates for the far cup layout
    yInput = 90;
    xInput = 50;
    
    % Get the far cup layout
    spriteData = cupLayout.c_spriteLayout;
    
    % Define the inital value as "the cup was not fit"
    l_isCup = false;
    
    % Don't define a cup number since it hasn't been hit yet
    l_cupNum = 0;
    
    % Loop through every cup'd data
    for index = 1:length(spriteData)
        % Get the current cup's data
        currentSprite = spriteData{index};
        
        % Calculate the lower bounds for the cup's opening
        lowerBoundY = yInput + currentSprite.yCoord;
        lowerBoundX = xInput + currentSprite.xCoord;
        
        % Calculate the upper bounds for the cup's opening
        upperBoundY = lowerBoundY + 8;
        upperBoundX = lowerBoundX + 3;
        
        % Check if the ball is between these bounds
        yCheck = (yPos >= lowerBoundY) && (yPos <= upperBoundY);
        xCheck = (xPos >= lowerBoundX) && (xPos <= upperBoundX);
        
        if yCheck && xCheck
            % The cup has been hit
            l_isCup = true;
            
            % Store the hit cup's value
            l_cupNum = index;
            
            % Break out of the loop
            break;
        end
    end
    
    % Return the calculated values
    isCup = l_isCup;
    cupNum = l_cupNum;
    
end