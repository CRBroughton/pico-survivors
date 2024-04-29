function _init()
    local var screenWidth = 128
    local var screenHeight = 128
    player = {}
    player.new = function ()
        local self = {}

        function self.draw() 
           spr(0, 2, 3)
        end

        return self
    end

    test = player.new()
end

function _update60()
end

function _draw()
    cls()
    rectfill(0, 0, 128, 128, 15)
    test.draw()
end