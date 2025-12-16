#import <Foundation/Foundation.h>

NSDictionary* rules;

// Returns a set of possible remaining string positions after matching
NSSet* matchRule(NSString* message, int pos, int ruleNum) {
	if (pos >= message.length) { return NSSet.new; }
	
	NSString* rule = rules[@(ruleNum)];
	
	// Literal character match
	if ([rule hasPrefix:@"\""]) {
		char c = [rule characterAtIndex:1];
		if ([message characterAtIndex:pos] == c) {
			return [NSSet setWithObject:@(pos + 1)];
		}
		return NSSet.new;
	}
	
	// Handle alternatives (split by |)
	NSMutableSet* results = NSMutableSet.new;
	NSArray* alternatives = [rule componentsSeparatedByString:@" | "];
	
	for (NSString* alt in alternatives) {
		NSArray* subRules = [alt componentsSeparatedByString:@" "];
		NSSet* positions = [NSSet setWithObject:@(pos)];
		
		for (NSString* subRuleStr in subRules) {
			int subRule = subRuleStr.intValue;
			NSMutableSet* newPositions = NSMutableSet.new;
			for (NSNumber* p in positions) {
				NSSet* matched = matchRule(message, p.intValue, subRule);
				[newPositions unionSet:matched];
			}
			positions = newPositions;
		}
		
		[results unionSet:positions];
	}
	
	return results;
}

BOOL matches(NSString* message) {
	NSSet* endPositions = matchRule(message, 0, 0);
	return [endPositions containsObject:@((int)message.length)];
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday19a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* sections = [inputFile componentsSeparatedByString:@"\n\n"];
		
		// Parse rules
		NSMutableDictionary* ruleDict = NSMutableDictionary.new;
		for (NSString* line in [sections[0] componentsSeparatedByString:@"\n"]) {
			if (line.length == 0) { continue; }
			NSArray* parts = [line componentsSeparatedByString:@": "];
			int ruleNum = [parts[0] intValue];
			ruleDict[@(ruleNum)] = parts[1];
		}
		rules = ruleDict;
		
		// Check messages
		int count = 0;
		for (NSString* message in [sections[1] componentsSeparatedByString:@"\n"]) {
			if (message.length == 0) { continue; }
			if (matches(message)) { count++; }
		}
		
		NSLog(@"%d", count);
	}
}
