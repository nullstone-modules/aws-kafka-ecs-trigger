#!/bin/bash

echo "Running from Kafka trigger..."

if [ -n "$INPUT_PAYLOAD" ]; then
  echo "INPUT_PAYLOAD:"
  echo "$INPUT_PAYLOAD"

  echo "Decoded value:"
  echo "$INPUT_PAYLOAD" | base64 -d || true
else
  echo "No INPUT_PAYLOAD environment variable set."
fi
