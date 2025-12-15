#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* scheduleFile = [NSString stringWithContentsOfFile:@"./Data/inputday13a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* lines = [scheduleFile componentsSeparatedByString:@"\n"];
		NSArray* busIds = [lines[1] componentsSeparatedByString:@","];
		
		long long timestamp = 0;
		long long step = 1;
		
		for (int i = 0; i < busIds.count; i++) {
			if ([busIds[i] isEqualToString:@"x"]) { continue; }
			long long busId = [busIds[i] longLongValue];
			while ((timestamp + i) % busId != 0) {
				timestamp += step;
			}
			step *= busId;
		}
		
		NSLog(@"%lld", timestamp);
	}
}
