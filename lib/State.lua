local State = Class()

local callback_functions = {
	"audiodisconnected", "directorydropped", "draw", "dropbegan",
	"dropcompleted", "dropmoved", "exposed", "filedropped", "focus",
	"gamepadaxis", "gamepadpressed", "gamepadreleased", "joystickadded",
	"joystickpressed", "joystickreleased", "joystickremoved", "joysticksensorupdated",
	"keypressed", "keyreleased", "load", "localechanged", "lowmemory",
	"mousefocus", "mousemoved", "mousepressed", "mousereleased", "occluded",
	"quit", "resize", "sensorupdated", "textedited", "textinput",
	"touchmoved", "touchpressed", "touchreleased", "update", "visible", "wheelmoved"
}

for _, callback in pairs( callback_functions ) do
	State[ callback ] = function( self )
		if self.loaded_state then
			if self.loaded_state[ callback ] then
				self.loaded_state[ callback ]( self.loaded_state )
			end
		end
	end
end

State.loaded_state = false

function State:load( state )
	self.loaded_state = state()
end

return State()
