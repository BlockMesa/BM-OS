local files = {
    --BIN
    "bin/sh.lua",
    "bin/cat.lua",
    "bin/cd.lua",
    "bin/ls.lua",
    "bin/mkdir.lua",
    "bin/shutdown.lua",
    "bin/package.lua",

    --SBIN
    "sbin/kernel.lua"
}
local baseUrl = "https://raw.githubusercontent.com/BlockMesa/BM-UNIX/main/"
print("BM-UNIX WILL NOW BE INSTALLED.")
fs.makeDir("/home")
fs.makeDir("/bin")
fs.makeDir("/sbin")

for i,v in pairs(files) do
    shell.run("wget "..baseUrl..v.." "..v)
end
shell.run("wget https://raw.githubusercontent.com/BlockMesa/BM-BIOS/main/bios.lua startup.lua")
print("Installation complete!")
