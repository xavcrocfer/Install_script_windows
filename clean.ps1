# Temporarily disable ExecutionPolicy
$currentPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Ensure temporary folder exists
$tempFolder = "C:\XC\"
if (-not (Test-Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder -Force
}

function ChangeHostname {
    $newHostname = Read-Host "Enter new hostname"
    Rename-Computer -NewName $newHostname
    "Hostname changed to $newHostname" | Out-File "$tempFolder\Log.txt" -Append
}

function InstallBrowsers {
    # Firefox and Chrome URLs need to be verified for the latest French versions
    # Firefox
    $firefoxUrl = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=fr"
    $firefoxInstaller = "$tempFolder\FirefoxInstaller.exe"
    Invoke-WebRequest -Uri $firefoxUrl -OutFile $firefoxInstaller
    Start-Process -FilePath $firefoxInstaller -Args "/S" -Wait
    
    # Chrome
    $chromeUrl = "https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
    $chromeInstaller = "$tempFolder\ChromeInstaller.msi"
    Invoke-WebRequest -Uri $chromeUrl -OutFile $chromeInstaller
    Start-Process "msiexec.exe" -Arg "/i $chromeInstaller /quiet /norestart" -Wait

    "Firefox and Chrome installed" | Out-File "$tempFolder\Log.txt" -Append
}

function JoinDomain {
    $domain = Read-Host "Enter domain name"
    $user = Read-Host "Enter username"
    $password = Read-Host "Enter password" -AsSecureString
    $credential = New-Object System.Management.Automation.PSCredential($user, $password)
    Add-Computer -DomainName $domain -Credential $credential
    "Joined domain $domain" | Out-File "$tempFolder\Log.txt" -Append
}

function InstallWindowsUpdates {
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate
    Install-WindowsUpdate -AcceptAll -AutoReboot
    "Windows updates installed" | Out-File "$tempFolder\Log.txt" -Append
}

function InstallNotepadPlusPlus {
    $nppUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.2/npp.8.6.2.Installer.x64.exe"  # Update for the latest French version
    $nppInstaller = "$tempFolder\NppInstaller.exe"
    Invoke-WebRequest -Uri $nppUrl -OutFile $nppInstaller
    Start-Process -FilePath $nppInstaller -Args "/S" -Wait
    "Notepad++ installed" | Out-File "$tempFolder\Log.txt" -Append
}

function DisableFastStartup {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -Value 0
    "Fast startup disabled" | Out-File "$tempFolder\Log.txt" -Append
}

function EnableAndDownloadDotNet35 {
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All
    ".NET Framework 3.5 enabled and downloaded" | Out-File "$tempFolder\Log.txt" -Append
}

function SetOutlookAsDefaultMailClient {
    # This requires manual steps or specific scripts depending on the version of Windows and Outlook
    "Setting Outlook as default mail client might require manual configuration." | Out-File "$tempFolder\Log.txt" -Append
}

function Install7Zip {
    $zipUrl = "https://www.7-zip.org/a/7z1900-x64.msi"  # Update for the latest French version if available
    $zipInstaller = "$tempFolder\7ZipInstaller.msi"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipInstaller
    Start-Process "msiexec.exe" -Arg "/i $zipInstaller /quiet /norestart" -Wait
    "7-Zip installed" | Out-File "$tempFolder\Log.txt" -Append
}

# Function to add current user to local administrators group
function AddCurrentUserToLocalAdmins {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Add-LocalGroupMember -Group "Administrateurs" -Member $currentUser
    "$currentUser added to local Administrators group" | Out-File "$tempFolder\Log.txt" -Append
}

# Function to set Google as default in Chrome
function SetGoogleDefaultChrome {
    $chromePoliciesPath = "HKCU:\Software\Policies\Google\Chrome"

    # Ensure the Chrome policy path exists
    if (-not (Test-Path $chromePoliciesPath)) {
        New-Item -Path $chromePoliciesPath -Force | Out-Null
    }

    # Set Google as the default search engine
    New-ItemProperty -Path $chromePoliciesPath -Name "DefaultSearchProviderEnabled" -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $chromePoliciesPath -Name "DefaultSearchProviderName" -Value "Google" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $chromePoliciesPath -Name "DefaultSearchProviderSearchURL" -Value "https://www.google.com/search?q={searchTerms}" -PropertyType String -Force | Out-Null

    Write-Host "Google set as default search engine in Chrome."
}

# Function to set Google as default in Edge
function SetGoogleDefaultEdge {
    # For Edge, this sets the default search engine to Google using the registry.
    # Note: This approach might not work on all versions of Edge, especially newer versions that are frequently updated.

    $edgeSearchScopePath = "HKCU:\Software\Microsoft\Internet Explorer\SearchScopes"
    $guidGoogle = "{012E1000-F331-11DB-8314-0800200C9A66}"

    # Create the registry path for the new search scope if it doesn't exist
    if (-not (Test-Path "$edgeSearchScopePath\$guidGoogle")) {
        New-Item -Path "$edgeSearchScopePath\$guidGoogle" -Force | Out-Null
    }

    # Define Google search scope settings
    New-ItemProperty -Path "$edgeSearchScopePath\$guidGoogle" -Name "DisplayName" -Value "Google" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path "$edgeSearchScopePath\$guidGoogle" -Name "URL" -Value "https://www.google.com/search?q={searchTerms}" -PropertyType String -Force | Out-Null

    # Set Google as the default search provider
    Set-ItemProperty -Path $edgeSearchScopePath -Name "DefaultScope" -Value $guidGoogle

    Write-Host "Google set as default search engine in Edge."
}

# Function to Install Office 365 French 32 Bits
function InstallO365 {
    $O365Installer = "$tempFolder\setup.exe"
    Start-Process -FilePath $O365Installer -Args "/configure $tempFolder\Configuration-cc.xml" -Wait
    "Microsoft 365 FR 32bits installed" | Out-File "$tempFolder\Log.txt" -Append
}

# Interactive Menu
Write-Host "Select the operation(s) to perform:"
$options = @("Change Hostname", "Install Firefox and Chrome (French)", "Join Domain", "Install Windows Updates", "Install Notepad++ (French)", "Disable Fast Startup", "Enable and Download .NET Framework 3.5", "Set Outlook as Default Mail Client", "Install 7-Zip (French)", "Add Current User to Local Admin Group", "Set Default Search For Edge", "Set default Search For Chrome", "Install Microsoft 365 Fr 32Bits", "Perform All Tasks")
foreach ($option in $options) { Write-Host "$($options.IndexOf($option) + 1): $option" }

$choice = Read-Host "Enter your choice (1-14)"
switch ($choice) {
    "1" { ChangeHostname }
    "2" { InstallBrowsers }
    "3" { JoinDomain }
    "4" { InstallWindowsUpdates }
    "5" { InstallNotepadPlusPlus }
    "6" { DisableFastStartup }
    "7" { EnableAndDownloadDotNet35 }
    "8" { SetOutlookAsDefaultMailClient }
    "9" { Install7Zip }
    "10" { AddCurrentUserToLocalAdmins }
    "11" { SetGoogleDefaultChrome }
    "12" { SetGoogleDefaultEdge }
    "13" { InstallO365 }
    "14" {
        ChangeHostname
        InstallBrowsers
        JoinDomain
        InstallWindowsUpdates
        InstallNotepadPlusPlus
        DisableFastStartup
        EnableAndDownloadDotNet35
        SetOutlookAsDefaultMailClient
        Install7Zip
	AddCurrentUserToLocalAdmins
        SetGoogleDefaultChrome
        SetGoogleDefaultEdge
        InstallO365
    }
}

# Restore the original execution policy
Set-ExecutionPolicy $currentPolicy -Scope Process -Force

Write-Host "Operation(s) completed. Check $tempFolder\Log.txt for details."
