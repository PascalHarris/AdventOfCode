#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* scheduleFile = [NSString stringWithContentsOfFile:@"./Data/inputday13a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* lines = [scheduleFile componentsSeparatedByString:@"\n"];
		int earliest = [lines[0] intValue];
		NSArray* busIds = [lines[1] componentsSeparatedByString:@","];
		
		int bestBus = 0;
		int bestWait = INT_MAX;
		
		for (NSString* busId in busIds) {
			if ([busId isEqualToString:@"x"]) { continue; }
			int id = busId.intValue;
			int wait = id - (earliest % id);
			if (wait == id) { wait = 0; }
			if (wait < bestWait) {
				bestWait = wait;
				bestBus = id;
			}
		}
		
		NSLog(@"%d", bestBus * bestWait);
	}
}
