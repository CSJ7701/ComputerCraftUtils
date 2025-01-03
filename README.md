# ComputerCraftUtils
This is a collection of modules and programs that I use to structure my OS in ComputerCraft, a Minecraft mod that adds computers to the game.


## Utils
**MakeBootDrive**

Create a boot drive. Requires a computer connected to a disk drive, and a floppy disk inside. This floppy disk can then be ejected and used to install the OS on other computers.

```shell
wget run https://raw.githubusercontent.com/CSJ7701/ComputerCraftUtils/main/Utils/MakeBootDrive.lua
```

This program will wipe the floppy disk and turn it into boot media for my lightweight OS.

---
**BareInstall**

Install the OS on a bare computer. Does not require a disk or disk drive, but is also not reproduceable - this is a single install.

```shell
wget run https://raw.githubusercontent.com/CSJ7701/ComputerCraftUtils/main/Utils/BareInstall.lua
```
---
