util = {}

-- Not used
function clamp(val, lower, upper)
    assert(val  , "val not defined")
    assert(lower, "lower not defined")
    assert(upper, "upper not defined")
    
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function drawCircle(object)
    love.graphics.circle("fill", object.pBody:getX(), object.pBody:getY(), object.shape:getRadius())
end

function drawConnection(object1, object2)
  love.graphics.line(object1.pBody:getX(), object1.pBody:getY(), object2.pBody:getX(), object2.pBody:getY())
end

function util.newDistanceJoint(pBody1, pBody2, collide)
  love.physics.newDistanceJoint( pBody1, pBody2, pBody1:getX(), pBody1:getY(), pBody2:getX(), pBody2:getY(), collide or false )
end

function util.makeRect() -- This will help me draw and see rectangles for physics
  
end

-- Returns the distance between two points.
function util.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
-- Returns the angle between two points.
function util.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

-- Need a better name
-- Eh, lerp works better
-- But I would prefer to 'zoom' between them
-- not a contstant change but with asymptotes on either side
function util.rectify(x)
  if x > 0 then
    return x
  elseif x < 0 then
    return -1/x
  else
    print("Rectify can't deal with zeros")
    crash() -- Funny, but I don't know how you're supposed to print a stack trace
  end
end

-- Linear interpolation between two numbers.
function util.lerp(a,b,t) return (1-t)*a + t*b end
function util.lerp2(a,b,t) return a+(b-a)*t end

return util