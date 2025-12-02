(*
	Advent of Code - Invalid Product IDs (AppleScriptObjC version)
	
	Finds all "invalid" product IDs within given ranges, where an invalid ID
	is one whose digits form a sequence repeated exactly twice (e.g., 123123, 5555, 6464).
	Returns the sum of all invalid IDs found.
	
	Uses Foundation framework for large number handling and performance.
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
	makeInvalidIDString
	
	Creates an invalid ID string by doubling the base string.
	
	Input: baseStr (string) - the base number as string
	Output: string - the doubled string (e.g., "123" -> "123123")
*)
on makeInvalidIDString(baseStr)
	return baseStr & baseStr
end makeInvalidIDString

(*
	findInvalidIDsInRange
	
	Finds all invalid IDs within a single range by generating only the
	candidates that could fall within [rangeStart, rangeEnd].
	
	Input: rangeStart (NSDecimalNumber) - start of range
	       rangeEnd (NSDecimalNumber) - end of range
	Output: list of NSDecimalNumbers - invalid IDs found in the range
*)
on findInvalidIDsInRange(rangeStart, rangeEnd)
	set foundIDs to {}
	
	set startStr to decimalToString(rangeStart)
	set endStr to decimalToString(rangeEnd)
	set minDigits to length of startStr
	set maxDigits to length of endStr
	
	-- Only even digit lengths can be invalid IDs
	if minDigits mod 2 is 1 then set minDigits to minDigits + 1
	if maxDigits mod 2 is 1 then set maxDigits to maxDigits - 1
	
	repeat with totalDigits from minDigits to maxDigits by 2
		set halfLen to totalDigits div 2
		
		-- Calculate the base range for this digit length
		-- e.g., for 6-digit invalid IDs, base is 3 digits: 100-999
		if halfLen is 1 then
			set baseMin to 1
			set baseMax to 9
		else
			set baseMin to (10 ^ (halfLen - 1)) as integer
			set baseMax to ((10 ^ halfLen) - 1) as integer
		end if
		
		-- Narrow down based on the actual range boundaries
		-- For the minimum: if rangeStart is within this digit length,
		-- we can start from a higher base
		if (length of startStr) is totalDigits then
			set candidateMin to (text 1 thru halfLen of startStr) as integer
			if candidateMin > baseMin then set baseMin to candidateMin
		end if
		
		-- For the maximum: if rangeEnd is within this digit length,
		-- we can end at a lower base
		if (length of endStr) is totalDigits then
			set candidateMax to (text 1 thru halfLen of endStr) as integer
			if candidateMax < baseMax then set baseMax to candidateMax
		end if
		
		-- Generate and check candidates
		repeat with base from baseMin to baseMax
			set baseStr to base as text
			set invalidStr to makeInvalidIDString(baseStr)
			set invalidDec to makeDecimal(invalidStr)
			
			-- Check if within range
			if compareDecimals(invalidDec, rangeStart) ³ 0 and compareDecimals(invalidDec, rangeEnd) ² 0 then
				set end of foundIDs to invalidDec
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

set totalSum to makeDecimal("0")

repeat with r in ranges
	set rangeStart to item 1 of r
	set rangeEnd to item 2 of r
	set invalidIDs to findInvalidIDsInRange(rangeStart, rangeEnd)
	
	repeat with invalidID in invalidIDs
		set totalSum to addDecimals(totalSum, invalidID)
	end repeat
end repeat

set resultStr to decimalToString(totalSum)
display dialog "Sum of all invalid IDs: " & resultStr buttons {"OK"} default button "OK"

return resultStr