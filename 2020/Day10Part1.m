#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* joltageData = [NSString stringWithContentsOfFile:@"./Data/inputday10a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* returnArray = NSMutableArray.new;
	[returnArray addObject:@(0)]; // the aeroplane socket
	for (NSString* value in [joltageData componentsSeparatedByString:@"\n"]) {
		if (value.length == 0) { continue; }
		[returnArray addObject:@(value.intValue)];
	}
	return [returnArray sortedArrayUsingSelector: @selector(compare:)];
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* joltageArray = [NSArray.alloc initWithArray:loadData()];
		int jd1 = 0, jd3 = 0;
		for (int i = 1; i < joltageArray.count; i++) {
			if ([joltageArray[i] intValue] - [joltageArray[i-1] intValue] == 1) { 
				jd1++; 
			} else if ([joltageArray[i] intValue] - [joltageArray[i-1] intValue] == 3) { 
				jd3++; 
			}
		}
		NSLog(@"%d",jd1*(++jd3));
	}
}