-- A collection of handy math functions

local random = love.math.random
local Math = {}

--:: General stuff ::--
function Math.normal(val, min, max)
	return (val - min) / (max - min)
end

function Math.map(val, min, max)
	return (max - min) * val + min
end

function Math.lerp(a, b, t)
	return a + (b - a) * t
end

function Math.clamp(val, min, max)
	return math.max(min, math.min(val, max))
end

function Math.distance(x1, y1, x2, y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function Math.angle(x1, y1, x2, y2)
	return math.atan2(y2-y1, x2-x1)
end

-- math.sin() shoved into the range of 0-1
function Math.psin(v)
    return (sin(v) + 1) / 2 
end

--:: Intersections ::--
function Math.pointInRect(px, py, rx, ry, rw, rh)
	return px > rx and px < rx + rw and py > ry and py < ry + rh
end

function Math.rectIntersect(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end

--:: Random ::--
function Math.randomBool()
	return math.random() < 0.5
end

function Math.rsign()
	return random(2) == 2 and 1 or -1
end

return Math
