% HOW WE PULL IT ALL TOGETHER. RENDERING ENGINE SEPARATE? MAYBE MAYBE

classdef GameEngine < handle
    properties
        g_spriteSheet = {}; % color data of the sprites
        g_spriteWidth = 0;
        g_spriteHeight = 0;
        
        g_canvasSize = [];
        
        g_spriteQueue = {};
        
        g_backgroundColor = [0, 0, 0];
        g_useBackgroundColor = true;
        
        g_backgroundSpriteId = -1;
        g_useBackgroundSpriteId = false;
        
        g_previousZoomFactor = 1;
        g_currentZoomFactor = 1;
        
        my_figure; % figure identifier
        my_image;  % image data
    end
    
    methods
        function obj = GameEngine(spriteSheet, spriteHeight, spriteWidth, zoomFactor)
            
            %Initialize variables
            
            obj.g_spriteWidth = spriteWidth;
            obj.g_spriteHeight = spriteHeight;
            
            argumentCount = nargin;
            
            if argumentCount > 3
                obj.g_currentZoomFactor = zoomFactor;
                obj.g_previousZoomFactor = zoomFactor;
            end
            obj.g_spriteSheet = spriteSheet;
        end
        
        function fadeOut(obj)
            
        end
        
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
                            tileData(:,:,rgb_idx) = backgroundColor(rgb_idx);
                        end
                    end
                    
                    if obj.g_useBackgroundSpriteId
                        backgroundSpriteId = obj.g_backgroundSpriteId;
                        
                        spriteSheet = obj.g_spriteSheet;
                        
                        backgroundSpriteData = getSpriteById(spriteSheet, backgroundSpriteId);
                        backgroundSprite = backgroundSpriteData.imageData;
                        backgroundSpriteTransparency = backgroundSpriteData.transparencyData;
                        
                        tileData = backgroundSprite .* (backgroundSpriteTransparency / 255) + ...
                        tileData .* ((255 - backgroundSpriteTransparency) / 255);
                    end
                    
                    
                    % If needed, layer on the second sprite
                    % TODO - ADD FOREGROUD SPRITE LAYER
                    %if nargin > 2
                    %    tileData = obj.sprites{fg_sprite_id} .* (obj.g_spriteSheetTransparency{fg_sprite_id}/255) + ...
                    %        tileData .* ((255-obj.g_spriteSheetTransparency{fg_sprite_id})/255);
                    %end
                    
                    yMin = spriteHeight * (currentRow - 1) + 1;
                    yMax = spriteHeight * (currentRow - 1) + spriteHeight;
                    
                    xMin = spriteWidth * (currentCol - 1) + 1;
                    xMax = spriteWidth * (currentCol - 1) + spriteWidth;
                    
                    % Write the tile to the scene_data array
                    canvasData(yMin:yMax,xMin:xMax,:) = tileData;
                end
            end
            spriteQueue = obj.g_spriteQueue;
            if (~isempty(spriteQueue))
                for customSpriteIndex = 1:length(spriteQueue)
                    currentSpriteData = spriteQueue{customSpriteIndex};
                    
                    %width = currentSpriteData.width;
                    xCoord = currentSpriteData.xCoord;
                    yCoord = currentSpriteData.yCoord;
                    
                    sprite = currentSpriteData.imageData;
                    
                    spriteTransparency = currentSpriteData.transparencyData;

                        originalSize = size(currentSpriteData.imageData);
                        originalWidth = originalSize(1);

                        %scale = (width / originalWidth);

                        %spriteObject = imresize(spriteObject, scale, 'nearest');
                        %spriteTransparency = imresize(spriteTransparency, scale, 'nearest');

                        %scaledSize = size(spriteObject);
                        %scaledWidth = scaledSize(1);
                        
                            replaceData = canvasData(yCoord+1:yCoord+originalWidth, xCoord+1:xCoord+originalWidth,:);
                            
                        replaceData = sprite .* (spriteTransparency/255) + ...
                                replaceData .* ((255-spriteTransparency)/255);

                        canvasData(yCoord+1:yCoord+originalWidth, xCoord+1:xCoord+originalWidth,:) = replaceData;

                end
            end
            
            % handle zooming
            big_scene_data = canvasData;
            
            %if (obj.g_currentZoomFactor ~= obj.g_previousZoomFactor)
                big_scene_data = imresize(canvasData,obj.g_currentZoomFactor,'nearest');
                obj.g_previousZoomFactor = obj.g_currentZoomFactor;
            %end
            
            
            % This part is a bit tricky, but avoids some latency, the idea
            % is that we only want to completely create a new figure if we
            % absolutely have to: the first time the figure is created,
            % when the old figure has been closed, or if the scene is
            % resized. Otherwise, we just update the image data in the
            % current image, which is much faster.
            
            
            if isempty(obj.my_figure) || ~isvalid(obj.my_figure)
                % inititalize figure
                obj.my_figure = figure();
                
                set(obj.my_figure, 'MenuBar', 'none');
                set(obj.my_figure, 'ToolBar', 'none');
                set(obj.my_figure, 'visible','off');
                
                % set guidata to the  key press and release functions,
                % this allows keeping track of what key has been pressed
                obj.my_figure.KeyPressFcn = @(src,event)guidata(src,event.Key);
                obj.my_figure.KeyReleaseFcn = @(src,event)guidata(src,0);
                
                % actually display the image to the figure
                obj.my_image = imshow(big_scene_data,'InitialMagnification', 100);
                
            elseif isempty(obj.my_image)  || ~isprop(obj.my_image, 'CData') || ~isequal(size(big_scene_data), size(obj.my_image.CData))
                % Re-display the image if its size changed
                figure(obj.my_figure);
                obj.my_image = imshow(big_scene_data,'InitialMagnification', 100);
            else
                % otherwise just update the image data
                obj.my_image.CData = big_scene_data;
            end
        end
        
        function removeSprite(obj, spriteId)
            spriteQueue = obj.g_spriteQueue;
            if ~isempty(spriteQueue)
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
                        break;
                    end
                    removeIndex = removeIndex + 1;
                end
            end
            obj.g_spriteQueue = spriteQueue(~cellfun(@isempty, spriteQueue));
        end
        
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
        
        function showFigure(obj)
           set(obj.my_figure, 'visible','on'); 
        end
        
        function setBackgroundColor(obj, backgroundColor)
            obj.g_backgroundColor = backgroundColor;
        end
        function backgroundColor = getBackgroundColor(obj)
            backgroundColor = obj.g_backgroundColor;
        end
        
        function setUseBackgroundColor(obj, useBackgroundColor)
            obj.g_useBackgroundColor = useBackgroundColor;
        end
        function useBackgroundColor = getUseBackgroundColor(obj)
            useBackgroundColor = obj.g_useBackgroundColor;
        end
        
        function setBackgroundSpriteId(obj, backgroundSpriteId)
            obj.g_backgroundSpriteId = backgroundSpriteId;
        end
        function backgroundSpriteId = getBackgroundSpriteId(obj)
            backgroundSpriteId = obj.g_backgroundSpriteId;
        end
        
        function setUseBackgroundSpriteId(obj, useBackgroundSpriteId)
            obj.g_useBackgroundSpriteId = useBackgroundSpriteId;
        end
        function useBackgroundSpriteId = getUseBackgroundSpriteId(obj)
            useBackgroundSpriteId = obj.g_useBackgroundSpriteId;
        end
        
        function key = getKeyboardInput(obj)
            % getKeyboardInput
            % Input: an SGE scene, which gains focus
            % Output: next key pressed while scene has focus
            % Note: the operation of the program pauses while it waits for input
            % Example:
            %     	k = getKeyboardInput(my_scene);

            
            % Bring this scene to focus
            figure(obj.my_figure);
            
            % Pause the program until the user hits a key on the keyboard,
            % then return the key pressed. The loop is required so that
            % we don't exit on a mouse click instead.
            keydown = 0;
            while ~keydown
                keydown = waitforbuttonpress;
            end
            key = get(obj.my_figure,'CurrentKey');
        end
        
        function [row,col,button] = getMouseInput(obj)
            % getMouseInput
            % Input: an SGE scene, which gains focus
            % Output:
            %  1. The row of the tile clicked by the user
            %  2. The column of the tile clicked by the user
            %  3. (Optional) the button of the mouse used to click (1,2, or 3 for left, middle, and right, respectively)
            % 
            % Notes: A set of “crosshairs” appear in the scene’s figure,
            % and the program will pause until the user clicks on the
            % figure. It is possible to click outside the area of the
            % scene, in which case, the closest row and/or column is
            % returned.
            % 
            % Example:
            %     	[row,col,button] = getMouseInput (my_scene);
            
            % Bring this scene to focus
            figure(obj.my_figure);
            
            % Get the user mouse input
            [X,Y,button] = ginput(1);
            
            % Convert this into the tile row/column
            row = ceil(Y/obj.sprite_height/obj.zoom);
            col = ceil(X/obj.sprite_width/obj.zoom);
            
            % Calculate the maximum possible row and column from the
            % dimensions of the current scene
            sceneSize = size(obj.my_image.CData);
            max_row = sceneSize(1)/obj.sprite_height/obj.zoom;
            max_col = sceneSize(2)/obj.sprite_width/obj.zoom;
            
            % If the user clicked outside the scene, return instead the
            % closest row and/or column
            if row < 1
                row = 1;
            elseif row > max_row
                row = max_row;
            end
            if col < 1
                col = 1;
            elseif col > max_col
                col = max_col;
            end
        end
    end
end