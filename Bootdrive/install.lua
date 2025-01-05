--- Function to check and setup environment variables
local function env_setup()
   local env_defaults = {["createos.repo"] = "CSJ7701/ComputerCraftUtils", ["createos.branch"] = "main", ["createos.module_dir"] = "Modules/"}
   local env_addons = {["shell.package_path"] = "/modules/?/init.lua"}
   
   for var_name, default_value in pairs(env_defaults) do
      -- Check if the variable already has a value
      local current_value = settings.get(var_name)  -- os.getenv retrieves the environment variable value
      if not current_value or current_value == "" then
	 -- Set the variable to the default value
	 settings.set(var_name, default_value)  -- os.setenv sets the environment variable
	 print("[LOG] -- Set " .. var_name .. " to " .. default_value)
      else
	 print("[LOG] -- " .. var_name .. " is already set to " .. current_value)
      end
   end

   for var_name, var_val in pairs(env_addons) do
      local current_value = settings.get(var_name)
      if current_value or not current_value == "" then
	 settings.set(var_name, current_value .. ";" .. var_val)
      else
	 settings.set(var_name, var_val)
      end
   end
   settings.save()
end

print("Welcome to CreateOS")
print("The installer will now run...")
print("=============================")
textutils.slowPrint("Deleting existing files...")
if fs.exists("startup") then
   shell.run("delete","startup")
end
if fs.exists("os") then
   shell.run("delete","os")
end
if fs.exists("bin") then
   shell.run("delete","bin")
end
print("=============================")
sleep(1)
textutils.slowPrint("Installing new files...")
fs.copy("/disk/install/bin","/bin")
fs.copy("/disk/install/os","/os")
fs.copy("/disk/install/startup","/startup")
print("==============================")
sleep(1)
textutils.slowPrint("Setting up OS environment...")
env_setup()
fs.makeDir("/Home")
fs.makeDir("/Modules")
print("==============================")
shell.run("eject")


