<#Diego Garcia
#Created on 8/4/20
#This script is to be used when initially setting up a Windows computer. 

# Variables used:
# $user = name of computer's user (computer name)
# $ChromeInstaller = location where chrome intaller will be placed
# $LocalTempDir= directory where chrome files will be at
# Process2Monitor =displays process of
# $FirefoxInstaller = Location where firefox installer is placed

#>


<#he Following Runs Windows Update#> 
function WinUpdate {

    param ()
    Install-Module PSWindowsUpdate  #install the Windows Update module in PowerShell.
    Get-WindowsUpdate   #Checks for updates
    Install-WindowsUpdate   #installs the available updates. 
}

<#KranzSetup joing domain#>
function Kranzsetup {
    param ()

    process{<#Renames computer#>
        -prompt 'Enter Computer Computer Number and user name:
                 Example: #-###-Username'
        $user = -Read-Host   # Gets users name
        Rename-Computer -NewName $user
        #Joins Kranzassoc.com domain

        Add-Computer -DomainName <#Enter Domain#> -Credential AD\adminuser #unsure about "AD\adminuser" different credential woul be used
        

    }
   

}
<#Install Chrome and makes it default browser#>
function InstallChrome {
    param ()
    process{

        -prompt "Installing Google Chrome...."
        $LocalTempDir = $env:TEMP; 
        $ChromeInstaller = "ChromeInstaller.exe";
        (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); 
        & "$LocalTempDir\$ChromeInstaller" /silent /install; 
        $Process2Monitor =  "ChromeInstaller"; 
        Do {$ProcessesFound = Get-Process | ?
            {$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name;
              If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } 
              else { 
                  Remove-Item "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose 
                } 
            } 
            Until (!$ProcessesFound)

            -prompt "Google Chrome is installed"
    }
}

    # Silent Install Firefox 

    function IntallFirefox {
    param ()

    -prompt "Installing Firefox..."

    $FirefoxInstaller = $env:TEMP  # Path for the FirefoxInstaller

# Check if work directory exists if not it will create it
#If (Test-Path -Path $FirefoxInstaller -PathType Container)
#{ Write-Host "$FirefoxInstaller already exists" -ForegroundColor Red}
#ELSE
#{ New-Item -Path $FirefoxInstaller  -ItemType directory }

# Downloads the installer
$source = "https://download.mozilla.org/?product=firefox-51.0.1-SSL&os=win64&lang=en-US"
$destination = "$FirefoxInstaller\firefox.exe"

# Check if Invoke-Webrequest exists otherwise execute WebClient
if (Get-Command 'Invoke-Webrequest')
{
     Invoke-WebRequest $source -OutFile $destination
}
else
{
    $WebClient = New-Object System.Net.WebClient
    $webclient.DownloadFile($source, $destination)
}
# Starts the installation
Start-Process -FilePath "$FirefoxInstaller\firefox.exe" -ArgumentList "/S"

# Wait for the installation to finish
Start-Sleep -s 240

# Remove the installer
Remove-Item -Force $FirefoxInstaller\firefox*    


-prompt "Firefox is installed"
}


# Install Adobe Reader DC
function InstallAcrobat {
    param ()
-prompt "Checking is Acrobat is Already Installed... "

# Check if Software is installed already in registry.
$CheckADCReg = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Adobe Acrobat Reader DC*"}
# If Adobe Reader is not installed continue with script. If it's istalled already script will exit.
If ($null -eq $CheckADCReg) {

-prompt "Installing Acrobat Reader DC"
# Path for the temporary downloadfolder. Script will run as system so no issues here
$Installdir = $env:TEMP + "\install_adobe"
New-Item -Path $Installdir  -ItemType directory

# Download the installer from the Adobe website.
$source = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/1800920044/AcroRdrDC1800920044_en_US.exe"
$destination = "$Installdir\AcroRdrDC1800920044_en_US.exe"
Invoke-WebRequest $source -OutFile $destination

# Start the installation when download is finished
Start-Process -FilePath "$Installdir\AcroRdrDC1800920044_en_US.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES"

# Wait for the installation to finish. .
Start-Sleep -s 240

# Finish by cleaning up the download. 
Remove-Item -Force $Installdir\AcroRdrDC*

    -prompt "Acrobat Reader DC is installed"
    }
    else
    {
        -prompt "Acrobat Reader is already installed"
        return
    }
    
}


-restart -force #Restart computer

