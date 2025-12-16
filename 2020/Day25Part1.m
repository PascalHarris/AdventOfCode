#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString* inputFile = [NSString stringWithContentsOfFile:@"./Data/inputday25a.txt" encoding:NSUTF8StringEncoding error:NULL];
		NSArray* lines = [inputFile componentsSeparatedByString:@"\n"];
		
		long long cardPublicKey = [lines[0] longLongValue];
		long long doorPublicKey = [lines[1] longLongValue];
		long long mod = 20201227;
		
		// Find card's loop size by brute force
		long long value = 1;
		int cardLoopSize = 0;
		while (value != cardPublicKey) {
			value = (value * 7) % mod;
			cardLoopSize++;
		}
		
		// Calculate encryption key using door's public key and card's loop size
		long long encryptionKey = 1;
		for (int i = 0; i < cardLoopSize; i++) {
			encryptionKey = (encryptionKey * doorPublicKey) % mod;
		}
		
		NSLog(@"%lld", encryptionKey);
	}
}
