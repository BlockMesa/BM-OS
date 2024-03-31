local version = "0.01"
local versionString = "BM-UNIX version "..version
term.clear()
term.setCursorPos(1,1)
term.write(versionString)
term.setCursorPos(1,3)
_G.os.version = function() return versionString end
function interpret(command)
		if command:sub(1, 5) == "echo " then print(command:sub(6)) end
		if command:sub(1, 7) == "runlua " then load("return "..command:sub(8))() end
  		_G.os.pullEvent = os.pullEventOld
  		if fs.exists(command) then pcall(os.run,_G,program) end
		_G.os.pullEvent = os.pullEventRaw
end
while true do
	term.setCursorBlink(true)
	term.setTextColor(colors.red)
 	term.write("root")
	term.setTextColor(colors.white)
 	term.write("@cc")
	term.setTextColour(colours.green)
	term.write(" ~ >")
 	term.setTextColor(colors.white)
  	term.write("") -- beloved hack
	local command = read()
	local success, err = pcall(interpret,command)
	if not success then
		print(err)
	end
end
