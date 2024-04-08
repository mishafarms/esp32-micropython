#!/bin/bash

# Check if the dist directory exists and is not empty
if [ -d "dist" ] && [ "$(ls -A dist)" ]; then
   echo "Removing existing files in dist/"
   rm -f dist/* || { echo 'Failed to remove files in dist/'; exit 1; }
else
   echo "dist directory is empty or does not exist, skipping removal."
fi

# Run Parcel build
parcel build web/index.html || { echo 'Parcel build failed'; exit 1; }
