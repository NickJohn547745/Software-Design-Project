% HOW WE STORE SPRITES AND DATA FROM INDIVIDUAL FILES

classdef SpriteSheet < handle
    properties
        c_spriteData = {}; % color data of the sprites
        c_spriteSize = [0, 0];
    end
    
    methods
        function obj = SpriteSheet(p_filename, p_spriteSize, p_spriteIds)
            
            % Get the number of arguments passed to the constructor.
            argumentCount = nargin;
            
            if argumentCount < 3
                % Assert error if no parameter for sprite ids is provided
                error("Error: No sprite id array provided. Failing initialization of SpriteSheet.");
            elseif argumentCount < 2
                % Assert error if no parameter for sprite size is provided
                error("Error: No sprite size provided. Failing initialization of SpriteSheet.");
            end
            
            % Set the class variable of sprite size to the parameter variable
            % spriteSize = p_spriteSize;
            
            % Derive height and width from provided sprite size
            spriteHeight = p_spriteSize(1);
            spriteWidth = p_spriteSize(2);
            
            % Read the raw image data and raw transparency
            [rawImage, ~, rawTransparency] = imread(p_filename);
            
            % Calculate how many sprites are in the given raw image data.
            
            % Get the size, height, & width of the raw image
            rawImageSize = size(rawImage);
            rawImageHeight = rawImageSize(1);
            rawImageWidth = rawImageSize(2);
            
            % Declare the amount of rows and columns in the spritesheet
            spriteSheetRowCount = (rawImageHeight + 1) / (spriteHeight + 1);
            spriteSheetColCount = (rawImageWidth  + 1) / (spriteWidth  + 1);
            
            % Createa transparency layer if none exists
            
            % Check if transparency layer exists
            if isempty(rawTransparency)
                % If not, create one of full transparency
                rawTransparency = 255 * ones(spriteSheetSize,'uint8');
            else
                % If one exists, disperse the layer across 3 channels (R, G, B)
                rawTransparency = repmat(rawTransparency, 1, 1, 3);
            end
            
            % loop over the image and load the individual sprite data into
            % the object
            
            % Loop through the image and store the corresponding data in an
            % organized format
            for currentRow = 1:spriteSheetRowCount
                for currentCol = 1:spriteSheetColCount
                    % Calculate minimum bounds of the current sprite
                    yMin = spriteHeight * (currentRow - 1) + currentRow;
                    xMin = spriteWidth  * (currentCol - 1) + currentCol;
                    
                    % Calculate maximum bounds of the current sprite
                    yMax = spriteHeight * currentRow + currentRow - 1;
                    xMax = spriteWidth  * currentCol + currentCol - 1;
                    
                    % Get the current sprite's id from p_spriteIds
                    currentSpriteId = p_spriteIds(currentRow, currentCol);
                    
                    % Get the current sprite's image data 
                    currentImageData = rawImage(yMin:yMax, xMin:xMax, :);
                    
                    % Get the current sprite's transparency data 
                    currentTransparencyData = rawTransparency(yMin:yMax, xMin:xMax, :);
                    
                    % Insert current data into a struct 
                    currentSpriteData.id = currentSpriteId;
                    currentSpriteData.imageData = currentImageData;
                    currentSpriteData.transparencyData = currentTransparencyData;
                    
                    % Add current sprite struct to an array of all sprites
                    obj.c_spriteData{end+1} = currentSpriteData;
                end
            end
        end
        function spriteSheet = getSpriteSheet(obj)
            spriteSheet = obj.c_spriteData;
        end
        function sprite = getSpriteById(obj, spriteId)
            sprite = -1;
            for index = 1:length(obj.c_spriteData)
                currentSprite = obj.c_spriteData{index};
                if currentSprite.id == spriteId
                    sprite = currentSprite;
                    break;
                end
            end
        end
        function addSpriteSheet(obj, spriteSheet)
            spriteSheetData = getSpriteSheet(spriteSheet);
            for index = 1:length(spriteSheetData)
                obj.c_spriteData{end+1} = spriteSheetData{index};
            end
        end
    end
end