$websitePath = "C:\path\to\website\folder"
$imagePath = "C:\path\to\image.jpg"

while ($true) {
  Copy-Item $imagePath $websitePath
  cd $websitePath
  git add .
  git commit -m "Update image"
  git push origin main
  Start-Sleep -Seconds 600
}
