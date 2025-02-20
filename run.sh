#!/bin/bash

clear
make clean
make 
./build/parser.out test.txt | tee output.log
