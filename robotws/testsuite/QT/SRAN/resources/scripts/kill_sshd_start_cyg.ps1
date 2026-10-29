taskkill /F /IM sshd.exe
timeout 2
Start-Service -Name cygsshd
