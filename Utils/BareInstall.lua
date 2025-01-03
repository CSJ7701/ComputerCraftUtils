--- This script is designed to perform a bare metal install of my ComputerCraft OS.
--- This is similar to 'MakeBootDrive.lua', but it does not create a boot drive, it ONLY installs the OS to the current computer.

--- This will create a new directory 'ISO', and install to that before writing to the correct locations.

local v = require("cc.expect")

local ghApiBase = "https://api.github.com/repos/"
local coreRepo = "CSJ7701/ComputerCraftUtils"
local ref = "main"
local installApiUrl = ghApiBase .. coreRepo .. "/contents/Bootdrive?ref=" .. ref

--- Makes a trial request, verifies the response code, and returns the response.
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

--- Fetches file contents from url using =getAndCheck=, then writes to a file.
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

    -- Extract the base url (everything up to and including "Bootdrive")
    local baseUrl = apiUrl:match("(.*/Bootdrive)")
    if not baseUrl then
       error("Unable to find 'Bootdrive' in the API URL: "..apiUrl)
    end

    -- Extract entries and download files or recurse for directories
    for item in body:gmatch('%b{}') do
       local itemType = item:match('"type"%s*:%s*"(%w+)"')
       local itemName = item:match('"name"%s*:%s*"([^"]+)"')
       local itemPath = item:match('"path"%s*:%s*"([^"]+)"')
       local downloadUrl = item:match('"download_url"%s*:%s*"([^"]+)"')

       if itemType and itemName and itemPath then
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
	     local relativePath = itemPath:match("Bootdrive/(.+)") or itemPath
	     local dirApiUrl = baseUrl .. "/" .. relativePath
	    print("[LOG] -- Downloading subdirectory: "..itemName)
            fetchAndDownloadDirectory(dirApiUrl, fullLocalPath)
	  end
       end
    end
end

local function clearDisk()
   local path = "/OS_INSTALL"

   -- Check whether there is a disk connected
   if not (fs.exists(path)) then
      fs.makeDir(path)
   else
      local files = fs.list(path)
      -- Delete all files on disk
      for _, file in ipairs(files) do
	 local fullPath = fs.combine(path, file)
	 fs.delete(fullPath)
      end
   end
   print("[Success] -- Install path wiped.")
   return 1
end

local function main_download()
   local basePath = "/OS_INSTALL/"

   -- Ensure base directory exists
   if not fs.exists(basePath) then
      fs.makeDir(basePath)
   end

   -- Fetch and download bootdrive directory
   fetchAndDownloadDirectory(installApiUrl, basePath)
end

local function main_install()
   if fs.exists("startup") then
      shell.run("delete","startup")
   end
   if fs.exists("os") then
      shell.run("delete","os")
   end
   if fs.exists("bin") then
      shell.run("delete","bin")
   end
   sleep(1)
   fs.copy("/disk/install/bin","/bin")
   fs.copy("/disk/install/os","/os")
   fs.copy("/disk/install/startup","/startup")

   ---clearDisk()
end

if clearDisk() == 1 then
   print("[LOG] -- Attempting Download")
   main_download()
else
   print("[LOG] -- Download aborted, /OS_INSTALL could not be cleared.")
end


