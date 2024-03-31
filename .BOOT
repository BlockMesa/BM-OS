
--bios.protect("/.boot")
--bios.protect(bios.getBootedDrive()..".boot")
term.clear()
term.setCursorPos(1,1)
term.write("Starting BM-UNIX...")
term.setCursorPos(1,3)
if not fs.find(bios.getBootedDrive()) then
	print("ERROR LOADING BOOT DEVICE!") --how does this happen
	while true do os.sleep() end
end
local success, response = pcall(os.run,{bios=bios},bios.getBootedDrive().."sh")
if not success then
	while true 
		do os.sleep() 
	end
end
