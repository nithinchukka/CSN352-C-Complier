# Directories
SRCDIR = src
BUILDDIR = build

# Tools
YACC = bison
LEX = flex
CC = g++
LDFLAGS = -lfl -ll -lm -g
CFLAGS = -I$(BUILDDIR)

# Files
LEX_SRC = $(SRCDIR)/lexer.l
YACC_SRC = $(SRCDIR)/parser.y
CODEGEN_SRC = $(SRCDIR)/codeGen.cpp

LEX_OUT = $(BUILDDIR)/lex.yy.c
YACC_OUT = $(BUILDDIR)/y.tab.cc
OUTPUT_BIN = $(BUILDDIR)/compiler.out

# Create build directory if not exists
$(shell mkdir -p $(BUILDDIR))

# Default target
all: build

# Build parser, lexer, and codegen
build: $(LEX_SRC) $(YACC_SRC) $(CODEGEN_SRC)
	$(YACC) -d -o $(YACC_OUT) $(YACC_SRC)
	$(LEX) -o$(LEX_OUT) $(LEX_SRC)
	$(CC) $(CFLAGS) $(LEX_OUT) $(YACC_OUT) $(CODEGEN_SRC) -o $(OUTPUT_BIN) $(LDFLAGS)
	@echo "Build completed!"

# Clean build artifacts
clean:
	rm -f $(BUILDDIR)/*
	@echo "Cleaned build files!"

.PHONY: all build clean
