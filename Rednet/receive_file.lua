rednet.open("top")

term.clear()
term.setCursorPos(1,1)
print("Single-File or Persistant?")
print("Enter [1] for single, [2] for persistant")
Mode = read()
if not Mode == 1 or Mode == 2 then
   error("Invalid mode")
end

textutils.slowPrint("Receiving Files...")

while true do
   id,msg = rednet.receive()
   if msg == "RECEIVE" then
      id2,msg2 = rednet.receive()
      f = fs.open(msg2, "w")
      id3,msg3 = rednet.receive()
      f.write(msg3)
      f.close()
      print("File "..msg2.." received!")
      if Mode == 1 then
	 sleep(5)
	 shell.run("menu")
      end
   end
end


