local a = http.get('https://notbronwyn.neocities.org/blockmesa/meta.json')
local c = textutils.unserializeJSON(a.readAll())
local b = c.packages.base
local b1 = c.packages.kernel
local b2 = c.packages.bootloader
local b3 = c.packages.shell
local b4 = c.packages.package

a.close()
local baseUrl = b.assetBase
local baseUrl1 = b1.assetBase
local baseUrl2 = b2.assetBase
local baseUrl3 = b3.assetBase
local baseUrl4 = b4.assetBase
print("BM-OS WILL NOW BE INSTALLED.")
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

local function installFile(url,file)
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
print("Installing kernel")
for i,v in pairs(b1.files) do
    installFile(baseUrl1..v,v)
end
print("Installing bootloader")
for i,v in pairs(b2.files) do
    installFile(baseUrl2..v,v)
end
print("Installing shell")
for i,v in pairs(b3.files) do
    installFile(baseUrl3..v,v)
end
print("Installing package manager")
for i,v in pairs(b4.files) do
    installFile(baseUrl4..v,v)
end
print("Installing base commands")
for i,v in pairs(b.files) do
    installFile(baseUrl..v,v)
end
installFile(c.packages.bios.assetBase.."bios.lua","startup.lua")
print("Installation complete!")
os.reboot()