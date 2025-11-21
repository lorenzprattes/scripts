    
#!/bin/bash

while getopts ":w:" opt; do
  case $opt in
    w)
      WEBHOOK_URL="$OPTARG"
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument." >&2
      exit 2
      ;;
    \?)
      echo "Usage: $0 [-w webhook_url] message..." >&2
      exit 2
      ;;
  esac
done
shift $((OPTIND - 1))

MESSAGE="$*"


if [ -z "$WEBHOOK_URL" ]; then
  echo "Error: DISCORD_WEBHOOK_URL environment variable is not set." >&2
  exit 2
fi

if [ -z "$MESSAGE" ]; then
  echo "Error: No message provided."
  exit 1
fi

ESCAPED_MESSAGE=$(echo "$MESSAGE" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\": \"$ESCAPED_MESSAGE\"}" \
     $WEBHOOK_URL

