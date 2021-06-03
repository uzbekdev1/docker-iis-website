cd %systemroot%\system32\inetsrv\
appcmd.exe unlock config -section:system.webServer/handlers
appcmd.exe unlock config -section:anonymousAuthentication
appcmd.exe unlock config -section:windowsAuthentication
appcmd.exe set config "WinAuth" -section:system.webServer/security/authentication/anonymousAuthentication /enabled:"False" /commit:apphost
appcmd.exe set config "WinAuth" -section:system.webServer/security/authentication/windowsAuthentication /enabled:"True" /commit:apphost