-- Autostart



local entries = {
	"nitrogen --restore",
	"dropbox",
	"steam",
	"pidgin"
}

local autostart = {}
local awful = require("awful")
function autostart.init()
	for _,v in pairs(entries) do
		--if(v.shell ~= nil or v.shell ~= false)
			--awful.util.spawn_with_shell(v.exec)
		awful.util.spawn(v)
	end
end

return autostart