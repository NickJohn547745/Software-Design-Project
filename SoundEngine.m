% HOW WE INTEGRATE SOUND INTO THE ENGINE

classdef SoundEngine < handle
    properties
        c_sounds = {};
    end
    
    methods
        function obj = SoundEngine(spriteFile, spriteHeight, spriteWidth, zoomFactor, backgroundColor)
            % simpleGameEngine
            % Input: 
            %  1. File name of sprite sheet as a character array
            %  2. Height of the sprites in pixels
            %  3. Width of the sprites in pixels
            %  4. (Optional) Zoom factor to multiply image by in final figure (Default: 1)
            %  5. (Optional) Background color in RGB format as a 3 element vector (Default: [0,0,0] i.e. black)
            % Output: an SGE scene variable
            % Note: In RGB format, colors are specified as a mixture of red, green, and blue on a scale of 0 to 255. [0,0,0] is black, [255,255,255] is white, [255,0,0] is red, etc.
            % Example:
            %     	my_scene = simpleGameEngine('tictactoe.png',16,16,5,[0,150,0]);
            
            % load the input data into the object
            obj.g_spriteWidth = spriteWidth;
            obj.g_spriteHeight = spriteHeight;
            
            argumentCount = nargin;
            
            if argumentCount > 4
                obj.g_backgroundColor = backgroundColor;
            end
            
            if argumentCount > 3
                obj.g_currentZoomFactor = zoomFactor;
            end
            
            % read the sprites image data and transparency
            [spriteSheet, ~, spriteTransparency] = imread(spriteFile);
            
            % determine how many sprites there are based on the sprite size
            % and image size
            spriteSheetSize = size(spriteSheet);
            spriteSheetMaxRow = (spriteSheetSize(1)+1)/(spriteHeight+1);
            spriteSheetMaxCol = (spriteSheetSize(2)+1)/(spriteWidth+1);
            
            % Make a transparency layer if there is none (this happens when
            % there are no transparent pixels in the file).
            if isempty(spriteTransparency)
                spriteTransparency = 255*ones(spriteSheetSize,'uint8');
            else
                % If there is a transparency layer, use repmat() to
                % replicate is to all three color channels
                spriteTransparency = repmat(spriteTransparency,1,1,3);
            end
            
            % loop over the image and load the individual sprite data into
            % the object
            for currentRow = 1:spriteSheetMaxRow
                for currentCol = 1:spriteSheetMaxCol
                    yMin = spriteHeight*(currentRow-1)+currentRow;
                    yMax = spriteHeight*currentRow+currentRow-1;
                    xMin = spriteWidth*(currentCol-1)+currentCol;
                    xMax = spriteWidth*currentCol+currentCol-1;
                    obj.g_spriteSheet{end+1} = spriteSheet(yMin:yMax,xMin:xMax,:);
                    obj.g_spriteSheetTransparency{end+1} = spriteTransparency(yMin:yMax,xMin:xMax,:);
                end
            end
        end
        
        
    end
end