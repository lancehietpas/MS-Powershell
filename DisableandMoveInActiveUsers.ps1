Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 90
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
  
#-------------------------------
# FIND INACTIVE USERS
#-------------------------------
#
# Get AD Users that haven't logged on in xx days
$Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and PasswordNeverExpires -eq $false } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------
# Export results to CSV
$Users | Export-Csv C:\InactiveUsers.csv -NoTypeInformation

#-------------------------------
# INACTIVE USER MANAGEMENT
#-------------------------------
#Disable and Move to Disabled OU

# Disable Inactive Users
ForEach ($Item in $Users){
  $DistName = $Item.DistinguishedName
  Disable-ADAccount -Identity $DistName
  Get-ADUser -Filter { DistinguishedName -eq $DistName } | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, Enabled
}

$moveToOU = "CN=disabled,DC=ymcafoxcities,DC=org"

Search-ADAccount -AccountDisabled -UsersOnly |
Select Name,Distinguishedname |
Out-GridView -OutputMode Multiple |
foreach { 
 Move-ADObject -Identity $_.DistinguishedName -TargetPath $moveToOU -WhatIf
 }