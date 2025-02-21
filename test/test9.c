struct Student {
    int id;
    char name[50];
    float marks;
};

int main() {
    struct Student s1 = {101, "Alice", 89.5};
    struct Student *ptr = &s1;
    (*ptr).marks += 5;

    return 0;
}
