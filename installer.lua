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

for i,v in pairs(b1.files) do
    shell.run("wget "..baseUrl1..v.." "..v)
end
for i,v in pairs(b2.files) do
    shell.run("wget "..baseUrl2..v.." "..v)
end
for i,v in pairs(b3.files) do
    shell.run("wget "..baseUrl3..v.." "..v)
end
for i,v in pairs(b4.files) do
    shell.run("wget "..baseUrl4..v.." "..v)
end
for i,v in pairs(b.files) do
    shell.run("wget "..baseUrl..v.." "..v)
end
shell.run("wget "..c.packages.bios.assetBase.."/bios.lua startup.lua")
print("Installation complete!")
os.reboot()