function _init()
    local var screenWidth = 128
    local var screenHeight = 128
    local var offScreen = -8

    enemies = {}
    enemies.new = function (player, projectiles)
        local self = {
            dt = 4,
            lastEnemy = 0,
            -- ['waves'] = {
            --     [1] = {
            --         sprite = 3,
            --     }
            -- }
        }

        function createEnemyCoords()
            local padding = 12
            local side = rnd(4)
            local x, y
        
            if side < 1 then
                -- Above
                x = flr(rnd(128))
                y = -padding
            elseif side < 2 then
                --  Below
                x = flr(rnd(128))
                y = 128 + padding
            elseif side < 3 then
                -- Left
                x = -padding
                y = flr(rnd(128))
            else
                -- Right
                x = 128 + padding
                y = flr(rnd(128))
            end
            return x, y
        end
        

        function self.createWave(waveNumber)
            local id = 0
            for i = 1, 10 do
                local x, y = createEnemyCoords()
                add(enemies, {
                    x = x,
                    y = y,
                    sprite = 3,
                    id = 0,
                })
            end
        end

        function self.draw()
            for en in all(enemies) do
                spr(en.sprite, en.x, en.y)
            end
        end

        function self.update()
            self.dt = self.dt - 1
            for i, en in ipairs(enemies) do
                for _, proj in ipairs(projectiles) do
                    if isDead(en.x, en.y, 8, 8, proj.x, proj.y, 8, 8) then
                        del(enemies, en)
                        del(projectiles, proj)
                        break
                    end
                end

                if self.dt <= 0 then
                    local moveX, moveY = 0, 0
                    if player.x - 8 > en.x then
                        moveX = 1
                    elseif player.x + 8 < en.x then
                        moveX = -1
                    end
                    if player.y - 8 > en.y then
                        moveY = 1
                    elseif player.y + 8 < en.y then
                        moveY = -1
                    end

                    -- Check for collision with other enemies
                    local newX, newY = en.x + moveX, en.y + moveY
                    local collision = false
                    for j, otherEn in ipairs(enemies) do
                        if j ~= i then -- Skip self
                            local distance = sqrt((newX - otherEn.x)^2 + (newY - otherEn.y)^2)
                            if distance < 8 then
                                collision = true
                                break
                            end
                        end
                    end

                    if not collision then
                        en.x = en.x + moveX
                        en.y = en.y + moveY
                    end

                    -- Reset dt when processing the last enemy
                    if i == #enemies then
                        self.dt = 4
                    end
                end
            end
        end


        function isDead(x1, y1, w1, h1, x2, y2, w2, h2)
            local hit = false
        
            local xs = w1 * 0.5 + w2 * 0.5
            local ys = h1 * 0.5 + h2 * 0.5
        
            local xd = abs((x1 + (w1 / 2)) - (x2 +(w2 / 2)))
            local yd = abs((y1 + (h1 / 2)) - (y2 +(h2 / 2)))
        
            if xd < xs and yd < ys then
                hit = true
            end
            return hit
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
    enemies = enemies.new(player, projectiles)

    enemies.createWave()
end

function _update60()
    player.move()
    projectiles.update()
    enemies.update()
end

function _draw()
    cls(1)
    player.selectClass("wizard")
    player.draw()
    player.attack()
    projectiles.draw()
    enemies.draw()
end