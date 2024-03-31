
bios.fixColorScheme()
bios.protect("/.boot")
term.clear()
term.setCursorPos(1,1)
term.write("BM-OS BOOTLOADER")
term.setCursorPos(1,3)
if not fs.find(bios.getBootedDrive()) then
	print("ERROR LOADING BOOT DEVICE!") --how does this happen
	while true do os.sleep() end
end
local success, response = pcall(os.run,_ENV,"/sbin/kernel.lua")
if not success then
	while true 
		do os.sleep() 
	end
end
