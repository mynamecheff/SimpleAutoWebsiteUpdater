# Set the website path and image path
$websitePath = $PSScriptRoot
$imagePath = "$PSScriptRoot\image.png"
$tempImagePath = "$PSScriptRoot\image1.png"

# Prompt to enable autorun on startup
do {
    $autorun = Read-Host "Do you want to enable autorun on startup? (y/n): "
} while ($autorun -notin @('y','n'))

# Set autorun registry value
if ($autorun -eq 'y') {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $regName = "AutoUpdateWebsite"
    $regValue = $PSCommandPath
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue
}

while ($true) {
    # Check if the image has changed
    $imageHash = Get-FileHash $imagePath
    $tempImageHash = Get-FileHash $tempImagePath
    if ($imageHash.Hash -ne $tempImageHash.Hash) {
        # Copy the image and commit changes
        Copy-Item $imagePath $tempImagePath -Force
        Remove-Item $imagePath
        Rename-Item $tempImagePath -NewName "image.png"
        cd $websitePath
        git add .
        git commit -m "Update image"
        git push origin main
    }

    # Wait for 10 minutes
    Start-Sleep -Seconds 5
}

# Close the console window
Exit
