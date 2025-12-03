(*
Main script to solve the battery joltage puzzle - Part 2
Prompts user to select input file and calculates total maximum joltage
Now selecting exactly 12 batteries per bank
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

-- Get the input file from user
set inputFile to choose file with prompt "Select the input.txt file:"
set batteryBanks to readInputFile(inputFile)

-- Calculate total joltage using Objective-C for speed
set totalJoltage to calculateTotalJoltageObjC(batteryBanks)

display dialog "Total output joltage: " & totalJoltage buttons {"OK"} default button 1

(*
Reads the input file and returns a list of battery bank strings
Input: fileAlias - alias to the input file
Output: list of strings, each representing a battery bank
*)
on readInputFile(fileAlias)
	set fileContent to read fileAlias as Çclass utf8È
	set AppleScript's text item delimiters to {return, linefeed}
	set lineList to text items of fileContent
	set AppleScript's text item delimiters to {""}
	
	-- Filter out empty lines
	set cleanLines to {}
	repeat with aLine in lineList
		set lineContent to contents of aLine
		if lineContent is not "" then
			set end of cleanLines to lineContent
		end if
	end repeat
	
	return cleanLines
end readInputFile

(*
Calculates total joltage from all battery banks using Objective-C
Input: bankList - list of battery bank strings
Output: large integer representing total joltage
*)
on calculateTotalJoltageObjC(bankList)
	-- Use NSDecimalNumber for large number arithmetic
	set totalJoltage to current application's NSDecimalNumber's zero()
	
	repeat with bankLine in bankList
		set maxJoltage to findMaxJoltage12Digits(bankLine)
		set totalJoltage to totalJoltage's decimalNumberByAdding:maxJoltage
	end repeat
	
	-- Convert to string for display (numbers are too large for AppleScript integers)
	return (totalJoltage's stringValue()) as text
end calculateTotalJoltageObjC

(*
Finds the maximum 12-digit joltage from a battery bank using greedy algorithm
Strategy: For each of 12 positions, pick the largest digit that still allows
         us to select enough remaining digits to complete the 12-digit number
Input: bankString - string of digits representing battery joltage ratings
Output: NSDecimalNumber representing maximum 12-digit joltage from this bank
*)
on findMaxJoltage12Digits(bankString)
	set theString to current application's NSString's alloc()'s initWithString:bankString
	set bankLength to theString's |length|()
	
	-- Need at least 12 digits
	if bankLength < 12 then return current application's NSDecimalNumber's zero()
	
	set resultString to current application's NSMutableString's alloc()'s initWithString:""
	set currentPos to 0 -- Current position in the source string
	set digitsNeeded to 12 -- How many more digits we need to select
	
	-- Select 12 digits greedily
	repeat while digitsNeeded > 0
		-- Calculate how many positions we can search
		-- We need to leave enough digits after this position to complete the number
		set searchLimit to bankLength - digitsNeeded
		
		-- Find the largest digit in the valid range
		set maxDigit to -1
		set maxDigitPos to currentPos
		
		repeat with pos from currentPos to searchLimit
			set digitStr to theString's substringWithRange:(current application's NSMakeRange(pos, 1))
			set digitVal to (digitStr's integerValue()) as integer
			
			if digitVal > maxDigit then
				set maxDigit to digitVal
				set maxDigitPos to pos
			end if
			
			-- Early exit: can't do better than 9
			if maxDigit = 9 then exit repeat
		end repeat
		
		-- Add the digit to result
		resultString's appendString:(maxDigit as text)
		
		-- Move past this position
		set currentPos to maxDigitPos + 1
		set digitsNeeded to digitsNeeded - 1
	end repeat
	
	-- Convert result string to NSDecimalNumber for large number arithmetic
	return current application's NSDecimalNumber's alloc()'s initWithString:resultString
end findMaxJoltage12Digits