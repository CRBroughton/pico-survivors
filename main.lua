local utils = {}

function utils.delete(table, item)
    if item.x > screenWidth then
        del(table, item)
    end
    if item.x < offScreen then
        del(table, item)
    end
    if item.y > screenHeight then
        del(table, item)
    end
    if item.y < offScreen then
        del(table, item)
    end
end

function utils.updateCamera(player)
    camX = player.x - 60
	camY = player.y - 60

	camX = mid(0, camX, 128)
	camY = mid(0, camY, 128)
	
	camera(camX,camY)
end

function _init()
    local var screenWidth = 256 - 8
    local var screenHeight = 256 - 8
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

    function checkForEnemyCollision(en, i, moveX, moveY)
        local newX, newY = en.x + moveX, en.y + moveY
        local collision = false
        for j, otherEn in ipairs(enemies) do
            if j ~= i then -- Skip self
                local distance = sqrt((newX - otherEn.x)^2 + (newY - otherEn.y)^2)
                if distance < 8 then
                    -- Handle collision by moving both enemies away from each other
                    local dx = newX - otherEn.x
                    local dy = newY - otherEn.y
                    local d = sqrt(dx * dx + dy * dy)
                    if d == 0 then d = 0.00001 end -- Avoid division by zero
                    local overlap = 8 - d
                    local moveX = overlap * (dx / d)
                    local moveY = overlap * (dy / d)
                    newX = newX + moveX
                    newY = newY + moveY
                    break
                end
            end
        end
        return newX, newY
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
        
                    newX, newY = checkForEnemyCollision(en, i, moveX, moveY)
        
                    en.x = newX
                    en.y = newY
        
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
                utils.delete(projectiles, proj)
            end
        end


        return self
    end

    abilities = {
        ['arrow'] = {
            unlocked = false,
            sprite = 5,
            speed = 1,
        }
    }

    player = {}
    player.new = function ()
        local self = {
            x = 128,
            y = 128,
            timer = 0,
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
            self.timer += 1
            if self.timer == 1 * 60 then
                if self.facing == 'left' then
                    add(projectiles, {
                        x = self.x - 8,
                        y = self.y,
                        speed = 1,
                        dir = 'left',
                        sprite = self.attacks.fireball.sprite
                    })
                end
                if self.facing == 'right' then
                    add(projectiles, {
                        x = self.x + 8,
                        y = self.y,
                        speed = 1,
                        dir = 'right',
                        sprite = self.attacks.fireball.sprite
                    })
                end
                self.timer = 0
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
            if btn(0) and player.x > 8 then
                player.x -= 1
                self.currentSprite = self.spriteLeft
                self.facing = 'left'
            elseif btn(1) and player.x < screenWidth - 8 then
                player.x += 1
                self.currentSprite = self.spriteRight
                self.facing = 'right'
            elseif btn(2) and player.y > 8 then
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
    map(0,0,0,0,128,32)
    player.selectClass("wizard")
    utils.updateCamera(player)
    player.draw()
    player.attack()
    projectiles.draw()
    enemies.draw()
end