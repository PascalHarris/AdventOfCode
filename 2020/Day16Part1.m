#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* ticketFile = [NSString stringWithContentsOfFile:@"./Data/inputday16a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* sections = [ticketFile componentsSeparatedByString:@"\n\n"];
		
		// Parse rules - collect all valid ranges
		NSMutableArray* validRanges = NSMutableArray.new;
		for (NSString* line in [sections[0] componentsSeparatedByString:@"\n"]) {
			if (line.length == 0) { continue; }
			NSString* rangePart = [line componentsSeparatedByString:@": "][1];
			for (NSString* range in [rangePart componentsSeparatedByString:@" or "]) {
				NSArray* bounds = [range componentsSeparatedByString:@"-"];
				[validRanges addObject:@[@([bounds[0] intValue]), @([bounds[1] intValue])]];
			}
		}
		
		// Parse nearby tickets and find invalid values
		NSArray* nearbyLines = [sections[2] componentsSeparatedByString:@"\n"];
		int errorRate = 0;
		
		for (int i = 1; i < nearbyLines.count; i++) {
			NSString* line = nearbyLines[i];
			if (line.length == 0) { continue; }
			for (NSString* valueStr in [line componentsSeparatedByString:@","]) {
				int value = valueStr.intValue;
				BOOL valid = NO;
				for (NSArray* range in validRanges) {
					if (value >= [range[0] intValue] && value <= [range[1] intValue]) {
						valid = YES;
						break;
					}
				}
				if (!valid) {
					errorRate += value;
				}
			}
		}
		
		NSLog(@"%d", errorRate);
	}
}
