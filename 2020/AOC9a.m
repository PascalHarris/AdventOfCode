#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* xmasData = [NSString stringWithContentsOfFile:@"./Data/inputday9a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* returnArray = NSMutableArray.new;
	for (NSString* value in [xmasData componentsSeparatedByString:@"\n"]) {
		[returnArray addObject:@(value.intValue)];
	}
	return returnArray;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* xmasData = [NSArray.alloc initWithArray:loadData()];
		int windowsize = 25;
		for (int tpointer = windowsize; tpointer < xmasData.count; tpointer++) {
			int j = 0, target = [xmasData[tpointer] intValue];
			bool found = false;
			NSArray* windowArray = [xmasData subarrayWithRange:NSMakeRange(tpointer - windowsize, tpointer < xmasData.count ? windowsize:windowsize-(tpointer - xmasData.count))];
			
			for (NSString* number1 in windowArray) {
				int number2 = target - number1.intValue;
				if ([windowArray containsObject:@(number2)] ) {
					found = true;
					break;
				}
			}
			if (!found) {
				NSLog(@"%d",target);
				break;
			}
		}
	}
}