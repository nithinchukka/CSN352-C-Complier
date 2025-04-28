int main(){
    int a = 4;
    switch(a){
        case 1:
        {
            a--;
            break;
        }
        case 2:
        {
            a += 2;
            break;
        }
        case 3:
        {
            a /= 2;
            if(a==4){
                break;
            }
            break;
        }
        case 4:
        {
            for(int i=0;i<3;i++){
                a += i;
            }
            break;
        }
        default:
        {
            a += 5;
            break;
        }
    }
}