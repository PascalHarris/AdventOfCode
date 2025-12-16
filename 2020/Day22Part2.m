#import <Foundation/Foundation.h>

// Returns 1 if player 1 wins, 2 if player 2 wins
int playRecursiveCombat(NSMutableArray* deck1, NSMutableArray* deck2) {
	NSMutableSet* seen = NSMutableSet.new;
	
	while (deck1.count > 0 && deck2.count > 0) {
		// Check for repeated state
		NSString* state = [NSString stringWithFormat:@"%@|%@", 
			[deck1 componentsJoinedByString:@","],
			[deck2 componentsJoinedByString:@","]];
		if ([seen containsObject:state]) {
			return 1; // Player 1 wins by infinite loop prevention
		}
		[seen addObject:state];
		
		// Draw cards
		int card1 = [deck1[0] intValue];
		int card2 = [deck2[0] intValue];
		[deck1 removeObjectAtIndex:0];
		[deck2 removeObjectAtIndex:0];
		
		int roundWinner;
		
		// Check if we need to recurse
		if (deck1.count >= card1 && deck2.count >= card2) {
			// Play sub-game with copies
			NSMutableArray* subDeck1 = [[deck1 subarrayWithRange:NSMakeRange(0, card1)] mutableCopy];
			NSMutableArray* subDeck2 = [[deck2 subarrayWithRange:NSMakeRange(0, card2)] mutableCopy];
			roundWinner = playRecursiveCombat(subDeck1, subDeck2);
		} else {
			// Normal comparison
			roundWinner = (card1 > card2) ? 1 : 2;
		}
		
		// Winner takes cards
		if (roundWinner == 1) {
			[deck1 addObject:@(card1)];
			[deck1 addObject:@(card2)];
		} else {
			[deck2 addObject:@(card2)];
			[deck2 addObject:@(card1)];
		}
	}
	
	return deck1.count > 0 ? 1 : 2;
}

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
		
		// Play recursive combat
		int winner = playRecursiveCombat(deck1, deck2);
		
		// Calculate score
		NSMutableArray* winnerDeck = (winner == 1) ? deck1 : deck2;
		long long score = 0;
		for (int i = 0; i < winnerDeck.count; i++) {
			score += [winnerDeck[i] longLongValue] * (winnerDeck.count - i);
		}
		
		NSLog(@"%lld", score);
	}
}
