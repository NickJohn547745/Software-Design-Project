% HOW WE REFERENCE SPRITES FROM MULTIPLE SHEETS

classdef SpriteContainer < handle
    properties
        c_sprites = {};
    end
    
    methods
        function obj = SpriteContainer(obj, spriteSheet)
            
            spriteSheetData = getSpriteSheet(spriteSheet);
            obj.c_sprites = {obj.c_sprites, spriteSheetData};
            
        end
        function spriteSheet = getSpriteSheet(obj)
            spriteSheet = obj.c_spriteData;
        end
        function sprite = getSpriteById(obj, spriteId)
            sprite = -1;
            for index = 1:length(obj.c_spriteData)
                currentSprite = obj.c_spriteData(index);
                if currentSprite.id == spriteId
                    sprite = currentSprite;
                end
            end
        end
    end
end