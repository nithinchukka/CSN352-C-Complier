# CSN352-C-Compiler
A minimal end-to-end compiler for a C-like language.

## Installation & Compilation
### Prerequisites
Ensure you have the following installed:
- **Flex** (Lexical analyzer generator)
- **G++** (C++ compiler)

### Build the Lexer
To compile the lexer, run:
```sh
make
```
This will generate `lexer.out` inside the `build/` directory.

### Running the Lexer
To run the lexer on a test file, use:
```sh
make runlexer FILE=test/test1.c
```
Alternatively, use the provided script to run all test cases:
```sh
bash run.sh
```
The output will be stored in `output.log`.

### Cleaning Build Files
To remove compiled files and reset the build directory, run:
```sh
make clean
```
