
// Function to demonstrate pointer arithmetic
void pointerArithmetic() {
    int arr[] = {10, 20, 30, 40, 50};
    int *ptr = arr; // Points to the first element

    printf("Pointer Arithmetic:\n");
    for (int i = 0; i < 5; i++) {
        printf("Value at ptr[%d]: %d\n", i, *(ptr + i));
    }
}

// Function to demonstrate pointer to pointer
void pointerToPointer() {
    int num = 10;
    int *ptr = &num;
    int **ptr2 = &ptr;

    printf("\nPointer to Pointer:\n");
    printf("Value of num: %d\n", num);
    printf("Value using ptr: %d\n", *ptr);
    printf("Value using ptr2: %d\n", **ptr2);
}

// Function to demonstrate function pointers
void greet() {
    printf("\nHello from function pointer!\n");
}

void functionPointerDemo() {
    void (*funcPtr)(); // Declaring function pointer
    funcPtr = greet;   // Assign function address
    funcPtr();         // Calling function via pointer
}

// Function to demonstrate dynamic memory allocation
void dynamicMemory() {
    int *ptr = (int *)malloc(5 * sizeof(int));

    printf("\nDynamic Memory Allocation:\n");
    for (int i = 0; i < 5; i++) {
        ptr[i] = (i + 1) * 10;
    }

    for (int i = 0; i < 5; i++) {
        printf("Value at ptr[%d]: %d\n", i, ptr[i]);
    }

    free(ptr); // Free allocated memory
}

// Function to demonstrate array of pointers
void arrayOfPointers() {
    char *names[] = {"Alice", "Bob", "Charlie", "David"};
    printf("\nArray of Pointers:\n");
    for (int i = 0; i < 4; i++) {
        printf("Name[%d]: %s\n", i, names[i]);
    }
}

// Main function
int main() {
    pointerArithmetic();
    pointerToPointer();
    functionPointerDemo();
    dynamicMemory();
    arrayOfPointers();

    return 0;
}
