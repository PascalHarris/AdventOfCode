#import <Foundation/Foundation.h>

NSArray* loadData() {
	NSString* mathFile = [NSString stringWithContentsOfFile:@"./Data/inputday18a.txt" encoding:NSUTF8StringEncoding error:NULL];
	NSMutableArray* returnArray = NSMutableArray.new;
	for (NSString* line in [mathFile componentsSeparatedByString:@"\n"]) {
		if (line.length == 0) { continue; }
		[returnArray addObject:[line stringByReplacingOccurrencesOfString:@" " withString:@""]];
	}
	return returnArray;
}

long long evaluate(NSString* expr, int* pos);

long long getValue(NSString* expr, int* pos) {
	if ([expr characterAtIndex:*pos] == '(') {
		(*pos)++; // skip '('
		long long result = evaluate(expr, pos);
		(*pos)++; // skip ')'
		return result;
	} else {
		long long num = 0;
		while (*pos < expr.length && [expr characterAtIndex:*pos] >= '0' && [expr characterAtIndex:*pos] <= '9') {
			num = num * 10 + ([expr characterAtIndex:*pos] - '0');
			(*pos)++;
		}
		return num;
	}
}

long long evaluate(NSString* expr, int* pos) {
	long long result = getValue(expr, pos);
	
	while (*pos < expr.length && [expr characterAtIndex:*pos] != ')') {
		char op = [expr characterAtIndex:*pos];
		(*pos)++;
		long long next = getValue(expr, pos);
		if (op == '+') {
			result += next;
		} else {
			result *= next;
		}
	}
	
	return result;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* expressions = loadData();
		long long sum = 0;
		
		for (NSString* expr in expressions) {
			int pos = 0;
			sum += evaluate(expr, &pos);
		}
		
		NSLog(@"%lld", sum);
	}
}
