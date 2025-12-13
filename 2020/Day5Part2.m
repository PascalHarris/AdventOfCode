#import <Foundation/Foundation.h>
#define maximumrow 128 // 0 - 127
#define maximumseat 8 // 0 - 7

NSArray* loadData() {
	NSString* boardingPasses = [NSString stringWithContentsOfFile:@"./Data/inputday5a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* passArray = NSMutableArray.new;
	for (NSString* pass in [boardingPasses componentsSeparatedByString:@"\n"]) {
		if (pass.length == 0) { break; }
		NSString* row = [pass substringWithRange:NSMakeRange(0, 7)];
		NSString* seat = [pass substringWithRange:NSMakeRange(7, 3)];
		[passArray addObject:@{@"row":row,@"seat":seat}];
	}
	return passArray;
}

int getRow(NSString* rowAddress) {
	int minNumber = 0, incr = maximumrow /2;
	for (int i=0; i< rowAddress.length; i++) {
		NSString* chr = [rowAddress substringWithRange:NSMakeRange(i, 1)];
		minNumber = [chr isEqualToString:@"F"] ? minNumber : minNumber + incr;
		incr = incr / 2;
	}
	return minNumber;
}

int getSeat(NSString* seatAddress) {
	int minNumber = 0, incr = maximumseat /2;
	for (int i=0; i< seatAddress.length; i++) {
		NSString* chr = [seatAddress substringWithRange:NSMakeRange(i, 1)];
		minNumber = [chr isEqualToString:@"L"] ? minNumber : minNumber + incr;
		incr = incr / 2;
	}
	return minNumber;
}


int main(int argc, char *argv[]) {
	@autoreleasepool {
		int highestId = 0;
		NSArray* boardingPasses = loadData();
		NSMutableArray* seatIds = NSMutableArray.new;
		for (NSDictionary* boardingID in boardingPasses) {
			int row = getRow(boardingID[@"row"]);
			int seat = getSeat(boardingID[@"seat"]);
			highestId = row*8+seat > highestId?row*8+seat:highestId;
			[seatIds addObject:@(row*8+seat)];
		}
		
		NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
		[seatIds sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
		
		for (int i = [[seatIds valueForKeyPath:@"@min.self"] intValue]; i < [[seatIds valueForKeyPath:@"@max.self"] intValue]; i++) {
			if (![seatIds containsObject:@(i)]) {
				NSLog(@"%d",i);
			} 
		}
	}
}