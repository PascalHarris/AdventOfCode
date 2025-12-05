(*
	Fresh Ingredients Checker - Part 2
	
	This script counts the total number of unique ingredient IDs that are
	considered fresh according to all the fresh ID ranges.
	
	Optimization strategy:
	1. Parse all ranges as NSDecimalNumber pairs
	2. Sort ranges by start value
	3. Merge overlapping/adjacent ranges into non-overlapping intervals
	4. Sum (end - start + 1) for each merged range
	
	This avoids enumerating individual IDs - we just calculate the span of each
	merged interval.
	
	Complexity: O(m log m) for sorting + O(m) for merging and summing
	where m = number of ranges
	
	Uses Objective-C NSDecimalNumber for large integer arithmetic.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

(*
	readFileContents
	
	Reads the contents of a file and returns it as a string.
	
	Input: fileAlias - alias to the file
	Output: string - the contents of the file
*)
on readFileContents(fileAlias)
	return read fileAlias as Çclass utf8È
end readFileContents

(*
	parseRanges
	
	Parses only the ranges section of the input (before the blank line).
	Returns ranges as NSMutableArray of NSDictionary.
	
	Input: inputText (string) - the raw file contents
	Output: NSMutableArray of range dictionaries
*)
on parseRanges(inputText)
	set nsText to current application's NSString's stringWithString:inputText
	set allLines to (nsText's componentsSeparatedByCharactersInSet:(current application's NSCharacterSet's newlineCharacterSet())) as list
	
	set rawRanges to current application's NSMutableArray's array()
	
	repeat with aLine in allLines
		set lineContent to aLine as text
		
		-- Stop at blank line (end of ranges section)
		if lineContent is "" then exit repeat
		
		-- Parse range "start-end"
		set AppleScript's text item delimiters to {"-"}
		set rangeParts to text items of lineContent
		set AppleScript's text item delimiters to {""}
		
		if (count of rangeParts) is 2 then
			set startDec to current application's NSDecimalNumber's decimalNumberWithString:(item 1 of rangeParts)
			set endDec to current application's NSDecimalNumber's decimalNumberWithString:(item 2 of rangeParts)
			set rangeDict to current application's NSMutableDictionary's dictionary()
			rangeDict's setObject:startDec forKey:"rangeStart"
			rangeDict's setObject:endDec forKey:"rangeEnd"
			rawRanges's addObject:rangeDict
		end if
	end repeat
	
	return rawRanges
end parseRanges

(*
	sortAndMergeRanges
	
	Sorts ranges by start value, then merges overlapping/adjacent ranges
	into non-overlapping intervals.
	
	Input: rawRanges - NSMutableArray of NSDictionary with "rangeStart" and "rangeEnd" keys
	Output: NSArray of NSDictionary with merged, non-overlapping ranges
*)
on sortAndMergeRanges(rawRanges)
	-- Sort by start value
	set sortDesc to current application's NSSortDescriptor's sortDescriptorWithKey:"rangeStart" ascending:true
	rawRanges's sortUsingDescriptors:{sortDesc}
	
	set merged to current application's NSMutableArray's array()
	
	if (rawRanges's |count|()) is 0 then return merged
	
	-- Start with first range
	set firstRange to (rawRanges's objectAtIndex:0)
	set currentStart to (firstRange's objectForKey:"rangeStart")
	set currentEnd to (firstRange's objectForKey:"rangeEnd")
	
	set rangeCount to (rawRanges's |count|()) as integer
	set one to current application's NSDecimalNumber's one()
	
	repeat with i from 1 to (rangeCount - 1)
		set nextRange to (rawRanges's objectAtIndex:i)
		set nextStart to (nextRange's objectForKey:"rangeStart")
		set nextEnd to (nextRange's objectForKey:"rangeEnd")
		
		-- Check if ranges overlap or are adjacent
		-- They overlap/touch if nextStart <= currentEnd + 1
		set currentEndPlusOne to (currentEnd's decimalNumberByAdding:one)
		
		if (nextStart's compare:currentEndPlusOne) is not greater than 0 then
			-- Merge: extend currentEnd if necessary
			if (nextEnd's compare:currentEnd) > 0 then
				set currentEnd to nextEnd
			end if
		else
			-- No overlap: save current range and start new one
			set mergedDict to current application's NSMutableDictionary's dictionary()
			mergedDict's setObject:currentStart forKey:"rangeStart"
			mergedDict's setObject:currentEnd forKey:"rangeEnd"
			merged's addObject:mergedDict
			set currentStart to nextStart
			set currentEnd to nextEnd
		end if
	end repeat
	
	-- Don't forget the last range
	set mergedDict to current application's NSMutableDictionary's dictionary()
	mergedDict's setObject:currentStart forKey:"rangeStart"
	mergedDict's setObject:currentEnd forKey:"rangeEnd"
	merged's addObject:mergedDict
	
	return merged
end sortAndMergeRanges

(*
	countTotalFreshIDs
	
	Counts the total number of unique IDs covered by all merged ranges.
	For each range, adds (end - start + 1) to the total.
	
	Input: mergedRanges - NSArray of sorted, non-overlapping range dictionaries
	Output: NSDecimalNumber - total count of fresh IDs
*)
on countTotalFreshIDs(mergedRanges)
	set totalCount to current application's NSDecimalNumber's zero()
	set one to current application's NSDecimalNumber's one()
	
	set rangeCount to (mergedRanges's |count|()) as integer
	
	repeat with i from 0 to (rangeCount - 1)
		set aRange to (mergedRanges's objectAtIndex:i)
		set rangeStart to (aRange's objectForKey:"rangeStart")
		set rangeEnd to (aRange's objectForKey:"rangeEnd")
		
		-- Calculate: rangeEnd - rangeStart + 1
		set rangeSize to ((rangeEnd's decimalNumberBySubtracting:rangeStart)'s decimalNumberByAdding:one)
		set totalCount to (totalCount's decimalNumberByAdding:rangeSize)
	end repeat
	
	return totalCount
end countTotalFreshIDs

(*
	Main execution
*)

-- Get the input file from user
set inputFile to choose file with prompt "Select the input file:" of type {"public.plain-text"}

-- Read and parse the ranges only
set inputText to readFileContents(inputFile)
set rawRanges to parseRanges(inputText)

-- Sort and merge ranges
set mergedRanges to sortAndMergeRanges(rawRanges)

-- Count total fresh IDs across all merged ranges
set totalFreshIDs to countTotalFreshIDs(mergedRanges)

-- Convert to string for display
set resultStr to (totalFreshIDs's stringValue()) as text

-- Display result
display dialog "Total fresh ingredient IDs: " & resultStr buttons {"OK"} default button 1

return resultStr