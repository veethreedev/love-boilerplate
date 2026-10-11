local Camera = Class()

function Camera:init()
	self.position = Vector()
	self.scale = 1
end

function Camera:getMouse()
    local mx, my = love.mouse.getPosition()    
    return self.position.x + mx / self.scale, self.position.y + my / self.scale
end

function Camera:look( x, y )
	local offset_x = lg.getWidth() / 2
	local offset_y = lg.getHeight() / 2
	self.position:set( x - offset_x, y - offset_y )
end

function Camera:move( x, y )
	self.position:set( x, y )
end

-- Zooms so the world point x, y stays at the same spot on screen
function Camera:zoom( x, y, z )
	local ratio = self.scale / z
	self.position:set(
		x - ( x - self.position.x ) * ratio,
		y - ( y - self.position.y ) * ratio
	)
	self.scale = z
end

function Camera:push()
	lg.push()
	lg.scale( self.scale, self.scale )
	lg.translate( -self.position.x, -self.position.y )
end

function Camera:pop() lg.pop() end

return Camera
