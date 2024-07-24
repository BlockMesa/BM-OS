term.clear()
term.setCursorPos(1,1)
print(" ____  _  _         __   ____ ")
print("(  _ \\( \\/ ) ___   /  \\ / ___)")
print(" ) _ (/ \\/ \\(___) (  O )\\___ \\")
print("(____/\\_)(_/       \\__/ (____/")
print("Bootloader v3")
print("")
local parentDir = debug.getinfo(1).source:match("@?(.*/)") --https://stackoverflow.com/a/35072122 (getting current file location)
local success, response = pcall(os.run,{_BOOTDRIVE="/"},parentDir.."kernel.lua")
if not success then
	printError(response)
	while true do
		os.sleep() 
	end
end