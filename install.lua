-- Installer program for basks
-- needs to install
-- basalt shell.run("pastebin run ESs1mg7P packed true "..filePath:gsub(".lua", ""))
-- ktwsl https://raw.githubusercontent.com/MasonGulu/msks/main/ktwsl.lua
-- redrun https://gist.githubusercontent.com/MCJack123/473475f07b980d57dd2bd818026c97e8/raw/139df815254818dc6dc3c7f6ca4a3784f6e0b8f4/redrun.lua
-- abstractInvLib https://raw.githubusercontent.com/MasonGulu/msks/main/abstractInvLib.lua

print("Installing basalt..")
shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua dev")

print("Downloading KTWSL..")
shell.run("wget https://raw.githubusercontent.com/MasonGulu/msks/main/ktwsl.lua ktwsl.lua")

print("Downloading Redrun..")
shell.run("wget https://gist.githubusercontent.com/MCJack123/473475f07b980d57dd2bd818026c97e8/raw/139df815254818dc6dc3c7f6ca4a3784f6e0b8f4/redrun.lua redrun.lua")

print("Downloading abstractInvLib..")
shell.run("wget https://raw.githubusercontent.com/MasonGulu/msks/main/abstractInvLib.lua abstractInvLib.lua")

print("Downloading basks")
shell.run("wget https://raw.githubusercontent.com/MasonGulu/BASKS/master/basks.lua basks.lua")

print("Downloading config")
shell.run("wget https://raw.githubusercontent.com/MasonGulu/BASKS/master/basksconfig.lua config.lua")