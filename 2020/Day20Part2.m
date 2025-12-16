#import <Foundation/Foundation.h>

@interface Tile : NSObject
@property int tileId;
@property NSMutableArray* data;
- (NSString*)top;
- (NSString*)bottom;
- (NSString*)left;
- (NSString*)right;
- (Tile*)rotated;
- (Tile*)flipped;
- (NSArray*)allOrientations;
- (NSMutableArray*)stripped;
@end

@implementation Tile
- (NSString*)top { return _data[0]; }
- (NSString*)bottom { return _data[_data.count - 1]; }
- (NSString*)left {
	NSMutableString* s = NSMutableString.new;
	for (NSString* row in _data) { [s appendFormat:@"%c", [row characterAtIndex:0]]; }
	return s;
}
- (NSString*)right {
	NSMutableString* s = NSMutableString.new;
	for (NSString* row in _data) { [s appendFormat:@"%c", [row characterAtIndex:row.length-1]]; }
	return s;
}
- (Tile*)rotated {
	Tile* t = Tile.new;
	t.tileId = _tileId;
	t.data = NSMutableArray.new;
	int size = (int)_data.count;
	for (int i = 0; i < size; i++) {
		NSMutableString* row = NSMutableString.new;
		for (int j = size - 1; j >= 0; j--) {
			[row appendFormat:@"%c", [_data[j] characterAtIndex:i]];
		}
		[t.data addObject:row];
	}
	return t;
}
- (Tile*)flipped {
	Tile* t = Tile.new;
	t.tileId = _tileId;
	t.data = NSMutableArray.new;
	for (NSString* row in _data) {
		NSMutableString* rev = NSMutableString.new;
		for (NSInteger i = row.length - 1; i >= 0; i--) {
			[rev appendFormat:@"%c", [row characterAtIndex:i]];
		}
		[t.data addObject:rev];
	}
	return t;
}
- (NSArray*)allOrientations {
	NSMutableArray* arr = NSMutableArray.new;
	Tile* t = self;
	for (int i = 0; i < 4; i++) {
		[arr addObject:t];
		[arr addObject:[t flipped]];
		t = [t rotated];
	}
	return arr;
}
- (NSMutableArray*)stripped {
	NSMutableArray* arr = NSMutableArray.new;
	for (int i = 1; i < _data.count - 1; i++) {
		NSString* row = _data[i];
		[arr addObject:[row substringWithRange:NSMakeRange(1, row.length - 2)]];
	}
	return arr;
}
@end

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday20a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* tileBlocks = [inputFile componentsSeparatedByString:@"\n\n"];
		
		NSMutableDictionary* tiles = NSMutableDictionary.new;
		for (NSString* block in tileBlocks) {
			if (block.length == 0) { continue; }
			NSArray* lines = [block componentsSeparatedByString:@"\n"];
			int tileId = [[[lines[0] componentsSeparatedByString:@" "][1] stringByReplacingOccurrencesOfString:@":" withString:@""] intValue];
			Tile* tile = Tile.new;
			tile.tileId = tileId;
			tile.data = NSMutableArray.new;
			for (int i = 1; i < lines.count; i++) {
				if ([lines[i] length] > 0) { [tile.data addObject:lines[i]]; }
			}
			tiles[@(tileId)] = tile;
		}
		
		// Build edge map
		NSMutableDictionary* edgeToTiles = NSMutableDictionary.new;
		for (NSNumber* tid in tiles) {
			Tile* t = tiles[tid];
			for (Tile* orient in [t allOrientations]) {
				for (NSString* edge in @[[orient top], [orient bottom], [orient left], [orient right]]) {
					if (!edgeToTiles[edge]) { edgeToTiles[edge] = NSMutableSet.new; }
					[edgeToTiles[edge] addObject:tid];
				}
			}
		}
		
		// Find a corner tile
		NSNumber* cornerTileId = nil;
		for (NSNumber* tid in tiles) {
			Tile* t = tiles[tid];
			int unmatchedCount = 0;
			for (NSString* edge in @[[t top], [t bottom], [t left], [t right]]) {
				BOOL matched = NO;
				for (Tile* orient in [t allOrientations]) {
					if ([edgeToTiles[[orient top]] count] > 1 || [edgeToTiles[[orient bottom]] count] > 1 ||
						[edgeToTiles[[orient left]] count] > 1 || [edgeToTiles[[orient right]] count] > 1) {
						matched = YES;
					}
				}
			}
			// Simpler: count unique edges
			NSMutableSet* uniqueEdges = NSMutableSet.new;
			for (Tile* orient in [t allOrientations]) {
				if ([edgeToTiles[[orient top]] count] == 1) [uniqueEdges addObject:[orient top]];
				if ([edgeToTiles[[orient bottom]] count] == 1) [uniqueEdges addObject:[orient bottom]];
				if ([edgeToTiles[[orient left]] count] == 1) [uniqueEdges addObject:[orient left]];
				if ([edgeToTiles[[orient right]] count] == 1) [uniqueEdges addObject:[orient right]];
			}
			if (uniqueEdges.count == 4) { // 2 edges * 2 directions each = 4
				cornerTileId = tid;
				break;
			}
		}
		
		// Orient corner tile so its unmatched edges are top and left
		Tile* corner = tiles[cornerTileId];
		Tile* startTile = nil;
		for (Tile* orient in [corner allOrientations]) {
			if ([edgeToTiles[[orient top]] count] == 1 && [edgeToTiles[[orient left]] count] == 1) {
				startTile = orient;
				break;
			}
		}
		
		// Assemble grid
		int gridSize = (int)sqrt(tiles.count);
		NSMutableArray* grid = NSMutableArray.new;
		for (int i = 0; i < gridSize; i++) {
			[grid addObject:[NSMutableArray new]];
		}
		
		NSMutableSet* usedTiles = NSMutableSet.new;
		grid[0][0] = startTile;
		[usedTiles addObject:@(startTile.tileId)];
		
		// Fill first row
		for (int col = 1; col < gridSize; col++) {
			Tile* leftTile = grid[0][col - 1];
			NSString* needLeft = [leftTile right];
			for (NSNumber* tid in tiles) {
				if ([usedTiles containsObject:tid]) { continue; }
				Tile* t = tiles[tid];
				BOOL found = NO;
				for (Tile* orient in [t allOrientations]) {
					if ([[orient left] isEqualToString:needLeft] && [edgeToTiles[[orient top]] count] == 1) {
						grid[0][col] = orient;
						[usedTiles addObject:tid];
						found = YES;
						break;
					}
				}
				if (found) break;
			}
		}
		
		// Fill remaining rows
		for (int row = 1; row < gridSize; row++) {
			for (int col = 0; col < gridSize; col++) {
				Tile* aboveTile = grid[row - 1][col];
				NSString* needTop = [aboveTile bottom];
				NSString* needLeft = (col > 0) ? [grid[row][col - 1] right] : nil;
				
				for (NSNumber* tid in tiles) {
					if ([usedTiles containsObject:tid]) { continue; }
					Tile* t = tiles[tid];
					BOOL found = NO;
					for (Tile* orient in [t allOrientations]) {
						if ([[orient top] isEqualToString:needTop]) {
							if (col == 0) {
								if ([edgeToTiles[[orient left]] count] == 1) {
									grid[row][col] = orient;
									[usedTiles addObject:tid];
									found = YES;
									break;
								}
							} else if ([[orient left] isEqualToString:needLeft]) {
								grid[row][col] = orient;
								[usedTiles addObject:tid];
								found = YES;
								break;
							}
						}
					}
					if (found) break;
				}
			}
		}
		
		// Build final image (strip borders)
		NSMutableArray* image = NSMutableArray.new;
		int tileSize = (int)[((Tile*)grid[0][0]).data count] - 2;
		for (int row = 0; row < gridSize; row++) {
			for (int tr = 0; tr < tileSize; tr++) {
				NSMutableString* imgRow = NSMutableString.new;
				for (int col = 0; col < gridSize; col++) {
					Tile* t = grid[row][col];
					NSArray* stripped = [t stripped];
					[imgRow appendString:stripped[tr]];
				}
				[image addObject:imgRow];
			}
		}
		
		// Sea monster pattern
		NSArray* monster = @[@"                  # ",
							 @"#    ##    ##    ###",
							 @" #  #  #  #  #  #   "];
		int monsterHeight = 3;
		int monsterWidth = 20;
		
		// Get monster offsets
		NSMutableArray* monsterOffsets = NSMutableArray.new;
		for (int r = 0; r < monsterHeight; r++) {
			NSString* row = monster[r];
			for (int c = 0; c < monsterWidth; c++) {
				if ([row characterAtIndex:c] == '#') {
					[monsterOffsets addObject:@[@(r), @(c)]];
				}
			}
		}
		
		// Try all 8 orientations of the image
		Tile* imgTile = Tile.new;
		imgTile.data = image;
		
		for (Tile* orient in [imgTile allOrientations]) {
			NSMutableArray* img = orient.data;
			int imgHeight = (int)img.count;
			int imgWidth = (int)[img[0] length];
			int monstersFound = 0;
			NSMutableSet* monsterCells = NSMutableSet.new;
			
			for (int r = 0; r <= imgHeight - monsterHeight; r++) {
				for (int c = 0; c <= imgWidth - monsterWidth; c++) {
					BOOL found = YES;
					for (NSArray* off in monsterOffsets) {
						int dr = [off[0] intValue];
						int dc = [off[1] intValue];
						if ([img[r + dr] characterAtIndex:c + dc] != '#') {
							found = NO;
							break;
						}
					}
					if (found) {
						monstersFound++;
						for (NSArray* off in monsterOffsets) {
							int dr = [off[0] intValue];
							int dc = [off[1] intValue];
							[monsterCells addObject:[NSString stringWithFormat:@"%d,%d", r + dr, c + dc]];
						}
					}
				}
			}
			
			if (monstersFound > 0) {
				int totalHashes = 0;
				for (NSString* row in img) {
					for (int c = 0; c < row.length; c++) {
						if ([row characterAtIndex:c] == '#') { totalHashes++; }
					}
				}
				NSLog(@"%d", totalHashes - (int)monsterCells.count);
				return 0;
			}
		}
	}
	return 0;
}
