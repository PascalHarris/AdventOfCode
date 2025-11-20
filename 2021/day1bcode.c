#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int *array;
    size_t used;
    size_t size;
} Array;

void initArray(Array *a, size_t initialSize) {
    a->array = malloc(initialSize * sizeof(int));
    a->used = 0;
    a->size = initialSize;
}

void insertArray(Array *a, int element) {
    if (a->used == a->size) {
      a->size *= 2;
      a->array = realloc(a->array, a->size * sizeof(int));
    }
    a->array[a->used++] = element;
}

void freeArray(Array *a) {
    free(a->array);
    a->array = NULL;
    a->used = a->size = 0;
}

int main() {
    FILE *file = fopen("day1input.txt", "r");
    
    if (file != NULL) {
        Array inpData;
        int newNumber, oldNumber = 0xFFFF, counter = 0;
    
        initArray(&inpData, 10);
        while (fscanf(file, "%d", &newNumber) != EOF) { insertArray(&inpData, newNumber); }
        
        for (int i = 2; i < inpData.used; i++) {
            newNumber = inpData.array[i] + inpData.array[i-1] + inpData.array[i-2];
            if ( newNumber > oldNumber ) { counter++; }
            oldNumber = newNumber;
        }
        freeArray(&inpData);
        printf("%d\n", counter);
        return 0;
    }
    return 1;
}