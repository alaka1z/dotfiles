Set shell = CreateObject("WScript.Shell")
shell.Run "wsl.exe -d Ubuntu-24.04 --exec sleep infinity", 0, False
