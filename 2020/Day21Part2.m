#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday21a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* lines = [inputFile componentsSeparatedByString:@"\n"];
		
		NSMutableDictionary* allergenCandidates = NSMutableDictionary.new;
		
		for (NSString* line in lines) {
			if (line.length == 0) { continue; }
			
			NSArray* parts = [line componentsSeparatedByString:@" (contains "];
			NSArray* ingredients = [parts[0] componentsSeparatedByString:@" "];
			NSMutableSet* ingredientSet = [NSMutableSet setWithArray:ingredients];
			
			if (parts.count > 1) {
				NSString* allergenPart = [parts[1] stringByReplacingOccurrencesOfString:@")" withString:@""];
				NSArray* allergens = [allergenPart componentsSeparatedByString:@", "];
				
				for (NSString* allergen in allergens) {
					if (!allergenCandidates[allergen]) {
						allergenCandidates[allergen] = [ingredientSet mutableCopy];
					} else {
						[allergenCandidates[allergen] intersectSet:ingredientSet];
					}
				}
			}
		}
		
		// Solve by elimination
		NSMutableDictionary* allergenToIngredient = NSMutableDictionary.new;
		while (allergenToIngredient.count < allergenCandidates.count) {
			for (NSString* allergen in allergenCandidates) {
				NSMutableSet* candidates = allergenCandidates[allergen];
				if (candidates.count == 1) {
					NSString* ingredient = [candidates anyObject];
					allergenToIngredient[allergen] = ingredient;
					// Remove this ingredient from all other candidate sets
					for (NSString* otherAllergen in allergenCandidates) {
						[allergenCandidates[otherAllergen] removeObject:ingredient];
					}
				}
			}
		}
		
		// Sort allergens alphabetically and build result
		NSArray* sortedAllergens = [allergenToIngredient.allKeys sortedArrayUsingSelector:@selector(compare:)];
		NSMutableArray* dangerousIngredients = NSMutableArray.new;
		for (NSString* allergen in sortedAllergens) {
			[dangerousIngredients addObject:allergenToIngredient[allergen]];
		}
		
		NSLog(@"%@", [dangerousIngredients componentsJoinedByString:@","]);
	}
}
