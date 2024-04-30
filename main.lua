function _init()
    local var screenWidth = 128
    local var screenHeight = 128
    local var offScreen = -8

    enemies = {}
    enemies.new = function (player)
        local self = {
            dt = 4,
        }

        function self.draw()
            for en in all(enemies) do
                spr(en.sprite, en.x, en.y)
            end
        end

        function self.update()
            self.dt = self.dt - 1
            for en in all(enemies) do
                if self.dt <= 0 then
                    if player.x > en.x then
                        en.x += 1
                    elseif player.x < en.x then
                        en.x -= 1
                    end
                    if player.y > en.y then
                        en.y += 1
                    elseif player.y < en.y then
                        en.y -= 1
                    end
                    self.dt = 4
                end
            end
        end

        return self
    end

    projectiles = {}
    projectiles.new = function()
        local self = {}

        function self.draw()
            for proj in all(projectiles) do
                spr(proj.sprite, proj.x, proj.y)
            end
        end

        function self.update()
            for proj in all(projectiles) do
                if proj.dir == 'left' then
                    proj.x -= proj.speed
                end
                if proj.dir == 'right' then
                    proj.x += proj.speed
                end
                delete(proj)
            end
        end

        function delete(proj)
            if proj.x > screenWidth then
                del(projectiles, proj)
            end
            if proj.x < offScreen then
                del(projectiles, proj)
            end
            if proj.y > screenHeight then
                del(projectiles, proj)
            end
            if proj.y < offScreen then
                del(projectiles, proj)
            end
        end

        return self
    end

    player = {}
    player.new = function ()
        local self = {
            x = 64,
            y = 64,
            facing = 'right',
            currentSprite = 0,
            spriteLeft = 0,
            spriteRight = 0,
            classes = {
                ['wizard'] = {
                    spriteLeft = 1,
                    spriteRight = 0
                }
            },
            attacks = {
                ['fireball'] = {
                    sprite = 2,
                    power = 1,
                }
            }
        }

        function self.attack()
            if self.facing == 'left' and btnp(5) then
                add(projectiles, {
                    x = self.x - 8,
                    y = self.y,
                    speed = 1,
                    dir = 'left',
                    sprite = self.attacks.fireball.sprite
                })
            end
            if self.facing == 'right' and btnp(5) then
                add(projectiles, {
                    x = self.x + 8,
                    y = self.y,
                    speed = 1,
                    dir = 'right',
                    sprite = self.attacks.fireball.sprite
                })
            end
        end
    
        function self.selectClass(className)
            self.spriteLeft = self.classes[className].spriteLeft
            self.spriteRight = self.classes[className].spriteRight
        end

        function self.draw()
            spr(self.currentSprite, self.x, self.y)
        end

        function self.move()
            if btn(0) and player.x > 0 then
                player.x -= 1
                self.currentSprite = self.spriteLeft
                self.facing = 'left'
            elseif btn(1) and player.x < screenWidth - 8 then
                player.x += 1
                self.currentSprite = self.spriteRight
                self.facing = 'right'
            elseif btn(2) and player.y > 0 then
                player.y -= 1
            elseif btn(3) and player.y < screenHeight - 8 then
                player.y += 1
            end
        end

        return self
    end

    player = player.new()
    projectiles = projectiles.new()
end

function _update60()
    player.move()
    projectiles.update()
end

function _draw()
    cls(1)
    player.selectClass("wizard")
    player.draw()
    player.attack()
    projectiles.draw()
end