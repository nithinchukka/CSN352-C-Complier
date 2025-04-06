
int main() {
    int count = 0;
    int sum = 0;
    int multiplier = 2;
    do {
        int value = count * multiplier;
        sum = sum + value;
        count = count + 1;
    } while (count < 5);
    printf("Final sum = %d\n", sum);
    return 0;
}
