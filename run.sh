#!/bin/bash

if [ -z "$(ls -A test)" ]; then
    echo "Empty Test directory"
    exit 1
fi

make lexer
echo " " | tee output.log

for file in test/*; do
    echo "Running $file" | tee -a output.log
    echo " " | tee -a output.log
    ./build/lexer.out $file | tee -a output.log
done

echo "Output saved to output.log"