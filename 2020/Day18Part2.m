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

long long evalMul(NSString* expr, int* pos);

long long getValue(NSString* expr, int* pos) {
	if ([expr characterAtIndex:*pos] == '(') {
		(*pos)++;
		long long result = evalMul(expr, pos);
		(*pos)++;
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

long long evalAdd(NSString* expr, int* pos) {
	long long result = getValue(expr, pos);
	
	while (*pos < expr.length && [expr characterAtIndex:*pos] == '+') {
		(*pos)++;
		result += getValue(expr, pos);
	}
	
	return result;
}

long long evalMul(NSString* expr, int* pos) {
	long long result = evalAdd(expr, pos);
	
	while (*pos < expr.length && [expr characterAtIndex:*pos] == '*') {
		(*pos)++;
		result *= evalAdd(expr, pos);
	}
	
	return result;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray* expressions = loadData();
		long long sum = 0;
		
		for (NSString* expr in expressions) {
			int pos = 0;
			sum += evalMul(expr, &pos);
		}
		
		NSLog(@"%lld", sum);
	}
}
