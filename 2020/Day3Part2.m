#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* slopeFile = [NSString stringWithContentsOfFile:@"./Data/inputday3a.txt" encoding:NSUTF8StringEncoding error:NULL];
	
	NSMutableArray *returnArray = NSMutableArray.new;
	for (NSString* line in [slopeFile componentsSeparatedByString:@"\n"]) {
		int i = 0;
		NSMutableArray *lineArray = NSMutableArray.new;
		while (i < line.length) {
			NSRange range = [line rangeOfComposedCharacterSequenceAtIndex:i];
			[lineArray addObject:[line substringWithRange:range]];
			i += range.length;
		}
		[returnArray addObject:lineArray];
	}
	
	return returnArray;
}

uint32 countCollisions(int right, int down) {
	int collisions = 0, x = 0, y = 0;
	NSMutableArray* slopeArray = loadData().mutableCopy;
	for (int i = 1; i < slopeArray.count; i++) {
		y = (y + right) % [slopeArray[x] count];
		if (y < [slopeArray[i] count] && [slopeArray[i][y] isEqualToString:@"#"]) { collisions++; }
	}
	return (uint32)collisions;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		uint32 answer = countCollisions(1, 1)*countCollisions(3, 1)*countCollisions(5, 1)*countCollisions(7, 1)*countCollisions(1, 2);
		NSLog(@"%u",answer);
	}
}