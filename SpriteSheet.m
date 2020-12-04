%% SpriteSheet class

% This handles the loading of sprites and their relative indexing by ids.

classdef SpriteSheet < handle
    
    % Class properties of the SpriteSheet
    properties
        % Map of all of the sprites keyed to their ids
        c_spriteMap = containers.Map();
        
        % The size of every sprite
        c_spriteSize = [0, 0];
    end
    
    methods
        %% Contract - SpriteSheet(p_filename, p_spriteSize, p_spriteIds)
        % This is the contructor for the SpriteSheet class. It defines the
        % class properties based on the input parameters.
        % 
        % @param p_filename
        %   The input filename of the spritesheet image
        % @param p_spriteSize
        %   The size of each sprite
        % @param p_spriteIds
        %   An array of ids for each sprite
        %
        % @updates <class properties>
        % @requires param(s) ~= NULL
        
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
                    
                    % Insert current data into a map 
                    spriteStruct.imageData = currentImageData;
                    spriteStruct.transparencyData = currentTransparencyData;
                    
                    obj.c_spriteMap(currentSpriteId) = spriteStruct;
                    
                end
            end
        end
        function spriteSheet = getSpriteSheet(obj)
            spriteSheet = obj.c_spriteMap;
        end
    end
end