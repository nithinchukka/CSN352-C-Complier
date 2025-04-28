int main(){
    int x = 3;
    int y = 2;
    int a = 10;
    if((x>2) && (y>5)){
        a++;
    }
    else if (x > 1){
        a--;
    }
    else{
        a *= 2;
    }
    int w = 11;
    for(int i=0;i<10;i++){
        if(i%2){
            w++;
        }
        else w-=2;
        int a = w+3;
        if(a==4){
            break;
        }
    }
    while(w > 2){
        w++;
        if(w == 6){
            continue;
        }
        else if(w==8){
            break;
        }
    }
    do{
        x++;
        y--;
    }while(x<y);
    printf("%d,  %d, %d, %d" , a, x, y,w);
}