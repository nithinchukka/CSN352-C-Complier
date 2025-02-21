// Function for basic arithmetic operations
void basicArithmetic(int a, int b) {
    printf("\nBasic Arithmetic Operations:\n");
    printf("%d + %d = %d\n", a, b, a + b);
    printf("%d - %d = %d\n", a, b, a - b);
    printf("%d * %d = %d\n", a, b, a * b);
    printf("%d / %d = %d\n", a, b, a / b);
    printf("%d %% %d = %d\n", a, b, a % b);
}

// Function for arithmetic with float and double
void floatArithmetic(float x, float y) {
    printf("\nFloating-Point Arithmetic:\n");
    printf("%.2f + %.2f = %.2f\n", x, y, x + y);
    printf("%.2f - %.2f = %.2f\n", x, y, x - y);
    printf("%.2f * %.2f = %.2f\n", x, y, x * y);
    printf("%.2f / %.2f = %.2f\n", x, y, x / y);
}

// Function demonstrating pointer arithmetic
void pointerArithmetic() {
    int arr[] = {10, 20, 30, 40, 50};
    int *ptr = arr; // Points to the first element

    printf("\nPointer Arithmetic:\n");
    printf("Value at ptr: %d\n", *ptr);
    printf("Value at ptr + 1: %d\n", *(ptr + 1));
    printf("Value at ptr + 2: %d\n", *(ptr + 2));
}

// Function demonstrating arithmetic on arrays
void arrayArithmetic(int arr[], int size) {
    int sum = 0, product = 1;

    printf("\nArray Arithmetic:\n");
    for (int i = 0; i < size; i++) {
        sum += arr[i];
        product *= arr[i];
    }

    printf("Sum of array elements: %d\n", sum);
    printf("Product of array elements: %d\n", product);
}

// Function demonstrating arithmetic with typecasting
void typeCastingArithmetic() {
    int a = 10, b = 3;
    double result = (double)a / b;

    printf("\nTypecasting Arithmetic:\n");
    printf("Integer division: %d / %d = %d\n", a, b, a / b);
    printf("Using typecasting: (double) %d / %d = %.2f\n", a, b, result);
}

// Function demonstrating arithmetic with function pointers
int add(int a, int b) { return a + b; }
int subtract(int a, int b) { return a - b; }

void functionPointerArithmetic() {
    int (*operation)(int, int);
    
    operation = add;
    printf("\nFunction Pointer Arithmetic:\n");
    printf("Addition using function pointer: %d\n", operation(10, 5));

    operation = subtract;
    printf("Subtraction using function pointer: %d\n", operation(10, 5));
}

// Main function
int main() {
    int a, b;
    float x, y;
    int arr[] = {2, 4, 6, 8, 10};
    int size = sizeof(arr) / sizeof(arr[0]);

    printf("Enter two integers: ");
    scanf("%d %d", &a, &b);

    printf("Enter two floating-point numbers: ");
    scanf("%f %f", &x, &y);

    // Function calls
    basicArithmetic(a, b);
    floatArithmetic(x, y);
    pointerArithmetic();
    arrayArithmetic(arr, size);
    typeCastingArithmetic();
    functionPointerArithmetic();

    return 0;
}
