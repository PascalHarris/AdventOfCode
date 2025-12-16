#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday21a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* lines = [inputFile componentsSeparatedByString:@"\n"];
		
		NSMutableArray* allFoods = NSMutableArray.new; // array of ingredient sets
		NSMutableDictionary* allergenCandidates = NSMutableDictionary.new; // allergen -> possible ingredients
		NSMutableArray* allIngredientsList = NSMutableArray.new; // all ingredients for counting
		
		for (NSString* line in lines) {
			if (line.length == 0) { continue; }
			
			NSArray* parts = [line componentsSeparatedByString:@" (contains "];
			NSArray* ingredients = [parts[0] componentsSeparatedByString:@" "];
			NSMutableSet* ingredientSet = [NSMutableSet setWithArray:ingredients];
			[allFoods addObject:ingredientSet];
			[allIngredientsList addObjectsFromArray:ingredients];
			
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
		
		// Find all ingredients that could contain an allergen
		NSMutableSet* possibleAllergenIngredients = NSMutableSet.new;
		for (NSString* allergen in allergenCandidates) {
			[possibleAllergenIngredients unionSet:allergenCandidates[allergen]];
		}
		
		// Count appearances of safe ingredients (those not in possibleAllergenIngredients)
		int count = 0;
		for (NSString* ingredient in allIngredientsList) {
			if (![possibleAllergenIngredients containsObject:ingredient]) {
				count++;
			}
		}
		
		NSLog(@"%d", count);
	}
}
