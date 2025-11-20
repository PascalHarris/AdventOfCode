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

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* sourceArray = [NSArray.alloc initWithArray:loadData()];
		
		BOOL recurse = NO;
		int pointer = 0, accumulate = 0;
		while (!recurse) {
			sourceArray[pointer][@"debug"] = @(YES);
			if ([sourceArray[pointer][@"instruction"] isEqualToString:@"acc"]) {
				accumulate += [sourceArray[pointer][@"operand"] isEqualToString:@"-"]? 0-[sourceArray[pointer][@"value"] intValue]: [sourceArray[pointer][@"value"] intValue];
				pointer++;
			} else if ([sourceArray[pointer][@"instruction"] isEqualToString:@"jmp"]) {
				pointer += [sourceArray[pointer][@"operand"] isEqualToString:@"-"]? 0-[sourceArray[pointer][@"value"] intValue]: [sourceArray[pointer][@"value"] intValue];
			} else if ([sourceArray[pointer][@"instruction"] isEqualToString:@"nop"]) {
				pointer++;
			}
			NSLog(@"%d", accumulate);
			if ([sourceArray[pointer][@"debug"] intValue]) { recurse = YES; }
		}
		NSLog(@"%d",accumulate);
	}
}