#!/bin/bash

# Universal script to send POST requests with static or dynamic fields
# Usage: ./script.sh <field1=value1> <field2=value2> ... <number_of_requests>

# API URL
API_URL="https://example.com/api" # Replace with your endpoint

# Generate a random string of letters (default length: 10)
generate_random_string() {
  local length=${1:-10}
  LC_CTYPE=C tr -dc 'a-zA-Z' < /dev/urandom | head -c "$length"
}

# Generate a random number in a given range (default: 100000 to 999999)
generate_random_number() {
  local min=${1:-100000}
  local max=${2:-999999}
  echo $((RANDOM % (max - min + 1) + min))
}

# Check if enough arguments are provided
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <field1=value1> <field2=value2> ... <number_of_requests>"
  exit 1
fi

# Extract the number of requests (last argument)
NUM_REQUESTS="${!#}" # Last argument is the number of requests
if ! [[ "$NUM_REQUESTS" =~ ^[0-9]+$ ]]; then
  echo "Error: Last argument must be a number (number of requests)."
  exit 1
fi

# Parse field-value pairs
declare -A FIELDS
for arg in "${@:1:$(($# - 1))}"; do
  key=$(echo "$arg" | cut -d'=' -f1)
  value=$(echo "$arg" | cut -d'=' -f2)
  FIELDS["$key"]="$value"
done

# Send POST requests
for ((i = 1; i <= NUM_REQUESTS; i++)); do
  # Prepare JSON payload dynamically
  JSON_PAYLOAD="{"
  for key in "${!FIELDS[@]}"; do
    case "${FIELDS[$key]}" in
      randomstring*)
        length=$(echo "${FIELDS[$key]}" | grep -o '[0-9]*' | head -n 1)
        value=$(generate_random_string "${length:-10}")
        ;;
      randomnumber*)
        range=$(echo "${FIELDS[$key]}" | grep -o '[0-9]\+')
        min=$(echo "$range" | head -n 1)
        max=$(echo "$range" | tail -n 1)
        value=$(generate_random_number "${min:-100000}" "${max:-999999}")
        ;;
      *)
        value="${FIELDS[$key]}"
        ;;
    esac
    JSON_PAYLOAD+="\"$key\":\"$value\","
  done
  JSON_PAYLOAD=${JSON_PAYLOAD%,} # Remove trailing comma
  JSON_PAYLOAD+="}"

  # Send POST request
  RESPONSE=$(curl -s -L -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD")

  echo "Request $i: $RESPONSE"
done

echo "All requests completed!"
