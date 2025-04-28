# CSN352-C-Compiler
A minimal end-to-end compiler for a C-like language.

---

## Installation & Compilation

### Prerequisites
Make sure you have the following installed:
- Flex
- Bison
- G++

---

### Build the Compiler
To compile the project, run:
```bash
make
```
This will generate `compiler.out` inside the `build/` directory.

---

### Running the Compiler
To run the compiler on a test file:
```bash
./build/compiler.out <test_file_path>
```

Or to run all provided test cases:
```bash
./run.sh
```

---

### Cleaning Up
To clean the build files and reset:
```bash
make clean
```

---

## Output Files
- Intermediate 3-address code (`.3ac`) will be stored in `output/3ac/`
- Generated assembly code (`.s`) will be stored in `output/asm/`
- Output filenames will match the input filenames.

---

## Running the Assembly Code
You can execute the generated `.s` files in two ways:

### 1. Online Simulator
Use [this x86-64 online simulator](https://app.x64.halb.it/) to upload and run `.s` files directly.

### 2. GCC on Local Machine
Compile and run the assembly file locally:  
**Note:** If you are using this method, remove the code section labeled `_start:` from the `<file_name>.s` file before compiling.

```bash
gcc <file_name>.s
./a.out
```


---
