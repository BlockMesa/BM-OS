local oldErr = printError
local oldPull = os.pullEvent
local oldPullRaw = os.pullEventRaw
_G.os.pullEventOld = oldPull
_G.os.pullEvent = os.pullEventRaw
local function boot()
	term.clear()
	term.setCursorPos(1,1)
	print(" ____  _  _         __   ____ ")
	print("(  _ \\( \\/ ) ___   /  \\ / ___)")
	print(" ) _ (/ \\/ \\(___) (  O )\\___ \\")
	print("(____/\\_)(_/       \\__/ (____/")
	print("Bootloader v3")
	print("")
	local success, response = pcall(os.run,{_BOOTDRIVE="/"},"/sbin/kernel.lua")
	if not success then
		while true do
			os.sleep() 
		end
	end
end
local function overwrite()
    _G.printError = oldErr
    _G.os.pullEvent = oldPullRaw
    _G['rednet'] = nil
	local success, err = pcall(boot)
	if not success then
		print(err)
		print("Press any key to continue.")
		os.pullEvent("key")
	end
end
term.clear()
term.setCursorPos(1,1)
_G.printError = overwrite
_G.os.pullEvent = nil