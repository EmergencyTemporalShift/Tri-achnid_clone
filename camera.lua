if not util then
    util = require 'util'
end

camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.bounds = {}

love.graphics.origin()


function camera.set (self)
	love.graphics.push ()
	love.graphics.rotate (-self.rotation)
	love.graphics.scale (1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate (-self.x, -self.y)
end

function camera:unset ()
	love.graphics.pop ()
end

function camera:move (dx, dy)
	self.x = self.x + (dx or 0)
	self.y = self.y + (dy or 0)
end

function camera:rotate (dr)
	self.rotation = self.rotation + dr
end

function camera:scale (sx, sy)
	self.scaleX = self.scaleX * (sx or 1)
	self.scaleY = self.scaleY * (sy or 1)
end

function camera:getX ()
    return self.x
end

function camera:getY ()
    return self.y
end

function camera:setX (value)
	if (self.bounds) then
		self.x = util.clamp (value, self.bounds.x1, self.bounds.x2)
	else
		self.x = value
	end
end

function camera:setY (value)
	if (self.bounds) then
		self.y = util.clamp (value, self.bounds.y1, self.bounds.y2)
	else
		self.y = value
	end
end

function camera:setPosition(x, y)
	if (x) then
		self:setX(x)
	end
	
	if (y) then
		self:setY(y)
	end
end

function camera:setScale (sx, sy)
	self.scaleX = (sx or self.scaleX)
	self.scaleY = (sy or self.scaleY)
end

function camera:setBounds (x1, y1, x2, y2)
	self.bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

function camera:getBounds ()
	return unpack (self.bounds)
end

function camera:getMouseX ()
	return love.mouse.getX () * self.scaleX + self.x
end

function camera:getMouseY ()
	return love.mouse.getY () * self.scaleY + self.y
end

return camera
