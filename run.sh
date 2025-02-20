#!/bin/bash

clear
make clean
make 
./build/parser.out text.txt | tee output.log
