#import <Foundation/Foundation.h>

NSMutableArray* loadData() {
	NSString* seatFile = [NSString stringWithContentsOfFile:@"./Data/inputday11a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* returnArray = NSMutableArray.new;
	for (NSString* line in [seatFile componentsSeparatedByString:@"\n"]) {
		if (line.length == 0) { continue; }
		NSMutableArray* lineArray = NSMutableArray.new;
		for (int i = 0; i < line.length; i++) {
			[lineArray addObject:[line substringWithRange:NSMakeRange(i, 1)]];
		}
		[returnArray addObject:lineArray];
	}
	return returnArray;
}

NSMutableArray* copyGrid(NSArray* grid) {
	NSMutableArray* newGrid = NSMutableArray.new;
	for (NSArray* row in grid) {
		[newGrid addObject:[row mutableCopy]];
	}
	return newGrid;
}

int countVisibleOccupied(NSArray* grid, int row, int col) {
	int count = 0;
	int numRows = (int)grid.count;
	int numCols = (int)[grid[0] count];
	int directions[8][2] = {{-1,-1},{-1,0},{-1,1},{0,-1},{0,1},{1,-1},{1,0},{1,1}};
	for (int d = 0; d < 8; d++) {
		int dr = directions[d][0];
		int dc = directions[d][1];
		int newRow = row + dr;
		int newCol = col + dc;
		while (newRow >= 0 && newRow < numRows && newCol >= 0 && newCol < numCols) {
			NSString* seat = grid[newRow][newCol];
			if ([seat isEqualToString:@"#"]) { count++; break; }
			if ([seat isEqualToString:@"L"]) { break; }
			newRow += dr;
			newCol += dc;
		}
	}
	return count;
}

NSMutableArray* simulateStep(NSArray* grid) {
	NSMutableArray* newGrid = copyGrid(grid);
	int numRows = (int)grid.count;
	int numCols = (int)[grid[0] count];
	for (int row = 0; row < numRows; row++) {
		for (int col = 0; col < numCols; col++) {
			NSString* seat = grid[row][col];
			int visible = countVisibleOccupied(grid, row, col);
			if ([seat isEqualToString:@"L"] && visible == 0) {
				newGrid[row][col] = @"#";
			} else if ([seat isEqualToString:@"#"] && visible >= 5) {
				newGrid[row][col] = @"L";
			}
		}
	}
	return newGrid;
}

BOOL gridsEqual(NSArray* grid1, NSArray* grid2) {
	for (int row = 0; row < grid1.count; row++) {
		for (int col = 0; col < [grid1[0] count]; col++) {
			if (![grid1[row][col] isEqualToString:grid2[row][col]]) { return NO; }
		}
	}
	return YES;
}

int countOccupied(NSArray* grid) {
	int count = 0;
	for (NSArray* row in grid) {
		for (NSString* seat in row) {
			if ([seat isEqualToString:@"#"]) { count++; }
		}
	}
	return count;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSMutableArray* grid = loadData();
		while (YES) {
			NSMutableArray* newGrid = simulateStep(grid);
			if (gridsEqual(grid, newGrid)) { break; }
			grid = newGrid;
		}
		NSLog(@"%d", countOccupied(grid));
	}
}
