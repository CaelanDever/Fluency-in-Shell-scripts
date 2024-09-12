# PowerShell script to manage Active Directory user accounts

# Import the Active Directory module
Import-Module ActiveDirectory

# Configuration
$LogFile = "C:\Logs\AD_UserManagement.log"
$ErrorLogFile = "C:\Logs\AD_UserManagement_Error.log"
$InactivityThresholdDays = 90

# Function to initialize logs
function Initialize-Logs {
    "User Management Report - $(Get-Date)" | Out-File -FilePath $LogFile -Append
    "Error Log - $(Get-Date)" | Out-File -FilePath $ErrorLogFile -Append
}

# Function to check for errors
function Check-Error {
    param([string]$Message)
    if ($LASTEXITCODE -ne 0) {
        $ErrorMessage = "Error occurred: $Message - $(Get-Date)"
        $ErrorMessage | Out-File -FilePath $ErrorLogFile -Append
        throw $ErrorMessage
    }
}

# Function to create a new user
function Create-NewUser {
    param(
        [string]$UserName,
        [string]$Password,
        [string]$OU,
        [string]$GivenName,
        [string]$Surname
    )
    $UserParams = @{
        Name             = $UserName
        GivenName        = $GivenName
        Surname          = $Surname
        UserPrincipalName = "$UserName@domain.com"
        Path             = $OU
        AccountPassword  = (ConvertTo-SecureString -AsPlainText $Password -Force)
        Enabled          = $true
    }
    New-ADUser @UserParams
    Check-Error "Creating user $UserName"
    "$UserName created successfully" | Out-File -FilePath $LogFile -Append
}

# Function to update user attributes
function Update-User {
    param(
        [string]$UserName,
        [hashtable]$Attributes
    )
    Set-ADUser -Identity $UserName -Description $Attributes.Description
    Check-Error "Updating user $UserName"
    "$UserName updated successfully" | Out-File -FilePath $LogFile -Append
}

# Function to disable inactive users
function Disable-InactiveUsers {
    $DateThreshold = (Get-Date).AddDays(-$InactivityThresholdDays)
    $InactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $DateThreshold} -Properties LastLogonDate
    foreach ($User in $InactiveUsers) {
        Disable-ADAccount -Identity $User.SamAccountName
        Check-Error "Disabling user $($User.SamAccountName)"
        "$($User.SamAccountName) disabled successfully" | Out-File -FilePath $LogFile -Append
    }
}

# Error handling
try {
    Initialize-Logs

    # Example usage
    Create-NewUser -UserName "jdoe" -Password "P@ssw0rd" -OU "OU=Users,DC=domain,DC=com" -GivenName "John" -Surname "Doe"
    Update-User -UserName "jdoe" -Attributes @{Description="Updated Description"}
    Disable-InactiveUsers

} catch {
    $_ | Out-File -FilePath $ErrorLogFile -Append
    Write-Error $_
}

# End of script
