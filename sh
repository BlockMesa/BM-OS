local version = "x.xx"
local versionString = "BM-UNIX version "..version
term.clear()
term.setCursorPos(1,1)
term.write(versionString)
term.setCursorPos(1,3)

--modify the env
local oldSettingsGet = bios.settingsGet
local oldSettingsSet = bios.settingsSet
_G.os.version = function() return versionString end
while true do
	term.setCursorBlink(true)
	term.setTextColor(colors.white)
	term.write("there_is_no_user_yet@cc:/>")
	local command = read()
	local success, err = pcall(print,command)
	if not success then
		--print(err)
		print("Illegal command: "..command..".")
	end
end
