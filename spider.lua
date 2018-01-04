if not main then
  main = require 'main'
end

if not util then
  util = require 'util'
end

if not object then
  object = require 'object'
end
if not color then
  color = require 'color'
end

newObject = object.newObject


Spider = {}
Spider.__index = Spider

function Spider:initSpiders() -- Should this use a seperate class?
  -- Probobly static
  Spider.thighLength  = 65
  Spider.calfLength   = 45
  Spider.legLength    = Spider.thighLength + Spider.calfLength
  Spider.thighWidth   = 10
  Spider.calfWidth    = 8
  Spider.legWidth     = 10

  Spider.headSize     = 20
  Spider.eyeScale     = 1/2
  Spider.pupilScale   = 1/3
  Spider.kneeSize     = 10
  Spider.footSize     = 8
  Spider.numberOfLegs = 3

  Spider.headStrength = 200
  Spider.legStrength  = 5
end

function Spider:createUnpacker(args)
  local name          = args.name
  local centerOffset  = args.offset
  local bodySize      = args.bodySize
  local density       = args.density
  local restitution   = args.restitution
  local friction      = args.friction
  local isDraggable   = args.isDraggable
  local dragPriority  = args.dragPriority
  local headGrab      = args.headGrab
  
  return Spider:create(name,centerOffset[1],centerOffset[2],bodySize,density,restitution,friction,isDraggable,dragPriority,headGrab)
end

-- I have way too many arguments, how should I fix that?
function Spider:create(name, centerOffsetX, centerOffsetY, bodySize, density, restitution, friction, isDraggable, dragPriority, headGrab)
--   local spdr = {} 
--   setmetatable(spdr, Spider) -- Keeping this for now, in case I broke something
   setmetatable(self, Spider)  -- handle lookup -- no idea what this is honestly
                       --newObject(name, centerOffsetX, centerOffsetY, bodySize, density, restitution, friction, isDraggable, dragPriority, canGrab, canBeGrabbed)
  self.head = object.newObject(name, centerOffsetX, centerOffsetY, bodySize, density, restitution, friction, isDraggable, dragPriority, headGrab, false)

  self.eye = {}
  -- Add googly eye later, or one that looks at mouse
  -- or other interesting things.
  
  -- Shortcuts so I don't have to replace stuff
  -- Define these per spider later
  local thighLength = Spider.thighLength
  local kneeSize    = Spider.kneeSize
  local legLength   = Spider.legLength
  local footSize    = Spider.footSize
  
  self.knees = {}
--newObject(name, centerOffsetX, centerOffsetY, bodySize, density, restitution, friction, isDraggable, dragPriority, canGrab, canBeGrabbed)
  self.knees["knee1"] = newObject("knee1",  thighLength,  0, kneeSize, nil, 0.9, 0.9, true, 2, false, false)
  self.knees["knee2"] = newObject("knee2", -thighLength,  0, kneeSize, nil, 0.9, 0.9, true, 2, false, false)
  self.knees["knee3"] = newObject("knee3",  0, -thighLength, kneeSize, nil, 0.9, 0.9, true, 2, false, false)
  self.knees["knee1"].fixture:setMask(2)
  self.knees["knee2"].fixture:setMask(2)
  self.knees["knee3"].fixture:setMask(2)
  
  self.thighs = {}
  self.thighs["thigh1"] = util.newDistanceJoint(self.head.pBody, self.knees["knee1"].pBody, false )
  self.thighs["thigh2"] = util.newDistanceJoint(self.head.pBody, self.knees["knee2"].pBody, false )
  self.thighs["thigh3"] = util.newDistanceJoint(self.head.pBody, self.knees["knee3"].pBody, false )
  
  
  self.feet = {}
  --newObject(name, centerOffsetX, centerOffsetY, bodySize, density, restitution, friction, isDraggable, dragPriority, canGrab, canBeGrabbed)
  self.feet["foot1"] = newObject("foot1",  legLength, 0, footSize, nil, 0.9, 0.9, true, nil, true, false)
  self.feet["foot2"] = newObject("foot2", -legLength, 0, footSize, nil, 0.9, 0.9, true, nil, true, false)
  self.feet["foot3"] = newObject("foot3", 0, -legLength, footSize, nil, 0.9, 0.9, true, nil, true, false)
  self.feet["foot1"].fixture:setMask(2)
  self.feet["foot2"].fixture:setMask(2)
  self.feet["foot3"].fixture:setMask(2)
    
  self.calves = {}
  
--  self.calves["calf1"] = love.physics.newDistanceJoint( self.knees["knee1"].pBody, self.feet["foot1"].pBody, self.knees["knee1"].pBody:getX(), self.knees["knee1"].pBody:getY(), self.feet["foot1"].pBody:getX(), self.feet["foot1"].pBody:getY(), false )
  self.calves["calf1"] = util.newDistanceJoint(self.knees["knee1"].pBody, self.feet["foot1"].pBody, false )
  self.calves["calf2"] = util.newDistanceJoint(self.knees["knee2"].pBody, self.feet["foot2"].pBody, false )
  self.calves["calf3"] = util.newDistanceJoint(self.knees["knee3"].pBody, self.feet["foot3"].pBody, false )

  -- This is just a test to make legs more rigid
  -- But it makes knees behave strangely
--defHeadToFoot()
--  return spdr  
  return self
end

function Spider:defHeadToFoot()
    self.headToFoot = {}
        
    self.headToFoot["headToFoot1"] = love.physics.newDistanceJoint( self.head.pBody, self.feet["foot1"].pBody, self.head.pBody:getX(), self.head.pBody:getY(), self.feet["foot1"].pBody:getX(), self.feet["foot1"].pBody:getY(), false )
    self.headToFoot["headToFoot2"] = love.physics.newDistanceJoint( self.head.pBody, self.feet["foot2"].pBody, self.head.pBody:getX(), self.head.pBody:getY(), self.feet["foot2"].pBody:getX(), self.feet["foot2"].pBody:getY(), false )
    self.headToFoot["headToFoot3"] = love.physics.newDistanceJoint( self.head.pBody, self.feet["foot3"].pBody, self.head.pBody:getX(), self.head.pBody:getY(), self.feet["foot3"].pBody:getX(), self.feet["foot3"].pBody:getY(), false )
end
  

function Spider:drawHeadToFoot()
    assert(self)
    love.graphics.setLineWidth( 2 )
    love.graphics.setColor({193, 47, 14})
     -- This is probobly more efficent, but it doesn't work with my drawConnection function
    local headX, headY = self["head"].pBody:getPosition()
    
    love.graphics.line(headX, headY, self.feet.foot1.pBody:getX(),self.feet.foot1.pBody:getY())
    love.graphics.line(headX, headY, self.feet.foot2.pBody:getX(),self.feet.foot2.pBody:getY())
    love.graphics.line(headX, headY, self.feet.foot3.pBody:getX(),self.feet.foot3.pBody:getY())
end

function Spider:getHeadPosition()
    return self["head"].pBody:getPosition()
end

function Spider:drawHead()
  love.graphics.setColor(color.bodyColor)
  drawCircle(self["head"])
end

function Spider:drawEye()
  local eyeScale   = Spider.eyeScale
  local pupilScale = Spider.pupilScale
 --sclera
  love.graphics.setColor(color.scleraColor)  
  love.graphics.circle("fill", self["head"].pBody:getX(), self["head"].pBody:getY(), self["head"].shape:getRadius()*eyeScale)  
--pupil
  love.graphics.setColor(color.pupilColor)  
  love.graphics.circle("fill", self["head"].pBody:getX(), self["head"].pBody:getY(), self["head"].shape:getRadius()*pupilScale)  
end

function Spider:drawKnees()
  drawCircle(self.knees["knee1"])
  drawCircle(self.knees["knee2"])
  drawCircle(self.knees["knee3"])
end

function Spider:drawThighs()
  love.graphics.setLineWidth( Spider.thighWidth )
  drawConnection(self["head"], self.knees["knee1"])
  drawConnection(self["head"], self.knees["knee2"])
  drawConnection(self["head"], self.knees["knee3"])
end

function Spider:drawCalves()
  love.graphics.setLineWidth( Spider.calfWidth )
  drawConnection(self.knees["knee1"], self.feet["foot1"])
  drawConnection(self.knees["knee2"], self.feet["foot2"])
  drawConnection(self.knees["knee3"], self.feet["foot3"])
end

function Spider:drawFeet()
  drawCircle(self.feet["foot1"])
  drawCircle(self.feet["foot2"])
  drawCircle(self.feet["foot3"])
end


function Spider:drawSpider()
  love.graphics.setColor(color.bodyDColor)
  Spider:drawThighs()
  Spider:drawCalves()
  love.graphics.setColor(color.bodyColor)
  Spider:drawHead()
  Spider:drawKnees()
  Spider:drawFeet()
  --drawHeadToFoot()
  
  
  Spider:drawEye()
end

function Spider:controlHead()
  local headStrength = Spider.headStrength
  --here we are going to create some keyboard events
  local a, d, w, s = love.keyboard.isDown("a"), love.keyboard.isDown("d"), love.keyboard.isDown("w"), love.keyboard.isDown("s")
  if a and d then --I always do this so there are no 'priority keys'
    --Nothing
    elseif a then -- Move the head left
      self.head.pBody:applyForce(-headStrength, 0)
    elseif d then -- Move the head right
      self.head.pBody:applyForce( headStrength, 0)
  end
  
  if w and s then -- No priority keys!
    --Nothing
    elseif w then -- Move the head up
      self.head.pBody:applyForce(0, -headStrength)
    elseif s then -- Move the head down
      self.head.pBody:applyForce(0,  headStrength)
  end
end

