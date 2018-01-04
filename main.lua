function love.load()
  
--  if not spider then
    require 'spider'
--  end
  if not object then
    object = require 'object'
  end
  if not camera then
    camera = require 'hump.camera'
  end
  if not color then
    color = require 'color'
  end
  
  debugGame = require 'debugGame'
  
  
  lovebird = require("lovebird.lovebird")
--  require 'cupid' -- cupid breaks it for some reason (and doesn't have a cool table browser)
  
  
  objects             = object.objects
  grabTable           = object.grabTable
  draggableObjectList = object.draggableObjectList
  jointTable          = object.jointTable
  flatObjects         = object.flatObjects
  winSizeX, winSizeY  = 650, 650
  impulseLocation     = {0, 0, 0, 0}
  drag                = false
  closestPBody        = nil
  mouseCamera         = false
  toggleTimer         = 0
  mouseStrength       = 0.5
  lineCoords          = {false, false, false, false} -- Would use nil but thats the same as {}
  lineDrawing         = false
  currentPlayer       = nil
  

  --let's create the ground
  objects.ground = object:newStatic("ground", 0, winSizeY/2-50/2, winSizeX, 50, 0)
  objects.wall = object:newStatic("wall", -200, -100, 50, 50, 45)
    Spider:initSpiders()
--  --let's create a player body
--    objects.spider = Spider:create("spider1", 0, 0, headSize, 0.1, 0.9, 0.9, false, nil, false)
    local spiderConstructor = {
       name          = "spider1",
       offset       = {0,0},
       bodySize      = 20,
       density       = 0.1,
       restitution   = 0.3,
       friction      = 0.9,
       isDraggable   = false,
       dragPriority  = nil,
       headGrab      = false
      }
      objects.spider1 = Spider:createUnpacker(spiderConstructor)
      -- You can't seem to assign two variables to one table in one go, annoying
      currentPlayer = objects.spider1
    -- Intresting. TODO: add an iterator for spider drawing
    --objects.spider_body2 = Spider:create("spider2", 0, 0, headSize, 0.1, 0.9, 0.9, false, nil, false)
-- 
    world:setCallbacks(beginContact)
    camera = camera(winSizeX/2, winSizeY/2)

 
  --let's create a couple blocks to play around with
  objects.blocks = {}
  
  objects.blocks["block1"] = newBlock("block1", 200, 550, 50, 100, 30, .5, 0, false)
  objects.blocks["block2"] = newBlock("block2", 200, 400, 100, 50, 45, .2, 0, false)
  
                    --newObject(name    , centerOffsetX, centerOffsetY, bodySize, density, restitution, friction, isDraggable, dragPriority, canGrab, canBeGrabbed)
  objects["ball"] = object.newObject("ball",             0,            50,       20,     0.1,         0.9,      0.9,        true,          nil,   false,         true)
 
  --initial graphics setup
  love.graphics.setBackgroundColor(Color.skyColor) --set the background color to a nice blue
  love.window.setMode(winSizeX, winSizeY) --set the window dimensions to winSizeX by winSizeY
  love.window.setTitle("Tri-achnid Clone")
end

function love.wheelmoved(x, y)
  if y>0 then
    camera:zoom(1.1)
  elseif y<0 then
    camera:zoom(1/1.1)
  end
  -- mousewheel x: just another control I have
  if x<0 then
    mouseStrength = mouseStrength + .1
  elseif x>0 then
    mouseStrength = mouseStrength - .1
  end
  
end

function beginContact(a, b, coll)
  local aData = a:getUserData() or {false, false}
  local bData = b:getUserData() or {false, false}
  local grabber, touched = nil
  if (aData[1] or bData[1]) and (not aData[2] and not bData[2]) then -- If a or b can grab, but not both, and neither is ungrabbable
    if aData[1] then
      grabber = a
      touched = b
    elseif bData[1] then
      grabber = b
      touched = a
    end
    local gData = grabber:getUserData()
    local tData = touched:getUserData() or {false, true}
    local x1, y1, x2, y2 = coll:getPositions( )
    --xa, ya = (x1 + x2)/2, (y1 + y2)/2 --x2, y2 is nil, weird
    if not grabTable[grabber:getBody()] and (tData[2]) then
      grabTable[grabber:getBody()] = { grabber:getBody(), touched:getBody(), x1, y1, true }
    end
  end
  
end

function impulseDrag(body)
  local bx, by = body:getPosition()
  local mx, my = camera:mousePosition()
--  local wmx, wmy = mx * scale + ox, my * scale + oy
--  local dx, dy = bx - wmx, by - wmy
  local dx, dy = bx - mx, by - my
  local d = math.sqrt ( dx * dx + dy * dy )
  d = 100
  local ndx, ndy = dx / d, dy / d
  local ix, iy = ndx * currentPlayer.legStrength, ndy *currentPlayer.legStrength
  
  impulseLocation = {-ix, -iy, bx, by}
  body:applyLinearImpulse ( -ix, -iy)--, bx, by ) --not needed it assumes center of mass
end

function locationDrag(body)
      --if mouseDragMode == 1 then
      body:setPosition(camera:mousePosition())
      if resetVelocity then
        body:setLinearVelocity(0, 0)
      end
end

function mouseDrag(body, resetVelocity) -- Does resetVelocity even help at all?
  --mx, my = love.mouse.getPosition()
  if body then
    if love.mouse.isDown(1) then
      locationDrag(body)
    elseif love.mouse.isDown(2) then
        impulseDrag(body)
    end
  end    
end

function love.mousepressed(x, y, button)
  if button == 1 or button == 2 then
    local wx, wy = camera:worldCoords(x, y)
    
    closestPBody = getNearestDraggable(wx, wy, draggableObjectList, 1000, true)
    drag = true
  elseif button == 3 then
    lineDrawing  = true
     -- It's too bad I can't use the functions arguments, 
--     but then I have to do the math anyway.
    local mx, my = camera:mousePosition()
    
    lineCoords   = {mx, my, false, false}
  end
  
end

function love.mousereleased(x, y, button)
  if button == 1 or button == 2 then
    drag = false
    closestPBody = nil
  elseif button == 3 then
    lineDrawing   = false
    local mx, my  = camera:mousePosition()
    lineCoords[3] = mx
    lineCoords[4] = my
    local dist  = util.dist(unpack(lineCoords))
    local angle = util.angle(unpack(lineCoords))
    objects.drawnWall = object:newStatic("drawnWall", lineCoords[1], lineCoords[2], 10, dist, angle)
  end
end
  
function love.mousemoved(x, y, dx, dy, istouch)
  if lineDrawing then
   -- Should I convert the real arguments instead?
    local mx, my  = camera:mousePosition()
    lineCoords[3] = mx
    lineCoords[4] = my
  end
end
  
function drawMouseLine()
  love.graphics.line(unpack(lineCoords))
end
  
function getNearestDraggable(x, y, draggableObjectList, maxDistance, scaling)
  closestKey  = nil
  closestBody = nil
  closestBodyDist = 1000 or maxDistance
  for key, object in pairs(draggableObjectList) do
    local dx = object.pBody:getX() - x
    local dy = object.pBody:getY() - y
    local dist = 0
    if scaling == nil or object.dragPriority == nil then
      dist = math.sqrt(dx * dx + dy * dy)      
    else
      dist = object.dragPriority * math.sqrt(dx * dx + dy * dy)
    end
    if dist < closestBodyDist then
      closestBodyDist = dist
      closestBody = object.pBody
      closestKey = key
    end
  end
  return closestBody, closestBodyDist, closestKey
end
  
function resetSpider()
  resetObject(currentPlayer.head, true)
  resetObject(currentPlayer.feet["foot1"], true)
  resetObject(currentPlayer.feet["foot2"], true)
  resetObject(currentPlayer.feet["foot3"], true)
  resetObject(currentPlayer.knees["knee1"], true)
  resetObject(currentPlayer.knees["knee2"], true)
  resetObject(currentPlayer.knees["knee3"], true)
  resetObject(flatObjects["ball"])
end

function resetObject(object, resetVelocity)
  object.pBody:setPosition((winSizeX/2 + object.centerOffsetX) or winSizeX/2, (winSizeY/2 + object.centerOffsetY) or winSizeY/2)
  if resetVelocity == nil or resetVelocity == true then
    object.pBody:setLinearVelocity(0, 0)
  end
end


function drawBlocks()
  love.graphics.setColor(color.blockColor) -- set the drawing color to grey for the blocks
  love.graphics.polygon("fill", objects.blocks["block1"].pBody:getWorldPoints(objects.blocks["block1"].shape:getPoints()))
  love.graphics.polygon("fill", objects.blocks["block2"].pBody:getWorldPoints(objects.blocks["block2"].shape:getPoints()))
end

function followCamera(strength)
  strength = strength or 1
--  if strength == -1 then
--    strength = 1
--  end
    --camera:setX(love.mouse.getX())
    --camera:setY(love.mouse.getY())

	--if love.keyboard.isDown("m") then
        local bodyX, bodyY       = currentPlayer:getHeadPosition() -- love.mouse.getPosition()
        local cameraX, cameraY   = camera:cameraCoords(bodyX, bodyY)
        if mouseCamera then
          local mouseX, mouseY   = camera:mousePosition()
--          local tempX, tempY     = (bodyX + strength * mouseX)/(strength+1), (bodyY + strength * mouseY)/(strength+1)
          local tempX            = util.lerp(bodyX,mouseX,strength)
          local tempY            = util.lerp(bodyY,mouseY,strength)
          camera:lookAt(tempX, tempY)
        else
          camera:lookAt(bodyX, bodyY)
        end
        --camera:moveTo(1,0)
        --print(camera:position())

		--camera:setX(camera:getX() * 64)-- + objects.currentPlayer.head.pBody:getX() -- or camera.y = camera.y + player.y, or something like this (depends what you need)
        --camera:set() doesn't work
        --camera.set(camera)
	--end
end

function love.update(dt)
  lovebird.update()
  world:update(dt) --this puts the world into motion

  if toggleTimer > 0 then -- TODO: make this time dependent
    toggleTimer = toggleTimer - dt
  end

  if drag then
    mouseDrag(closestPBody, true)
  end
  for key, value in pairs(grabTable) do
    if grabTable[key] and not jointTable[key] then
      jointTable[key] = love.physics.newWeldJoint( unpack(grabTable[key]) )
      
    end
  end

    currentPlayer:controlHead()
  
    followCamera(mouseStrength)
  
  if love.keyboard.isDown("space") then -- Reset the position
   resetSpider()
  end
  if love.keyboard.isDown("r") then -- Destroy and delete all grab joints
    for key, value in pairs(jointTable) do
      jointTable[key]:destroy()
      jointTable[key] = nil
      grabTable[key]  = nil
    end
  end
  if (not love.keyboard.isDown("z")) and drag and jointTable[closestPBody] then -- Hold on, even while dragging
    jointTable[closestPBody]:destroy()
    jointTable[closestPBody] = nil
    grabTable[closestPBody]  = nil
  end
  
  if love.keyboard.isDown("x") and jointTable[closestPBody] then -- should delete all but closest grab
    for key, value in pairs(jointTable) do
        if not (value == jointTable[closestPBody]) then
          jointTable[key]:destroy()
          jointTable[key] = nil
          grabTable[key]  = nil
        end
      end
  end
  
  if love.keyboard.isDown("c") and toggleTimer <= 0 then
    toggleCanGrab(currentPlayer.head)
    toggleTimer = 1
  end
  
  if love.keyboard.isDown("o") and toggleTimer <= 0 then
    mouseCamera = not mouseCamera
    toggleTimer = 1
  end
  
  if love.keyboard.isDown("=") then
    camera:zoom(1.1)
  end
  if love.keyboard.isDown("-") then
    camera:zoom(1/1.1)
  end
  
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end    
end

function love.draw()
  camera:attach()

  object:drawStatic("ground", {72, 160, 14})
  object:drawStatic("wall", {40, 160, 14})
  Spider:drawSpider()
  
  drawBlocks()
  drawCircle(objects["ball"]) -- No need for an external function really
  love.graphics.setColor(0, 255, 0)
  if closestPBody then -- This should highlight the object that the mouse will drag
    local x, y = closestPBody:getPosition()
    love.graphics.circle("fill", x, y, 4) -- I would use my function, but  it takes an object not a pBody
  end
  if lineCoords[3] then -- Check if the second set of coords are defined (as numbers)
    -- TODO: This could probobly be made nicer
    drawMouseLine()
  end
  --debugDistance()
  debugGame.debugGrabbing()
  --debugCamera()
  camera:detach()
end
