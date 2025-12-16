#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* ticketFile = [NSString stringWithContentsOfFile:@"./Data/inputday16a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* sections = [ticketFile componentsSeparatedByString:@"\n\n"];
		
		// Parse rules
		NSMutableArray* fieldNames = NSMutableArray.new;
		NSMutableArray* fieldRanges = NSMutableArray.new;
		for (NSString* line in [sections[0] componentsSeparatedByString:@"\n"]) {
			if (line.length == 0) { continue; }
			NSArray* parts = [line componentsSeparatedByString:@": "];
			[fieldNames addObject:parts[0]];
			NSMutableArray* ranges = NSMutableArray.new;
			for (NSString* range in [parts[1] componentsSeparatedByString:@" or "]) {
				NSArray* bounds = [range componentsSeparatedByString:@"-"];
				[ranges addObject:@[@([bounds[0] intValue]), @([bounds[1] intValue])]];
			}
			[fieldRanges addObject:ranges];
		}
		
		// Parse your ticket
		NSArray* yourTicketLines = [sections[1] componentsSeparatedByString:@"\n"];
		NSMutableArray* yourTicket = NSMutableArray.new;
		for (NSString* valueStr in [yourTicketLines[1] componentsSeparatedByString:@","]) {
			[yourTicket addObject:@(valueStr.intValue)];
		}
		
		// Collect all valid ranges for filtering
		NSMutableArray* allRanges = NSMutableArray.new;
		for (NSArray* ranges in fieldRanges) {
			for (NSArray* range in ranges) {
				[allRanges addObject:range];
			}
		}
		
		// Parse nearby tickets and filter valid ones
		NSArray* nearbyLines = [sections[2] componentsSeparatedByString:@"\n"];
		NSMutableArray* validTickets = NSMutableArray.new;
		
		for (int i = 1; i < nearbyLines.count; i++) {
			NSString* line = nearbyLines[i];
			if (line.length == 0) { continue; }
			NSMutableArray* ticket = NSMutableArray.new;
			BOOL ticketValid = YES;
			for (NSString* valueStr in [line componentsSeparatedByString:@","]) {
				int value = valueStr.intValue;
				[ticket addObject:@(value)];
				BOOL valueValid = NO;
				for (NSArray* range in allRanges) {
					if (value >= [range[0] intValue] && value <= [range[1] intValue]) {
						valueValid = YES;
						break;
					}
				}
				if (!valueValid) { ticketValid = NO; }
			}
			if (ticketValid) { [validTickets addObject:ticket]; }
		}
		
		// For each field, determine which positions are possible
		int numFields = (int)fieldNames.count;
		NSMutableArray* possiblePositions = NSMutableArray.new;
		for (int f = 0; f < numFields; f++) {
			NSMutableSet* possible = NSMutableSet.new;
			for (int pos = 0; pos < numFields; pos++) {
				[possible addObject:@(pos)];
			}
			[possiblePositions addObject:possible];
		}
		
		// Eliminate impossible positions based on valid tickets
		for (NSArray* ticket in validTickets) {
			for (int pos = 0; pos < numFields; pos++) {
				int value = [ticket[pos] intValue];
				for (int f = 0; f < numFields; f++) {
					NSArray* ranges = fieldRanges[f];
					BOOL matches = NO;
					for (NSArray* range in ranges) {
						if (value >= [range[0] intValue] && value <= [range[1] intValue]) {
							matches = YES;
							break;
						}
					}
					if (!matches) {
						[possiblePositions[f] removeObject:@(pos)];
					}
				}
			}
		}
		
		// Solve by elimination - find fields with only one possible position
		NSMutableDictionary* fieldToPosition = NSMutableDictionary.new;
		while (fieldToPosition.count < numFields) {
			for (int f = 0; f < numFields; f++) {
				NSMutableSet* possible = possiblePositions[f];
				if (possible.count == 1) {
					NSNumber* pos = [possible anyObject];
					fieldToPosition[@(f)] = pos;
					for (int f2 = 0; f2 < numFields; f2++) {
						[possiblePositions[f2] removeObject:pos];
					}
				}
			}
		}
		
		// Multiply values of fields starting with "departure"
		long long result = 1;
		for (int f = 0; f < numFields; f++) {
			if ([fieldNames[f] hasPrefix:@"departure"]) {
				int pos = [fieldToPosition[@(f)] intValue];
				result *= [yourTicket[pos] longLongValue];
			}
		}
		
		NSLog(@"%lld", result);
	}
}
