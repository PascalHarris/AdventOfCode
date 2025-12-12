#import <Foundation/Foundation.h>
#include <string.h>
#include <stdlib.h>

/*
 * Polyomino Packing Solver using Dancing Links (https://en.wikipedia.org/wiki/Dancing_links)
 */

#define MAX_SHAPES 10
#define MAX_ORIENTATIONS 8
#define MAX_CELLS 20

typedef struct {
    int numCells;
    int cells[MAX_CELLS][2];
} Shape;

typedef struct {
    int numOrientations;
    Shape orientations[MAX_ORIENTATIONS];
} ShapeVariants;

ShapeVariants allShapes[MAX_SHAPES];
int numShapes = 0;

// DLX structures - dynamically allocated per problem
int *L, *R, *U, *D, *C, *S;
int nodeCount;
int maxNodes;
int solved;

void cover(int c) {
    L[R[c]] = L[c];
    R[L[c]] = R[c];
    for (int i = D[c]; i != c; i = D[i]) {
        for (int j = R[i]; j != i; j = R[j]) {
            U[D[j]] = U[j];
            D[U[j]] = D[j];
            S[C[j]]--;
        }
    }
}

void uncover(int c) {
    for (int i = U[c]; i != c; i = U[i]) {
        for (int j = L[i]; j != i; j = L[j]) {
            S[C[j]]++;
            D[U[j]] = j;
            U[D[j]] = j;
        }
    }
    R[L[c]] = c;
    L[R[c]] = c;
}

void search(int k) {
    if (solved) return;
    
    if (R[0] == 0) {
        solved = 1;
        return;
    }
    
    // Choose column with minimum size
    int minSize = S[R[0]];
    int c = R[0];
    for (int j = R[0]; j != 0; j = R[j]) {
        if (S[j] < minSize) {
            minSize = S[j];
            c = j;
        }
    }
    
    if (minSize == 0) return;
    
    cover(c);
    
    for (int r = D[c]; r != c && !solved; r = D[r]) {
        for (int j = R[r]; j != r; j = R[j]) {
            cover(C[j]);
        }
        
        search(k + 1);
        
        for (int j = L[r]; j != r; j = L[j]) {
            uncover(C[j]);
        }
    }
    
    uncover(c);
}

void normalizeShape(Shape *s) {
    if (s->numCells == 0) return;
    int minR = s->cells[0][0], minC = s->cells[0][1];
    for (int i = 1; i < s->numCells; i++) {
        if (s->cells[i][0] < minR) minR = s->cells[i][0];
        if (s->cells[i][1] < minC) minC = s->cells[i][1];
    }
    for (int i = 0; i < s->numCells; i++) {
        s->cells[i][0] -= minR;
        s->cells[i][1] -= minC;
    }
}

int compareCells(const void *a, const void *b) {
    const int *ca = (const int *)a;
    const int *cb = (const int *)b;
    if (ca[0] != cb[0]) return ca[0] - cb[0];
    return ca[1] - cb[1];
}

void sortShape(Shape *s) {
    qsort(s->cells, s->numCells, sizeof(int[2]), compareCells);
}

int shapesEqual(Shape *a, Shape *b) {
    if (a->numCells != b->numCells) return 0;
    for (int i = 0; i < a->numCells; i++) {
        if (a->cells[i][0] != b->cells[i][0] || a->cells[i][1] != b->cells[i][1]) return 0;
    }
    return 1;
}

Shape rotateShape(Shape *s) {
    Shape r;
    r.numCells = s->numCells;
    for (int i = 0; i < s->numCells; i++) {
        r.cells[i][0] = s->cells[i][1];
        r.cells[i][1] = -s->cells[i][0];
    }
    normalizeShape(&r);
    sortShape(&r);
    return r;
}

Shape reflectShape(Shape *s) {
    Shape r;
    r.numCells = s->numCells;
    for (int i = 0; i < s->numCells; i++) {
        r.cells[i][0] = s->cells[i][0];
        r.cells[i][1] = -s->cells[i][1];
    }
    normalizeShape(&r);
    sortShape(&r);
    return r;
}

void generateOrientations(Shape *base, ShapeVariants *sv) {
    Shape variants[8];
    int count = 0;
    
    Shape current = *base;
    normalizeShape(&current);
    sortShape(&current);
    
    for (int rot = 0; rot < 4; rot++) {
        int unique = 1;
        for (int i = 0; i < count; i++) {
            if (shapesEqual(&current, &variants[i])) { unique = 0; break; }
        }
        if (unique) variants[count++] = current;
        current = rotateShape(&current);
    }
    
    current = reflectShape(base);
    normalizeShape(&current);
    sortShape(&current);
    
    for (int rot = 0; rot < 4; rot++) {
        int unique = 1;
        for (int i = 0; i < count; i++) {
            if (shapesEqual(&current, &variants[i])) { unique = 0; break; }
        }
        if (unique) variants[count++] = current;
        current = rotateShape(&current);
    }
    
    sv->numOrientations = count;
    for (int i = 0; i < count; i++) {
        sv->orientations[i] = variants[i];
    }
}

int canFitPieces(int width, int height, int *quantities) {
    // Quick area check
    int cellsNeeded = 0;
    int totalPieces = 0;
    for (int i = 0; i < numShapes; i++) {
        cellsNeeded += quantities[i] * allShapes[i].orientations[0].numCells;
        totalPieces += quantities[i];
    }
    if (cellsNeeded > width * height) return 0;
    if (totalPieces == 0) return 1;
    
    int gridCells = width * height;
    int numPrimaryCols = totalPieces;
    int numSecondaryCols = gridCells;
    int totalCols = numPrimaryCols + numSecondaryCols;
    
    // Estimate max nodes needed
    // Each piece placement creates (1 + numCells) nodes
    // Max placements per piece orientation ~= width * height
    int maxPlacements = 0;
    for (int i = 0; i < numShapes; i++) {
        maxPlacements += quantities[i] * allShapes[i].numOrientations * width * height;
    }
    maxNodes = totalCols + 1 + maxPlacements * 10;  // 10 = max cells per piece + 1
    
    L = malloc(maxNodes * sizeof(int));
    R = malloc(maxNodes * sizeof(int));
    U = malloc(maxNodes * sizeof(int));
    D = malloc(maxNodes * sizeof(int));
    C = malloc(maxNodes * sizeof(int));
    S = malloc(maxNodes * sizeof(int));
    
    if (!L || !R || !U || !D || !C || !S) {
        if (L) free(L); if (R) free(R); if (U) free(U);
        if (D) free(D); if (C) free(C); if (S) free(S);
        return 0;  // Memory allocation failed
    }
    
    nodeCount = totalCols + 1;
    
    // Header links only to primary columns
    L[0] = numPrimaryCols;
    R[0] = (numPrimaryCols > 0) ? 1 : 0;
    U[0] = D[0] = 0;
    S[0] = 0;
    C[0] = 0;
    
    // Primary columns: 1 to numPrimaryCols
    for (int i = 1; i <= numPrimaryCols; i++) {
        L[i] = i - 1;
        R[i] = (i < numPrimaryCols) ? i + 1 : 0;
        U[i] = D[i] = i;
        C[i] = i;
        S[i] = 0;
    }
    if (numPrimaryCols > 0) {
        R[numPrimaryCols] = 0;
    }
    
    // Secondary columns: numPrimaryCols+1 to totalCols
    // NOT linked into header chain
    for (int i = numPrimaryCols + 1; i <= totalCols; i++) {
        L[i] = i;
        R[i] = i;
        U[i] = D[i] = i;
        C[i] = i;
        S[i] = 0;
    }
    
    // Add rows for each piece placement
    int pieceInstance = 0;
    
    for (int shapeIdx = 0; shapeIdx < numShapes; shapeIdx++) {
        ShapeVariants *sv = &allShapes[shapeIdx];
        
        for (int q = 0; q < quantities[shapeIdx]; q++) {
            int pieceCol = pieceInstance + 1;
            
            for (int ori = 0; ori < sv->numOrientations; ori++) {
                Shape *s = &sv->orientations[ori];
                
                int maxR = 0, maxC = 0;
                for (int i = 0; i < s->numCells; i++) {
                    if (s->cells[i][0] > maxR) maxR = s->cells[i][0];
                    if (s->cells[i][1] > maxC) maxC = s->cells[i][1];
                }
                
                for (int row = 0; row + maxR < height; row++) {
                    for (int col = 0; col + maxC < width; col++) {
                        if (nodeCount + s->numCells + 1 >= maxNodes) {
                            // Would exceed buffer
                            free(L); free(R); free(U); free(D); free(C); free(S);
                            return 0;
                        }
                        
                        int rowCols[MAX_CELLS + 1];
                        int numRowCols = 0;
                        
                        rowCols[numRowCols++] = pieceCol;
                        
                        for (int i = 0; i < s->numCells; i++) {
                            int r = row + s->cells[i][0];
                            int c = col + s->cells[i][1];
                            int cellCol = numPrimaryCols + 1 + r * width + c;
                            rowCols[numRowCols++] = cellCol;
                        }
                        
                        int firstNode = nodeCount;
                        
                        for (int i = 0; i < numRowCols; i++) {
                            int colIdx = rowCols[i];
                            int node = nodeCount++;
                            
                            C[node] = colIdx;
                            
                            U[node] = U[colIdx];
                            D[node] = colIdx;
                            D[U[colIdx]] = node;
                            U[colIdx] = node;
                            S[colIdx]++;
                            
                            if (i == 0) {
                                L[node] = R[node] = node;
                            } else {
                                int prevNode = nodeCount - 2;
                                L[node] = prevNode;
                                R[node] = firstNode;
                                R[prevNode] = node;
                                L[firstNode] = node;
                            }
                        }
                    }
                }
            }
            pieceInstance++;
        }
    }
    
    solved = 0;
    search(0);
    
    free(L); free(R); free(U); free(D); free(C); free(S);
    
    return solved;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) { printf("Usage: solver <input>\n"); return 1; }
        
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        int parsingShapes = 1;
        int currentShapeIdx = -1;
        Shape currentShape;
        int shapeRow = 0;
        
        NSMutableArray *regions = [NSMutableArray array];
        
        for (NSString *line in lines) {
            NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (trimmed.length == 0) {
                if (currentShapeIdx >= 0 && currentShape.numCells > 0) {
                    generateOrientations(&currentShape, &allShapes[currentShapeIdx]);
                    numShapes = currentShapeIdx + 1;
                }
                currentShapeIdx = -1;
                shapeRow = 0;
                continue;
            }
            
            if ([trimmed containsString:@":"] && parsingShapes) {
                NSArray *parts = [trimmed componentsSeparatedByString:@":"];
                NSString *firstPart = [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if ([firstPart containsString:@"x"]) {
                    parsingShapes = 0;
                    if (currentShapeIdx >= 0 && currentShape.numCells > 0) {
                        generateOrientations(&currentShape, &allShapes[currentShapeIdx]);
                        numShapes = currentShapeIdx + 1;
                    }
                } else {
                    currentShapeIdx = [firstPart intValue];
                    currentShape.numCells = 0;
                    shapeRow = 0;
                    continue;
                }
            }
            
            if (parsingShapes && currentShapeIdx >= 0) {
                for (int col = 0; col < (int)trimmed.length; col++) {
                    unichar c = [trimmed characterAtIndex:col];
                    if (c == '#') {
                        currentShape.cells[currentShape.numCells][0] = shapeRow;
                        currentShape.cells[currentShape.numCells][1] = col;
                        currentShape.numCells++;
                    }
                }
                shapeRow++;
            }
            
            if (!parsingShapes) {
                if ([trimmed containsString:@"x"] && [trimmed containsString:@":"]) {
                    [regions addObject:trimmed];
                }
            }
        }
        
        if (parsingShapes && currentShapeIdx >= 0 && currentShape.numCells > 0) {
            generateOrientations(&currentShape, &allShapes[currentShapeIdx]);
            numShapes = currentShapeIdx + 1;
        }
        
        fprintf(stderr, "Parsed %d shapes\n", numShapes);
        for (int i = 0; i < numShapes; i++) {
            fprintf(stderr, "  Shape %d: %d cells, %d orientations\n", 
                    i, allShapes[i].orientations[0].numCells, allShapes[i].numOrientations);
        }
        fprintf(stderr, "Processing %d regions...\n", (int)regions.count);
        
        int successCount = 0;
        int regionNum = 0;
        
        for (NSString *regionLine in regions) {
            regionNum++;
            NSArray *mainParts = [regionLine componentsSeparatedByString:@":"];
            if (mainParts.count < 2) continue;
            
            NSString *dimPart = [mainParts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *quantPart = [mainParts[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSArray *dims = [dimPart componentsSeparatedByString:@"x"];
            if (dims.count != 2) continue;
            int width = [dims[0] intValue];
            int height = [dims[1] intValue];
            
            NSArray *quantStrs = [quantPart componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            int quantities[MAX_SHAPES] = {0};
            int qIdx = 0;
            for (NSString *qs in quantStrs) {
                NSString *trimQ = [qs stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (trimQ.length > 0 && qIdx < numShapes) {
                    quantities[qIdx++] = [trimQ intValue];
                }
            }
            
            int result = canFitPieces(width, height, quantities);
            if (result) {
                successCount++;
            }
            
            if (regionNum % 50 == 0) {
                fprintf(stderr, "Processed %d/%d regions, %d successful so far...\n", 
                        regionNum, (int)regions.count, successCount);
            }
        }
        
        printf("%d\n", successCount);
    }
    return 0;
}
