function _init()
    local var screenWidth = 128
    local var screenHeight = 128
    player = {}
    player.new = function ()
        local self = {
            x = 0,
            y = 0,
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
            spr(self.classes.wizard.spriteLeft, self.x, self.y)
            self.spriteLeft = self.classes[className].spriteLeft
            self.spriteRight = self.classes[className].spriteRight
        end

        function self.draw() 
           spr(self.classes.wizard.spriteLeft, self.x, self.y)
        end

        function self.move()
            if btn(0) then
                player.x -= 1
            elseif btn(1) then
                player.x += 1
            elseif btn(2) then
                player.y -= 1
            elseif btn(3) then
                player.y += 1
            end
        end

        return self
    end

    player = player.new()
end

function _update60()
    player.move()
end

function _draw()
    cls()
    player.selectClass("wizard")
    player.draw()
end