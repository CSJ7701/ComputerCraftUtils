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
shell.run("eject")


