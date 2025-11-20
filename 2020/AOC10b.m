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
/*		int jd1 = 0, jd3 = 0;
		for (int i = 1; i < joltageArray.count; i++) {
			if ([joltageArray[i] intValue] - [joltageArray[i-1] intValue] == 1) { 
				jd1++; 
			} else if ([joltageArray[i] intValue] - [joltageArray[i-1] intValue] == 3) { 
				jd3++; 
			}
		}
		NSLog(@"%d",jd1*(++jd3));*/
		NSMutableDictionary* solutionDictionary = NSMutableDictionary.new;
		//for (NSUInteger i = 0; i < 156; i++) {
		//	[solutionArray addObject:@(0)];
		//}
		solutionDictionary[@(0)] = @(1);
		for (NSNumber* joltage in joltageArray) {
			solutionDictionary[joltage] = @(0);
			//NSLog(@"a");
			//int result = [solutionArray[joltage.intValue] intValue];
			if ([solutionDictionary.allKeys containsObject:@(joltage.intValue - 1)]) {
				solutionDictionary[joltage] = @([solutionDictionary[joltage] intValue] + [solutionDictionary[@(joltage.intValue-1)] intValue]);
			}
			if ([solutionDictionary.allKeys containsObject:@(joltage.intValue - 2)]) {
				solutionDictionary[joltage] = @([solutionDictionary[joltage] intValue] + [solutionDictionary[@(joltage.intValue-2)] intValue]);
			}
			if ([solutionDictionary.allKeys containsObject:@(joltage.intValue - 3)]) {
				solutionDictionary[joltage] = @([solutionDictionary[joltage] intValue] + [solutionDictionary[@(joltage.intValue-3)] intValue]);
			}
			/*if ([solutionArray containsObject:@(joltage.intValue - 1)]) { solutionArray[joltage.intValue] = @([solutionArray[joltage.intValue] intValue] + [solutionArray[joltage.intValue-1] intValue]); }
			if ([solutionArray containsObject:@(joltage.intValue - 2)]) { solutionArray[joltage.intValue] = @([solutionArray[joltage.intValue] intValue] + [solutionArray[joltage.intValue-2] intValue]); }
			if ([solutionArray containsObject:@(joltage.intValue - 3)]) { solutionArray[joltage.intValue] = @([solutionArray[joltage.intValue] intValue] + [solutionArray[joltage.intValue-3] intValue]); }*/
//			solutionArray[joltage.intValue] = @(result); 
		}
		NSLog(@"%@",solutionDictionary);
	}
}