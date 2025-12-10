#import <Foundation/Foundation.h>
#include <string.h>

/*
 * Solve Ax = b, minimize sum(x), x >= 0 integers
 * 
 * Strategy:
 * 1. Use Gaussian elimination to find the rank and identify pivot/free variables
 * 2. Express pivot variables in terms of free variables
 * 3. Search only over free variables (typically 0-3 free vars)
 * 4. For each assignment of free vars, compute pivot vars and check validity
 */

typedef struct { long long n, d; } Rat;

long long gcd(long long a, long long b) { 
    a = llabs(a); b = llabs(b);
    while(b) { long long t = b; b = a % b; a = t; } 
    return a ? a : 1; 
}

Rat rat(long long n, long long d) {
    if (d == 0) return (Rat){0, 1};
    if (d < 0) { n = -n; d = -d; }
    long long g = gcd(n, d);
    return (Rat){n/g, d/g};
}

Rat addr(Rat a, Rat b) { return rat(a.n*b.d + b.n*a.d, a.d*b.d); }
Rat subr(Rat a, Rat b) { return rat(a.n*b.d - b.n*a.d, a.d*b.d); }
Rat mulr(Rat a, Rat b) { return rat(a.n*b.n, a.d*b.d); }
Rat divr(Rat a, Rat b) { return rat(a.n*b.d, a.d*b.n); }

long long solveMachine(int m, int n, int **A, long long *b) {
    // m = rows (counters), n = cols (buttons)
    // Copy to augmented matrix with rationals
    Rat **M = malloc(m * sizeof(Rat*));
    for (int i = 0; i < m; i++) {
        M[i] = malloc((n+1) * sizeof(Rat));
        for (int j = 0; j < n; j++) M[i][j] = rat(A[i][j], 1);
        M[i][n] = rat(b[i], 1);
    }
    
    int *pivotCol = malloc(m * sizeof(int));
    int *isPivot = calloc(n, sizeof(int));
    int rank = 0;
    
    for (int col = 0; col < n && rank < m; col++) {
        // Find pivot
        int prow = -1;
        for (int i = rank; i < m; i++) {
            if (M[i][col].n != 0) { prow = i; break; }
        }
        if (prow < 0) continue;
        
        // Swap rows
        Rat *tmp = M[rank]; M[rank] = M[prow]; M[prow] = tmp;
        pivotCol[rank] = col;
        isPivot[col] = 1;
        
        // Eliminate below AND above (reduced row echelon)
        for (int i = 0; i < m; i++) {
            if (i != rank && M[i][col].n != 0) {
                Rat f = divr(M[i][col], M[rank][col]);
                for (int j = col; j <= n; j++) {
                    M[i][j] = subr(M[i][j], mulr(f, M[rank][j]));
                }
            }
        }
        rank++;
    }
    
    // Check consistency
    for (int i = rank; i < m; i++) {
        if (M[i][n].n != 0) {
            for (int i = 0; i < m; i++) free(M[i]);
            free(M); free(pivotCol); free(isPivot);
            return -1; // No solution
        }
    }
    
    // Identify free variables
    int *freeVars = malloc(n * sizeof(int));
    int numFree = 0;
    for (int j = 0; j < n; j++) {
        if (!isPivot[j]) freeVars[numFree++] = j;
    }
    
    // For each pivot row, M[i][pivotCol[i]] is the pivot (should be 1 after normalization)
    // Normalize pivot rows
    for (int i = 0; i < rank; i++) {
        int pc = pivotCol[i];
        Rat pv = M[i][pc];
        for (int j = 0; j <= n; j++) {
            M[i][j] = divr(M[i][j], pv);
        }
    }
    
    // Find max value any variable could take
    long long maxVal = 0;
    for (int i = 0; i < m; i++) {
        if (b[i] > maxVal) maxVal = b[i];
    }
    
    long long bestSum = LLONG_MAX;
    
    // Search over free variables (each from 0 to maxVal)
    // Number of combinations: (maxVal+1)^numFree
    long long numCombos = 1;
    for (int i = 0; i < numFree; i++) {
        numCombos *= (maxVal + 1);
        if (numCombos > 100000000LL) {
            // Too many - fall back to greedy or heuristic
            numCombos = 100000000LL;
            break;
        }
    }
    
    long long *freeVals = calloc(numFree, sizeof(long long));
    
    for (long long combo = 0; combo < numCombos; combo++) {
        // Decode combo into freeVals
        long long tmp = combo;
        for (int i = 0; i < numFree; i++) {
            freeVals[i] = tmp % (maxVal + 1);
            tmp /= (maxVal + 1);
        }
        
        // Compute pivot variables
        long long sum = 0;
        int valid = 1;
        
        // Add free variable values to sum
        for (int i = 0; i < numFree; i++) {
            sum += freeVals[i];
        }
        if (sum >= bestSum) continue; // Prune early
        
        // For each pivot variable, compute its value
        for (int i = 0; i < rank && valid; i++) {
            int pc = pivotCol[i];
            // x[pc] = M[i][n] - sum over free vars j of M[i][j]*freeVals[mapping[j]]
            Rat val = M[i][n];
            for (int fi = 0; fi < numFree; fi++) {
                int fv = freeVars[fi];
                val = subr(val, mulr(M[i][fv], rat(freeVals[fi], 1)));
            }
            
            // Check if val is a non-negative integer
            if (val.d != 1 || val.n < 0) {
                valid = 0;
            } else {
                sum += val.n;
                if (sum >= bestSum) valid = 0; // Prune
            }
        }
        
        if (valid && sum < bestSum) {
            bestSum = sum;
        }
    }
    
    for (int i = 0; i < m; i++) free(M[i]);
    free(M); free(pivotCol); free(isPivot); free(freeVars); free(freeVals);
    
    return (bestSum == LLONG_MAX) ? -1 : bestSum;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) { printf("Usage: solver <input>\n"); return 1; }
        
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        long long totalPresses = 0;
        
        for (NSString *line in lines) {
            NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimmed.length == 0) continue;
            
            // Parse buttons
            NSMutableArray *buttons = [NSMutableArray array];
            NSRegularExpression *buttonRegex = [NSRegularExpression regularExpressionWithPattern:@"\\(([0-9,]+)\\)" options:0 error:nil];
            NSArray *buttonMatches = [buttonRegex matchesInString:trimmed options:0 range:NSMakeRange(0, trimmed.length)];
            
            for (NSTextCheckingResult *match in buttonMatches) {
                NSString *buttonStr = [trimmed substringWithRange:[match rangeAtIndex:1]];
                NSArray *indices = [buttonStr componentsSeparatedByString:@","];
                NSMutableArray *buttonIndices = [NSMutableArray array];
                for (NSString *idx in indices) {
                    [buttonIndices addObject:@([idx integerValue])];
                }
                [buttons addObject:buttonIndices];
            }
            
            // Parse targets
            NSMutableArray *targetList = [NSMutableArray array];
            NSRegularExpression *targetRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{([0-9,]+)\\}" options:0 error:nil];
            NSArray *targetMatches = [targetRegex matchesInString:trimmed options:0 range:NSMakeRange(0, trimmed.length)];
            
            if (targetMatches.count > 0) {
                NSString *targetStr = [trimmed substringWithRange:[targetMatches[0] rangeAtIndex:1]];
                NSArray *targetParts = [targetStr componentsSeparatedByString:@","];
                for (NSString *t in targetParts) {
                    [targetList addObject:@([t integerValue])];
                }
            }
            
            if (buttons.count == 0 || targetList.count == 0) continue;
            
            int numButtons = (int)buttons.count;
            int numCounters = (int)targetList.count;
            
            // Build matrix A[counter][button]
            int **matrix = malloc(numCounters * sizeof(int*));
            for (int i = 0; i < numCounters; i++) {
                matrix[i] = calloc(numButtons, sizeof(int));
            }
            
            for (int b = 0; b < numButtons; b++) {
                for (NSNumber *idx in buttons[b]) {
                    int ci = [idx intValue];
                    if (ci < numCounters) matrix[ci][b] = 1;
                }
            }
            
            long long *targetArr = malloc(numCounters * sizeof(long long));
            for (int i = 0; i < numCounters; i++) {
                targetArr[i] = [targetList[i] longLongValue];
            }
            
            long long presses = solveMachine(numCounters, numButtons, matrix, targetArr);
            if (presses >= 0) totalPresses += presses;
            
            for (int i = 0; i < numCounters; i++) free(matrix[i]);
            free(matrix);
            free(targetArr);
        }
        
        printf("%lld\n", totalPresses);
    }
    return 0;
}
