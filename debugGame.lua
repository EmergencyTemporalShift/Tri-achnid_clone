
debug = {}

function debug.debugImpulse()
  if impulseLocation then
    impulseColor = (impulseColor + 1) % 255
    love.graphics.setColor({0, 0, impulseColor})
    love.graphics.circle("fill", impulseLocation[1], impulseLocation[2], spider_body["head"].shape:getRadius()*eyeScale)  
    love.graphics.setColor({impulseColor, 0, 0})
    love.graphics.circle("fill", impulseLocation[3], impulseLocation[4], spider_body["head"].shape:getRadius()*eyeScale)  
    love.graphics.setColor({impulseColor, 0, impulseColor})
    love.graphics.line(impulseLocation )
  end
end

function debug.debugGrabbing()
  for body, joint in pairs(jointTable) do
  local trash, body2 = joint:getBodies()
    love.graphics.setColor({255, 255, 128})
    love.graphics.circle("fill", body:getX(), body:getY(), 4)
    love.graphics.setColor({128, 128, 255})
    love.graphics.circle("fill", body2:getX(), body2:getY(), 4)
  end
end

function debug.debugDistance()
  local mx, my = love.mouse.getPosition()
  closestBodyDist = 1000 or maxDistance
  love.graphics.setColor(blockColor)
  love.graphics.setLineWidth( 2 )
  for key, object in pairs(draggableObjectList) do
    local dx = object.pBody:getX() - mx
    local dy = object.pBody:getY() - my
    if object.dragPriority == nil then
      local dist = math.sqrt(dx * dx + dy * dy)      
    else
      local dist = object.dragPriority * math.sqrt(dx * dx + dy * dy)
    end
    love.graphics.circle("line", object.pBody:getX(), object.pBody:getY(), 1000/dist)
  end
end

function debug.debugCamera()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    local size = 4
    local cx, cy = camera:position()
    love.graphics.rectangle( "line", cx-size/2, cy-size/2, size, size )
end

return debug