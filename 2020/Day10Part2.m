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
        NSArray* joltageArray = loadData();
        NSMutableDictionary* solutionDictionary = NSMutableDictionary.new;
        solutionDictionary[@(0)] = @(1);  // Base case: 1 way to be at the outlet
        
        for (NSNumber* joltage in joltageArray) {
            if (joltage.intValue == 0) continue;  // Skip 0, we already set it
            
            long long count = 0;
            if (solutionDictionary[@(joltage.intValue - 1)]) {
                count += [solutionDictionary[@(joltage.intValue - 1)] longLongValue];
            }
            if (solutionDictionary[@(joltage.intValue - 2)]) {
                count += [solutionDictionary[@(joltage.intValue - 2)] longLongValue];
            }
            if (solutionDictionary[@(joltage.intValue - 3)]) {
                count += [solutionDictionary[@(joltage.intValue - 3)] longLongValue];
            }
            solutionDictionary[joltage] = @(count);
        }
        
        // Get the answer for the highest joltage adapter
        NSNumber* maxJoltage = [joltageArray lastObject];
        NSLog(@"%lld", [solutionDictionary[maxJoltage] longLongValue]);
    }
}
