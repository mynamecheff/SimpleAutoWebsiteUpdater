# Get the path of the script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Prompt user to enable autorun on startup
$autorun = Read-Host "Do you want to enable autorun on startup? (y/n)"
if ($autorun -eq "y") {
    $autorunPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Set-ItemProperty -Path $autorunPath -Name "AutoUpdate" -Value $MyInvocation.MyCommand.Definition
}

# Initialize variables
$tempImagePath = "$scriptPath\tempimage.png"
$latestImageHash = ""

while ($true) {
    # Copy image to script directory
    Copy-Item "$scriptPath\image.png" $tempImagePath -Force

    # Get hash of latest image
    $latestImageHash = (Get-FileHash $tempImagePath).Hash

    # Compare hash of latest image with previous hash
    if ($latestImageHash -ne $previousImageHash) {
        # Copy latest image to website directory
        Copy-Item $tempImagePath "$websitePath\image.png" -Force

        # Change to website directory
        Set-Location $websitePath

        # Add, commit, and push changes
        git add .
        git commit -m "Update image"
        git push origin main

        # Update previous hash
        $previousImageHash = $latestImageHash
    }

    # Wait 10 minutes before checking again
    Start-Sleep -Seconds 600
}
