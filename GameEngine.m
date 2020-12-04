%% GameEngine class

% This handles the rendering, scaling, sounds, pathing, and all user
% friendly mathods for the engine.
classdef GameEngine < handle
    
    % Class properties of the GameEngine
    properties
        
        % Sprite data
        g_spriteSheet = {};
        
        % Sprite dimensions
        g_spriteWidth = 0;
        g_spriteHeight = 0;
     
        % Canvas dimensions
        g_canvasSize = [];
     
        % Sprite's to be drawn
        g_spriteQueue = {};
        
        % Layouts to be drawn
        g_layoutQueue = {};
        
        % Whether or not to use a priority transparency
        g_useMasterTransparency = false;
        
        % Master transparency values (0-255)
        g_masterTransparency = 1;
        
        % Whether or not to wait for the spacebar
        g_waitToStart = true;
     
        % Defined background color
        g_backgroundColor = [0, 0, 0];
        
        % Boolean value for if the user wants a defined background color
        g_useBackgroundColor = true;
     
        % Id of the bcakground sprite
        g_backgroundSpriteId = - 1;
        
        % Boolean value for if the user wants a defined background sprite
        g_useBackgroundSpriteId = false;
        
        % Boolean value for if the path should be drawn
        g_drawPath = false;
        
        % Ending values of the path
        g_endX = 0;
        g_endY = 0;
     
        % Figure to display the image
        g_figure; 
        
        % Raw : x : x 3 array (raw image data x, y ,z[rgb])
        g_imageData;
        
        % Cell array of sound data
        g_soundData = {};
    end
 
    methods
        %% Contract - GameEngine(spriteSheet, spriteHeight, spriteWidth)
        % This is the contructor for the GameEngine class. It defines the
        % class properties based on the input parameters.
        % 
        % @param spriteSheet
        %   The data of all sprites that will be used
        % @param spriteHeight
        %   The height of all input sprites
        % @param spriteWidth
        %   The width of all input sprites
        %
        % @updates <class properties>
        % @requires param(s) ~= NULL
        
        function obj = GameEngine(spriteSheet, spriteHeight, spriteWidth)
         
            % Store incoming parameter variables as class properties
            obj.g_spriteSheet = spriteSheet;
            obj.g_spriteHeight = spriteHeight;
            obj.g_spriteWidth = spriteWidth;
        end
     
        %% Contract - fadeOut(obj)
        % Fades the canvas from the scene to black
        % 
        % @param obj
        %   The GameEngine object
        %
        % @updates <obj.g_masterTransparency>
        % @requires obj ~= NULL
        
        function fadeOut(obj)
            
            % Update the property so drawCanvas() knows to use the master
            % transparency
            obj.g_useMasterTransparency = true;
            
            % Loop through the values 1-255 backwards for the fade
            for index = 255:-1:0
                
                % Update the master transparency
                obj.g_masterTransparency = index;
                
                % Update the canvas
                drawCanvas(obj);
                
                % Pause the loop to ensure everything gets drawn
                pause(0.01);
            end
        end
        
        %% Contract - fadeIn(obj)
        % Fades the canvas from the black to the scene
        % 
        % @param obj
        %   The GameEngine object
        %
        % @updates <obj.g_masterTransparency>
        % @requires obj ~= NULL
        
        function fadeIn(obj)
            
            % Update the property so drawCanvas() knows to use the master
            % transparency
            obj.g_useMasterTransparency = true;
            
            % Loop through the values 1-255 forwards for the fade
            for index = 0:255
                
                % Update the master transparency
                obj.g_masterTransparency = index;
                
                % Update the canvas
                drawCanvas(obj);
                
                % Pause the loop to ensure everything gets drawn
                pause(0.01);
            end
            
            % Tell drawCanvas() to not use the master transparency
            obj.g_useMasterTransparency = false;
            
            % Update the canvas as regular transparency
            drawCanvas(obj);
        end
     
        %% Contract - drawCanvas(obj, s_size)
        % Draws the canvas with the current properties and the current
        % image data
        % 
        % @param obj
        %   The GameEngine object
        % @param s_size
        %   The canvas size
        %
        % @updates <obj.g_figure> & <obj.g_imageData>
        % @requires obj ~= NULL
        
        function drawCanvas(obj, s_size)
            %% Handle incoming arguments
            
            % Get the number of arguments passed into the method
            argumentCount = nargin;
         
            % Check if only the GameEngine object was passed in
            if argumentCount == 1
                % If so, use the predefined canvas size
                s_size = obj.g_canvasSize;
            % Check if both arguments have been passed in
            else
                % Redefine the canvas size to the passed value
                obj.g_canvasSize = s_size;
            end
         
            % Get the canvas height and width (in terms of # of sprites)
            t_height = s_size(1);
            t_width = s_size(2);
         
            % Get the sprite height and width
            spriteHeight = obj.g_spriteHeight;
            spriteWidth = obj.g_spriteWidth;
         
            % Get the true canas height an width
            canvasHeight = spriteHeight * t_height;
            canvasWidth = spriteWidth * t_width;
                    
            %% Initialize the canvas
            
            % Initialize the canvas data as an array (height X width X 3)
            % of zeros
            canvasData = zeros(canvasHeight, canvasWidth, 3, 'uint8');
         
            %% Handle background data
            
            % Check if a background color was defined
            if obj.g_useBackgroundColor
                % If so, get thebackground color's property
                backgroundColor = obj.g_backgroundColor;
                
                % Iterate through the RGB channels
                for rgb_idx = 1:3
                    % Set the image data as only that color.
                    canvasData(:, :, rgb_idx) = backgroundColor(rgb_idx);
                end
            % Check if the background sprite should be used
            elseif obj.g_useBackgroundSpriteId
                % If so, get the class spritesheet's property
                spriteSheet = obj.g_spriteSheet;
                
                % Get the class's background spritesheet id
                backgroundSpriteId = obj.g_backgroundSpriteId;
                
                % Get the background sprite based on its id
                backgroundSprite = spriteSheet.getSpriteById(backgroundSpriteId);
                
                % Get the background sprite's image data based on the
                % sprite
                backgroundSpriteData = backgroundSprite.imageData;
                
                % Get the background sprite's transparency data based on the
                % sprite 
                backgroundSpriteTransparency = backgroundSprite.transparencyData;
                
                % Check if we should use the master transparency
                if obj.g_useMasterTransparency
                    % If so, adjust the data to use that transparency
                    tileData = backgroundSpriteData * (obj.g_masterTransparency / 255);
                else
                    % Else, adjust the data to use the unique sprite
                    % background transparency
                    tileData = backgroundSpriteData .* (backgroundSpriteTransparency / 255);
                end
                
                % Update the canvasData with a tiled background sprite
                canvasData = repmat(tileData, t_height, t_width);
            end
            
            %% Display queued layout data
            
            % Get the class's layout queue property
            layoutQueue = obj.g_layoutQueue;
            
            % Check if the queue is populated
            if (~ isempty(layoutQueue))
                % If so, iterate through the layout queue
                for queueIndex = 1:length(layoutQueue)
                    % Get the current layout from the queue
                    currentLayout = layoutQueue{queueIndex};
                 
                    % Get the sprite array from the current queue
                    spriteData = currentLayout.c_spriteLayout;
                    
                    % Iterate through the sprites in the sprite array
                    for spriteIndex = 1:length(spriteData)
                        % Extract the x and y coordinates from the layout
                        xCoord = currentLayout.c_xCoord;
                        yCoord = currentLayout.c_yCoord;
                    
                        % Get the current sprite from the sprite array
                        currentSprite = spriteData{spriteIndex}.sprite;
                        
                        % Get the image data from the current sprite
                        currentSpriteData = currentSprite.imageData;
                        
                        % Get the transparency data from the current sprite
                        currentSpriteTransparancy = currentSprite.transparencyData;
                        
                        % Check if we should use the master transparency
                        if obj.g_useMasterTransparency
                            % If so, replace the current sprite's
                            % transparency data
                            currentSpriteTransparancy = currentSpriteTransparancy * (obj.g_masterTransparency / 255);
                        end
                        
                        %Get the proper size of the sprite
                        originalSize = size(currentSpriteData);
                        
                        % Get the proper width of the sprite
                        originalWidth = originalSize(1);

                        % Get the relative coordinates of the current
                        % sprite
                        xRelCoord = spriteData{spriteIndex}.xCoord;
                        yRelCoord = spriteData{spriteIndex}.yCoord;
                        
                        % Adjust the absolute coordinates to incorporate
                        % the new relative coordinates
                        yCoord = yCoord + yRelCoord;
                        xCoord = xCoord + xRelCoord;

                        % Check if the drawn sprites will go over the
                        % bounds of the current image array
                        if (yCoord + originalWidth <= canvasHeight) && (xCoord + originalWidth <= canvasWidth)
                            % If not, only update the image that is in the
                            % correct bounds
                            replaceData = canvasData(yCoord + 1:yCoord + originalWidth, xCoord + 1:xCoord + originalWidth, :);

                            % Incorporate the sprite's transparency
                            replaceData = (double(currentSpriteData)) .* ((double(currentSpriteTransparancy)) / 255) + ...
                            (double(replaceData)) .* ((255 - (double(currentSpriteTransparancy))) / 255);

                            % Layer this over the other layers of
                            % canvasData
                            canvasData(yCoord + 1:yCoord + originalWidth, xCoord + 1:xCoord + originalWidth, :) = replaceData;
                        end
                    end
                end
            end
            
            %% Display queued sprite data
            
            spriteQueue = obj.g_spriteQueue;
            if (~ isempty(spriteQueue))
                for customSpriteIndex = 1:length(spriteQueue)
                    % Get the sprite data from the current sprite
                    currentSprite = spriteQueue{customSpriteIndex};
                 
                    % Get the image data from the current sprite
                    currentSpriteData = currentSprite.imageData;
                    
                    % Get the transparency data from the current sprite
                    currentSpriteTransparency = currentSprite.transparencyData;
                    
                    % Extract the x and y coordinates from the layout
                    xCoord = floor(currentSprite.xCoord);
                    yCoord = floor(currentSprite.yCoord);
                 
                    % Check if we should use the master transparency
                    if obj.g_useMasterTransparency
                        % If so, replace the current sprite's
                        % transparency data
                        currentSpriteTransparency(:, :, :) = currentSpriteTransparency(:, :, :) .* (obj.g_masterTransparency / 255);
                    end
                    
                    %Get the proper size of the sprite
                    originalSize = size(currentSprite.imageData);
                    
                    %Get the proper width of the sprite
                    originalWidth = originalSize(1);
                    
                    % Check if the drawn sprites will go over the bounds of
                    % the current image array
                    if (yCoord + originalWidth <= canvasHeight) && (xCoord + originalWidth <= canvasWidth)
                        % If not, only update the image that is in the
                        % correct bounds
                        replaceData = canvasData(yCoord + 1:yCoord + originalWidth, xCoord + 1:xCoord + originalWidth, :);
                     
                        % Incorporate the sprite's transparency
                        replaceData = (double(currentSpriteData)) .* ((double(currentSpriteTransparency)) / 255) + ...
                        (double(replaceData)) .* ((255 - (double(currentSpriteTransparency))) / 255);
                     
                        % Layer this over the other layers of canvasData
                        canvasData(yCoord + 1:yCoord + originalWidth, xCoord + 1:xCoord + originalWidth, :) = replaceData;
                    end
                end
            end

            %% Display desired projectile motion path
            
            % Check if we should draw the path
            if obj.g_drawPath
                % Declare starting coordinates (Static)
                startX = 208;
                startY = 80;
                
                % Get desired ending coordinates from the class properties
                endX = obj.g_endX;
                endY = obj.g_endY;
                
                % Declare arrays of points to fit to a quadratic curve
                testX = [startX, startX - 1, endX];
                testY = [startY, startY, endY];
                
                % Fit the test points to a quadratic curve
                curveFit = fit(testX(:), testY(:), "poly2");
                
                % Get the equation coefficients from the fit
                coefficients = coeffvalues(curveFit);
                a = coefficients(1);
                b = coefficients(2);
                c = coefficients(3);
                
                % Loop from the lower x bound to the upper x bound
                for index = startX:-1:endX
                    % Calculate the new y coordinate
                    yCoord = floor(a * power(index, 2) + b * index + c);
                    
                    % Update canvas data accordingly
                    canvasData(yCoord, index, :) = 255;
                end
                
                % Set the destination point with color blue
                canvasData(endY, endX, :) = [0, 0, 255];
            end
        
            %% Finish diaplaying the image
            
            % Reset the class property to not draw the path again
            obj.g_drawPath = false;
         
            % This part is a bit tricky, but avoids some latency, the idea
            % is that we only want to completely create a new figure if we
            % absolutely have to: the first time the figure is created,
            % when the old figure has been closed, or if the scene is
            % resized. Otherwise, we just update the image data in the
            % current image, which is much faster.
         
            % Check if the figure is empty or if the figure is not valid
            if isempty(obj.g_figure) || ~ isvalid(obj.g_figure)
                % If so, inititalize figure
                obj.g_figure = figure('Renderer', 'painters', 'CloseRequestFcn', @(src, evt) close_figure(obj, src, evt));
             
                % Declare figure properties
                set(obj.g_figure, 'MenuBar', 'none');
                set(obj.g_figure, 'ToolBar', 'none');
                set(obj.g_figure, 'WindowState', 'maximize');
                set(obj.g_figure, 'KeyPressFcn', @(src, evt) keypressCallback(obj, src, evt));
             
                % Display the image to the figure to fit the screen
                obj.g_imageData = imshow(canvasData, 'InitialMagnification', 'fit');
                
            % Check if the image is empty, if data is not a property of the
            % image, or if the size has changed
            elseif isempty(obj.g_imageData) || ~ isprop(obj.g_imageData, 'CData') || ~ isequal(size(canvasData), size(obj.g_imageData.CData))
                % If so, re-display the image
                figure(obj.g_figure);
                uiwait(obj.g_figure);
                disp('figure closed');
                obj.g_imageData = imshow(canvasData, 'InitialMagnification', 'fit');
            else
                % Update the image data
                obj.g_imageData.CData = canvasData;
            end
        end
     
        %% Contract - keypressCallback(obj, ~, evt)
        % Detects when the spacebar is pressed in the focused figure
        % 
        % @param obj
        %   The GameEngine object
        % @param ~
        %   <PLACEHOLDER>
        % @param evt
        %   The keypress event
        %
        % @updates <obj.g_waitToStart>
        % @requires (obj & evt) ~= NULL
        
        function keypressCallback(obj, ~, evt)
            % Check if the spacebar was pressed
            if evt.Key == 'space'
                % If so, update the clas property to notify the main script
                obj.g_waitToStart = false;
            end
        end
        
        %% Contract - drawPath(obj, startX, startY, endX, endY)
        % Detects when the spacebar is pressed in the focused figure
        % 
        % @param obj
        %   The GameEngine object
        % @param startX
        %   The starting x coordinate of the path
        % @param startY
        %   The starting y coordinate of the path
        % @param endX
        %   The ending x coordinate of the path
        % @param endY
        %   The ending y coordinate of the path
        %
        % @updates <obj.*>
        % @requires param(s) ~= NULL
        
        function drawPath(obj, endX, endY)
            % Set the class properties to match the parameters
            obj.g_endX = endX;
            obj.g_endY = endY;
            
            % Tell drawCanvas() to draw the path on the next dar
            obj.g_drawPath = true;
            
            % Update the canvas
            obj.drawCanvas();
        end
        
        %% Contract - removeSprite(obj, spriteId)
        % Removes the sprite with the given id
        % 
        % @param obj
        %   The GameEngine object
        % @param spriteId
        %   Id of the sprite to remove
        %
        % @updates <obj.g_spriteQueue>
        % @requires (obj & spriteId) ~= NULL
        
        function removeSprite(obj, queueSprite)
            % Get the class's sprite queue property
            spriteQueue = obj.g_spriteQueue;
            
            % Check if the sprite queue is populated
            if ~ isempty(spriteQueue)
                %If so, begin the removval check at index 1
                removeIndex = 1;
                
                % Iterate through the sprites in the queue
                while removeIndex <= length(spriteQueue)
                    % Get the current sprite from the queue
                    currentSprite = spriteQueue{removeIndex};
                 
                    % Check if the current sprite is empty
                    if isempty(currentSprite)
                        % If so, skip this sprite and increase the index
                        removeIndex = removeIndex + 1;
                        continue;
                    end
                 
                    % Get the current sprite's id
                    id = currentSprite.id;
                    
                    % Check if the sprite's id matches the desired id
                    if id == queueSprite
                        % If so, remove the sprite from the queue
                        spriteQueue{removeIndex} = [];
                    end
                    
                    % Increase the removal index
                    removeIndex = removeIndex + 1;
                end
            end
            
            % Clear the empty values in sprite queue
            obj.g_spriteQueue = spriteQueue(~ cellfun(@isempty, spriteQueue));
        end
     
        %% Contract - drawSprite(obj, spriteId, queueId, coords)
        % Draws the sprite with the given id at the given coordinates
        % 
        % @param obj
        %   The GameEngine object
        % @param spriteId
        %   The id of the sprite to draw
        % @param queueId
        %   The unique id of the sprite
        % @param coords
        %   The coordinates where to draw the sprite at
        %
        % @updates <obj.g_spriteQueue>
        % @requires param(s) ~= NULL
        
        function drawSprite(obj, spriteId, queueId, coords)
            %Extract the x & y coordinates of the sprite
            xCoord = coords(1);
            yCoord = coords(2);
            
            % Get the sprite queue's class property
            spriteQueue = obj.g_spriteQueue;
            
            % Get the sprite sheet's class property
            spriteSheet = obj.g_spriteSheet;
            
            % Get the next index of the queue (end of the queue)
            nextIndex = length(spriteQueue) + 1;
         
            % Get sprite data based on its id
            nextSprite = getSpriteById(spriteSheet, spriteId);
            
            % Set the coordinates of the sprite
            nextSprite.xCoord = xCoord;
            nextSprite.yCoord = yCoord;
            
            % Set the unique id of the sprite
            nextSprite.id = queueId;
         
            % Add the sprite to the temp queue
            spriteQueue{nextIndex} = nextSprite;
         
            % Replace the queue with the temp queue
            obj.g_spriteQueue = spriteQueue;
         
            % Update the canvas
            drawCanvas(obj);
        end
        
        %% Contract - queueSprite(obj, spriteId, coords)
        % Queues the sprite with the given id at the given coordinates
        % 
        % @param obj
        %   The GameEngine object
        % @param spriteId
        %   The id of the sprite to draw
        % @param queueId
        %   The unique id of the sprite
        % @param coords
        %   The coordinates where to draw the sprite at
        %
        % @updates <obj.g_spriteQueue>
        % @requires param(s) ~= NULL
        
        function queueSprite(obj, spriteId, queueId, coords)
            %Extract the x & y coordinates of the sprite
            xCoord = coords(1);
            yCoord = coords(2);
            
            % Get the sprite queue's class property
            spriteQueue = obj.g_spriteQueue;
            
            % Get the sprite sheet's class property
            spriteSheet = obj.g_spriteSheet;
            
            % Get the next index of the queue (end of the queue)
            nextIndex = length(spriteQueue) + 1;
         
            % Get sprite data based on its id
            nextSprite = getSpriteById(spriteSheet, spriteId);
            
            % Set the coordinates of the sprite
            nextSprite.xCoord = xCoord;
            nextSprite.yCoord = yCoord;
            
            % Set the unique id of the sprite
            nextSprite.id = queueId;
         
            % Add the sprite to the temp queue
            spriteQueue{nextIndex} = nextSprite;
         
            % Replace the queue with the temp queue
            obj.g_spriteQueue = spriteQueue;
        end
        
        %% Contract - removeLayout(obj, layoutId)
        % Remove the layout with the specified layoutId
        % 
        % @param obj
        %   GameEngine object
        % @param layoutId
        %   Id of the layout to remove
        %
        % @updates <obj.g_layoutQueue>
        % @requires param(s) ~= NULL
        
        function removeLayout(obj, layoutId)
            % Get the class property of the layout queue
            layoutQueue = obj.g_layoutQueue;
            
            % Check if the layout queue is populated
            if ~ isempty(layoutQueue)
                %If so, begin the removval check at index 1
                removeIndex = 1;
                
                % Iterate through the sprites in the queue
                while removeIndex <= length(layoutQueue)
                    % Get the current layout from the queue
                    currentLayout = layoutQueue{removeIndex};
                 
                    % Check if the current layout is empty
                    if isempty(currentLayout)
                        % If so, skip this layout and increase the index
                        removeIndex = removeIndex + 1;
                        continue;
                    end
                 
                    % Get the current layout's id
                    id = currentLayout.c_id;
                    
                    % Check if the layout's id matches the desired id
                    if id == layoutId
                        % If so, remove the layout from the queue
                        layoutQueue{removeIndex} = [];
                        break;
                    end
                    
                    % Increase the removal index
                    removeIndex = removeIndex + 1;
                end
            end
            
            % Clear the empty values in layout queue
            obj.g_layoutQueue = layoutQueue(~ cellfun(@isempty, layoutQueue));
        end
     
        %% Contract - drawLayout(obj, layout, coords, id)
        % Draws the given layout at coords with a given id
        % 
        % @param obj
        %   GameEngine object
        % @param layout
        %   Layout to draw
        % @param coords
        %   Coordinate where to draw the layout
        % @param id
        %   Unique layout id
        %
        % @updates <obj.g_layoutQueue>
        % @requires param(s) ~= NULL
        
        function drawLayout(obj, layout, coords, id)
            %Extract the x & y coordinates of the layout
            xCoord = coords(1);
            yCoord = coords(2);
            
            % Set the unique id of the layout
            layout.c_id = id;
            
            % Set the coordinates of the layout
            layout.c_xCoord = xCoord;
            layout.c_yCoord = yCoord;
         
            % Add the layout to the queue
            obj.g_layoutQueue{end + 1} = layout;
         
            % Update the canvas
            drawCanvas(obj);
        end
        
        %% Contract - queueLayout(obj, layout, coords, id)
        % Queues the given layout at coords with a given id
        % 
        % @param obj
        %   GameEngine object
        % @param layout
        %   Layout to draw
        % @param coords
        %   Coordinate where to draw the layout
        % @param id
        %   Unique layout id
        %
        % @updates <obj.g_layoutQueue>
        % @requires param(s) ~= NULL
        
        function queueLayout(obj, layout, coords, id)
            %Extract the x & y coordinates of the layout
            xCoord = coords(1);
            yCoord = coords(2);
            
            % Set the unique id of the layout
            layout.c_id = id;
            
            % Set the coordinates of the layout
            layout.c_xCoord = xCoord;
            layout.c_yCoord = yCoord;
         
            % Add the layout to the queue
            obj.g_layoutQueue{end + 1} = layout;
        end
        
        %% Contract - close_figure(~, src, ~)
        % Callback function to handle the window being closed as well as
        % stopping the music.
        % 
        % @param ~
        %   <PLACEHOLDER>
        % @param src
        %   Source of the closed figure
        % @param ~
        %   <PLACEHOLDER>
        %
        % @updates <src>
        % @requires src ~= NULL
        
        function close_figure(~, src, ~)
            % Clears all sounds
            clear sound;
            
            % Deletes the source of the callback
            delete(src);
        end
        
        %% Contract - loadSoundFile(obj, filePath, soundId)
        % Adds the data from the given sound file as well as the custom id
        % of the sound object to the class property.
        % 
        % @param obj
        %   GameEngine object
        % @param filePath
        %   Path of the sound file
        % @param soundId
        %   Custom sound object Id
        %
        % @updates <obj.g_soundData> 
        % @requires param(s) ~= NULL

        function loadSoundFile(obj, filePath, soundId)
            % Load the audio file into data
           [soundData, bitRate] = audioread(filePath);
           
           % Set the class properties to match the incoming parameters as
           % well as the sound data
           soundObject.soundData = soundData;
           soundObject.bitRate = bitRate;
           soundObject.soundId = soundId;
           
           % Add the sound object to the class's sound array property
           obj.g_soundData{end+1} = soundObject;
        end
        
        %% Contract - playSound(obj, soundId, volume)
        % Plays the sound data of the sound object with Id == soundId
        % 
        % @param obj
        %   GameEngine object
        % @param soundId
        %   Custom sound object Id
        % @param volume (opt)
        %   Custom sound object Id
        %
        % @requires (obj, soundId) ~= NULL
        
        function playSound(obj, soundId, volume)
            % Get the number of arguments passed into the method
            argumentCount = nargin;
         
            % Check if no volume was provided
            if argumentCount == 2
                % If so, set the volume to 100%
                volume = 100 / 100;
            else
                % Else, set the volume to the provided value
                volume = volume / 100;
            end
            
            % Get the class's sound array property
            soundList = obj.g_soundData;
            
            % Iterate through all sounds in the array
            for index = 1:length(soundList)
                % Get the current sound object
                currentSound = soundList{index};
               
                % Get the current sound's id
                currentSoundId = currentSound.soundId;
               
                % Check if the current id matches the desired id
                if currentSoundId == soundId
                    %If so, get the current sound's data & bitrate
                    currentSoundData = currentSound.soundData;
                    currentSoundBitrate = currentSound.bitRate;
                    
                    % Play the sound at the specified volume
                    sound(currentSoundData * volume, currentSoundBitrate, 16); 
                end
            end
            
        end
        
        %% Contract - showFigure(obj)
        % Shows the figure
        % 
        % @param obj
        %   GameEngine object
        %
        % @requires obj ~= NULL
        
        function showFigure(obj)
            % Set the figure's property to visible.
            set(obj.g_figure, 'visible', 'on');
        end
        
        %% Contract - hideFigure(obj)
        % Hides the figure
        % 
        % @param obj
        %   GameEngine object
        %
        % @requires obj ~= NULL
        
        function hideFigure(obj)
            % Set the figure's property to hidden.
            set(obj.g_figure, 'visible', 'off');
        end
     
        %% Contract - setCanvasSize(obj, canvasSize)
        % Set the class property for canvas size
        % 
        % @param obj
        %   GameEngine object
        % @param canvasSize
        %   Size of the desired canvas
        %
        % @updates <obj.g_canvasSize>
        % @requires param(s) ~= NULL
        
        function setCanvasSize(obj, canvasSize)
            % Set the class property for canvas size
            obj.g_canvasSize = canvasSize;
        end
        
        %% Contract - setBackgroundColor(obj, backgroundColor)
        % Set the class property for background color
        % 
        % @param obj
        %   GameEngine object
        % @param backgroundColor
        %   Desired background color
        %
        % @updates <obj.g_backgroundColor>
        % @requires param(s) ~= NULL
        
        function setBackgroundColor(obj, backgroundColor)
            % Set the class property for background color
            obj.g_backgroundColor = backgroundColor;
        end
        
        %% Contract - getBackgroundColor(obj)
        % Returns the class property for background color
        % 
        % @param obj
        %   GameEngine object
        %
        % @requires obj ~= NULL
        
        function backgroundColor = getBackgroundColor(obj)
            % Returns the class property for background color
            backgroundColor = obj.g_backgroundColor;
        end
     
        %% Contract - setUseBackgroundColor(obj, useBackgroundColor)
        % Set the class property for whether or not to use background color
        % 
        % @param obj
        %   GameEngine object
        % @param useBackgroundColor
        %   Whether or not to use the background color
        %
        % @updates <obj.g_useBackgroundColor>
        % @requires param(s) ~= NULL
        
        function setUseBackgroundColor(obj, useBackgroundColor)
            % Set the class property for whether or not to use background color
            obj.g_useBackgroundColor = useBackgroundColor;
        end
        
        %% Contract - getUseBackgroundColor(obj)
        % Returns the class property for whether or not to use background 
        % color
        % 
        % @param obj
        %   GameEngine object
        %
        % @requires obj ~= NULL
        
        function useBackgroundColor = getUseBackgroundColor(obj)
            % Returns the class property for whether or not to use background 
            % color
            useBackgroundColor = obj.g_useBackgroundColor;
        end
     
        %% Contract - setBackgroundSpriteId(obj, backgroundSpriteId)
        % Set the class property for background sprite id
        % 
        % @param obj
        %   GameEngine object
        % @param backgroundSpriteId
        %   Id of the desired sprite
        %
        % @updates <obj.g_backgroundSpriteId>
        % @requires param(s) ~= NULL
        
        function setBackgroundSpriteId(obj, backgroundSpriteId)
            % Set the class property for background sprite id
            obj.g_backgroundSpriteId = backgroundSpriteId;
        end
        
        %% Contract - getBackgroundSpriteId(obj)
        % Returns the class property for background sprite id
        % 
        % @param obj
        %   GameEngine object
        %
        % @requires obj ~= NULL
        
        function backgroundSpriteId = getBackgroundSpriteId(obj)
            % Returns the class property for background sprite id
            backgroundSpriteId = obj.g_backgroundSpriteId;
        end
     
        %% Contract - setUseBackgroundSpriteId(obj, useBackgroundSpriteId)
        % Set the class property for whether or not to use background sprite
        % 
        % @param obj
        %   GameEngine object
        % @param usebackgroundSpriteId
        %   Whether or not to use the backgtround sprite's id
        %
        % @updates <obj.g_useBackgroundSpriteId>
        % @requires param(s) ~= NULL
        
        function setUseBackgroundSpriteId(obj, useBackgroundSpriteId)
            % Set the class property for whether or not to use background sprite
            obj.g_useBackgroundSpriteId = useBackgroundSpriteId;
        end
        
        %% Contract - useBackgroundSpriteId = getUseBackgroundSpriteId(obj)
        % Returns the class property for whether or not to use background
        % sprite
        % 
        % @param obj
        %   GameEngine object
        %
        % @requires obj ~= NULL
        
        function useBackgroundSpriteId = getUseBackgroundSpriteId(obj)
            % Returns the class property for whether or not to use background
            % sprite
            useBackgroundSpriteId = obj.g_useBackgroundSpriteId;
        end
    end
end