struct Test{
    int x;
    int y;
    int arr[10];
};

int main(){
    Test t;
    t.x = 4;
    t.x = t.y+5;
    t.arr[2]++;
}