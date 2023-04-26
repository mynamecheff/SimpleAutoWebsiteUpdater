#!/bin/bash

# Check if running as administrator
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as an administrator." >&2
    exit 1
fi

# Prompt to enable autorun on startup
while true; do
    read -rp "Do you want to enable autorun on startup? (y/n): " choice
    case $choice in
        [Yy]*)
            task_name="UpdateImage"
            task_path="$PWD/UpdateImage.sh"
            trigger="AtStartup"
            action="powershell.exe -File \"$task_path\""
            settings="-AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 1)"
            # Register the scheduled task
            schtasks /Create /TN "$task_name" /TR "$action" /SC $trigger /ST 00:00 /F $settings
            echo "Autorun on startup has been enabled."
            break
            ;;
        [Nn]*)
            # Unregister the scheduled task
            schtasks /Delete /TN "UpdateImage" /F
            echo "Autorun on startup has been disabled."
            break
            ;;
        *)
            echo "Invalid input, please try again." >&2
            ;;
    esac
done

# Verify if the image has changed before pushing to Git
image_path="$PWD/image.png"
last_hash=""

while true; do
    current_hash=$(sha256sum "$image_path" | awk '{print $1}')
    if [ "$current_hash" != "$last_hash" ]; then
        # Image has changed, push to Git
        cp "$image_path" "$website_path"
        cd "$website_path" || exit
        git add .
        git commit -m "Update image"
        git push origin main
        echo "Image has been updated and pushed to Git."
        last_hash="$current_hash"
    else
        echo "Image has not changed, no action taken."
    fi
    sleep 600
done
