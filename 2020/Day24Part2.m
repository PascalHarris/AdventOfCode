#import <Foundation/Foundation.h>

NSString* makeKey(int x, int y) {
	return [NSString stringWithFormat:@"%d,%d", x, y];
}

int countBlackNeighbors(NSSet* blackTiles, int x, int y) {
	int count = 0;
	// 6 hex neighbors in axial coordinates
	int dx[] = {1, -1, 1, -1, 0, 0};
	int dy[] = {0, 0, 1, -1, 1, -1};
	for (int i = 0; i < 6; i++) {
		if ([blackTiles containsObject:makeKey(x + dx[i], y + dy[i])]) {
			count++;
		}
	}
	return count;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday24a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* lines = [inputFile componentsSeparatedByString:@"\n"];
		
		NSMutableSet* blackTiles = NSMutableSet.new;
		
		// Initial setup (same as part 1)
		for (NSString* line in lines) {
			if (line.length == 0) { continue; }
			
			int x = 0, y = 0;
			int i = 0;
			
			while (i < line.length) {
				char c = [line characterAtIndex:i];
				if (c == 'e') {
					x++; i++;
				} else if (c == 'w') {
					x--; i++;
				} else if (c == 'n') {
					char c2 = [line characterAtIndex:i + 1];
					if (c2 == 'e') { x++; y++; }
					else { y++; }
					i += 2;
				} else if (c == 's') {
					char c2 = [line characterAtIndex:i + 1];
					if (c2 == 'e') { y--; }
					else { x--; y--; }
					i += 2;
				}
			}
			
			NSString* key = makeKey(x, y);
			if ([blackTiles containsObject:key]) {
				[blackTiles removeObject:key];
			} else {
				[blackTiles addObject:key];
			}
		}
		
		// Simulate 100 days
		int dx[] = {1, -1, 1, -1, 0, 0};
		int dy[] = {0, 0, 1, -1, 1, -1};
		
		for (int day = 0; day < 100; day++) {
			NSMutableSet* toCheck = NSMutableSet.new;
			
			// Add all black tiles and their neighbors to check set
			for (NSString* key in blackTiles) {
				NSArray* parts = [key componentsSeparatedByString:@","];
				int x = [parts[0] intValue];
				int y = [parts[1] intValue];
				[toCheck addObject:key];
				for (int i = 0; i < 6; i++) {
					[toCheck addObject:makeKey(x + dx[i], y + dy[i])];
				}
			}
			
			NSMutableSet* newBlack = NSMutableSet.new;
			
			for (NSString* key in toCheck) {
				NSArray* parts = [key componentsSeparatedByString:@","];
				int x = [parts[0] intValue];
				int y = [parts[1] intValue];
				int neighbors = countBlackNeighbors(blackTiles, x, y);
				
				if ([blackTiles containsObject:key]) {
					// Black tile: stays black if 1 or 2 neighbors
					if (neighbors == 1 || neighbors == 2) {
						[newBlack addObject:key];
					}
				} else {
					// White tile: becomes black if exactly 2 neighbors
					if (neighbors == 2) {
						[newBlack addObject:key];
					}
				}
			}
			
			blackTiles = newBlack;
		}
		
		NSLog(@"%lu", blackTiles.count);
	}
}
