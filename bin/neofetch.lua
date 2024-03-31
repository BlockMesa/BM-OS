-- this is for hte packaage manager
local leftpadsize = 16-7
local function leftpad(text, amt)
  local currentpos_x, currentpos_y = term.getCursorPos()
  local a_currentpos_x = currentpos_x + amt
  term.setCursorPos(a_currentpos_x, currentpos_y)
  print(text)
  term.setCursorPos(currentpos_x, currentpos_y+1)
end

local function printSeparator(char)
  leftpad(string.rep(char, #("root@".._G.kernel.hostname())), leftpadsize)
end
function drawBIMG(bimg, x, y, mon)
  local frame = bimg[1]
  for k,line in pairs(frame) do
      mon.setCursorPos(x,y+k-1)
      mon.blit(line[1], line[2], line[3])
  end
  sleep(1)
end
local art_pos_x, art_pos_y = term.getCursorPos()
local bimg = {{{"\128\143\156\143\143\147\143\128","0f000ff0","f0fff00f"},{"\151\135\128\128\128\128\139\148","f0000000","0fffffff"},{"\151\128\128\128\128\128\128\148","00000007","3ffffff0"},{"\138\128\149\128\128\128\139\133","30f000f7","0f000000"},{"\138\139\133\128\128\128\128\133","0ff00000","f000000f"},{"\128\131\143\128\128\143\131\128","00000000","ff8008ff"},}}
drawBIMG(bimg, art_pos_x, art_pos_y, term)
term.setCursorPos(art_pos_x+8, art_pos_y)
--math.floor((51 - #text) / 2)
term.setTextColor(colors.red)
term.write(" root")
term.setTextColor(colors.white)
term.write("@".._G.kernel.hostname())
print(" ")
printSeparator("-")
leftpad("Operating System: " .. "BM-UNIX 0.01", leftpadsize)
leftpad("Lua Version: " .. _VERSION, leftpadsize)
local w, h = term.getSize()
leftpad("Terminal Size: " .. w .. "x" .. h, leftpadsize)
local freeMemory = fs.getCapacity("/") - fs.getFreeSpace("/")
local totalMemory = fs.getCapacity("/")
leftpad("Root Capacity: " .. freeMemory .. "KB free / " .. totalMemory .. "KB total", leftpadsize)
local uptime = os.clock()
local hours = math.floor(uptime / 3600)
local minutes = math.floor((uptime % 3600) / 60)
local seconds = math.floor(uptime % 60)
leftpad("Uptime: " .. string.format("%02d:%02d:%02d", hours, minutes, seconds), leftpadsize)
