--> Globals
NAME               = "Untitled"
VERSION            = 1
VERSION_STRING     = "v1.0"
CONFIG             = false
CONFIG_OBJECT      = false
CONFIG_FILENAME    = "config.ini"
DEVELOPER_MODE     = true
IGNORE_CONFIG_FILE = true


--> Shorthands
lg     = love.graphics
fs     = love.filesystem
kb     = love.keyboard
lm     = love.mouse
lp     = love.physics
random = love.math.random
noise  = love.math.noise
sin    = math.sin
cos    = math.cos
floor  = math.floor
ceil   = math.floor
f      = string.format
insert = table.insert
remove = table.remove
concat = table.concat


function love.load()
	--> Loading libs
	Class = require "lib.Class"
	Util  = require "lib.Util"
	Util.requireDirectory( "lib" )

	--> Loading config
	initialize_conifg()

	if not IGNORE_CONFIG_FILE then
		if fs.getInfo( CONFIG_FILENAME ) then
			CONFIG_OBJECT:load( CONFIG_FILENAME )	
			CONFIG = CONFIG_OBJECT:getTable()
		end
	end

	--> Creating window
	love.window.setMode( CONFIG.window.width, CONFIG.window.height, { 
		fullscreen = CONFIG.window.fullscreen,
		resizable = CONFIG.window.resizable
	})
	love.window.setTitle( CONFIG.window.title )

end

function initialize_conifg()
	CONFIG_OBJECT = ini()
	:section( "window" )
	:property( "title", NAME .. " - " .. VERSION_STRING)
	:property( "width", 1280 )
	:property( "height", 720 )
	:property( "fullscreen", false )
	:property( "resizable", true )
	

	CONFIG = CONFIG_OBJECT:getTable()
end

function save_config()
	
end

function love.update( dt )

end

function love.draw()

end

function love.resize( width, height )
	CONFIG.window.width, CONFIG.window.height = width, height
end

function love.mousepressed( x, y, b )

end

function love.mousereleased( x, y, b )

end

function love.keypressed( key )
	if DEVELOPER_MODE and key == "escape" then
		love.event.push( "quit" )
	end
end

function love.keyreleased( key )

end

function love.quit()
	CONFIG_OBJECT:save( CONFIG_FILENAME )
end
