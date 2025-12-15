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
		int shipX = 0, shipY = 0;
		int waypointX = 10, waypointY = 1;
		
		for (NSString* instruction in instructions) {
			char action = [instruction characterAtIndex:0];
			int value = [[instruction substringFromIndex:1] intValue];
			int temp;
			
			switch (action) {
				case 'N': waypointY += value; break;
				case 'S': waypointY -= value; break;
				case 'E': waypointX += value; break;
				case 'W': waypointX -= value; break;
				case 'L':
					for (int i = 0; i < value / 90; i++) {
						temp = waypointX;
						waypointX = -waypointY;
						waypointY = temp;
					}
					break;
				case 'R':
					for (int i = 0; i < value / 90; i++) {
						temp = waypointX;
						waypointX = waypointY;
						waypointY = -temp;
					}
					break;
				case 'F':
					shipX += waypointX * value;
					shipY += waypointY * value;
					break;
			}
		}
		
		NSLog(@"%d", abs(shipX) + abs(shipY));
	}
}
