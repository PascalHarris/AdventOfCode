#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* startingNumbers = @[@10, @16, @6, @0, @1, @17];
		NSMutableDictionary* lastSpoken = NSMutableDictionary.new;
		int lastNumber = 0;
		
		for (int turn = 1; turn <= 2020; turn++) {
			int currentNumber;
			if (turn <= startingNumbers.count) {
				currentNumber = [startingNumbers[turn - 1] intValue];
			} else {
				if (lastSpoken[@(lastNumber)]) {
					currentNumber = (turn - 1) - [lastSpoken[@(lastNumber)] intValue];
				} else {
					currentNumber = 0;
				}
			}
			
			if (turn > 1) {
				lastSpoken[@(lastNumber)] = @(turn - 1);
			}
			lastNumber = currentNumber;
		}
		
		NSLog(@"%d", lastNumber);
	}
}
