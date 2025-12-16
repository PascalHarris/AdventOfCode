#import <Foundation/Foundation.h>
#import <stdlib.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* input = @"327465189";
		int numCups = 1000000;
		int numMoves = 10000000;
		
		// Use C array for speed
		int* next = malloc((numCups + 1) * sizeof(int));
		
		// Parse input
		int first = [input characterAtIndex:0] - '0';
		int prev = first;
		int maxInInput = 0;
		for (int i = 1; i < input.length; i++) {
			int cup = [input characterAtIndex:i] - '0';
			next[prev] = cup;
			prev = cup;
			if (cup > maxInInput) maxInInput = cup;
		}
		if (first > maxInInput) maxInInput = first;
		
		// Continue numbering from maxInInput+1 to numCups
		for (int i = maxInInput + 1; i <= numCups; i++) {
			next[prev] = i;
			prev = i;
		}
		next[prev] = first; // Close the circle
		
		int current = first;
		
		for (int move = 0; move < numMoves; move++) {
			// Pick up three cups after current
			int p1 = next[current];
			int p2 = next[p1];
			int p3 = next[p2];
			
			// Remove them from circle
			next[current] = next[p3];
			
			// Find destination
			int dest = current - 1;
			if (dest < 1) dest = numCups;
			while (dest == p1 || dest == p2 || dest == p3) {
				dest--;
				if (dest < 1) dest = numCups;
			}
			
			// Insert picked cups after destination
			int afterDest = next[dest];
			next[dest] = p1;
			next[p3] = afterDest;
			
			// Move to next current
			current = next[current];
		}
		
		// Get two cups after cup 1
		long long cup1 = next[1];
		long long cup2 = next[cup1];
		
		NSLog(@"%lld", cup1 * cup2);
		
		free(next);
	}
}
