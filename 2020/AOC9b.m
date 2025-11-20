#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* xmasData = [NSString stringWithContentsOfFile:@"./Data/inputday9a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* returnArray = NSMutableArray.new;
	for (NSString* value in [xmasData componentsSeparatedByString:@"\n"]) {
		[returnArray addObject:@(value.intValue)];
	}
	return returnArray;
}

int getWeakNumber(NSArray* xmasData) {
	int windowsize = 25;
	int returnValue;
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
			return target;
		}
	}
	return 0;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* xmasData = [NSArray.alloc initWithArray:loadData()];
		int weak_number = getWeakNumber(xmasData);
		
		for (int tpointer = 400; tpointer < xmasData.count; tpointer++) {
			int windowsize = 1, result = 0;
			
			while (result < weak_number) {
				NSArray* windowArray = [xmasData subarrayWithRange:NSMakeRange(tpointer,windowsize)];
				result = [[windowArray valueForKeyPath: @"@sum.self"] intValue];
				if (result == weak_number) {
					windowArray = [windowArray sortedArrayUsingSelector:@selector(compare:)];
					NSLog(@"%d",[windowArray[0] intValue]+[windowArray[windowArray.count-1] intValue]);
					exit(0);
				}
				windowsize++;
			}
		}
	}
}