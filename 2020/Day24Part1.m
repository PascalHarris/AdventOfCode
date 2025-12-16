#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday24a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* lines = [inputFile componentsSeparatedByString:@"\n"];
		
		// Using cube coordinates for hex grid
		// e/w changes x, ne/sw changes y, nw/se changes z
		// Constraint: x + y + z = 0 (but we can use just x, y)
		
		NSMutableSet* blackTiles = NSMutableSet.new;
		
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
					if (c2 == 'e') {
						x++; y++;
					} else { // nw
						y++;
					}
					i += 2;
				} else if (c == 's') {
					char c2 = [line characterAtIndex:i + 1];
					if (c2 == 'e') {
						y--;
					} else { // sw
						x--; y--;
					}
					i += 2;
				}
			}
			
			NSString* key = [NSString stringWithFormat:@"%d,%d", x, y];
			if ([blackTiles containsObject:key]) {
				[blackTiles removeObject:key];
			} else {
				[blackTiles addObject:key];
			}
		}
		
		NSLog(@"%lu", blackTiles.count);
	}
}
