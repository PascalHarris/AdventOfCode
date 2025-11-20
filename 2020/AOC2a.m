#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* passwordFile = [NSString stringWithContentsOfFile:@"./Data/inputday2a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* passwordArray = NSMutableArray.new;
	for (NSString* entry in [passwordFile componentsSeparatedByString:@"\n"]) {
		if (entry.length > 0) {
			NSString* password = [entry componentsSeparatedByString:@":"][1];
			NSString* letter = [[entry componentsSeparatedByString:@":"][0] componentsSeparatedByString:@" "][1];
			int lo = [[[entry componentsSeparatedByString:@":"][0] componentsSeparatedByString:@"-"][0] intValue];
			int hi = [[[[entry componentsSeparatedByString:@":"][0] componentsSeparatedByString:@" "][0] componentsSeparatedByString:@"-"][1] intValue];
			[passwordArray addObject:@{@"password":password,@"letter":letter,@"lo":@(lo),@"hi":@(hi)}];
		}
	}
	return passwordArray;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		int valid = 0;
		for (NSDictionary* password in loadData()) {
			NSUInteger numberOfOccurrences = [[password[@"password"] componentsSeparatedByString:password[@"letter"]] count] - 1;
			if (numberOfOccurrences >= [password[@"lo"] intValue] && numberOfOccurrences <= [password[@"hi"] intValue]) { valid++; }
		}
		NSLog(@"%d",valid);
	}
}