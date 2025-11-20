#import <Foundation/Foundation.h>
#define target_number 2020
NSArray* loadData() {
	NSString* expenseReport = [NSString stringWithContentsOfFile:@"./Data/inputday1a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* reportArray = NSMutableArray.new;
	for (NSString* entry in [expenseReport componentsSeparatedByString:@"\n"]) {
		if (entry.length > 0) { [reportArray addObject:@(entry.intValue)]; }
	}
	return [reportArray sortedArrayUsingSelector: @selector(compare:)];
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* reportArray = [NSArray.alloc initWithArray:loadData()];
		int solution = 0;
		for (int i = 0; i < reportArray.count; i++) {
			int number1 = [reportArray[i] intValue];
			for (int j = 0; j < reportArray.count; j++) {
				int number2 = [reportArray[j] intValue];
				if (number1 + number2 == target_number) {
					solution = number1 * number2;
					break;
				} else if (number2 > target_number - number1) {
					break;
				}
			}
			if (solution > 0) {
				break;
			}
		}
		NSLog(@"%d", solution);
	}
}