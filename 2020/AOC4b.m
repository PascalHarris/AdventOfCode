#import <Foundation/Foundation.h>

#define VALIDYEAR(year, min, max) ((year)>=(min) && (year)<=(max)? YES : NO) 

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

bool validateHeight(NSString* input) {
	if ([input rangeOfString:@"cm"].location != NSNotFound) {
		int height = [[input componentsSeparatedByString:@"cm"][0] intValue];
		return height >= 150 && height <= 193 ? YES:NO; 
	} else if ([input rangeOfString:@"in"].location != NSNotFound) {
		int height = [[input componentsSeparatedByString:@"in"][0] intValue];
		return height >= 59 && height <= 76 ? YES:NO;
	}
	return NO;
}

bool validateHairColour(NSString* input) {
	if (([input rangeOfString:@"#"].location != NSNotFound) && input.length == 7) {
		NSCharacterSet *validHex = [NSCharacterSet characterSetWithCharactersInString:@"#0123456789ABCDEF"].invertedSet;
		return (NSNotFound == [input.uppercaseString rangeOfCharacterFromSet:validHex].location);
	}
	return NO;
}

bool validateEyeColour(NSString* input) {
	for (NSString* colour in @[@"amb",@"blu",@"brn",@"gry",@"grn",@"hzl",@"oth"]) {
		if ([input isEqualToString:colour]) { return YES; }
	}
	return NO;
}

bool validNumber(NSString* input) {
	if (input.length != 9) { return NO; }
	NSCharacterSet *validNum = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"].invertedSet;
	return (NSNotFound == [input rangeOfCharacterFromSet:validNum].location);
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		int valid = 0;
		NSArray* passportData = loadData();
		
		for (NSDictionary* passport in passportData) {
			valid += (passport[@"byr"] && VALIDYEAR([passport[@"byr"] intValue], 1920, 2002)) && 
			(passport[@"iyr"] && VALIDYEAR([passport[@"iyr"] intValue], 2010, 2020)) && 
			(passport[@"eyr"] && VALIDYEAR([passport[@"eyr"] intValue], 2020, 2030)) &&
			(passport[@"hgt"] && validateHeight(passport[@"hgt"])) &&
			(passport[@"hcl"] && validateHairColour(passport[@"hcl"])) &&
			(passport[@"ecl"] && validateEyeColour(passport[@"ecl"])) &&
			(passport[@"pid"] && validNumber(passport[@"pid"])) ? 1:0;
		}
						
		NSLog(@"%d",valid);
	}
}