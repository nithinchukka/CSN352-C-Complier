int main(){
    int a;
    int* p = &a;
    int *q = p;
    int x = *p;
    p = q;
    p = a;
    a = *p;
}