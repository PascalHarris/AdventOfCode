(*
	Advent of Code - Invalid Product IDs Part 2 (AppleScriptObjC version)
	
	Finds all "invalid" product IDs within given ranges, where an invalid ID
	is one whose digits form a sequence repeated at least twice.
	
	Optimized: Only generates candidates that could fall within each range.
*)

use AppleScript version "2.4"
use framework "Foundation"
use scripting additions

(*
	makeDecimal
	
	Creates an NSDecimalNumber from a string.
	
	Input: s (string) - numeric string
	Output: NSDecimalNumber
*)
on makeDecimal(s)
	return current application's NSDecimalNumber's decimalNumberWithString:s
end makeDecimal

(*
	decimalToString
	
	Converts an NSDecimalNumber to a plain string (no scientific notation).
	
	Input: d (NSDecimalNumber)
	Output: string
*)
on decimalToString(d)
	return (d's stringValue()) as text
end decimalToString

(*
	compareDecimals
	
	Compares two NSDecimalNumbers.
	
	Input: a, b (NSDecimalNumber)
	Output: integer (-1 if a<b, 0 if a=b, 1 if a>b)
*)
on compareDecimals(a, b)
	return (a's compare:b) as integer
end compareDecimals

(*
	addDecimals
	
	Adds two NSDecimalNumbers.
	
	Input: a, b (NSDecimalNumber)
	Output: NSDecimalNumber
*)
on addDecimals(a, b)
	return a's decimalNumberByAdding:b
end addDecimals

(*
	trimWhitespace
	
	Removes leading and trailing whitespace and newlines from a string.
	
	Input: s (string) - the string to trim
	Output: string - the trimmed string
*)
on trimWhitespace(s)
	set whitespace to {" ", tab, linefeed, return}
	
	repeat while (length of s > 0) and ((character 1 of s) is in whitespace)
		set s to text 2 thru -1 of s
	end repeat
	
	repeat while (length of s > 0) and ((character -1 of s) is in whitespace)
		set s to text 1 thru -2 of s
	end repeat
	
	return s
end trimWhitespace

(*
	parseRanges
	
	Parses the input string into a list of {startDecimal, endDecimal} pairs.
	
	Input: inputText (string) - comma-separated ranges in "start-end" format
	Output: list of lists - each inner list contains {start, end} as NSDecimalNumbers
*)
on parseRanges(inputText)
	set ranges to {}
	
	set AppleScript's text item delimiters to ","
	set rangeStrings to text items of inputText
	set AppleScript's text item delimiters to ""
	
	repeat with rangeStr in rangeStrings
		set trimmed to my trimWhitespace(rangeStr as text)
		if trimmed is not "" then
			set AppleScript's text item delimiters to "-"
			set parts to text items of trimmed
			set AppleScript's text item delimiters to ""
			
			if (count of parts) is 2 then
				set startDec to makeDecimal(item 1 of parts)
				set endDec to makeDecimal(item 2 of parts)
				set end of ranges to {startDec, endDec}
			end if
		end if
	end repeat
	
	return ranges
end parseRanges

(*
	repeatString
	
	Repeats a string a given number of times.
	
	Input: s (string) - the string to repeat
	       repeatCount (integer) - number of repetitions
	Output: string - the repeated string
*)
on repeatString(s, repeatCount)
	set resultStr to ""
	repeat repeatCount times
		set resultStr to resultStr & s
	end repeat
	return resultStr
end repeatString

(*
	findInvalidIDsInRange
	
	Finds all invalid IDs within a single range by generating only
	candidates that could fall within [rangeStart, rangeEnd].
	
	Input: rangeStart (NSDecimalNumber) - start of range
	       rangeEnd (NSDecimalNumber) - end of range
	Output: list of strings - invalid ID strings found in the range
*)
on findInvalidIDsInRange(rangeStart, rangeEnd)
	set foundIDs to {}
	
	set startStr to decimalToString(rangeStart)
	set endStr to decimalToString(rangeEnd)
	set minDigits to length of startStr
	set maxDigits to length of endStr
	
	-- For each possible total digit length in this range
	repeat with totalDigits from minDigits to maxDigits
		
		-- Try each valid base length (divisors where totalDigits/baseLen >= 2)
		repeat with baseLen from 1 to (totalDigits div 2)
			if totalDigits mod baseLen is 0 then
				set repCount to totalDigits div baseLen
				
				-- Calculate base number range for this length
				if baseLen is 1 then
					set baseMin to 1
					set baseMax to 9
				else
					set baseMin to (10 ^ (baseLen - 1)) as integer
					set baseMax to ((10 ^ baseLen) - 1) as integer
				end if
				
				-- Narrow the base range based on range boundaries
				if (length of startStr) is totalDigits then
					set prefixMin to (text 1 thru baseLen of startStr) as integer
					if prefixMin > baseMin then set baseMin to prefixMin
				end if
				
				if (length of endStr) is totalDigits then
					set prefixMax to (text 1 thru baseLen of endStr) as integer
					if prefixMax < baseMax then set baseMax to prefixMax
				end if
				
				-- Generate and check candidates in narrowed range
				repeat with base from baseMin to baseMax
					set baseStr to base as text
					set candidateStr to repeatString(baseStr, repCount)
					set candidateDec to makeDecimal(candidateStr)
					
					if compareDecimals(candidateDec, rangeStart) ³ 0 and compareDecimals(candidateDec, rangeEnd) ² 0 then
						set end of foundIDs to candidateStr
					end if
				end repeat
			end if
		end repeat
	end repeat
	
	return foundIDs
end findInvalidIDsInRange

(*
	Main Script
*)

set inputFile to choose file with prompt "Select the input file:" of type {"public.plain-text"}
set inputText to read inputFile as Çclass utf8È
set ranges to parseRanges(inputText)

-- Use a set to avoid counting duplicates if ranges overlap
set matchedIDs to current application's NSMutableSet's |set|()

set rangeCount to count of ranges
repeat with i from 1 to rangeCount
	set r to item i of ranges
	set rangeStart to item 1 of r
	set rangeEnd to item 2 of r
	
	set foundIDs to findInvalidIDsInRange(rangeStart, rangeEnd)
	
	repeat with idStr in foundIDs
		matchedIDs's addObject:idStr
	end repeat
end repeat

-- Sum all matched IDs
set totalSum to makeDecimal("0")
set allMatched to matchedIDs's allObjects() as list
repeat with idStr in allMatched
	set totalSum to addDecimals(totalSum, makeDecimal(idStr))
end repeat

set resultStr to decimalToString(totalSum)
display dialog "Sum of all invalid IDs: " & resultStr buttons {"OK"} default button "OK"

return resultStr