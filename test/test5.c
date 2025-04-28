int foo(int a, int b) {
    int z = 1;
    goto skip;
    z = 11;
skip:
    return z;
}

int main() {
    int x = 10; 
    x /= foo(2, 3) + foo(4, 5);
}
