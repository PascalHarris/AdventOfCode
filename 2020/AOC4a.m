#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* passportFile = [NSString stringWithContentsOfFile:@"./Data/inputday4a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* passportArray = NSMutableArray.new;
	for (__strong NSString* details in [passportFile componentsSeparatedByString:@"\n\n"]) {
		details = [[details componentsSeparatedByString:@"\n"] componentsJoinedByString:@" "];
		NSMutableDictionary* detailsDict = NSMutableDictionary.new;
		for (NSString* item in [details componentsSeparatedByString:@" "]) {
			if (item.length == 0) { break; }
			[detailsDict setValue:[item componentsSeparatedByString:@":"][1] forKey:[item componentsSeparatedByString:@":"][0]];
		}
		[passportArray addObject:detailsDict.copy];
	}
	return passportArray;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		int valid = 0;
		NSArray* passportData = loadData();
		
		for (NSDictionary* passport in passportData) {
			valid += passport[@"byr"] && 
			passport[@"iyr"] && 
			passport[@"eyr"] &&
			passport[@"hgt"] && 
			passport[@"hcl"] &&
			passport[@"ecl"] && 
			passport[@"pid"] ? 1:0;
		}
		
		NSLog(@"%d",valid);
	}
}