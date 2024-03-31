local hostname = "bm"
kernel = {
	setDir = bios.setDir,
	getDir = bios.getDir,
	getBootedDrive = bios.getBootedDrive,
	fixColorScheme = bios.fixColorScheme,
	resolvePath = bios.resolvePath,
	updateFile = bios.updateFile,
	isProgramInPath = function(path,progName)
		if fs.exists(path..progName) then
			return path..progName
		elseif fs.exists(path..progName..".lua") then
			return path..progName..".lua"
		else
			return false
		end
	end,
	hostname = function()
		return hostname
	end
}
_G.kernel = kernel
bios.fixColorScheme()
if not fs.exists("etc") then
	fs.makeDir("/etc")
end
if not fs.exists("/etc/hostname") then
	print("Host name not set!")
	term.write("Please enter a hostname: ")
	local file = fs.open("/etc/hostname","w")
	while true do
		local a = read()
		if a ~= "" then
			file.write(a)
			break
		end
	end
	file.close()
end
local file = fs.open("/etc/hostname", "r")
hostname = file.readAll()
file.close()
os.run({require=bios.require},bios.getBootedDrive().."bin/sh.lua")