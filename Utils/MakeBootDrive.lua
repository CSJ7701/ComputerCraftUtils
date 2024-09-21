-- This script is designed to download my custom "ISO" and write it to a ComputerCraft drive.
-- This will only work if you have a ComputerCraft computer connected to a drive with a floppy disk.
-- This will overwrite EVERYTHING on the floppy disk, and turn it into installation media for my own OS.local json = require("json")

local v = require("cc.expect")

local ghApiBase = "https://api.github.com/repos/"
local coreRepo = "CSJ7701/ComputerCraftUtils"
local ref = "main"
local bootloaderApiUrl = ghApiBase .. coreRepo .. "/contents/Bootloader?ref=" .. ref

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


-- Recursive function to fetch and download directory contents
local function fetchAndDownloadDirectory(apiUrl, localPath)
    local r = http.get(apiUrl)
    if r == nil then
        error("Failed to fetch directory contents from GitHub API: " .. apiUrl)
    end
    
    local body = r.readAll()
    r.close()

    -- Extract entries and download files or recurse for directories
    for itemType, downloadUrl, itemName in string.gmatch(body, '"type":%s-"(.-)".-"download_url":%s-"(.-)".-"name":%s-"(.-)"') do
        local fullLocalPath = fs.combine(localPath, itemName)
        
        if itemType == "file" then
            -- Download the file
            download(downloadUrl, fullLocalPath)
        elseif itemType == "dir" then
            -- Create the directory locally and recurse into it
            if not fs.exists(fullLocalPath) then
                fs.makeDir(fullLocalPath)
            end
            -- Construct the API URL for the directory and fetch its contents
            local dirApiUrl = apiUrl:gsub("Bootloader", "Bootloader/" .. itemName)
            fetchAndDownloadDirectory(dirApiUrl, fullLocalPath)
        end
    end
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
	 local fullPath = fs.combine(path, file)
	 fs.delete(fullPath)
      end
   end
   print("[Success] -- Disk wiped")
   return 1
end


-- Modify main function to use fetched files
local function main()
    local basePath = "/disk/Bootdrive/"
    local files = fetchDirectoryContents()

    for _, fileUrl in ipairs(files) do
        -- Extract file name from URL (the last part of the URL path)
        local fileName = fileUrl:match("^.+/(.+)$")
        download(fileUrl, basePath .. fileName)
    end
end

if clearDisk() == 1 then
    print("[LOG] -- Attempting Download")
    main()
else
    print("[LOG] -- Download aborted, /disk could not be cleared.")
end
