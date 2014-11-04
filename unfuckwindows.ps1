#Powershell script to unfuck windows (slightly)

# Allow scripts to run.  This probaly has to be done manually.
Set-ExecutionPolicy Unrestricted


# Show all file extensions
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
