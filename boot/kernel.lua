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

-- by default everything is root, not great but unless we make FS protection it doesn't matter
-- since this is CC we don't really need to make user protection and don't need to figure out multi user at this moment
-- we may in the future but you can't really run things in the background so eh
local isRoot = true
local userAccount = "root" 

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

-- this figures out where the hell we are
local parentDir = debug.getinfo(1).source:match("@?(.*/)") --https://stackoverflow.com/a/35072122 (getting current file location)
-- basically we need to be able to make portable disks for a possible future installer
-- the current init system won't support that since its meant for specialized applications
-- not generic desktop usage since that would never be used

function resolvePath(path)
	local matches = {}
	for i in path:gmatch("[^/]+") do
		table.insert(matches,i)
	end
	local result1 = {}
	local lastIndex = 1
	for i,v in pairs(matches) do
		if v ~= "." then
			if v== ".." then
				result1[lastIndex] = nil
				lastIndex = lastIndex-1
			else
				lastIndex = lastIndex + 1
				result1[lastIndex] = v
			end
		end
	end
	local result = {}
	for i,v in pairs(result1) do
		table.insert(result,v)
	end
	local final = "/"
	for i,v in pairs(result) do
		if i ~= 1 then
			final = final .. "/"
		end
		final = final..v
	end
	return final
end
local accounts = { -- not final, just for now
	root = "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", --password, literally
}
local directory = "/"
kernel = {
	setDir = function(dir)
		directory = dir
	end,
	getDir = function()
		return directory
	end,
	getBootedDrive = function()
		local drive = resolvePath(parentDir.."..").."/"
		if drive == "//" then
			drive = "/"
		end
		return drive
	end,
	fixColorScheme = function()
		for i=0,15 do
			local color = 2^i
			term.setPaletteColor(color,term.nativePaletteColor(color))
		end
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
	end,
	resolvePath = resolvePath,
	updateFile = function(file,url)
		local result, reason = http.get({url = url, binary = true}) --make names better
		if not result then
			print(("Failed to update %s from %s (%s)"):format(file, url, reason)) --include more detail
			return
		end
		local a1 = fs.open(file,"wb")
		a1.write(result.readAll())
		a1.close()
		result.close()
	end,
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
		-- i don't want to have to deal with the kernel needing an SHA256 library
		-- the login system handles hashing it (i dont want to)
		if accounts[name] and accounts[name] == password then
			if not fs.exists("/home/"..name) then
				fs.makeDir("/home/"..name)
			end
			if (name:match("^[a-zA-Z0-9_]+$")) then
				userAccount = name
			else
				return false
			end
			isRoot = (userAccount == "root")
			return true
		else
			return false
		end
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

local function makeDir(dir)
	if not fs.exists(kernel.getBootedDrive()..dir) then
		fs.makeDir(kernel.getBootedDrive()..dir)
	end
end

kernel.fixColorScheme()
makeDir("/etc")
makeDir("/usr")
makeDir("/lib")
makeDir("/usr/bin")
makeDir("/usr/lib")
makeDir("/usr/bin")
makeDir("/usr/etc")
if not fs.exists(kernel.getBootedDrive().."/etc/hostname") then
	print("Host name not set!")
	term.write("Please enter a hostname: ")
	local file = fs.open(kernel.getBootedDrive().."/etc/hostname","w")
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
local file = fs.open(kernel.getBootedDrive().."/etc/hostname", "r")
hostname = file.readAll()
file.close()
os.run({},kernel.isProgramInPath(kernel.getBootedDrive().."sbin/","init"))
