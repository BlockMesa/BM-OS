kernel = {
	setDir = bios.setDir,
	getDir = bios.getDir,
	getBootedDrive = bios.getBootedDrive,
	fixColorScheme = bios.fixColorScheme,
	resolvePath = bios.resolvePath,
}
function kernel.isProgramInPath(path,progName)
	if fs.exists(path..progName) then
		return path..progName
	elseif fs.exists(path..progName..".lua") then
		return path..progName..".lua"
	else
		return false
	end
end
_G.kernel = kernel
bios.fixColorScheme()
os.run({require=bios.require},bios.getBootedDrive().."bin/sh.lua")