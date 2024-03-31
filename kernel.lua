kernel = {}
function kernel.interpret(command)
		if command:sub(1, 5) == "echo " then print(command:sub(6)) end
		if command:sub(1, 7) == "runlua " then load("return "..command:sub(8))() end
  		_G.os.pullEvent = os.pullEventOld
  		if fs.exists(command) then pcall(os.run,_G,program) end
		_G.os.pullEvent = os.pullEventRaw
end
return kernel
