int glb;
int glb1 = 10;

int glb2;

struct foo
{
    int a;
    int b;
    foo *next;
};

/*static*/ int bar(int a, float b)
{
    int lcl = 10;
    while (b)
    {
        b--;
    }
    if (a == 0)
        return 0;
    bar(--a, a + b + lcl); // what if I use a++;
    return 1;
}

int main()
{
    int a = 100, b[20], ret;
    for (int i = 0; i < a; i++)
    {
        int b = 0;
        b += i;
        if (b % 2 != b % 3)
            printf("%d\n", a + b);
        else if (b % 2 == 0)
        {
            switch (b)
            {
            case -100:
                printf("1\n");
                break;
            case 1000:
                printf("2\n");
            default:
                printf("2\n");
            }
        }
        // b[19] = i;
        ret = i;
    }
    int *c;
    foo newS;
    newS.a = 1;
    // printf("Final = %d", newS[3].b + ret);
    // if (*(b + 2) == 0)
    //     return 1;
    // bar(1, *b);
    return 0;
}