require('camera')

grav = 400
worldWidth = 3000
worldHeight = 650

function love.load()
  x = 50
  y = 50
  speed = 200

  bg = love.graphics.newImage("images/background.png")
  world = love.physics.newWorld(0, 0, worldWidth, 650) --create a world for the bodies to exist in with width and height of 650
  world:setGravity(0, grav) --the x component of the gravity will be 0, and the y component of the gravity will be 700
  world:setMeter(64) --the height of a meter in this world will be 64px

  objects = {} -- table to hold all our physical objects

  --let's create the ground
  objects.ground = {}
  --we need to give the ground a mass of zero so that the ground wont move
  objects.ground.body = love.physics.newBody(world, worldWidth/2, 625, 0, 0) --remember, the body anchors from the center of the shape
  objects.ground.shape = love.physics.newRectangleShape(objects.ground.body, 0, 0, worldWidth, 50, 0) --anchor the shape to the body, and make it a width of 650 and a height of 50
  objects.ground.shape:setData("platform")

  objects.rightWall = {}
  objects.rightWall.body = love.physics.newBody(world, worldWidth-25, worldHeight/2, 0, 0) --remember, the body anchors from the center of the shape
  objects.rightWall.shape = love.physics.newRectangleShape(objects.rightWall.body, 0, 0, 50, worldHeight, 0) --anchor the shape to the body, and make it a width of 650 and a height of 50
  objects.leftWall = {}
  objects.leftWall.body = love.physics.newBody(world, 5, worldHeight/2, 0, 0) --remember, the body anchors from the center of the shape
  objects.leftWall.shape = love.physics.newRectangleShape(objects.leftWall.body, 0, 2, 50, worldHeight, 0) --anchor the shape to the body, and make it a width of 650 and a height of 50

  objects.leftWall.shape:setFriction(0)
  objects.rightWall.shape:setFriction(0)

  objects.hamster = {}
  objects.hamster.body = love.physics.newBody(world, 650/2, 650/2, 15, 0) --place the body in the center of the world, with a mass of 15
  objects.hamster.shape = love.physics.newCircleShape(objects.hamster.body, 0, 0, 20) --the ball's shape has no offset from it's body and has a radius of 20
  objects.hamster.shape:setData("hamster")

  numFollow = 1
  objects.follow = {}
  for i=1,numFollow do
    objects.follow[i] = {body = love.physics.newBody(world, 650/2+100*i, 600, 15, 0)} 
    objects.follow[i].shape =  love.physics.newCircleShape(objects.follow[i].body, 0, 0, 10)
  end

  numWander = 2
  objects.wander = {}
  local wlx = {500, 900}
  local wly = {450, 350}
  for i=1,numWander do
    objects.wander[i] = {body = love.physics.newBody(world, wlx[i], wly[i], 15, 0)}  
    objects.wander[i].shape =  love.physics.newCircleShape(objects.wander[i].body, 0, 0, 10) 
    objects.wander[i].direction = 1
    objects.wander[i].starting = wlx[i]
  end

  objects.platform = {}
  objects.topPlatform = {}
  local plx = {500, 900}
  local ply = {500, 400}

  for i=1,2 do
    objects.platform[i] = {body = love.physics.newBody(world, plx[i], ply[i], 0, 0)} 
    objects.platform[i].shape =  love.physics.newRectangleShape(objects.platform[i].body, 0, 0, 300, 25)
    objects.platform[i].shape:setFriction(0)

    objects.topPlatform[i] = {body = love.physics.newBody(world, plx[i], ply[i]-20, 0, 0)} 
    objects.topPlatform[i].shape =  love.physics.newRectangleShape(objects.topPlatform[i].body, 0, 0, 300, 10)
    objects.topPlatform[i].shape:setData("platform")
  end

  world:setCallbacks(add, nil, rem, nil)
  canJump = false
end

function add(a, b, coll)
  print(a, b)
  if (a == "hamster" or b == "hamster") and (a == "platform" or b == "platform") then
    canJump = true
  end
end

function rem(a, b, coll)
  if (a == "hamster" or b == "hamster") and (a == "platform" or b == "platform") then
    canJump = false
  end
end

function wanderAI(wanderNumber)
  local ev = 200
  if objects.wander[wanderNumber].direction == 1 then  
    objects.wander[wanderNumber].body:setLinearVelocity(ev,0)
  else
    objects.wander[wanderNumber].body:setLinearVelocity(-ev,0)
  end

  local epx, epy = objects.wander[wanderNumber].body:getPosition()
  if objects.wander[wanderNumber].starting-epx > 150 then
    objects.wander[wanderNumber].direction = 1
  elseif epx - objects.wander[wanderNumber].starting > 150 then
    objects.wander[wanderNumber].direction = -1
  end
end

function followAI(followNumber)
  local epx, epy = objects.follow[followNumber].body:getPosition()
  local upx, upy = objects.hamster.body:getPosition()

  local ev = 100
  if epx > upx then
    objects.follow[followNumber].body:setLinearVelocity(-ev,0)
  else
    objects.follow[followNumber].body:setLinearVelocity(ev,0)
  end
end

function love.update(dt)
  local vx, vy = objects.hamster.body:getLinearVelocity()
  objects.hamster.body:wakeUp()

  local speed = 200
  if love.keyboard.isDown("right") then
    objects.hamster.body:setLinearVelocity(speed, vy)
  elseif love.keyboard.isDown("left") then
    objects.hamster.body:setLinearVelocity(-speed, vy)
  end

  local px, py = objects.hamster.body:getPosition()
  if love.keyboard.isDown("up") and canJump == true then
    objects.hamster.body:applyImpulse(0,1200, 0,0)
    canJump = false
  end

  for i=1,numFollow do
    followAI(i)
  end

  for i=1,numWander do
    wanderAI(i)
  end

  world:update(dt)
  camera:setPosition(math.clamp(px - 300,0,worldWidth-650), 0)

--[[
   if x < 0 then
     x = 0
   elseif x > love.graphics.getWidth() - hamster:getWidth() then
     x = love.graphics.getWidth() - hamster:getWidth()
   end

   if y < 0 then
     y = 0
   elseif y > love.graphics.getHeight() - hamster:getHeight() then
     y = love.graphics.getHeight() - hamster:getWidth()
   end
   --]]
end

function love.draw()
  camera:set()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(bg, 0, 0)
  --love.graphics.draw(hamster, x, y)
  love.graphics.setColor(238, 130, 238)
  love.graphics.polygon("fill", objects.ground.shape:getPoints()) -- draw a "filled in" polygon using the ground's coordinates
  love.graphics.polygon("fill", objects.leftWall.shape:getPoints()) -- draw a "filled in" polygon using the ground's coordinates
  love.graphics.polygon("fill", objects.rightWall.shape:getPoints()) -- draw a "filled in" polygon using the ground's coordinates

  love.graphics.setColor(255, 0, 0) --set the drawing color to red for the ball
  love.graphics.circle("fill", objects.hamster.body:getX(), objects.hamster.body:getY(), objects.hamster.shape:getRadius(), 20) -- we want 20 line segments to form the "circle"

  love.graphics.setColor(0,0,0)

  for i=1,numFollow do
    love.graphics.circle("fill", objects.follow[i].body:getX(), objects.follow[i].body:getY(), objects.follow[i].shape:getRadius(), 10)
  end

  for i=1, numWander do
    love.graphics.setColor(13,52,200)
    love.graphics.circle("fill", objects.wander[i].body:getX(), objects.wander[i].body:getY(), objects.wander[i].shape:getRadius(), 10)
  end

  for i=1,2 do
    love.graphics.setColor(100,100,100)
    love.graphics.polygon("fill", objects.platform[i].shape:getPoints())
    love.graphics.setColor(0,0,138)
    love.graphics.polygon("fill", objects.topPlatform[i].shape:getPoints())
  end
  camera:unset()
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end
