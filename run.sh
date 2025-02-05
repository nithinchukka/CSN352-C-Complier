#!/bin/bash

if [ -z "$(ls -A test)" ]; then
    echo "Empty Test directory"
    exit 1
fi

for file in test/*; do
    make runlexer FILE="$file"
done
