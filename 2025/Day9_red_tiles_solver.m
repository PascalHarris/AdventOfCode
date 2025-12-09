#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) { printf("Usage: solver <input>\n"); return 1; }
        
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSMutableArray<NSNumber *> *xCoords = [NSMutableArray array];
        NSMutableArray<NSNumber *> *yCoords = [NSMutableArray array];
        
        for (NSString *line in lines) {
            NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimmed.length > 0) {
                NSArray *parts = [trimmed componentsSeparatedByString:@","];
                if (parts.count == 2) {
                    [xCoords addObject:@([parts[0] integerValue])];
                    [yCoords addObject:@([parts[1] integerValue])];
                }
            }
        }
        
        NSInteger n = xCoords.count;
        
        // Find Y range
        NSInteger minY = [yCoords[0] integerValue];
        NSInteger maxY = minY;
        for (NSInteger i = 1; i < n; i++) {
            NSInteger y = [yCoords[i] integerValue];
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
        }
        
        NSInteger yRange = maxY - minY + 1;
        
        // For each Y, store minX and maxX of polygon interior
        // Initialize with invalid values
        NSInteger *spanMinX = malloc(yRange * sizeof(NSInteger));
        NSInteger *spanMaxX = malloc(yRange * sizeof(NSInteger));
        for (NSInteger i = 0; i < yRange; i++) {
            spanMinX[i] = NSIntegerMax;
            spanMaxX[i] = NSIntegerMin;
        }
        
        // Process each edge of the polygon
        for (NSInteger i = 0; i < n; i++) {
            NSInteger nextI = (i + 1) % n;
            NSInteger x1 = [xCoords[i] integerValue];
            NSInteger y1 = [yCoords[i] integerValue];
            NSInteger x2 = [xCoords[nextI] integerValue];
            NSInteger y2 = [yCoords[nextI] integerValue];
            
            if (y1 == y2) {
                // Horizontal edge - update span for this Y
                NSInteger yIdx = y1 - minY;
                NSInteger edgeMinX = (x1 < x2) ? x1 : x2;
                NSInteger edgeMaxX = (x1 > x2) ? x1 : x2;
                if (edgeMinX < spanMinX[yIdx]) spanMinX[yIdx] = edgeMinX;
                if (edgeMaxX > spanMaxX[yIdx]) spanMaxX[yIdx] = edgeMaxX;
            } else {
                // Vertical edge - update spans for all Y in range
                NSInteger edgeMinY = (y1 < y2) ? y1 : y2;
                NSInteger edgeMaxY = (y1 > y2) ? y1 : y2;
                for (NSInteger y = edgeMinY; y <= edgeMaxY; y++) {
                    NSInteger yIdx = y - minY;
                    if (x1 < spanMinX[yIdx]) spanMinX[yIdx] = x1;
                    if (x1 > spanMaxX[yIdx]) spanMaxX[yIdx] = x1;
                }
            }
        }
        
        // Now find largest valid rectangle
        long long bestArea = 0;
        
        for (NSInteger i = 0; i < n - 1; i++) {
            NSInteger x1 = [xCoords[i] integerValue];
            NSInteger y1 = [yCoords[i] integerValue];
            
            for (NSInteger j = i + 1; j < n; j++) {
                NSInteger x2 = [xCoords[j] integerValue];
                NSInteger y2 = [yCoords[j] integerValue];
                
                if (x1 == x2 || y1 == y2) continue;
                
                NSInteger dx = llabs(x2 - x1) + 1;
                NSInteger dy = llabs(y2 - y1) + 1;
                long long area = (long long)dx * dy;
                
                if (area <= bestArea) continue;
                
                // Check if rectangle fits
                NSInteger rxMin = (x1 < x2) ? x1 : x2;
                NSInteger rxMax = (x1 > x2) ? x1 : x2;
                NSInteger ryMin = (y1 < y2) ? y1 : y2;
                NSInteger ryMax = (y1 > y2) ? y1 : y2;
                
                BOOL fits = YES;
                for (NSInteger y = ryMin; y <= ryMax && fits; y++) {
                    NSInteger yIdx = y - minY;
                    if (rxMin < spanMinX[yIdx] || rxMax > spanMaxX[yIdx]) {
                        fits = NO;
                    }
                }
                
                if (fits) {
                    bestArea = area;
                }
            }
        }
        
        printf("%lld\n", bestArea);
        
        free(spanMinX);
        free(spanMaxX);
    }
    return 0;
}
