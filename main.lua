grav = 400
worldWidth = 3000
worldHeight = 650

function love.load()
  x = 50
  y = 50
  speed = 200

  world = love.physics.newWorld(0, 0, worldWidth, 650) --create a world for the bodies to exist in with width and height of 650
  world:setGravity(0, grav) --the x component of the gravity will be 0, and the y component of the gravity will be 700
  world:setMeter(64) --the height of a meter in this world will be 64px

  objects = {} -- table to hold all our physical objects

  --let's create the ground
  objects.ground = {}
  --we need to give the ground a mass of zero so that the ground wont move
  objects.ground.body = love.physics.newBody(world, worldWidth/2, 625, 0, 0) --remember, the body anchors from the center of the shape
  objects.ground.shape = love.physics.newRectangleShape(objects.ground.body, 0, 0, worldWidth, 50, 0) --anchor the shape to the body, and make it a width of 650 and a height of 50

  objects.rightWall = {}
  objects.rightWall.body = love.physics.newBody(world, worldWidth-25, worldHeight/2, 0, 0) --remember, the body anchors from the center of the shape
  objects.rightWall.shape = love.physics.newRectangleShape(objects.rightWall.body, 0, 0, 50, worldHeight, 0) --anchor the shape to the body, and make it a width of 650 and a height of 50
  objects.leftWall = {}
  objects.leftWall.body = love.physics.newBody(world, 25, worldHeight/2, 0, 0) --remember, the body anchors from the center of the shape
  objects.leftWall.shape = love.physics.newRectangleShape(objects.leftWall.body, 0, 0, 50, worldHeight, 0) --anchor the shape to the body, and make it a width of 650 and a height of 50

  objects.hamster = {}
  objects.hamster.body = love.physics.newBody(world, 650/2, 650/2, 15, 0) --place the body in the center of the world, with a mass of 15
  objects.hamster.shape = love.physics.newCircleShape(objects.hamster.body, 0, 0, 20) --the ball's shape has no offset from it's body and has a radius of 20

  hamsterImg = love.graphics.newImage("icon_hamster.gif")

end

function love.update(dt)
  local vx, vy = objects.hamster.body:getLinearVelocity()
  objects.hamster.body:wakeUp()
  if love.keyboard.isDown("right") then
    objects.hamster.body:setLinearVelocity(200, vy)
  elseif love.keyboard.isDown("left") then
    objects.hamster.body:setLinearVelocity(-200, vy)
  end

  local px, py = objects.hamster.body:getPosition()
  if love.keyboard.isDown("up") and py > 580 then
    objects.hamster.body:applyImpulse(0,900, 0,0)
  end
  world:update(dt)
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
  --love.graphics.draw(hamster, x, y)
  love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
  love.graphics.polygon("fill", objects.ground.shape:getPoints()) -- draw a "filled in" polygon using the ground's coordinates
  love.graphics.setColor(72, 0, 1)
  love.graphics.polygon("fill", objects.leftWall.shape:getPoints()) -- draw a "filled in" polygon using the ground's coordinates
  love.graphics.polygon("fill", objects.rightWall.shape:getPoints()) -- draw a "filled in" polygon using the ground's coordinates

  love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  love.graphics.circle("fill", objects.hamster.body:getX(), objects.hamster.body:getY(), objects.hamster.shape:getRadius(), 20) -- we want 20 line segments to form the "circle"

end
