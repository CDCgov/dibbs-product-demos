#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# unicode symbols
CHECK_MARK="\u2714"
CROSS_MARK="\u2718"

# list of services and their respective image names
services=(
  "fhir-converter ghcr.io/cdcgov/phdi/fhir-converter:latest"
  "message-parser ghcr.io/cdcgov/phdi/message-parser:latest"
)

# default to both checking and updating
check_only=false
update_only=false

# parse command-line options
while [[ "$1" ]]; do
  case "$1" in
  --check-only)
    check_only=true
    ;;
  --update)
    update_only=true
    ;;
  esac
  shift
done

echo "Processing Docker images..."

# loop through the services and pull/update if needed
for service_info in "${services[@]}"; do
  # split the service_info into service and image
  service=$(echo "$service_info" | awk '{print $1}')
  image=$(echo "$service_info" | awk '{print $2}')

  # check if the local image exists
  local_image=$(docker inspect --format='{{index .RepoDigests 0}}' "$image" 2>/dev/null)

  if [ -z "$local_image" ]; then
    # if running in --update mode, pull the image
    if [ "$update_only" = true ]; then
      echo "Pulling $service..."
      pull_output=$(docker pull "$image" 2>&1)
      if echo "$pull_output" | grep -q "Downloaded newer image"; then
        status="${GREEN}$CHECK_MARK Successfully installed${NC}"
      elif echo "$pull_output" | grep -q "Image is up to date"; then
        status="${GREEN}$CHECK_MARK Already up to date${NC}"
      else
        status="${RED}$CROSS_MARK Failed to install${NC}"
      fi
      echo -e "$service:"
      echo -e "  Status         : $status"
      echo ""
    else
      # if not in update mode, warn the user
      echo -e "${YELLOW}Warning:${NC} $service image not found locally."
      echo -e "You need to run ${YELLOW}'./dibbs-version.sh --update'${NC} to install it."
      echo ""
    fi
    continue
  fi

  # extract the digest for checking or after pulling
  local_digest=$(echo "$local_image" | awk -F'@' '{print $2}')

  # check mode: check if the image is up to date
  if [ "$check_only" = true ] || [ "$update_only" = false ]; then
    echo "Checking $service..."
    pull_output=$(docker pull "$image" 2>&1)
    if echo "$pull_output" | grep -q "Image is up to date"; then
      status="${GREEN}$CHECK_MARK Up to date${NC}"
    else
      status="${RED}$CROSS_MARK Needs update${NC}"
    fi

    echo -e "$service:"
    echo -e "  Local Digest   : $local_digest"
    echo -e "  Status         : $status"
    echo ""
  fi

  # update mode: if image exists and needs an update, pull it
  if [ "$update_only" = true ] && [ -n "$local_image" ]; then
    echo "Updating $service..."
    pull_output=$(docker pull "$image" 2>&1)
    if echo "$pull_output" | grep -q "Downloaded newer image"; then
      status="${GREEN}$CHECK_MARK Successfully updated${NC}"
    elif echo "$pull_output" | grep -q "Image is up to date"; then
      status="${GREEN}$CHECK_MARK Already up to date${NC}"
    else
      status="${RED}$CROSS_MARK Failed to update${NC}"
    fi

    echo -e "$service:"
    echo -e "  Local Digest   : $(docker inspect --format='{{index .RepoDigests 0}}' "$image" 2>/dev/null | awk -F'@' '{print $2}')"
    echo -e "  Status         : $status"
    echo ""
  fi
done
