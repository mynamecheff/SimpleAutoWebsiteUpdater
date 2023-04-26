$websitePath = $PSScriptRoot
$prevHash = ""

# Prompt to enable autorun on startup
$autorun = Read-Host "Do you want to enable autorun on startup? (y/n)"
if ($autorun -eq "y") {
  $autorunPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
  $autorunName = "My Image Updater"
  $autorunValue = "powershell -ExecutionPolicy Bypass -File `"$PSCommandPath`" autorun"
  Set-ItemProperty $autorunPath $autorunName $autorunValue
  Write-Host "Autorun enabled"
}

if ($args[0] -eq "autorun") {
  # Run in autorun mode
  while ($true) {
    $hash = Get-FileHash "image.png" -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    if ($hash -ne $prevHash) {
      Copy-Item "image.png" $websitePath
      cd $websitePath
      git add .
      git commit -m "Update image"
      git push origin main
      $prevHash = $hash
    }
    Start-Sleep -Seconds 600
  }
} elseif ($args[0] -eq "disable-autorun") {
  # Disable autorun
  $autorunPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
  $autorunName = "My Image Updater"
  Remove-ItemProperty $autorunPath $autorunName
  Write-Host "Autorun disabled"
} else {
  # Run normally
  $hash = Get-FileHash "image.png" -Algorithm SHA256 | Select-Object -ExpandProperty Hash
  if ($hash -ne $prevHash) {
    Copy-Item "image.png" $websitePath
    cd $websitePath
    git add .
    git commit -m "Update image"
    git push origin main
    $prevHash = $hash
  }
}
