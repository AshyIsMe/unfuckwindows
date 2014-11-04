#Powershell script to unfuck windows (slightly).
#Open a powershell terminal with Admin privileges and paste this whole script in.

# Allow scripts to run.  This probaly has to be done manually.
Set-ExecutionPolicy Unrestricted

# Show all file extensions
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f





#The below is taken and slightly modified from here: https://gallery.technet.microsoft.com/scriptcenter/How-to-batch-add-URLs-to-c8207c23
#
# Start of AddingTrustedSites.ps1
# Modified to be functions instead of a standalone script
#

#Initialize key variables
$UserRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"

$DWord = 2

#Main function
Function CreateKeyReg
{
    Param
    (
        [String]$KeyPath,
        [String]$Name
    )

    If(Test-Path -Path $KeyPath)
    {
        Write-Verbose "Creating a new key '$Name' under $KeyPath."
        New-Item -Path "$KeyPath" -ItemType File -Name "$Name" `
        -ErrorAction SilentlyContinue | Out-Null
    }
    Else
    {
        Write-Warning "The path '$KeyPath' not found."
    }
}

Function SetRegValue
{
    Param
    (
        [Boolean]$blnHTTP=$false,
        [String]$RegPath
    )

    Try
    {
        If($blnHTTP)
        {
            Write-Verbose "Creating a Dword value named 'HTTP' and set the value to 2."
            Set-ItemProperty -Path $RegPath -Name "http" -Value $DWord `
            -ErrorAction SilentlyContinue | Out-Null
        }
        Else
        {
            Write-Verbose "Creating a Dword value named 'HTTPS' and set the value to 2."
            Set-ItemProperty -Path $RegPath -Name "https" -Value $DWord `
            -ErrorAction SilentlyContinue | Out-Null
        }
    }
    Catch
    {
        Write-Host "Failed to add trusted sites in Internet Explorer." -BackgroundColor Red
    }

}

Function AddTrustedSites
{
    Param
    (        
        [String[]]$TrustedSites,        
        [Switch]$HTTP=$false        
    )   
    
    #Adding trusted sites in the registry
    Foreach($TruestedSite in $TrustedSites)
    {
        #If user does not specify the user type. By default,the script will add the trusted sites for the current user.

        If($HTTP)
        {
            CreateKeyReg -KeyPath $UserRegPath -Name $TruestedSite 
            SetRegValue -RegPath "$UserRegPath\$TruestedSite" -blnHTTP $true -DWord $DWord
            Write-Host "Successfully added '$TruestedSite' domain to trusted Sites in Internet Explorer."
        }
        Else
        {
            CreateKeyReg -KeyPath $UserRegPath -Name $TruestedSite 
            SetRegValue -RegPath "$UserRegPath\$TruestedSite" -blnHTTP $false -DWord $DWord
            Write-Host "Successfully added '$TruestedSite' domain to to trusted Sites in Internet Explorer."
        }
    }
    
}

Function AddTrustedSubdomain
{
    Param
    (        
        [String]$PrimaryDomain,        
        [String]$SubDomain,
        [Switch]$HTTP=$false
    )   
    
    #Setting the primary domain and sub-domain
    If($HTTP)
    {
        CreateKeyReg -KeyPath $UserRegPath -Name $PrimaryDomain
        CreateKeyReg -KeyPath "$UserRegPath\$PrimaryDomain" -Name $SubDomain 
        SetRegValue -RegPath "$UserRegPath\$PrimaryDomain\$SubDomain" -blnHTTP $true -DWord $DWord
        Write-Host "Successfully added $SubDomain.$PrimaryDomain' domain to trusted Sites in Internet Explorer."
    }
    Else
    {
        CreateKeyReg -KeyPath $UserRegPath -Name $PrimaryDomain
        CreateKeyReg -KeyPath "$UserRegPath\$PrimaryDomain" -Name $SubDomain
        SetRegValue -RegPath "$UserRegPath\$PrimaryDomain\$SubDomain" -blnHTTP $false -DWord $DWord
        Write-Host "Successfully added '$SubDomain.$PrimaryDomain' domain to trusted Sites in Internet Explorer."
    }
}

#
# End of AddingTrustedSites.ps1
#


# Add trusted sites to stop the annoying crap when you're trying to install chrome
#TODO: Doesn't seem to work on WinServer2012, probably need to try a different HKEY location in $UserRegPath 
AddTrustedSites ("google.com","bing.com") -HTTP $true
AddTrustedSites ("google.com","bing.com")

