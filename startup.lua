local oldErr = printError
local oldPull = os.pullEvent
local oldPullRaw = os.pullEventRaw
_G.os.pullEventOld = oldPull
_G.os.pullEvent = os.pullEventRaw
local function boot()
	os.run({},"/boot/loader.lua")
end
local function overwrite()
    _G.printError = oldErr
    _G.os.pullEvent = oldPullRaw
    _G['rednet'] = nil
	local success, err = pcall(boot)
	if not success then
		printError(err)
		print("Press any key to continue.")
		os.pullEvent("key")
	end
end
term.clear()
term.setCursorPos(1,1)
_G.printError = overwrite
_G.os.pullEvent = nil