function love.load()
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

    zombies = {}

    -- Collision point between the player and the zombie
    collision = sprites.player:getWidth() / 2 + sprites.zombie:getWidth() / 2
end

function love.update(dt)
    -- Player movement
    if love.keyboard.isDown('z') then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown('q') then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown('s') then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown('d') then
        player.x = player.x + player.speed * dt
    end

    -- Zombie movement
    for i, z in ipairs(zombies) do
        z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt
        z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt

        -- If a zombie touches the player
        if distance(z.x, z.y, player.x, player.y) < collision then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
            end
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth() / 2, sprites.player:getHeight() / 2)

    for i,zombie in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, zombie.x, zombie.y, zombiePlayerAngle(zombie), nil, nil, sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2)
    end

end

function love.keypressed(key)
    -- DEBUG
    if key == 'space' then spawnZombie() end
end

function playerMouseAngle()
    return math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
end

function zombiePlayerAngle(zombie)
    return math.atan2(player.y - zombie.y, player.x - zombie.x)
end

function spawnZombie()
    local zombie = {}
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = math.random(0, love.graphics.getHeight())
    zombie.speed = 100

    table.insert(zombies, zombie)
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
