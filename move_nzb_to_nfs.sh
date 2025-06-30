#!/bin/bash

# Fixed destination directory
DESTINATION="/mnt/nfs/media/usenet"

# Check if the source directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi

# Source directory from the first argument
SOURCE="$1"

# Check if the source directory exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

# Ensure the destination directory exists
if [ ! -d "$DESTINATION" ]; then
    echo "Destination directory '$DESTINATION' does not exist. Creating it."
    mkdir -p "$DESTINATION"
fi

# Move the directory to the destination
echo "Moving '$SOURCE' to '$DESTINATION'..."
mv "$SOURCE" "$DESTINATION"

# Check if the move was successful
if [ $? -eq 0 ]; then
    echo "Directory moved successfully to '$DESTINATION'."
    exit 0
else
    echo "Error: Failed to move directory."
    exit 1
fi