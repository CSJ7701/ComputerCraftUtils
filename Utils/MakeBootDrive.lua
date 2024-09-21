-- This script is designed to download my custom "ISO" and write it to a ComputerCraft drive.
-- This will only work if you have a ComputerCraft computer connected to a drive with a floppy disk.
-- This will overwrite EVERYTHING on the floppy disk, and turn it into installation media for my own OS.

local v = require("cc.expect")

local ghBase = "https://raw.githubusercontent.com/"
local coreRepo = "CSJ7701/ComputerCraftUtils"
local ref = "refs/heads/master"
local baseUrl = ghBase..coreRepo.."/"..ref


-- Makes a trial request, verifies the response code, and returns the response.
local function getAndCheck(url)
   v.expect(1, url, "string")
   url = url .. "?ts=" .. os.time(os.date("!*t"))
    local r = http.get(url)
    if r == nil then
        error(string.format("Bad HTTP Response: %s", url))
    end
    local rc, _ = r.getResponseCode()
    if rc ~= 200 then
        error(string.format("Bad HTTP code: %d", rc))
    end
    return r
end

-- Fetches file contents from url using =getAndCheck=, then writes to a file.
local function download(url, path)
    v.expect(1, url, "string")
    v.expect(2, path, "string")

    if (fs.exists(path)) then
        fs.delete(path)
    end

    local r = getAndCheck(url)
    local f = fs.open(path, 'w')
    f.write(r.readAll())
    f.close()
end

local function clearDisk()
   local path = "/disk"

   -- Check whether there is a disk connected
   if not (fs.exists(path)) then
      print("[Fatal Error] -- No disk connected.")
      return -1
   else
      local files = fs.list(path)
      -- Delete all files on disk
      for _, file in ipairs(files) do
	 local fullPath = fs.combine(Path, file)
	 fs.delete(fullPath)
      end
   end
   print("[Success] -- Disk wiped")
   return 1
end

local function main()
   local basePath = "/disk"
   download(baseUrl.."Bootdrive",basePath.."Bootdrive/")
end


if clearDisk() == 1 then
   print("[LOG] -- Attempting Download")
   main()
end
