#include <stdio.h>

int main() {
    FILE *file = fopen("day1input.txt", "r");
    
    if (file != NULL) {
        int newNumber, oldNumber = 0xFFFF, counter = 0;
    
        while (fscanf(file, "%d", &newNumber) != EOF) {
            if (newNumber > oldNumber) { counter++; }
            oldNumber = newNumber;
        }
        printf("%d\n", counter);
        return 0;
    }
    return 1;
}