#!/bin/bash

if [ -z "$(ls -A test)" ]; then
    echo "Empty Test directory"
    exit 1
fi

make lexer
echo " "

for file in test/*; do
    echo "Running $file"
    echo " "
    ./build/lexer.out $file
done
