#import <Foundation/Foundation.h>

NSString* reverseString(NSString* str) {
	NSMutableString* reversed = NSMutableString.new;
	for (NSInteger i = str.length - 1; i >= 0; i--) {
		[reversed appendFormat:@"%c", [str characterAtIndex:i]];
	}
	return reversed;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday20a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* tileBlocks = [inputFile componentsSeparatedByString:@"\n\n"];
		
		NSMutableDictionary* tileEdges = NSMutableDictionary.new; // tileId -> array of 8 edges (4 + 4 reversed)
		
		for (NSString* block in tileBlocks) {
			if (block.length == 0) { continue; }
			NSArray* lines = [block componentsSeparatedByString:@"\n"];
			
			// Parse tile ID
			NSString* header = lines[0];
			int tileId = [[[header componentsSeparatedByString:@" "][1] stringByReplacingOccurrencesOfString:@":" withString:@""] intValue];
			
			// Get tile data (skip header)
			NSMutableArray* tileData = NSMutableArray.new;
			for (int i = 1; i < lines.count; i++) {
				if ([lines[i] length] > 0) {
					[tileData addObject:lines[i]];
				}
			}
			
			// Extract 4 edges: top, right, bottom, left
			NSString* top = tileData[0];
			NSString* bottom = tileData[tileData.count - 1];
			
			NSMutableString* left = NSMutableString.new;
			NSMutableString* right = NSMutableString.new;
			for (int i = 0; i < tileData.count; i++) {
				NSString* row = tileData[i];
				[left appendFormat:@"%c", [row characterAtIndex:0]];
				[right appendFormat:@"%c", [row characterAtIndex:row.length - 1]];
			}
			
			// Store all 8 edge variants (each edge can match in either direction)
			NSArray* edges = @[top, reverseString(top),
							   right, reverseString(right),
							   bottom, reverseString(bottom),
							   left, reverseString(left)];
			tileEdges[@(tileId)] = edges;
		}
		
		// Count how many times each edge appears across all tiles
		NSMutableDictionary* edgeCount = NSMutableDictionary.new;
		for (NSNumber* tileId in tileEdges) {
			NSArray* edges = tileEdges[tileId];
			for (NSString* edge in edges) {
				if (!edgeCount[edge]) { edgeCount[edge] = @(0); }
				edgeCount[edge] = @([edgeCount[edge] intValue] + 1);
			}
		}
		
		// Corner tiles have exactly 2 edges (4 variants) that don't match any other tile
		// i.e., those edges appear only once (just in this tile's variants)
		long long product = 1;
		for (NSNumber* tileId in tileEdges) {
			NSArray* edges = tileEdges[tileId];
			int unmatchedEdges = 0;
			// Check each of the 4 edges (indices 0,2,4,6 are the "forward" versions)
			for (int i = 0; i < 8; i += 2) {
				NSString* edge = edges[i];
				NSString* edgeRev = edges[i + 1];
				// An edge is unmatched if both it and its reverse appear only once each
				// (once for this tile's forward, once for this tile's reverse)
				if ([edgeCount[edge] intValue] == 1 && [edgeCount[edgeRev] intValue] == 1) {
					unmatchedEdges++;
				}
			}
			if (unmatchedEdges == 2) {
				product *= tileId.longLongValue;
			}
		}
		
		NSLog(@"%lld", product);
	}
}
