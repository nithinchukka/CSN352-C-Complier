
int average(int x, int y, int z) {
    int sum = x + y + z;
    return sum / 3;
}

int minOfThree(int x, int y, int z) {
    int min = x;
    if (y < min)
        min = y;
    if (z < min)
        min = z;
    return min;
}

int weightedSum(int a, int b, int c, int w1, int w2, int w3) {
    return (a * w1) + (b * w2) + (c * w3);
}


int analyze(int a, int b, int c) {
    int avg = average(a, b, c);
    int min = minOfThree(a, b, c);
    int wsum = weightedSum(a, b, c, 1, 2, 3);
    if (avg > min) {
        return wsum + avg;
    } else {
        return wsum - min;
    }
}


int main() {
    int a = 4, b = 7, c = 2;
    int result = analyze(a, b, c);
    return 0;
}

