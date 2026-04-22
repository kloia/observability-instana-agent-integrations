#!/bin/bash

CONFIG_FILE="/opt/instana/agent/etc/instana/configuration.yaml"
ZONE=""
TAGS=()

# Arg parse
while [[ $# -gt 0 ]]; do
  case "$1" in
    -z|--zone)
      ZONE="$2"
      shift 2
      ;;
    -t|--tag)
      TAGS+=("$2")
      shift 2
      ;;
    *)
      echo "Kullanım: $0 [-z <availability-zone>] -t <tag1> [-t <tag2> ...]"
      exit 1
      ;;
  esac
done

if [[ ${#TAGS[@]} -eq 0 ]]; then
  echo "ERROR: Must enter at least one tag to run the script."
  exit 1
fi

{
  echo ""
  echo "com.instana.plugin.host:"
  echo "  tags:"
  for tag in "${TAGS[@]}"; do
    echo "    - '$tag'"
  done
  echo "com.instana.plugin.generic.hardware:"
  echo "  enabled: true"
  [[ -n "$ZONE" ]] && echo "  availability-zone: '$ZONE'"
} >> "$CONFIG_FILE"


systemctl restart instana-agent

echo "Configurations added (tags: ${TAGS[*]}${ZONE:+, zone: $ZONE}) and instana-agent restarted."
