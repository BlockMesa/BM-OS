local args = {...}
local argsStr = ""
local quietBoot = false
for i,v in pairs(args) do
	if i ~= 1 then
		argsStr = argsStr.." "
	end
	argsStr = argsStr..v
	if v == "quiet" then
		quietBoot = true
	end
end
print("Generic kernel version 0.2")
print("Command line: "..argsStr)
local hostname = ""
local rootColor = colors.red
local userColor = colors.green
local isRoot = false
local userAccount = ""
---prevent tampering
local oldGlobal = _G
local oldset = rawset

local newGlobal = setmetatable({},{
	__index = oldGlobal,
	__newindex = function(table, index, value)
		return
	end,
	__metatable = {}
})
_G = newGlobal
--------------------
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
		elseif fs.exists(path..progName..".why") then
			return path..progName..".why"
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
		return userAccount or "root"
	end,
	sudo = function(env,program,...)
		--in the future this will let programs access protected files mode
		--in the meantime file protection is off
	end,
	login = function(name, password)
		-- passwords arent made yet
		-- so we just login without any thought, and return true since it probably did it successfully
		if not fs.exists("/home/"..name) then
			fs.makeDir("/home/"..name)
		end
    		if (name:match("^[a-zA-Z0-9_]+$")) then
        		userAccount = name
		end
		isRoot = (userAccount == "root")
		return (name:match("^[a-zA-Z0-9_]+$"))
	end,
	home = function()
		return "/home/"..userAccount.."/"
	end,
	debug = function(...)
		if not quietBoot then
			print(...)
		end
	end
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

oldGlobal.kernel = kernel
function oldGlobal.rawset(tab,...)
	if tab ~= _G then
		return oldset(tab,...)
	end
end
local oldRun = os.run
function oldGlobal.os.run(env,file,...)
	--resolving this here since its required for files to work
	local a = fs.open(file,"r")
	if a then
		local firstLine = a.readLine(false)
		a.close()
		if firstLine:sub(1,2) == "#!" then
			local interpreter = firstLine:sub(3)
			if kernel.isProgramInPath("",interpreter) then
				interpreter = kernel.isProgramInPath("",interpreter)
			end
			oldRun(env,interpreter,file,...)
		else
			oldRun(env,file,...)
		end
	else
		print(file)
	end
end

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
oldGlobal.rednet = setmetatable({},{
	__metatable = {},
	__index = function(...)
		printError("Rednet is unsupported")
		return function(...) end
	end,
})
local file = fs.open("/etc/hostname", "r")
hostname = file.readAll()
file.close()
os.run({},kernel.isProgramInPath("/sbin/","init"))
