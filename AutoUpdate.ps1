$websitePath = $PSScriptRoot
$prevHash = ""

function Check-Hash {
  $hash = Get-FileHash -Algorithm MD5 -Path "$websitePath\image.png" | Select-Object -ExpandProperty Hash
  if ($hash -eq $prevHash) {
    return $false
  }
  $prevHash = $hash
  return $true
}

# Prompt user to enable autorun on startup
$answer = Read-Host "Do you want to enable autorun on startup? (y/n)"
if ($answer -eq "y") {
  $taskName = "Auto Update Website Image"
  $trigger = New-ScheduledTaskTrigger -AtLogOn
  $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$PSScriptRoot\AutoUpdate.ps1`""
  $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfIdle
  Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Settings $settings
}

while ($true) {
  if (Check-Hash) {
    Copy-Item "image.png" $websitePath
    cd $websitePath
    git add .
    git commit -m "Update image"
    git push origin main
  }
  Start-Sleep -Seconds 600
}
