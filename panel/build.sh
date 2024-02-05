#!/bin/bash

# Check if the dist directory exists and is not empty
if [ -d "dist" ] && [ "$(ls -A dist)" ]; then
   echo "Removing existing files in dist/"
   rm -f dist/* || { echo 'Failed to remove files in dist/'; exit 1; }
else
   echo "dist directory is empty or does not exist, skipping removal."
fi

# if there is no mainInfo.js file, then copy a default one in
if [ ! -f "web/mainInfo.js" ]; then
  echo "mainInfo.js does not exist in web/. Copying from default/mainInfo.js..."
  # Ensure the web directory exists
  cp default/mainInfo.js web/mainInfo.js || { echo 'Failed to copy mainInfo.js'; exit 1; }
else
  echo "mainInfo.js already exists in web/, no need to copy."
fi


# Run Parcel build
parcel build web/index.html || { echo 'Parcel build failed'; exit 1; }
