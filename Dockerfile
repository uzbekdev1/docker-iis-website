# escape=`
FROM mcr.microsoft.com/windows/servercore/iis:latest
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]

# feature
RUN Install-WindowsFeature Web-Windows-Auth

# .net
ENV DOTNET_VERSION 5.0.6
ENV DOTNET_DOWNLOAD_URL https://download.visualstudio.microsoft.com/download/pr/24847c36-9f3a-40c1-8e3f-4389d954086d/0e8ae4f4a8e604a6575702819334d703/dotnet-hosting-$DOTNET_VERSION-win.exe
ENV DOTNET_DOWNLOAD_SHA 9f48484fe0c55c3c3065e49f9cc3576bfd99703f250e5420bb3d2599af02c0380cd2f42278b9ce86088d70f19d171daa8fa9c504e14534b36c01afc282b4de1b
RUN Invoke-WebRequest $Env:DOTNET_DOWNLOAD_URL -OutFile WindowsHosting.exe; `
    if ((Get-FileHash WindowsHosting.exe -Algorithm sha512).Hash -ne $Env:DOTNET_DOWNLOAD_SHA) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    dir c:\Windows\Installer; `
    Start-Process "./WindowsHosting.exe" '/install /quiet /norestart' -Wait; `
    Remove-Item -Force -Recurse 'C:\ProgramData\Package Cache\*'; `
    Remove-Item -Force -Recurse C:\Windows\Installer\*; `
    Remove-Item -Force WindowsHosting.exe
RUN setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '\dotnet')

# Enabl
ENV DOTNET_RUNNING_IN_CONTAINER=true

# site
 
 RUN Remove-Website -Name 'Default Web Site'; `
    New-WebAppPool -Name 'webapp'; `
    Set-ItemProperty IIS:\AppPools\webapp -Name managedRuntimeVersion -Value ''; `
    Set-ItemProperty IIS:\AppPools\webapp -Name enable32BitAppOnWin64 -Value 0; `
    Set-ItemProperty IIS:\AppPools\webapp -Name processModel -value @{identitytype='ApplicationPoolIdentity'}; `
    New-Website -Name 'webapp' `
                -Port 80 -PhysicalPath 'C:\webapp' `
                -ApplicationPool 'webapp' -force;  `
    & $env:windir\system32\inetsrv\appcmd.exe unlock config -section:system.webServer/security/authentication/windowsAuthentication;  `
    & $env:windir\system32\inetsrv\appcmd.exe unlock config -section:system.webServer/security/authentication/anonymousAuthentication;	`
    & $env:windir\system32\inetsrv\appcmd.exe set config 'webapp' -section:system.webServer/security/authentication/anonymousAuthentication /enabled:'False' /commit:apphost;	`
    & $env:windir\system32\inetsrv\appcmd.exe set config 'webapp' -section:system.webServer/security/authentication/windowsAuthentication /enabled:'True' /commit:apphost;

# password
RUN net user Administrator Qwertyu7!

# root
RUN mkdir c:\webapp
COPY .\published\ C:\webapp 
