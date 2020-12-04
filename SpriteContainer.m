%% SpriteContainer class

% This handles combining and referencing sprites from multiple
% spritesheets

classdef SpriteContainer < handle
    
    % Class properties of the SpriteContainer
    properties
        % Map of the contained sprites
        c_spriteMap = {};
    end
    
    methods
        %% Contract - SpriteContainer(spriteSheet)
        % This is the contructor for the SpriteContainer class. It defines the
        % class properties based on the input parameters.
        % 
        % @param spriteSheet
        %   The spritesheet to contain
        %
        % @updates <class properties>
        % @requires param(s) ~= NULL
        
        function obj = SpriteContainer(spriteSheet)
            % Get the sprite map from the given sprite sheet
            spriteMap = getSpriteSheet(spriteSheet);
            
            % Add this map to the class's sprite map property
            obj.c_spriteMap = spriteMap;
            
        end
        %% Contract - getSpriteSheet(obj)
        % This is the contructor for the SpriteLayout class. It defines the
        % class properties based on the input parameters.
        % 
        % @param obj
        %   The SpriteContiner object
        %
        % @requires param(s) ~= NULL
        
        function spriteSheet = getSpriteSheet(obj)
            % Return the sprite map
            spriteSheet = obj.c_spriteMap;
        end
        %% Contract - getSpriteById(obj, spriteId)
        % This is the contructor for the SpriteLayout class. It defines the
        % class properties based on the input parameters.
        % 
        % @param obj
        %   The SpriteContiner object
        % @param spriteId
        %   The unique id of the desired sprite
        %
        % @requires param(s) ~= NULL
        
        function sprite = getSpriteById(obj, spriteId)
            % Return the desired sprite from the given id
            sprite = obj.c_spriteMap(spriteId);
        end
        %% Contract - addSpriteSheet(obj, spriteSheet)
        % This is the contructor for the SpriteLayout class. It defines the
        % class properties based on the input parameters.
        % 
        % @param obj
        %   The SpriteContiner object
        % @param spriteSheet
        %   The spritesheet to append to the class's sprite map property
        %
        % @updates <class properties>
        % @requires param(s) ~= NULL
        
        function addSpriteSheet(obj, spriteSheet)
            % Get the sprite map from the given sprite sheet
            spriteSheetMap = getSpriteSheet(spriteSheet);
            
            % Add the given spritesheet's map to the class's sprite map
            % property
            obj.c_spriteMap = [obj.c_spriteMap; spriteSheetMap];
        end
    end
end

% Check if the sprite queue is populated