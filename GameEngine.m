% HOW WE PULL IT ALL TOGETHER. RENDERING ENGINE SEPARATE? MAYBE MAYBE

classdef GameEngine < handle
    properties
        g_spriteSheet = {}; % color data of the sprites
        g_spriteWidth = 0;
        g_spriteHeight = 0;
     
        g_canvasSize = [];
     
        g_spriteQueue = {};
        g_layoutQueue = {};
        
        g_useMasterTransparency = false;
        g_masterTransparency = 1;
        
        s_waitToStart = true;
     
        g_prevBackgroundColor = [];
        g_backgroundColor = [0, 0, 0];
        g_useBackgroundColor = true;
     
        g_backgroundSpriteId = - 1;
        g_useBackgroundSpriteId = false;
     
        g_previousZoomFactor = 1;
        g_currentZoomFactor = 1;
     
        my_figure; % figure identifier
        
        g_backgroundImage;
        
        my_image; % image data
        
        sounds = {};
    end
 
    methods
        %% Contract - GameEngine(spriteSheet, spriteHeight, spriteWidth, zoomFactor)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function obj = GameEngine(spriteSheet, spriteHeight, spriteWidth, zoomFactor)
         
            % Initialize variables
         
            obj.g_spriteSheet = spriteSheet;
            obj.g_spriteHeight = spriteHeight;
            obj.g_spriteWidth = spriteWidth;
         
            argumentCount = nargin;
         
            if argumentCount > 3
                obj.g_currentZoomFactor = zoomFactor;
            end
        end
     
        %% Contract - fadeOut(obj)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function fadeOut(obj)
            obj.g_useMasterTransparency = true;
            for index = 255:-1:0
                obj.g_masterTransparency = index;
                drawCanvas(obj);
                pause(0.01);
            end
        end
        
        %% Contract - fadeIn(obj)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function fadeIn(obj)
            obj.g_useMasterTransparency = true;
            for index = 0:255
                obj.g_masterTransparency = index;
                drawCanvas(obj);
                pause(0.01);
            end
            obj.g_useMasterTransparency = false;
                drawCanvas(obj);
        end
     
        %% Contract - drawCanvas(obj, s_size)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function drawCanvas(obj, s_size)
            % Error checking: make sure the bg and fg are the same size
            argumentCount = nargin;
         
            if argumentCount == 1
                s_size = obj.g_canvasSize;
            else
                obj.g_canvasSize = s_size;
            end
         
            t_width = s_size(1);
            t_height = s_size(2);
         
            canvasHeight = obj.g_spriteHeight * t_width;
            canvasWidth = obj.g_spriteWidth * t_height;
         
            canvasData = zeros(canvasHeight, canvasWidth, 3, 'uint8');
         
            % loop over the rows and colums of the tiles in the scene to
            % draw the sprites in the correct locations
            for currentRow = 1:t_width
                for currentCol = 1:t_height
                    spriteHeight = obj.g_spriteHeight;
                    spriteWidth = obj.g_spriteWidth;
                 
                    tileData = zeros(spriteHeight, spriteWidth, 3, 'uint8');
                 
                    if obj.g_useBackgroundColor
                        backgroundColor = obj.g_backgroundColor;
                        for rgb_idx = 1:3
                            tileData(:, :, rgb_idx) = backgroundColor(rgb_idx);
                        end
                    end
                 
                    if obj.g_useBackgroundSpriteId
                        backgroundSpriteId = obj.g_backgroundSpriteId;
                     
                        spriteSheet = obj.g_spriteSheet;
                     
                        backgroundSpriteData = getSpriteById(spriteSheet, backgroundSpriteId);
                        backgroundSprite = backgroundSpriteData.imageData;
                        backgroundSpriteTransparency = backgroundSpriteData.transparencyData;
                        if obj.g_useMasterTransparency
                            backgroundSpriteTransparency(:, :, :) = backgroundSpriteTransparency(:, :, :) .* (obj.g_masterTransparency / 255);
                        end
                     
                      
                        tileData = (double(backgroundSprite)) .* ((double(backgroundSpriteTransparency)) / 255) + ...
                        (double(tileData)) .* ((255 - (double(backgroundSpriteTransparency))) / 255);
                      
                    end
                 
                 
                    % If needed, layer on the second sprite
                    % TODO - ADD FOREGROUD SPRITE LAYER
                    % if nargin > 2
                    %    tileData = obj.sprites{fg_sprite_id} .* (obj.g_spriteSheetTransparency{fg_sprite_id}/255) + ...
                    %        tileData .* ((255-obj.g_spriteSheetTransparency{fg_sprite_id})/255);
                    % end
                 
                    yMin = spriteHeight * (currentRow - 1) + 1;
                    yMax = spriteHeight * (currentRow - 1) + spriteHeight;
                 
                    xMin = spriteWidth * (currentCol - 1) + 1;
                    xMax = spriteWidth * (currentCol - 1) + spriteWidth;
                 
                    % Write the tile to the scene_data array
                    canvasData(yMin:yMax, xMin:xMax, :) = tileData;
                end
            end
            layoutQueue = obj.g_layoutQueue;
            
            
            if (~ isempty(layoutQueue))
                for queueIndex = 1:length(layoutQueue)
                    currentLayout = layoutQueue{queueIndex};
                    
                    layoutData = currentLayout.layout;
                 
                    for dataIndex = 1:length(layoutData)
                    xCoord = currentLayout.xCoord;
                    yCoord = currentLayout.yCoord;
                        currentLayoutData = layoutData{dataIndex}.imageData;
                        currentLayoutTransparency = layoutData{dataIndex}.transparencyData;
                        
                        if obj.g_useMasterTransparency
                            currentLayoutTransparency(:, :, :) = currentLayoutTransparency(:, :, :) .* (obj.g_masterTransparency / 255);
                        end
                        
                        originalSize = size(currentLayoutData);
                        originalWidth = originalSize(1);

                        xRelCoord = layoutData{dataIndex}.xCoord;
                        yRelCoord = layoutData{dataIndex}.yCoord;
                        
                        yCoord = yCoord + yRelCoord;
                        xCoord = xCoord + xRelCoord;

                        if (yCoord + originalWidth <= canvasHeight) && (xCoord + originalWidth <= canvasWidth)
                            replaceData = canvasData(yCoord + 1:yCoord + originalWidth, xCoord + 1:xCoord + originalWidth, :);

                        replaceData = (double(currentLayoutData)) .* ((double(currentLayoutTransparency)) / 255) + ...
                        (double(replaceData)) .* ((255 - (double(currentLayoutTransparency))) / 255);

                            canvasData(yCoord + 1:yCoord + originalWidth, xCoord + 1:xCoord + originalWidth, :) = replaceData;
                        end
                    end
                end
            end
            
            spriteQueue = obj.g_spriteQueue;
            if (~ isempty(spriteQueue))
                for customSpriteIndex = 1:length(spriteQueue)
                    currentSpriteData = spriteQueue{customSpriteIndex};
                 
                    % width = currentSpriteData.width;
                    xCoord = currentSpriteData.xCoord;
                    yCoord = currentSpriteData.yCoord;
                 
                    sprite = currentSpriteData.imageData;
                 
                    spriteTransparency = currentSpriteData.transparencyData;
                    
                        if obj.g_useMasterTransparency
                            spriteTransparency(:, :, :) = spriteTransparency(:, :, :) .* (obj.g_masterTransparency / 255);
                        end
                    
                    
                    originalSize = size(currentSpriteData.imageData);
                    originalWidth = originalSize(1);
                 
                    % scale = (width / originalWidth);
                 
                    % spriteObject = imresize(spriteObject, scale, 'nearest');
                    % spriteTransparency = imresize(spriteTransparency, scale, 'nearest');
                 
                    % scaledSize = size(spriteObject);
                    % scaledWidth = scaledSize(1);
                 
                    if (yCoord + originalWidth <= canvasHeight) && (xCoord + originalWidth <= canvasWidth)
                        replaceData = canvasData(yCoord + 1:yCoord + originalWidth, xCoord + 1:xCoord + originalWidth, :);
                     

%                         
                        replaceData = (double(sprite)) .* ((double(spriteTransparency)) / 255) + ...
                        (double(replaceData)) .* ((255 - (double(spriteTransparency))) / 255);
                     
                        canvasData(yCoord + 1:yCoord + originalWidth, xCoord + 1:xCoord + originalWidth, :) = replaceData;
                    end
                end
            end
            
            
         
            % handle zooming
            big_scene_data = canvasData;
%          
%             if (obj.g_currentZoomFactor ~= obj.g_previousZoomFactor)
%                 big_scene_data = imresize(canvasData, obj.g_currentZoomFactor, 'nearest');
%                 obj.g_previousZoomFactor = obj.g_currentZoomFactor;
%             end
         
         
            % This part is a bit tricky, but avoids some latency, the idea
            % is that we only want to completely create a new figure if we
            % absolutely have to: the first time the figure is created,
            % when the old figure has been closed, or if the scene is
            % resized. Otherwise, we just update the image data in the
            % current image, which is much faster.
         
         
            if isempty(obj.my_figure) || ~ isvalid(obj.my_figure)
                % inititalize figure
                obj.my_figure = figure('Renderer', 'painters', 'CloseRequestFcn', @(src, evt) close_figure(obj, src, evt));
             
                set(obj.my_figure, 'MenuBar', 'none');
                set(obj.my_figure, 'ToolBar', 'none');
                set(obj.my_figure, 'WindowState', 'maximize');
                set(obj.my_figure, 'KeyPressFcn', @(src, evt) keypressCallback(obj, src, evt));
%                 set(obj.my_figure, 'visible', 'off');
             
             
                % actually display the image to the figure
                obj.my_image = imshow(big_scene_data, 'InitialMagnification', 'fit');
             
            elseif isempty(obj.my_image) || ~ isprop(obj.my_image, 'CData') || ~ isequal(size(big_scene_data), size(obj.my_image.CData))
                % Re-display the image if its size changed
                figure(obj.my_figure);
                uiwait(obj.my_figure);
                disp('figure closed')
                obj.my_image = imshow(big_scene_data, 'InitialMagnification', 'fit');
            else
                % otherwise just update the image data
                obj.my_image.CData = big_scene_data;
            end
        end
     
        %%
        function keypressCallback(obj, src, evt)
            if evt.Key == 'space'
                obj.s_waitToStart = false;
            end
        end
        
        %% Contract - removeSprite(obj, spriteId)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function removeSprite(obj, spriteId)
            spriteQueue = obj.g_spriteQueue;
            if ~ isempty(spriteQueue)
                removeIndex = 1;
                while removeIndex <= length(spriteQueue)
                    currentSprite = spriteQueue{removeIndex};
                 
                    if isempty(currentSprite)
                        removeIndex = removeIndex + 1;
                        continue;
                    end
                 
                    id = currentSprite.id;
                    if id == spriteId
                        spriteQueue{removeIndex} = [];
                    end
                    removeIndex = removeIndex + 1;
                end
            end
            obj.g_spriteQueue = spriteQueue(~ cellfun(@isempty, spriteQueue));
        end
     
        %% Contract - drawSprite(obj, spriteId, coords)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function drawSprite(obj, spriteId, coords)
            xCoord = coords(1);
            yCoord = coords(2);
            spriteQueue = obj.g_spriteQueue;
            nextIndex = length(spriteQueue) + 1;
         
            spriteSheet = obj.g_spriteSheet;
            nextSprite = getSpriteById(spriteSheet, spriteId);
            nextSprite.xCoord = xCoord;
            nextSprite.yCoord = yCoord;
         
            spriteQueue{nextIndex} = nextSprite;
         
            obj.g_spriteQueue = spriteQueue;
         
            drawCanvas(obj);
        end
        
        %% Contract - queueSprite(obj, spriteId, coords)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function queueSprite(obj, spriteId, coords)
            xCoord = coords(1);
            yCoord = coords(2);
            spriteQueue = obj.g_spriteQueue;
            nextIndex = length(spriteQueue) + 1;
         
            spriteSheet = obj.g_spriteSheet;
            nextSprite = getSpriteById(spriteSheet, spriteId);
            nextSprite.xCoord = xCoord;
            nextSprite.yCoord = yCoord;
         
            spriteQueue{nextIndex} = nextSprite;
         
            obj.g_spriteQueue = spriteQueue;
        end
        
        %% Contract - removeLayout(obj, layoutId)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function removeLayout(obj, layoutId)
            layoutQueue = obj.g_layoutQueue;
            if ~ isempty(layoutQueue)
                removeIndex = 1;
                while removeIndex <= length(layoutQueue)
                    currentLayout = layoutQueue{removeIndex};
                 
                    if isempty(currentLayout)
                        removeIndex = removeIndex + 1;
                        continue;
                    end
                 
                    id = currentLayout.id;
                    if id == layoutId
                        layoutQueue{removeIndex} = [];
                        break;
                    end
                    removeIndex = removeIndex + 1;
                end
            end
            obj.g_layoutQueue = layoutQueue(~ cellfun(@isempty, layoutQueue));
        end
     
        %% Contract - drawLayout(obj, layout, coords, id)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function drawLayout(obj, layout, coords, id)
            xCoord = coords(1);
            yCoord = coords(2);
            layoutQueue = obj.g_layoutQueue;
            nextIndex = length(layoutQueue) + 1;
         
            spriteSheet = obj.g_spriteSheet;
            
            layoutData = layout.c_layoutData;
            
            
            currentLayout = cell(length(layoutData), 1);
            
            for dataIndex = 1:length(layoutData)
                currentLayoutData = layoutData{dataIndex};
                
                nextSprite = getSpriteById(spriteSheet, currentLayoutData.id);
                
                nextSprite.xCoord = currentLayoutData.xCoord;
                nextSprite.yCoord = currentLayoutData.yCoord;
                
                currentLayout{dataIndex} = nextSprite;
            end
            
            layoutQueue{nextIndex}.layout = currentLayout;
            
                layoutQueue{nextIndex}.xCoord = xCoord;
                layoutQueue{nextIndex}.yCoord = yCoord;
                layoutQueue{nextIndex}.id = id;
         
            obj.g_layoutQueue = layoutQueue;
         
            drawCanvas(obj);
        end
        
        %% Contract - queueLayout(obj, layout, coords, id)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function queueLayout(obj, layout, coords, id)
            xCoord = coords(1);
            yCoord = coords(2);
            layoutQueue = obj.g_layoutQueue;
            nextIndex = length(layoutQueue) + 1;
         
            spriteSheet = obj.g_spriteSheet;
            
            layoutData = layout.c_layoutData;
            
            
            currentLayout = cell(length(layoutData), 1);
            
            for dataIndex = 1:length(layoutData)
                currentLayoutData = layoutData{dataIndex};
                
                nextSprite = getSpriteById(spriteSheet, currentLayoutData.id);
                
                nextSprite.xCoord = currentLayoutData.xCoord;
                nextSprite.yCoord = currentLayoutData.yCoord;
                
                currentLayout{dataIndex} = nextSprite;
            end
            
            layoutQueue{nextIndex}.layout = currentLayout;
            
                layoutQueue{nextIndex}.xCoord = xCoord;
                layoutQueue{nextIndex}.yCoord = yCoord;
                layoutQueue{nextIndex}.id = id;
         
            obj.g_layoutQueue = layoutQueue;
        end
        
        %% Contract - close_figure(obj, src, evt)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function close_figure(obj, src, evt)
            clear sound;
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
        % @updates obj.sounds 
        % @requires obj, filePath, & soundId

        function loadSoundFile(obj, filePath, soundId)
           [soundData, bitRate] = audioread(filePath);
           
           soundObject.soundData = soundData;
           soundObject.bitRate = bitRate;
           soundObject.soundId = soundId;
           
           obj.sounds{end+1} = soundObject;
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
        % @requires obj & filePath
        
        function playSound(obj, soundId, volume)
            
            argumentCount = nargin;
         
            if argumentCount == 2
                volume = 100 / 100;
            else
                volume = volume / 100;
            end
            
            soundList = obj.sounds;
            
            for index = 1:length(soundList)
               currentSound = soundList{index};
               currentSoundId = currentSound.soundId;
               
               if currentSoundId == soundId
               currentSoundData = currentSound.soundData;
               currentSoundBitrate = currentSound.bitRate;
                    sound(currentSoundData * volume, currentSoundBitrate, 16); 
               end
            end
            
        end
        
        %% Contract - showFigure(obj)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function showFigure(obj)
            set(obj.my_figure, 'visible', 'on');
        end
     
        %% Contract - setCanvasSize(obj, canvasSize)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function setCanvasSize(obj, canvasSize)
            obj.g_canvasSize = canvasSize;
        end
        %% Contract - setBackgroundColor(obj, backgroundColor)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function setBackgroundColor(obj, backgroundColor)
            obj.g_backgroundColor = backgroundColor;
        end
        
        %% Contract - getBackgroundColor(obj)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function backgroundColor = getBackgroundColor(obj)
            backgroundColor = obj.g_backgroundColor;
        end
     
        %% Contract - setUseBackgroundColor(obj, useBackgroundColor)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function setUseBackgroundColor(obj, useBackgroundColor)
            obj.g_useBackgroundColor = useBackgroundColor;
        end
        
        %% Contract - getUseBackgroundColor(obj)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function useBackgroundColor = getUseBackgroundColor(obj)
            useBackgroundColor = obj.g_useBackgroundColor;
        end
     
        %% Contract - setBackgroundSpriteId(obj, backgroundSpriteId)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function setBackgroundSpriteId(obj, backgroundSpriteId)
            obj.g_backgroundSpriteId = backgroundSpriteId;
        end
        
        %% Contract - getBackgroundSpriteId(obj)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function backgroundSpriteId = getBackgroundSpriteId(obj)
            backgroundSpriteId = obj.g_backgroundSpriteId;
        end
     
        %% Contract - setUseBackgroundSpriteId(obj, useBackgroundSpriteId)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function setUseBackgroundSpriteId(obj, useBackgroundSpriteId)
            obj.g_useBackgroundSpriteId = useBackgroundSpriteId;
        end
        
        %% Contract - useBackgroundSpriteId = getUseBackgroundSpriteId(obj)
        % [Insert function description]
        % 
        % @param [param name]
        %   [param description]
        %
        % @updates [updated variables]
        % @requires [required variables]
        
        function useBackgroundSpriteId = getUseBackgroundSpriteId(obj)
            useBackgroundSpriteId = obj.g_useBackgroundSpriteId;
        end
    end
end
