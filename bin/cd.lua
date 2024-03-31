if not arg[1] then
    print("Usage: cd <directory>")
    return
end
local newDir = kernel.resolvePath(kernel.getDir()..arg[1])
if newDir ~= "/" then
    newDir = newDir.."/"
end
kernel.setDir(newDir)