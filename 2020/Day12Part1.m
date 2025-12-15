#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* navFile = [NSString stringWithContentsOfFile:@"./Data/inputday12a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* returnArray = NSMutableArray.new;
	for (NSString* line in [navFile componentsSeparatedByString:@"\n"]) {
		if (line.length == 0) { continue; }
		[returnArray addObject:line];
	}
	return returnArray;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* instructions = loadData();
		int x = 0, y = 0;
		int direction = 0; // 0=E, 90=S, 180=W, 270=N
		
		for (NSString* instruction in instructions) {
			char action = [instruction characterAtIndex:0];
			int value = [[instruction substringFromIndex:1] intValue];
			
			switch (action) {
				case 'N': y += value; break;
				case 'S': y -= value; break;
				case 'E': x += value; break;
				case 'W': x -= value; break;
				case 'L': direction = (direction - value + 360) % 360; break;
				case 'R': direction = (direction + value) % 360; break;
				case 'F':
					switch (direction) {
						case 0:   x += value; break;
						case 90:  y -= value; break;
						case 180: x -= value; break;
						case 270: y += value; break;
					}
					break;
			}
		}
		
		NSLog(@"%d", abs(x) + abs(y));
	}
}
