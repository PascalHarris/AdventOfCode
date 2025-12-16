#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday22a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* players = [inputFile componentsSeparatedByString:@"\n\n"];
		
		// Parse decks
		NSMutableArray* deck1 = NSMutableArray.new;
		NSMutableArray* deck2 = NSMutableArray.new;
		
		NSArray* lines1 = [players[0] componentsSeparatedByString:@"\n"];
		for (int i = 1; i < lines1.count; i++) {
			if ([lines1[i] length] > 0) {
				[deck1 addObject:@([lines1[i] intValue])];
			}
		}
		
		NSArray* lines2 = [players[1] componentsSeparatedByString:@"\n"];
		for (int i = 1; i < lines2.count; i++) {
			if ([lines2[i] length] > 0) {
				[deck2 addObject:@([lines2[i] intValue])];
			}
		}
		
		// Play game
		while (deck1.count > 0 && deck2.count > 0) {
			int card1 = [deck1[0] intValue];
			int card2 = [deck2[0] intValue];
			[deck1 removeObjectAtIndex:0];
			[deck2 removeObjectAtIndex:0];
			
			if (card1 > card2) {
				[deck1 addObject:@(card1)];
				[deck1 addObject:@(card2)];
			} else {
				[deck2 addObject:@(card2)];
				[deck2 addObject:@(card1)];
			}
		}
		
		// Calculate score
		NSMutableArray* winner = deck1.count > 0 ? deck1 : deck2;
		long long score = 0;
		for (int i = 0; i < winner.count; i++) {
			score += [winner[i] longLongValue] * (winner.count - i);
		}
		
		NSLog(@"%lld", score);
	}
}
