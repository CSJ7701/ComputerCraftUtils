local args = {...}

rednet.open("top")

term.clear()
term.setCursorPos(1,1)
print("Send a file")
print("===========")
term.setCursorPos(1,5)
print("Computer ID: (optional)")
ID = read()
term.setCursorPos(1,8)
print("File Name: (required)")
FILE = read()

if ID == "" then
   args = {FILE}
else
   args = {ID,FILE}
end

if #args < 1 then
   print("Usage (<> Required, [] Optional:")
   print("sendfile [ComputerID] <file>")
   return
end

if #args == 1 then
   if fs.exists(args[1]) then
      textutils.slowPrint("Sending File "..args[1].."...")
      rednet.broadcast("RECEIVE")
      rednet.broadcast(args[1]) -- This assumes the same file structure on all computers?
      file = fs.open(args[1],"r")
      rednet.broadcast(file.readAll())
      file.close()
      sleep(2)
      shell.run("menu")
   else
      print(args[1].." does not exist")
      sleep(5)
      shell.run("menu")
   end
else
   if fs.exists(args[2]) then
      textutils.slowPrint("Sending file "..args[2].." to "..args[1])
      F = fs.open(args[2], "r")
      id = tonumber(args[1])
      rednet.send(id, "RECEIVE")
      rednet.send(id, args[2])
      rednet.send(id, F.readAll())
      F.close()
      sleep(2)
      shell.run("menu")
   else
      print(args[2].." does not exist")
       sleep(2)
       shell.run("menu")
   end
end


