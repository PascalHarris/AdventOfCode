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
			NSString* firstLetter = [password[@"password"] substringWithRange:NSMakeRange([password[@"lo"] intValue], 1)];
			NSString* secondLetter = [password[@"password"] substringWithRange:NSMakeRange([password[@"hi"] intValue], 1)];
			if ([firstLetter isEqualToString:password[@"letter"]] != [secondLetter isEqualToString:password[@"letter"]]) { valid++; }
		}
		NSLog(@"%d",valid);
	}
}