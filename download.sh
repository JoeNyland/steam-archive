#!/bin/bash

# Takes a list of Steam store URLs from stdin and downloads the games using depotdownloader
# Usage: ./download.sh < steam_urls.txt
# URL format: https://store.steampowered.com/app/<game_id>/<game_name>/

set -e # Exit on error
set -u # Exit on unset variables
set -o pipefail # Exit on pipe error

# Set the username
username="masterroot24"

# Allow the user to set the output directory as a parameter or use the default
if [ "$#" -eq 1 ]; then
  output_dir="${1%/}" # Remove trailing slash if present
else
  output_dir="${PWD}/games"
fi

# Allow the user to enable debug mode
if [ "${DEBUG:-}" = "true" ]; then
  set -x # Print each command before executing
fi

# Read each line from stdin
while IFS= read -r url; do
  # Extract the game ID from the URL
  game_id=$(echo "$url" | awk -F'/' '{print $5}')

  # Extract the game name from the URL
  game_name=$(echo "$url" | awk -F'/' '{print $6}')

  # Define the game directory
  game_dir="${output_dir}/${game_name//_/ }"

  # Create a directory for the game if it doesn't exist
  mkdir -p "$game_dir"

  # Change to the game directory
  cd "$game_dir"

  # Run the depotdownloader command
  for os in Windows macOS Linux; do
    depotdownloader \
      -os "$(echo $os | tr '[:upper:]' '[:lower:]')" \
      -dir "${game_dir}/${os}" \
      -username $username \
      -remember-password \
      -validate \
      -app "$game_id"
  done
done
