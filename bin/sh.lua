local version = "0.1"
local versionString = "BM-OS "..version
term.clear()
term.setCursorPos(1,1)
_G.os.version = function() return versionString end
--Not taken directly from BM-DOS
local function splitString(str,toMatch)
	if not toMatch then
		toMatch = "%S"
	end
	local words = {}
	for w in str:gmatch(toMatch.."+") do
		table.insert(words,w)
	end
	return words
end
local function removeFirstIndex(t)
	local newTable = {}
	for i,v in pairs(t) do
		if i ~= 1 then
			table.insert(newTable,v)
		end
	end
	return newTable
end
local romPrograms = {
	edit = "/rom/programs/edit.lua",
	pastebin = "/rom/programs/http/pastebin.lua",
	wget = "/rom/programs/http/wget.lua",
	import = "/rom/programs/import.lua",
	lua = "/rom/programs/lua.lua",

	--aliases
	dir = "/bin/ls.lua",
	mv = "/bin/move.lua",
	cp = "/bin/copy.lua",
}

local interpret
local shell
shell = { --bare minimum to get some programs to run, more functions to be added when i feel like it
	run = function(...)
		local args = {...}
		local command = ""
		for i,v in pairs(args) do
			if type(v) == "string" then
				if i ~= 1 then
					command = command.." "
				end
				command = command..v
			end
		end
		interpret(command)
	end,
	execute = function(...) return fakeApis["shell"]["run"](...) end,
	exit = function(...) return end,
	dir = kernel.getDir,
	setDir = kernel.setDir,
	path = function() return ".:/rom/programs:/rom/programs/http" end,
	setPath = function(...) return end,
	resolve = function(progName)
		local program = progName
		local name = splitString(progName,"%P")
		if kernel.isProgramInPath("/bin/",progName) then
			program = kernel.isProgramInPath("/bin/",progName)
		elseif kernel.isProgramInPath("/usr/bin/",progName) then
			program = kernel.isProgramInPath("/usr/bin/",progName)
		elseif name[2] or not fs.exists(kernel.getDir()..progName..".lua") then
			program = kernel.getDir()..progName
		else
			program = kernel.getDir()..progName..".lua"
		end
		return program
	end,
}
function interpret(command)
	if command == "" then return end
	local program = ""
	local splitcommand = splitString(command,"%S")
	local args = removeFirstIndex(splitcommand)
	local name = splitString(splitcommand[1],"%P")
	local progName = splitcommand[1]
	--removed /sbin from this as it isnt in a normal user's path
	if romPrograms[string.lower(progName)] then
		program = romPrograms[string.lower(progName)]
	elseif kernel.isProgramInPath("/bin/",progName) then
		program = kernel.isProgramInPath("/bin/",progName)
	elseif kernel.isProgramInPath("/usr/bin/",progName) then
		program = kernel.isProgramInPath("/usr/bin/",progName)
	elseif name[2] or not fs.exists(kernel.getDir()..progName..".lua") then
		program = kernel.getDir()..progName
	else
		program = kernel.getDir()..progName..".lua"
	end
	if fs.exists(program) then
		local args1 = args
		args1[0] = progName
		local fakeGlobals = {shell=shell,arg=args1,require=_ENV.require}
		_G.os.pullEvent = os.pullEventOld
		local success, response = pcall(os.run,fakeGlobals,program,table.unpack(args))
		kernel.fixColorScheme()
		_G.os.pullEvent = os.pullEventRaw
		if not success then
			print(response)
		end
	else
		print("File not found!")
	end
end
if not fs.exists("/home") then
	fs.makeDir("/home")
end
kernel.setDir("/home/")
local rootColor = colors.red
local userColor = colors.green
local isRoot = false
while true do
	term.setCursorBlink(true)
	term.setTextColor(isRoot and rootColor or userColor)
 	term.write("user") --TODO: add changeable names
	term.setTextColor(colors.white)
 	term.write("@"..kernel.hostname())
	term.setTextColour(colours.green)
	local path = kernel.getDir()
	if string.sub(path,1,6) == "/home/" then
		path = "~"..string.sub(path,6,string.len(path)-1)
	end
	term.write(" "..path.." >")
 	term.setTextColor(colors.white)
  	term.write("") -- beloved hack
	local command = read()
	local success, err = pcall(interpret,command)
	if not success then
		print(err)
	end
end
