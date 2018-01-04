  -- This is broken code that should have made the pupil spin around (after putting it off center of course)
  -- But the physics kept seperating the eye from the head
  
--  objects.player_body.eye.sclera = {}
--  objects.player_body.eye.sclera.pBody = love.physics.newBody(world, winSizeX/2, winSizeY/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
--  objects.player_body.eye.sclera.shape = love.physics.newCircleShape(headSize/2) --the ball's shape has a radius of 20
--  objects.player_body.eye.sclera.fixture = love.physics.newFixture(objects.player_body.eye.sclera.pBody, objects.player_body.eye.sclera.shape, 1) -- Attach fixture to body and give it a density of 1.
--  
--  sclera_joint = love.physics.newRopeJoint( --Disable collision maybe? I could have sworn there was a null joint or something
--    objects.player_body.head.pBody,
--    objects.player_body.eye.sclera.pBody,
--    0, 0,
--    0, 0,
--    10,
--    false )
  
--  objects.player_body.eye.pupil = {}
--  objects.player_body.eye.pupil.pBody = love.physics.newBody(world, winSizeX/2, winSizeY/2, "dynamic")
--  objects.player_body.eye.pupil.shape = love.physics.newCircleShape(headSize/3)
--  objects.player_body.eye.pupil.fixture = love.physics.newFixture(objects.player_body.eye.pupil.pBody, objects.player_body.eye.pupil.shape, 0)
  
--  pupil_head_joint = love.physics.newRopeJoint( --Disable collision maybe?
--    objects.player_body.head.pBody,
--    objects.player_body.eye.pupil.pBody,
--    0, 0,
--    0, 0,
--    10,
--    false )
--  pupil_sclera_joint = love.physics.newWeldJoint(
--    objects.player_body.eye.sclera.pBody,
--    objects.player_body.eye.pupil.pBody,
--    0,
--    0,
--    false )
    
    --How do these even work?
--    objects.player_body.eye.sclera.fixture:setMask(2)
--    objects.player_body.eye.pupil.fixture:setMask(4)
  
  
  
  
    -- Broken impulse dragging, should keep the player from dragging through walls  
--  bx, by = objects.spider_body.feet.foot1.pBody:getPosition()
--  wmx, wmy = mx * scale + ox, my * scale + oy
--  dx, dy = bx - wmx, by - wmy
--  d = math.sqrt ( dx * dx + dy * dy )
--  ndx, ndy = dx / d, dy / d
--  impulse = 3
--  ix, iy = ndx * impulse, ndy * impulse
--  objects.spider_body.feet.foot1.pBody:applyLinearImpulse ( ix, iy, bx, by )
 
  

 -- Add a mousejoint for the foot
--  mouse_joint = love.physics.newMouseJoint(objects.spider_body.feet.foot1.pBody, love.mouse.getPosition())
--  mouse_joint:setMaxForce(10)
--  mouse_joint:setDampingRatio(2)
