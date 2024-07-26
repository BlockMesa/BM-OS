local sha256 = dofile("/lib/sha256.lua")
local success = false

print("Login on device "..os.hostname())
local attempts = 0
while not success do
	if attempts > 0 then
		printError("Incorrect username or password")
		print("")
	end
	if attempts > 3 then
		printError("Too many login attempts")
		sleep(1)
		os.shutdown()
	end
	term.write("Username:")
	local user = read()
	term.write("Password:")
	local password = read("*")
	success = user.login(user, sha256(password))
	attempts = attempts + 1
end
os.run({},"/bin/sh.lua")
