local hostname = "bm"
local rootColor = colors.red
local userColor = colors.green
local isRoot = false
local userAccount = "user"
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
	end,
	currentUserColor = function()
		return isRoot and rootColor or userColor
	end,
	currentUser = function()
		return userAccount
	end,
	sudo = function(env,program,...)
		--in the future this will let programs access protected files mode
		--in the meantime file protection is off
	end,
	login = function(name, password)
		-- passwords arent made yet
		-- so we just login without any thought, and return true since it probably did it successfully
		userAccount = name
		return true
}
local protectDir
function protectDir(dir)
	for i,v in pairs(fs.list(dir)) do
		if fs.isDir(dir..v) then
			protectDir(dir..v.."/")
		end
		bios.protect(bios.resolvePath(dir..v))
	end
end
_G.kernel = kernel
bios.fixColorScheme()
if not fs.exists("/etc") then
	fs.makeDir("/etc")
end
if not fs.exists("/usr") then
	fs.makeDir("/usr")
end
if not fs.exists("/lib") then
	fs.makeDir("/lib")
end

if not fs.exists("/usr/bin") then
	fs.makeDir("/usr/bin")
end
if not fs.exists("/usr/lib") then
	fs.makeDir("/usr/lib")
end
if not fs.exists("/usr/bin") then
	fs.makeDir("/usr/bin")
end
if not fs.exists("/usr/etc") then
	fs.makeDir("/usr/etc")
end
protectDir("/bin/")
protectDir("/sbin/")
protectDir("/usr/")
protectDir("/lib/")
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
_G.rednet = setmetatable({},{
	__metatable = {},
	__index = function(...)
		printError("Rednet is unsupported")
		return function(...) end
	end,
})
local file = fs.open("/etc/hostname", "r")
hostname = file.readAll()
file.close()
os.run({},"/bin/sh.lua")
