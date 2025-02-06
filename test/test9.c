class MyClass {
private:
    int a;

public:
    MyClass() : a(0) {}
    
    void setA(int x) { a = x; }
    int getA() const { return a; }

    static void staticMethod() {}

    virtual void print() { cout << "a: " << a << endl; }

protected:
    void setAProtected(int x) { a = x; }
};

int main() {
    MyClass obj;
    obj.setA(5);
    obj.print();
    MyClass::staticMethod();
    return 0;
}
