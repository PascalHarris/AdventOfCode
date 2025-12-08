#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) { printf("Usage: solver <input>\n"); return 1; }
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSMutableArray *xCoords = [NSMutableArray array];
        NSMutableArray *yCoords = [NSMutableArray array];
        NSMutableArray *zCoords = [NSMutableArray array];
        for (NSString *line in lines) {
            NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimmed.length > 0) {
                NSArray *parts = [trimmed componentsSeparatedByString:@","];
                if (parts.count == 3) {
                    [xCoords addObject:@([parts[0] integerValue])];
                    [yCoords addObject:@([parts[1] integerValue])];
                    [zCoords addObject:@([parts[2] integerValue])];
                }
            }
        }
        NSInteger n = xCoords.count;
        NSInteger pairCount = (n * (n - 1)) / 2;
        long long *dists = malloc(pairCount * sizeof(long long));
        int *idxI = malloc(pairCount * sizeof(int));
        int *idxJ = malloc(pairCount * sizeof(int));
        NSInteger p = 0;
        for (NSInteger i = 0; i < n - 1; i++) {
            long long x1 = [xCoords[i] longLongValue], y1 = [yCoords[i] longLongValue], z1 = [zCoords[i] longLongValue];
            for (NSInteger j = i + 1; j < n; j++) {
                long long dx = [xCoords[j] longLongValue] - x1;
                long long dy = [yCoords[j] longLongValue] - y1;
                long long dz = [zCoords[j] longLongValue] - z1;
                dists[p] = dx*dx + dy*dy + dz*dz;
                idxI[p] = (int)i; idxJ[p] = (int)j; p++;
            }
        }
        NSInteger *si = malloc(pairCount * sizeof(NSInteger));
        for (NSInteger i = 0; i < pairCount; i++) si[i] = i;
        __block void (^qs)(NSInteger, NSInteger);
        qs = ^(NSInteger lo, NSInteger hi) {
            if (lo >= hi) return;
            long long piv = dists[si[(lo + hi) / 2]];
            NSInteger i = lo, j = hi;
            while (i <= j) {
                while (dists[si[i]] < piv) i++;
                while (dists[si[j]] > piv) j--;
                if (i <= j) { NSInteger t = si[i]; si[i] = si[j]; si[j] = t; i++; j--; }
            }
            if (lo < j) qs(lo, j);
            if (i < hi) qs(i, hi);
        };
        qs(0, pairCount - 1);
        int *parent = malloc(n * sizeof(int));
        for (int i = 0; i < n; i++) parent[i] = i;
        int (^find)(int) = ^int(int x) {
            int r = x; while (parent[r] != r) r = parent[r];
            while (parent[x] != r) { int nx = parent[x]; parent[x] = r; x = nx; }
            return r;
        };
        NSInteger need = n - 1, done = 0; int lastI = 0, lastJ = 0;
        for (NSInteger k = 0; k < pairCount && done < need; k++) {
            int bi = idxI[si[k]], bj = idxJ[si[k]];
            int ri = find(bi), rj = find(bj);
            if (ri != rj) { parent[ri] = rj; done++; lastI = bi; lastJ = bj; }
        }
        printf("%lld,%lld,%lld\n", (long long)[xCoords[lastI] integerValue], (long long)[xCoords[lastJ] integerValue], (long long)[xCoords[lastI] integerValue] * [xCoords[lastJ] integerValue]);
        free(dists); free(idxI); free(idxJ); free(si); free(parent);
    }
    return 0;
}
