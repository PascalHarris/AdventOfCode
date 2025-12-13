#import <Foundation/Foundation.h>

NSString* tidyString(NSString* inputString, NSCharacterSet* set) {
	NSString* returnString = [inputString stringByReplacingOccurrencesOfString:@"bags" withString:@""];
	returnString = [returnString stringByReplacingOccurrencesOfString:@"bag" withString:@""];
	returnString = [returnString stringByTrimmingCharactersInSet:set];
	return returnString;
}

NSDictionary* populateRules() {
	NSMutableDictionary* childrenDictionary = NSMutableDictionary.new;
	NSMutableDictionary* parentDictionary = NSMutableDictionary.new;
	NSArray* lineArray = [[NSString stringWithContentsOfFile:@"./Data/inputday7a.txt" encoding:NSUTF8StringEncoding error:NULL] componentsSeparatedByString:@"\n"];
	NSMutableCharacterSet *wsap = [NSMutableCharacterSet characterSetWithCharactersInString:@"."];
	[wsap formUnionWithCharacterSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
	for (NSString* line in lineArray) {
		@autoreleasepool {
			NSMutableDictionary* children = NSMutableDictionary.new;
			NSMutableArray* parents = NSMutableArray.new;
			NSString* bagDesc = tidyString([[line componentsSeparatedByString:@"contain"][0] stringByTrimmingCharactersInSet:wsap], wsap);
			if (line.length == 0) { break; }
			
			NSArray* contentRules = [[line componentsSeparatedByString:@" contain"][1] componentsSeparatedByString:@","];
			if (![[contentRules[0] stringByTrimmingCharactersInSet:wsap] isEqualToString:@"no other bags."]) {
				for (id contentRule in contentRules) {
					NSString* rule = [contentRule stringByTrimmingCharactersInSet:wsap];
					int quantity = [[rule componentsSeparatedByString:@" "][0] intValue];
					NSString* bagDescription = @"";
					for (int i = 1; i < [rule componentsSeparatedByString:@" "].count; i++) {
						bagDescription = [bagDescription stringByAppendingFormat:@" %@",[rule componentsSeparatedByString:@" "][i]];
					}
					bagDescription = tidyString(bagDescription, wsap);
					
					children[bagDescription] = @(quantity);
					if (![bagDescription isEqualToString:@"other"]) {
						if (![parentDictionary.allKeys containsObject:bagDescription]) {
							NSMutableArray* parentArray = NSMutableArray.new;
							[parentDictionary setObject:parentArray.mutableCopy forKey:bagDescription];
						} 
						[parentDictionary[bagDescription] addObject:bagDesc];
					}
				}
			}
			[childrenDictionary setObject:children.copy forKey:bagDesc];
		}
	}
	return @{@"parent":parentDictionary.copy,@"children":childrenDictionary}; 
}

NSArray* contains(NSDictionary* rule, NSString* colour) {
	NSMutableArray* result = [rule[@"parent"][colour] mutableCopy];
	for (NSString* col in rule[@"parent"][colour]) {
		NSArray* temp = contains(rule, col);
		for (NSString* tempCol in temp) {
			if (![result containsObject:tempCol]) { [result addObject:tempCol]; }
		}
	}
	return result;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSDictionary* rules = populateRules();
		
		NSArray* result = contains(rules, @"shiny gold");
		
		NSLog(@"%lu", result.count);
	}
}