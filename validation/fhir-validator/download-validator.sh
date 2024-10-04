#!/bin/bash

# define constants
REPO="hapifhir/org.hl7.fhir.core"
FILE_PATTERN="validator_cli.jar"
BACKUP_FILE="validator_cli.jar.bak"

# function to get the current validator version from the jar file
get_current_version() {
  if [[ -f "$FILE_PATTERN" ]]; then
    echo "Checking current version of $FILE_PATTERN..."
    VERSION=$(java -jar "$FILE_PATTERN" help 2>&1 | grep "FHIR Validation tool Version" | awk '{print $5}')
    echo "Current validator version: $VERSION"
  else
    echo "No existing validator_cli.jar found."
    VERSION="none"
  fi
}

# function to get the latest release version from GitHub
get_latest_version() {
  echo "Checking latest version from GitHub releases..."
  LATEST_VERSION=$(gh release list --repo "$REPO" --limit 1 | awk '{print $1}')
  echo "Latest release version: $LATEST_VERSION"
}

# function to download the new validator jar file
download_validator_cli() {
  # only back up the file if it exists
  if [[ -f "$FILE_PATTERN" ]]; then
    echo "Backing up the existing validator_cli.jar to $BACKUP_FILE..."
    mv "$FILE_PATTERN" "$BACKUP_FILE"
  fi

  echo "Downloading the latest validator_cli.jar (version $LATEST_VERSION)..."
  gh release download --repo "$REPO" --pattern "$FILE_PATTERN" --clobber

  if [ $? -eq 0 ]; then
    echo "Download successful."
    # remove backup file only if download succeeds
    if [[ -f "$BACKUP_FILE" ]]; then
      echo "Removing backup file..."
      # use `command rm` to avoid aliasing
      command rm "$BACKUP_FILE" || {
        echo "rm failed or is aliased. Trying trash-put..."
        trash-put "$BACKUP_FILE" || echo "Failed to remove backup file, please manually delete."
      }
    fi
  else
    echo "Download failed."
    # restore backup if download failed
    if [[ -f "$BACKUP_FILE" ]]; then
      echo "Restoring from backup."
      mv "$BACKUP_FILE" "$FILE_PATTERN"
    fi
    exit 1
  fi
}

# function to compare versions and trigger the update if needed
compare_and_update() {
  if [[ "$VERSION" != "$LATEST_VERSION" ]]; then
    echo "Current version ($VERSION) is different from the latest version ($LATEST_VERSION)."
    download_validator_cli
  else
    echo "Current version ($VERSION) is up-to-date."
  fi
}

get_current_version
get_latest_version
compare_and_update
