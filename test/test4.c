
int main() {
    int count = 0;
    int value = 2;
    int total = 0;
    int evenSum = 0;
    int oddSum = 0;
    while (count < 10) {
        int product = count * value;
        total = total + product;
        count = count + 1;
        value = value + 1;
    }
    printf("\nFinal total = %d\n", total);
    printf("Sum of even numbers = %d\n", evenSum);
    printf("Sum of odd numbers = %d\n", oddSum);
    return 0;
}
