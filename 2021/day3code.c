#include <stdio.h>
#include <stdlib.h>

#define BITCOUNT 12

int invertBits(number) {
    int x = number;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;

    return (number ^ x);
}

int main() {
    FILE *file = fopen("day3input.txt", "r");
    
    if (file != NULL) {

        char diagString[BITCOUNT + 1] = {'\0'};
        int lines = 0, isTrueArray[BITCOUNT] = {0};
    
        while (fscanf(file, "%s", &diagString[0]) != EOF) { 
            lines++;
            for (int i = 0; i < BITCOUNT; i++ ) {
                if (diagString[i] == '1') { isTrueArray[i]++; }
            }
        }
        
        for (int i = 0; i < BITCOUNT; i++ ) {
            diagString[i] = isTrueArray[i] > (lines / 2)?'1':'0';
        }
        int gammaRate = (int)strtol(diagString, NULL, 2);
        int epsilonRate = invertBits(gammaRate);
        
        printf("%d\n", gammaRate * epsilonRate);
        
        return 0;
    }
    return 1;
}