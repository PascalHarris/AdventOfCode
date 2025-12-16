#import <Foundation/Foundation.h>

NSString* makeKey(int x, int y, int z, int w) {
	return [NSString stringWithFormat:@"%d,%d,%d,%d", x, y, z, w];
}

int countActiveNeighbors(NSSet* active, int x, int y, int z, int w) {
	int count = 0;
	for (int dx = -1; dx <= 1; dx++) {
		for (int dy = -1; dy <= 1; dy++) {
			for (int dz = -1; dz <= 1; dz++) {
				for (int dw = -1; dw <= 1; dw++) {
					if (dx == 0 && dy == 0 && dz == 0 && dw == 0) { continue; }
					if ([active containsObject:makeKey(x + dx, y + dy, z + dz, w + dw)]) { count++; }
				}
			}
		}
	}
	return count;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* cubeFile = [NSString stringWithContentsOfFile:@"./Data/inputday17a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* lines = [cubeFile componentsSeparatedByString:@"\n"];
		
		NSMutableSet* active = NSMutableSet.new;
		for (int y = 0; y < lines.count; y++) {
			NSString* line = lines[y];
			if (line.length == 0) { continue; }
			for (int x = 0; x < line.length; x++) {
				if ([line characterAtIndex:x] == '#') {
					[active addObject:makeKey(x, y, 0, 0)];
				}
			}
		}
		
		for (int cycle = 0; cycle < 6; cycle++) {
			NSMutableSet* newActive = NSMutableSet.new;
			NSMutableSet* toCheck = NSMutableSet.new;
			
			for (NSString* key in active) {
				NSArray* parts = [key componentsSeparatedByString:@","];
				int x = [parts[0] intValue];
				int y = [parts[1] intValue];
				int z = [parts[2] intValue];
				int w = [parts[3] intValue];
				for (int dx = -1; dx <= 1; dx++) {
					for (int dy = -1; dy <= 1; dy++) {
						for (int dz = -1; dz <= 1; dz++) {
							for (int dw = -1; dw <= 1; dw++) {
								[toCheck addObject:makeKey(x + dx, y + dy, z + dz, w + dw)];
							}
						}
					}
				}
			}
			
			for (NSString* key in toCheck) {
				NSArray* parts = [key componentsSeparatedByString:@","];
				int x = [parts[0] intValue];
				int y = [parts[1] intValue];
				int z = [parts[2] intValue];
				int w = [parts[3] intValue];
				int neighbors = countActiveNeighbors(active, x, y, z, w);
				
				if ([active containsObject:key]) {
					if (neighbors == 2 || neighbors == 3) { [newActive addObject:key]; }
				} else {
					if (neighbors == 3) { [newActive addObject:key]; }
				}
			}
			
			active = newActive;
		}
		
		NSLog(@"%lu", active.count);
	}
}
