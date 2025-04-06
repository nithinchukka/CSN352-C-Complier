
struct Point{
    int a;
    double b;
    int c;
    float f;
}k;

int main(){
    Point p;
    int x = p.c;
    int d = p.f;
    int w = p.b;
    w++;
    int *q = &(p.b+d);
    int m = *q;
}
