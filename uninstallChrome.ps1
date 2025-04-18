$64bit = if ([System.IntPtr]::Size -eq 8) { $true } else { $false }
$RegKeys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\')
if ($true -eq $64bit) { $RegKeys += 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'}
$Apps = $RegKeys | Get-ChildItem | Get-ItemProperty | Where-Object { $_.DisplayName -like '*Chrome*' }

$Apps | ForEach-Object {
    $ExecLocation = "$($_.UninstallString.Split('"')[1])"
    Start-Process -FilePath "$ExecLocation" -ArgumentList "--uninstall --system-level --force-uninstall" -Wait
}