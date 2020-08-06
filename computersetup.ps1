<#Diego Garcia
Created on 8/4/20
This script is to be used when initially setting up a Kranz computer. 
#>
<#Variables#>

$user = -Read-Host -Prompt 'Enter Computer Users name: ' # Gets users name

# The Following Runs Windows Update
Install-Module PSWindowsUpdate  #install the Windows Update module in PowerShell.
Get-WindowsUpdate   #Checks for updates
Install-WindowsUpdate   #installs the available updates. 

<#Renames computer#>
Rename-Computer -NewName "Kranz "$user

#Joins Kranzassoc.com domain
Add-Computer -DomainName ad.kranzassoc.com -Credential AD\adminuser #unsure about "AD\adminuser" different credential woul be used


-restart -force #Restart computer


function InstallFirefox {
    param ()
    process{
        [string] $downloadURL = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US";
        [string]$Installer = $env:TEMP + "\firefox.exe"; 
        Invoke-WebRequest $downloadURL -OutFile $Installer;
        Start-Process -FilePath $Installer -Args "/s" -Verb RunAs -Wait; 
        Remove-Item $Installer;   
    }
}

#this should updat eon githubd3d3dedwdww