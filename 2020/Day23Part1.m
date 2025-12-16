#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* input = @"327465189";
		
		// Build circular linked list using array (next[i] = cup after cup i)
		int next[10] = {0};
		int numCups = 9;
		
		// Parse input
		int first = [input characterAtIndex:0] - '0';
		int prev = first;
		for (int i = 1; i < input.length; i++) {
			int cup = [input characterAtIndex:i] - '0';
			next[prev] = cup;
			prev = cup;
		}
		next[prev] = first; // Close the circle
		
		int current = first;
		
		for (int move = 0; move < 100; move++) {
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
		
		// Build result string starting after cup 1
		NSMutableString* result = NSMutableString.new;
		int cup = next[1];
		while (cup != 1) {
			[result appendFormat:@"%d", cup];
			cup = next[cup];
		}
		
		NSLog(@"%@", result);
	}
}
