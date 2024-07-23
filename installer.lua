local makeJson = textutils.serializeJSON
local makeTable = textutils.unserializeJSON

local a = http.get('https://windclan.neocities.org/blockmesa/meta.json')
local json = a.readAll():gsub("%G","")
local c = textutils.unserializeJSON(json)
local b = c.packages.base

a.close()
print("Installing BM-OS")
fs.makeDir("/home")
fs.makeDir("/bin")
fs.makeDir("/sbin")
fs.makeDir("/etc")
fs.makeDir("/usr")
fs.makeDir("/lib")
fs.makeDir("/usr/bin")
fs.makeDir("/usr/lib")
fs.makeDir("/usr/bin")
fs.makeDir("/usr/etc")

local meta = {
    updated = "",
    installed = {
        base = {
            packageId = "base",
            version = b.version,
			requires = b.requires
        },
    },
	conflicts = {},
	provided = {}
}

local function installFile(file,url)
    local result, reason = http.get({url = url, binary = true}) --make names better
    if not result then
        print(("Failed to update %s from %s (%s)"):format(file, url, reason)) --include more detail
        return
    end
    a1 = fs.open(file,"wb")
    a1.write(result.readAll())
    a1.close()
    result.close()
end
for i,v in pairs(b.requires) do
	print("Installing package "..v)
	local files = {}
	for i,v1 in pairs(c.packages[v].files) do
		local url = v1
		local file = ""
		if type(i) == "string" then
			file = i
		else
			file = v1
		end
		table.insert(files,file)
		installFile(file,c.packages[v].assetBase..url)
	end
	meta.installed[v] = {
        packageId = v,
        version = c.packages[v].version,
		requires = c.packages[v].requires,
		files = files
    }
	meta.conflicts[v] = c.packages[v].conflicts or {}
	meta.provided[v] = {v}
	if c.packages[v].provides then
		for _,v1 in pairs(c.packages[v].provides) do
			table.insert(provided[v],v1)
		end
	end
end

local file = fs.open("/etc/packages.d/packages.json","w")
file.write(makeJson(meta))
file.close()

local file = fs.open("/etc/hostname", "w")
print("Please enter a hostname")
term.write("hostname: ")
local a = io.read()
if not a or a == "" then
	a = "computer"
end
file.write(a)
file.close()

print("Installation complete!")
os.reboot()
