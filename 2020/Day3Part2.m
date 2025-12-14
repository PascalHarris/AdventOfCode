#import <Foundation/Foundation.h>

NSArray* loadData() {
    NSString* slopeFile = [NSString stringWithContentsOfFile:@"./Data/inputday3a.txt" encoding:NSUTF8StringEncoding error:NULL];
    
    NSMutableArray *returnArray = NSMutableArray.new;
    for (NSString* line in [slopeFile componentsSeparatedByString:@"\n"]) {
        if (line.length == 0) continue;  // Skip empty lines
        
        int i = 0;
        NSMutableArray *lineArray = NSMutableArray.new;
        while (i < line.length) {
            NSRange range = [line rangeOfComposedCharacterSequenceAtIndex:i];
            [lineArray addObject:[line substringWithRange:range]];
            i += range.length;
        }
        [returnArray addObject:lineArray];
    }
    
    return returnArray;
}

uint32 countCollisions(int right, int down) {
    int collisions = 0;
    int col = 0;  // horizontal position
    NSArray* slopeArray = loadData();
    int width = (int)[slopeArray[0] count];
    
    for (int row = down; row < slopeArray.count; row += down) {
        col = (col + right) % width;  // move right (with wrap)
        if ([slopeArray[row][col] isEqualToString:@"#"]) {
            collisions++;
        }
    }
    return (uint32)collisions;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		uint32 answer = countCollisions(1, 1)*countCollisions(3, 1)*countCollisions(5, 1)*countCollisions(7, 1)*countCollisions(1, 2);
		NSLog(@"%u",answer);
	}
}