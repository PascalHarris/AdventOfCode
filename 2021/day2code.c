#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    FILE *file = fopen("day2input.txt", "r");
        
    if (file != NULL) {
        int depth = 0, hpos = 0;
        size_t len = 0;
        char *line = NULL, *remains;

        while (getline(&line, &len, file) != EOF) {
            char *tokenline = (char*)calloc(strlen(line)+1, sizeof(char));
            strncpy(tokenline, line, strlen(line));
            char *instr = strtok_r(tokenline, " ", &remains);
            char *value = strtok_r(NULL, " ", &remains);
    
            if (strstr(instr, "forward")) {
                hpos += atoi(value);
            } else if (strstr(instr, "down")) {
                depth += atoi(value);
            } else if (strstr(instr, "up")) {
                depth -= atoi(value);
            }
            free(tokenline);
        }
        printf("%d\n", depth*hpos);
        return 0;
    }
    return 1;
}