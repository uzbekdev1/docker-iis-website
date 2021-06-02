 
FROM mcr.microsoft.com/windows/servercore/iis

RUN powershell New-Item -Type Directory C:\setup

RUN powershell Invoke-WebRequest 'https://download.visualstudio.microsoft.com/download/pr/24847c36-9f3a-40c1-8e3f-4389d954086d/0e8ae4f4a8e604a6575702819334d703/dotnet-hosting-5.0.6-win.exe' -UserAgent '' -OutFile C:/setup/dotnet-hosting-5.0.6-win.exe
RUN powershell start-process -Filepath C:/setup/dotnet-hosting-5.0.6-win.exe -ArgumentList  @('/install', '/q', '/norestart', 'OPT_NO_RUNTIME=1', 'OPT_NO_SHAREDFX=1') -Wait

RUN powershell Remove-Item C:/setup/dotnet-hosting-5.0.6-win.exe -Force