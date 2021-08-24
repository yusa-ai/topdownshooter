function love.load()
    math.randomseed(os.time())

    love.window.setTitle('Top-Down Shooter')

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.rotation = 0
    player.speed = 180
    player.injured = false

    zombies = {}
    bullets = {}

    -- Collision point between the player and the zombie
    pzCollision = sprites.player:getWidth() / 2 + sprites.zombie:getWidth() / 2

    playing = false
    maxTime = 0
    timer = 0
    score = 0
end

function love.update(dt)
    if playing then
        -- Player movement
        if love.keyboard.isDown('z') and player.y - sprites.player:getHeight() / 2 > 0 then
            player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown('q') and player.x - sprites.player:getWidth() / 2 > 0 then
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown('s') and player.y + sprites.player:getHeight() / 2 < love.graphics.getHeight() then
            player.y = player.y + player.speed * dt
        end
        if love.keyboard.isDown('d') and player.x + sprites.player:getWidth() / 2 < love.graphics.getWidth() then
            player.x = player.x + player.speed * dt
        end
    end

    -- Zombie movement
    for i,z in ipairs(zombies) do
        z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt
        z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt

        -- Zombie/player collision
        if distance(z.x, z.y, player.x, player.y) < pzCollision then
            if not player.injured then
                player.injured = true
                player.speed = player.speed + 120
                table.remove(zombies, i)
            else
                for i,z in ipairs(zombies) do
                    zombies[i] = nil
                end
                playing = false
                player.injured = false
                player.speed = player.speed - 120
            end
        end
    end

    -- Bullet movement
    for i,b in ipairs(bullets) do
        b.x = b.x + math.cos(b.direction) * b.speed * dt
        b.y = b.y + math.sin(b.direction) * b.speed * dt
    end

    -- Destroy bullets off-screen
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end

    -- Mark zombie/bullet collisions
    for i,z in ipairs(zombies) do
        for j,b in ipairs(bullets) do
            if distance(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true

                score = score + 1
            end
        end
    end

    -- Remove bullets/zombies marked dead
    for i = #zombies, 1, -1 do
        local z = zombies[i]
        if z.dead == true then table.remove(zombies, i) end
    end
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if b.dead == true then table.remove(bullets, i) end
    end

    if playing then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            maxTime = maxTime * .95
            timer = maxTime
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    if not playing then
        love.graphics.setFont(love.graphics.newFont(30))
        love.graphics.printf('Click anywhere to begin!', 0, 50, love.graphics.getWidth(), 'center')
    end

    if playing then
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.printf('Score: ' .. score, 0, love.graphics.getHeight() - 50 - (love.graphics.getFont():getHeight() / 2), love.graphics.getWidth(), 'center')
    end

    if player.injured then
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth() / 2, sprites.player:getHeight() / 2)

    love.graphics.setColor(1, 1, 1) -- reset color

    -- Zombies
    for i,zombie in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, zombie.x, zombie.y, zombiePlayerAngle(zombie), nil, nil, sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2)
    end

    -- Bullets
    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, .75, .75, sprites.bullet:getWidth() / 2, sprites.bullet:getHeight() / 2)
    end
end

function love.mousepressed(x, y, button)
    if playing and button == 1 then
        spawnBullet()
    else
        playing = true
        maxTime = 2
        timer = maxTime
        score = 0
    end
end

function playerMouseAngle()
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
end

function zombiePlayerAngle(zombie)
    return math.atan2(player.y - zombie.y, player.x - zombie.x)
end

function spawnZombie()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 100
    zombie.dead = false

    local side = math.random(1, 4)
    if side == 1 then -- left
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then -- right
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then -- up
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then -- down
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()

    table.insert(bullets, bullet)
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end