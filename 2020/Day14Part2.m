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

void writeToAddresses(NSMutableDictionary* memory, NSString* mask, unsigned long long baseAddr, unsigned long long value, int bit) {
	if (bit == 36) {
		memory[@(baseAddr)] = @(value);
		return;
	}
	
	char c = [mask characterAtIndex:bit];
	int bitPos = 35 - bit;
	
	if (c == '0') {
		writeToAddresses(memory, mask, baseAddr, value, bit + 1);
	} else if (c == '1') {
		baseAddr |= (1ULL << bitPos);
		writeToAddresses(memory, mask, baseAddr, value, bit + 1);
	} else { // X - floating
		unsigned long long addr0 = baseAddr & ~(1ULL << bitPos);
		unsigned long long addr1 = baseAddr | (1ULL << bitPos);
		writeToAddresses(memory, mask, addr0, value, bit + 1);
		writeToAddresses(memory, mask, addr1, value, bit + 1);
	}
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* program = loadData();
		NSMutableDictionary* memory = NSMutableDictionary.new;
		NSString* mask = @"";
		
		for (NSString* line in program) {
			if ([line hasPrefix:@"mask"]) {
				mask = [[line componentsSeparatedByString:@" = "][1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
			} else {
				NSRange bracketStart = [line rangeOfString:@"["];
				NSRange bracketEnd = [line rangeOfString:@"]"];
				NSRange addrRange = NSMakeRange(bracketStart.location + 1, bracketEnd.location - bracketStart.location - 1);
				unsigned long long address = [[line substringWithRange:addrRange] longLongValue];
				unsigned long long value = [[[line componentsSeparatedByString:@" = "][1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] longLongValue];
				
				writeToAddresses(memory, mask, address, value, 0);
			}
		}
		
		unsigned long long sum = 0;
		for (NSNumber* addr in memory) {
			sum += [memory[addr] unsignedLongLongValue];
		}
		
		NSLog(@"%llu", sum);
	}
}
