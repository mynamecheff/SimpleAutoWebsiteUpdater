# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Please run this script as an administrator." -ForegroundColor Red
  Exit
}

# Prompt the user to confirm
$message = "Do you want to enable autorun on startup?"
$choice = [System.Management.Automation.Host.ChoiceDescription[]]@("&Yes", "&No")
$result = $Host.UI.PromptForChoice("Confirmation", $message, $choice, 0)

if ($result -eq 0) {
    # User confirmed, enable autorun on startup
    # ...
    Write-Host "Autorun on startup has been enabled." -ForegroundColor Green
} else {
    # User canceled, disable autorun on startup
    # ...
    Write-Host "Autorun on startup has been disabled." -ForegroundColor Yellow
}

# Close the console window
Out-Host -NoNewline



if ($result -eq 0) {
  $taskName = "UpdateImage"
  $taskPath = "$PSScriptRoot\UpdateImage.ps1"
  $trigger = New-ScheduledTaskTrigger -AtStartup
  $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$taskPath`""
  $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)
  $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings
  Register-ScheduledTask -TaskName $taskName -InputObject $task -Force
  Write-Host "Autorun on startup has been enabled." -ForegroundColor Green
} else {
  Write-Host "Autorun on startup has been disabled." -ForegroundColor Yellow
  Unregister-ScheduledTask -TaskName "UpdateImage" -Confirm:$false
}

# Verify if the image has changed before pushing to Git
$imagePath = "$PSScriptRoot\image.png"
$lastHash = ""

while ($true) {
  $currentHash = Get-FileHash $imagePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash

  if ($currentHash -ne $lastHash) {
      # Image has changed, push to Git
      Copy-Item $imagePath $websitePath
      Set-Location $websitePath
      git add .
      git commit -m "Update image"
      git push origin main
      Write-Host "Image has been updated and pushed to Git." -ForegroundColor Green
      $lastHash = $currentHash
  } else {
      Write-Host "Image has not changed, no action taken." -ForegroundColor Yellow
  }

  Start-Sleep -Seconds 5
}
