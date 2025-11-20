#include <stdio.h>
#include <stdlib.h>

#define BITCOUNT 12 //5

int findRating(FILE* file, char* diagString, int* isTrueArray, int lines, int og) {
    rewind(file);
    int found = 0;

    while (fscanf(file, "%s", &diagString[0]) != EOF) { 
        if (found) { break; }
        for (int i = 0; i < BITCOUNT; i++ ) {
            char bit = (og?(isTrueArray[i] >= (lines / 2)):(isTrueArray[i] <= (lines / 2)))?'1':'0';
            
            if (diagString[i] == bit) {
                found = 1;
            } else { 
                found = 0;
                break; 
            }
            if (diagString[i] == '1') { isTrueArray[i]++; }
        }
    }
    printf("%s\n\n",diagString);
    return (int)strtol(diagString, NULL, 2);
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
        
        int oGen = findRating(file, diagString, isTrueArray, lines, 1);
        int scrub = findRating(file, diagString, isTrueArray, lines, 0);
        
        printf("%d * %d = %d\n", oGen, scrub, oGen * scrub);
        
        return 0;
    }
    return 1;
}