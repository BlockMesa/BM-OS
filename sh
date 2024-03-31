local version = "0.01"
local versionString = "BM-UNIX version "..version
term.clear()
term.setCursorPos(1,1)
term.write(versionString)
term.setCursorPos(1,3)
_G.os.version = function() return versionString end
interpret = function(command)
		if command:sub(1, 4) == "echo" then print(command:sub(5))
  		else shell.run(command) end
end
while true do
	term.setCursorBlink(true)
	term.setTextColor(colors.white)
	term.write("there_is_no_user_yet@cc:/>")
	local command = read()
	local success, err = pcall(interpret,command)
	if not success then
		--print(err)
		print("Illegal command: "..command..".")
	end
end
