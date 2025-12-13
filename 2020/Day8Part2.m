#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* sourceText = [NSString stringWithContentsOfFile:@"./Data/inputday8a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* sourceCode = NSMutableArray.new;
	for (NSString* entry in [sourceText componentsSeparatedByString:@"\n"]) {
		if (entry.length > 0) {
			NSString* instruction = [entry componentsSeparatedByString:@" "][0];
			NSString* operand = [[entry componentsSeparatedByString:@" "][1] substringWithRange:NSMakeRange(0, 1)];
			NSString* value = [[entry componentsSeparatedByString:@" "][1] substringWithRange:NSMakeRange(1, entry.length-instruction.length-2)];
			NSNumber* debug = @(NO);
			
			[sourceCode addObject:[NSMutableDictionary.alloc initWithDictionary:@{@"instruction":instruction,
				@"operand":operand,
				@"value":value,
				@"debug":debug}]];
		}
	}
	return sourceCode;
}

// Horrible brute force - but it's late, and I haven't be brain power to be optimal (or clever!) right now.
int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* sourceArray = [NSArray.alloc initWithArray:loadData()];
		
		int accumulate;
		for (int i = 0; i < sourceArray.count; i++) {
			for (int l = 0; l < sourceArray.count; l++) {
				sourceArray[l][@"debug"] = @(NO);
			}
			
			int pointer = 0, j = 0;
			accumulate = 0;
			while (pointer < sourceArray.count) {
				j++;
				if (j > 10000) { break; };
				sourceArray[pointer][@"debug"] = @(YES);
				NSString* instruction = sourceArray[pointer][@"instruction"];
				if (pointer == i) {
					if ([instruction isEqualToString:@"jmp"]) {
						instruction = @"nop";
					} else if ([instruction isEqualToString:@"nop"]) {
						instruction = @"jmp";
					}
				}
				if ([instruction isEqualToString:@"acc"]) {
					accumulate += [sourceArray[pointer][@"operand"] isEqualToString:@"-"]? 0-[sourceArray[pointer][@"value"] intValue]: [sourceArray[pointer][@"value"] intValue];
					pointer++;
				} else if ([instruction isEqualToString:@"jmp"]) {
					pointer += [sourceArray[pointer][@"operand"] isEqualToString:@"-"]? 0-[sourceArray[pointer][@"value"] intValue]: [sourceArray[pointer][@"value"] intValue];
				} else if ([instruction isEqualToString:@"nop"]) {
					pointer++;
				}

			}
			if (pointer >= sourceArray.count) { break; }
		}
		NSLog(@"%d",accumulate);
	}
}