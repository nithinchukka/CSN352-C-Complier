#!/bin/bash

clear
make clean
make 

if [ -z "$(ls -A test)" ]; then
    echo "Empty Test directory"
    exit 1
fi

echo " " | tee -a output.log

for file in test/*; do
    echo "---------------------------------" | tee -a output.log
    echo "Processing File: $file" | tee -a output.log
    echo "---------------------------------" | tee -a output.log
    echo " " | tee -a output.log

    ./build/parser.out "$file" | tee -a output.log

    echo " " | tee -a output.log
    echo "---------------------------------" | tee -a output.log
    echo "  Finished Processing $file  " | tee -a output.log
    echo "---------------------------------" | tee -a output.log
    echo " " | tee -a output.log
done
