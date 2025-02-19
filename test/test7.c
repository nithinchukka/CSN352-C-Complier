struct Person {
    int age;
    char name[20];
    string name = "John";
};

int main() {
    struct Person p;
    p.age = 30;
    return 0;
}
