
int main(){
    int arr[5] = {1,2,3,4,5};
    int *p = arr;
    p = arr + 1;
    ++p;
    int x = 4;
    p = &x;
    int a = *(p+4);
    int x = arr[6];
}
