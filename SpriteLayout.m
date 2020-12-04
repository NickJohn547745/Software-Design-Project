%% SpriteLayout class

% This handles the loading of sprite sheets and relative coordinates per
% sprite to draw large ensembles of sprites in a more oganized and
% convenient method.

classdef SpriteLayout < handle
    
    % Class properties of the SpriteLayout
    properties
        % Cell array of each sprite and their coordinates
        c_spriteLayout = {};
        
        % Unique id of the layout
        c_id = "";
        
        % Absolute position of the ensemble
        c_xCoord = 0;
        c_yCoord = 0;
    end
    
    methods
        %% Contract - SpriteLayout(p_filename, p_layoutId, p_spriteSheet)
        % This is the contructor for the SpriteLayout class. It defines the
        % class properties based on the input parameters.
        % 
        % @param p_filename
        %   The input filename of the sprite layout data
        % @param p_layoutId
        %   The unique id of the layout
        % @param p_spriteSheet
        %   The spritesheet to reference for sprites
        %
        % @updates <class properties>
        % @requires param(s) ~= NULL
        
        function obj = SpriteLayout(p_filename, p_layoutId, p_spriteSheet)
            % Store the given layout id as a class property
            obj.c_id = p_layoutId;
            
            % Read the input file as a table
            data = tdfread(p_filename, 'bar');
            
            % Extract the columsn of data
            spriteIds = data.ids;
            yCoords = data.y;
            xCoords = data.x;
            
            % Get the size height of the table (minus headers)
            idSize = size(spriteIds);
            
            % Iterate through every row of the table
            for index = 1:idSize(1)
                % Get the id of the desired sprite
                currentImageId = strtrim(spriteIds(index, :));
                
                % Fetch the sprite based on the given id. Append this value
                % onto a structure
                layoutSprite.sprite = p_spriteSheet.getSpriteById(currentImageId);
                
                % Add the relative coordinates to the structure
                layoutSprite.yCoord = yCoords(index);
                layoutSprite.xCoord = xCoords(index);
                
                % Add this structure to the sprite layout property.
                obj.c_spriteLayout{end + 1} = layoutSprite;
            end
        end
    end
end