local makeJson = textutils.serializeJSON
local makeTable = textutils.unserializeJSON

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

local metadata = 'https://restructsblog.neocities.org/devmeta.json'
local function updatePackage(pack)
    local info = installed[pack]
    if info then
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
        info.version = "unstable"
        return true
    else
        printError("Package not installed")
        return false
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
local hasUpdated = false
for i,v in pairs(installed) do
    local a = updatePackage(i)
    if a then
        hasUpdated = true
    end
end
