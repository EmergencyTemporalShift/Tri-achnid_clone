--if not main then
--require './main'
--end
--print(require 'main')

-- TODO: Throw this stuff in an init function

local object = {}
local winSizeX, winSizeY = 650, 650 -- Just a copy for now
object.grabTable    = {}
object.jointTable   = {}
object.objects = {} -- table to hold all our physical objects
object.flatObjects  = {} -- Flattened table to iterate over
object.draggableObjectList = {}
object.staticObjects = {}
 

local gravity      = 9.81
local scale        = 64
love.physics.setMeter(scale) --the height of a meter our worlds will be 64px
world        = love.physics.newWorld(0, gravity*scale, true) --create a physics world
 

function getWorld()
  return world
end

function object.newObject(name, centerOffsetX, centerOffsetY, bodySize, density, restitution, friction, isDraggable, dragPriority, canGrab, canBeGrabbed)
  object.flatObjects[name] = {}
  object.flatObjects[name].centerOffsetX = centerOffsetX
  object.flatObjects[name].centerOffsetY = centerOffsetY
  object.flatObjects[name].pBody = love.physics.newBody(world, winSizeX/2 + (centerOffsetX or 0), winSizeY/2 + (centerOffsetY or 0), "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  object.flatObjects[name].shape = love.physics.newCircleShape(bodySize or 20) --the ball's shape has a radius of 20
  object.flatObjects[name].fixture = love.physics.newFixture(object.flatObjects[name].pBody, object.flatObjects[name].shape, density or 1) -- Attach fixture to body and give it a density of 1.
  object.flatObjects[name].fixture:setRestitution(restitution or 0.9) --let the ball bounce
  object.flatObjects[name].fixture:setFriction(friction or 0.9)
  --if canGrab then
    object.flatObjects[name].fixture:setUserData({canGrab, canBeGrabbed, nil})
  --end
  
  if isDraggable then
    object.flatObjects[name].dragPriority = dragPriority
    object.draggableObjectList[name] = object.flatObjects[name]
  end
  return object.flatObjects[name]
end

function object:setCanGrab(canGrab)
  local data = object.fixture:getUserData()
  object.fixture:setUserData({canGrab, data[2], data[3]})
end

function toggleCanGrab(object)
  local data = object.fixture:getUserData()
  object.fixture:setUserData({not data[1], data[2], data[3]})
end

function newBlock(name, centerOffsetX, centerOffsetY, width, height, angle, density, restitution, isDraggable)
  object.flatObjects[name] = {}
  object.flatObjects[name].centerOffsetX = centerOffsetX
  object.flatObjects[name].centerOffsetY = centerOffsetY
  object.flatObjects[name].pBody = love.physics.newBody(world, centerOffsetX or 0, centerOffsetY or 0, "dynamic")
  object.flatObjects[name].shape = love.physics.newRectangleShape(0, 0, width, height, math.rad(angle))
  object.flatObjects[name].fixture = love.physics.newFixture(object.flatObjects[name].pBody, object.flatObjects[name].shape, density or 5) -- A higher density gives it more mass.
  object.flatObjects[name].fixture:setRestitution(restitution or 0)
  if isDraggable then
    object.draggableObjectList[name] = object.flatObjects[name]
  end
  return object.flatObjects[name]
end

function object:newStatic(name, centerOffsetX, centerOffsetY, width, height, angle)
    --let's create the ground
  object.staticObjects[name] = {}
  object.staticObjects[name].pBody = love.physics.newBody(world, winSizeX/2 + centerOffsetX, winSizeY/2 + centerOffsetY) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (winSizeX/2, 650-50/2)
  object.staticObjects[name].shape = love.physics.newRectangleShape(0, 0, width, height, math.rad(angle)) --make a rectangle with a width of winSizeX and a height of 50
  object.staticObjects[name].fixture = love.physics.newFixture(object.staticObjects[name].pBody, object.staticObjects[name].shape); --attach shape to body
  object.staticObjects[name].fixture:setFriction(0.9)
  return objects.ground
end

function object:drawStatic(name, color)
  love.graphics.setColor(color) -- set the drawing color to green for the ground
  love.graphics.polygon("fill", object.staticObjects[name].pBody:getWorldPoints(object.staticObjects[name].shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
end  

return object
  
