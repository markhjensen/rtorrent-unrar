#!/bin/bash

# Define the destination folders
destination_sync="<path/to/folder>/sync"
destination_tmp="<path/to/folder>/tmp"

# Check if the 'sync' folder exists, create it if not
if [ ! -d "$destination_sync" ]; then
    mkdir -p "$destination_sync"
fi

# Check if the 'tmp' folder exists, create it if not
if [ ! -d "$destination_tmp" ]; then
    mkdir -p "$destination_tmp"
fi

# Check if any arguments were passed to the script
if [ $# -eq 0 ]; then
    echo "Usage: $0 <folder_or_file_location>"
    exit 1
fi

# Get the folder or file location from the command line argument passed by rtorrent
location="$1"

# Extract the folder name from the folder location or the base name if it's a file
if [ -d "$location" ]; then
    folder_name=$(basename "$location")
else
    folder_name=$(basename "${location%.*}")
fi

# Print the folder name
echo "Processing: $folder_name"

# Check if the folder or file exists
if [ ! -e "$location" ]; then
    echo "Error: Folder or file not found at $location"
    exit 1
fi

# Check if the folder already exists in the destination_sync
if [ -d "$destination_sync/$folder_name" ]; then
    echo "Folder already exists in $destination_sync"
    exit 0
fi

# Check if any file in the directory is 0 bytes (for folders) or if the file itself is 0 bytes (for files)
if [ -d "$location" ]; then
    # Check if any file in the directory is 0 bytes
    zero_byte_files=$(find "$location" -type f -size 0)
    if [ -n "$zero_byte_files" ]; then
        echo "Error: Folder contains files with 0 bytes"
        exit 1
    fi
else
    # Check if the file itself is 0 bytes
    if [ -s "$location" ]; then
        echo "Error: File is empty"
        exit 1
    fi
fi

# Check if the location is a file or a folder
if [ -d "$location" ]; then
    # Check if the folder contains a video file and doesn't contain 'sample' or 'trailer' in its name
    video_file=$(find "$location" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.mov" \) ! -iname "*sample*" ! -iname "*trailer*")
    if [ -n "$video_file" ]; then
        # Copy the entire folder to ../private/rtorrent/sync
        cp -r "$location" "$destination_sync/"

        echo "Folder copied to $destination_sync"
    else
        # Check if the folder contains rar files
        rar_files=$(find "$location" -type f \( -name "*.rar" -o -name "*.r00" \))
        if [ -n "$rar_files" ]; then

            # Create a temporary folder for unraring
            tmp_folder="$destination_tmp/$folder_name"
            mkdir -p "$tmp_folder"

            # Indicate that unrar process has started
            echo "Starting unrar process for $folder_name..."

            # Unrar the files to the temporary folder silently (only stdout is silenced)
            unrar x -o- "$location/*.rar" "$tmp_folder" >/dev/null

            # Check if unrar resulted in a plain file instead of a directory
            if [ -d "$tmp_folder" ]; then
                echo "Files unrared to $tmp_folder"
                # Move the entire folder from the temporary folder to destination_sync
                mv -T "$tmp_folder" "$destination_sync/$folder_name"
                echo "Folder moved to $destination_sync"
            else
                echo "Error: Unrar resulted in a plain file, not a directory"
                rm -rf "$tmp_folder" # Clean up temporary folder
            fi
        fi
    fi
else
    # Check if the file is a video file and doesn't contain 'sample' or 'trailer' in its name
    video_file=$(find "$location" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.mov" \) ! -iname "*sample*" ! -iname "*trailer*")
    if [ -n "$video_file" ]; then
        # Copy the video file to ../private/rtorrent/sync
        cp "$location" "$destination_sync/$folder_name.${location##*.}"

        echo "Video file copied to $destination_sync"
    else
        echo "Skipping non-video file or video file with 'sample' or 'trailer' in its name"
    fi
fi