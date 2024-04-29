function _init()
    local var screenWidth = 128
    local var screenHeight = 128
    player = {}
    player.new = function ()
        local self = {
            currentSprite = 0,
            spriteLeft = 0,
            spriteRight = 0,
            classes = {
                ['wizard'] = {
                    spriteLeft = 0,
                    spriteRight = 1
                }
            }
        }

        function self.selectClass(className)
            spr(self.classes.wizard.spriteLeft, 2, 3)
            self.spriteLeft = self.classes[className].spriteLeft
            self.spriteRight = self.classes[className].spriteRight
        end

        function self.draw() 
           spr(self.classes.wizard.spriteLeft, 2, 3)
        end

        return self
    end

    player = player.new()
end

function _update60()
end

function _draw()
    cls()
    player.selectClass("wizard")
    player.draw()
end