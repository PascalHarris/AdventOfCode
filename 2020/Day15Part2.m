#import <Foundation/Foundation.h>
#import <stdlib.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		int startingNumbers[] = {10, 16, 6, 0, 1, 17};
		int startingCount = 6;
		int target = 30000000;
		
		int* lastSpoken = calloc(target, sizeof(int));
		int lastNumber = 0;
		
		for (int turn = 1; turn <= target; turn++) {
			int currentNumber;
			if (turn <= startingCount) {
				currentNumber = startingNumbers[turn - 1];
			} else {
				if (lastSpoken[lastNumber] != 0) {
					currentNumber = (turn - 1) - lastSpoken[lastNumber];
				} else {
					currentNumber = 0;
				}
			}
			
			if (turn > 1) {
				lastSpoken[lastNumber] = turn - 1;
			}
			lastNumber = currentNumber;
		}
		
		NSLog(@"%d", lastNumber);
		free(lastSpoken);
	}
}
