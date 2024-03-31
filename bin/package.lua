local makeJson = textutils.serializeJSON
local makeTable = textutils.unserializeJSON

if not arg[1] then
    print("Usage: package [update or install]")
end
--verify the files exist
if not fs.exists("/etc/packages.d/") then
    fs.makeDir("/etc/packages.d/")
end
if not fs.exists("/etc/packages.d/packages.json") then
    local file = fs.open("/etc/packages.d/packages.json","w")
    file.write(makeJson({
        updated = "",
        installed = {
            bios = {
                packageId = "bios",
                version = ""
            },
            base = {
                packageId = "base",
                version = ""
            },
            kernel = {
                packageId = "kernel",
                version = ""
            },
            bootloader = {
                packageId = "bootloader",
                version = ""
            },
            shell = {
                packageId = "shell",
                version = ""
            },
            package = {
                packageId = "package",
                version = ""
            }
        }
    }))
    file.close()
end
if not fs.exists("/etc/packages.d/mirror.json") then
    local file = fs.open("/etc/packages.d/mirror.json","w")
    file.write(makeJson({
        lastupdated = "1970-01-01 12:00 AM",
        packages = {}
    }))
    file.close()
end
local file = fs.open("/etc/packages.d/mirror.json","r")
local packageList = makeTable(file.readAll())
file.close()
local file = fs.open("/etc/packages.d/packages.json","r")
local meta = makeTable(file.readAll())
file.close()
local updated = meta.updated
local installed = meta.installed

local metadata = 'https://notbronwyn.neocities.org/blockmesa/meta.json'
local function updatePackage(pack)
    local info = installed[pack]
    if info then
        if packageList.packages[pack].version ~= info.version then
            local baseUrl = packageList.packages[pack].assetBase
            print("Updating package "..pack)
            for i,v in pairs(packageList.packages[pack].files) do
                local url = v
                local file = ""
                if type(i) == "string" then
                    file = i
                else
                    file = v
                end
                kernel.updateFile(file,baseUrl..url)
            end
            info.version = packageList.packages[pack].version
        else
            print("No update needed!")
        end
    else
        printError("Package not installed")
        return
    end
end
local function installPackage(pack)
    local info = installed[pack]
    if info then
        print("Package already installed!")
        print("Did you mean: package update?")
    else
        if packageList.packages[pack] then
            local baseUrl = packageList.packages[pack].assetBase
            print("Installing package "..pack)
            for i,v in pairs(packageList.packages[pack].files) do
                local url = v
                local file = ""
                if type(i) == "string" then
                    file = i
                else
                    file = v
                end
                kernel.updateFile(file,baseUrl..url)
            end
            meta.installed[pack] = {
                packageId = pack,
                version = packageList.packages[pack].version
            }
        else   
            print("Invalid package")
        end
    end
end
print("Updating package list...")
local http, response = http.get(metadata)
if not http then
    print(response)
    return
end
packageList = makeTable(http.readAll())
http.close()
if arg[1] == "update" then
    for i,v in pairs(installed) do
        updatePackage(i)
    end
elseif arg[1] == "install" then
    if not arg[2] then
        print("Usage: package install [name]")
        return
    end
    installPackage(arg[2])
end
local file = fs.open("/etc/packages.d/mirror.json","w")
file.write(makeJson(packageList))
file.close()

local file = fs.open("/etc/packages.d/packages.json","w")
file.write(makeJson(meta))
file.close()