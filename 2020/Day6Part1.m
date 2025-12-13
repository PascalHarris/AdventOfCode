#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* answersFile = [NSString stringWithContentsOfFile:@"./Data/inputday6a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* answersArray = NSMutableArray.new;
	for (NSString* groupAnswers in [answersFile componentsSeparatedByString:@"\n\n"]) {
		NSMutableArray* groupArray = NSMutableArray.new;
		for (NSString* personAnswer in [groupAnswers componentsSeparatedByString:@"\n"]) {
			if (personAnswer.length == 0) { break; }
			[groupArray addObject:personAnswer.copy];
		}
		[answersArray addObject:groupArray.copy];
	}
	return answersArray; }

int main(int argc, char *argv[]) {
	@autoreleasepool {
		int total = 0;
		NSArray* answerArray = [NSArray.alloc initWithArray:loadData()];
		for (NSArray* group in answerArray) {
			int answer_array[26] = {0};
			for (NSString* person in group) {
				for(int i =0 ; i < person.length; i++) {
					char character = [person.uppercaseString characterAtIndex:i];
					answer_array[character-65] = 1;
				}
			}
			for (int i = 0; i < sizeof(answer_array)/sizeof(answer_array[0]); i++) { total += answer_array[i]; }
		}
		
		NSLog(@"%d", total);
	}
}