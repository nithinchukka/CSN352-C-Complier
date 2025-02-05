# Directories
BUILDDIR = build
SRCDIR = src

# Tools
LEX = flex
CC = g++
LDFLAGS = -lfl
CFLAGS = -I$(SRCDIR)

# Files
LEX_SRC = $(SRCDIR)/lexer.l
LEX_OUT = $(BUILDDIR)/lex.yy.cc
LEX_BIN = $(BUILDDIR)/lexer.out

# Create build directory if not exists
$(shell mkdir -p $(BUILDDIR))

# Default target
all: lexer

# Build lexer
lexer: $(LEX_SRC)
	$(LEX) -o$(LEX_OUT) $(LEX_SRC)
	$(CC) $(LEX_OUT) -o $(LEX_BIN) $(CFLAGS) $(LDFLAGS)
	@echo "Lexer built successfully!"

# Run lexer with input file
runlexer: lexer
	@if [ -z "$(FILE)" ]; then \
		echo "Error: No input file specified."; \
		echo "Usage: make runlexer FILE=<your_input_file>"; \
		echo "Example: make runlexer FILE=src/test.c"; \
		exit 1; \
	fi
	@echo "Running lexer on $(FILE)..."
	@echo " "
	./$(LEX_BIN) "$(FILE)"

# Clean build artifacts
clean:
	rm -rf $(BUILDDIR)/*
	rmdir $(BUILDDIR)
	@echo "Cleaned build files!"

.PHONY: all lexer runlexer clean
