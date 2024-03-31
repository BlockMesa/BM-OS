local a = http.get('https://notbronwyn.neocities.org/blockmesa/meta.json')
local c = textutils.unserializeJSON(a.readAll())
local b = c.packages.base
local b1 = c.packages.kernel
local b2 = c.packages.bootloader
a.close()
local baseUrl = b.assetBase
local baseUrl1 = b1.assetBase
local baseUrl2 = b2.assetBase
print("BM-UNIX WILL NOW BE INSTALLED.")
fs.makeDir("/home")
fs.makeDir("/bin")
fs.makeDir("/sbin")

for i,v in pairs(b1.files) do
    shell.run("wget "..baseUrl1..v.." "..v)
end
for i,v in pairs(b2.files) do
    shell.run("wget "..baseUrl2..v.." "..v)
end
for i,v in pairs(b.files) do
    shell.run("wget "..baseUrl..v.." "..v)
end
shell.run("wget "..c.packages.bios.assetBase.."/bios.lua startup.lua")
print("Installation complete!")
os.reboot()