int fac(int a)
{
    if (a == 1)
        return 1;
    return a * fac(a - 1);
}

int main()
{
    int c = fac(5);
    return 0;
}
