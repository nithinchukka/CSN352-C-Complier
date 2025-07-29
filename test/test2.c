void count_with_static() {
    static int counter = 0;
    counter++;
    printf("Static counter = %d\n", counter);
}

int main() {
    int i = 0;

start_loop:
    for (i = 0; i < 10; i++) {
        if (i == 2) {
            continue; 
        }
        if (i == 5) {
            break; 
        }
        printf("i = %d\n", i);
        count_with_static();
    }

    static int repeat = 0;
    if (repeat == 0) {
        repeat = 1;
        printf("Repeating the loop using goto!\n\n");
        goto start_loop;
    }

    printf("Program finished.\n");
    return 0;
}
