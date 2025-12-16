#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* programFile = [NSString stringWithContentsOfFile:@"./Data/inputday14a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* returnArray = NSMutableArray.new;
	for (NSString* line in [programFile componentsSeparatedByString:@"\n"]) {
		if (line.length == 0) { continue; }
		[returnArray addObject:line];
	}
	return returnArray;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* program = loadData();
		NSMutableDictionary* memory = NSMutableDictionary.new;
		unsigned long long orMask = 0;
		unsigned long long andMask = 0xFFFFFFFFF; // 36 bits all 1s
		
		for (NSString* line in program) {
			if ([line hasPrefix:@"mask"]) {
				NSString* maskStr = [[line componentsSeparatedByString:@" = "][1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
				orMask = 0;
				andMask = 0xFFFFFFFFF;
				for (int i = 0; i < 36; i++) {
					char c = [maskStr characterAtIndex:i];
					int bit = 35 - i;
					if (c == '1') {
						orMask |= (1ULL << bit);
					} else if (c == '0') {
						andMask &= ~(1ULL << bit);
					}
				}
			} else {
				NSRange bracketStart = [line rangeOfString:@"["];
				NSRange bracketEnd = [line rangeOfString:@"]"];
				NSRange addrRange = NSMakeRange(bracketStart.location + 1, bracketEnd.location - bracketStart.location - 1);
				unsigned long long address = [[line substringWithRange:addrRange] longLongValue];
				unsigned long long value = [[[line componentsSeparatedByString:@" = "][1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] longLongValue];
				
				value = (value | orMask) & andMask;
				memory[@(address)] = @(value);
			}
		}
		
		unsigned long long sum = 0;
		for (NSNumber* addr in memory) {
			sum += [memory[addr] unsignedLongLongValue];
		}
		
		NSLog(@"%llu", sum);
	}
}
