#!/bin/bash

websitePath="$(dirname "$(readlink -f "$0")")"

while true
do
  cp "image.png" "$websitePath"
  cd "$websitePath"
  git add .
  git commit -m "Update image"
  git push origin main
  sleep 600
done
