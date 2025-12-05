(*
	Fresh Ingredients Checker - Optimized Version
	
	This script solves the Advent of Code puzzle about identifying fresh ingredients.
	
	Optimization strategy:
	1. Parse all ranges and convert to NSDecimalNumber for large integer handling
	2. Sort ranges by start value
	3. Merge overlapping ranges into non-overlapping intervals
	4. Use binary search to check if each ID falls within any merged range
	
	Complexity: O(m log m) for sorting + O(n log m) for lookups
	where m = number of ranges, n = number of IDs
	
	Uses Objective-C for fast sorting and efficient data structures.
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
	parseInputData
	
	Parses the input into ranges and IDs using Objective-C for speed.
	Returns ranges as NSMutableArray of NSDictionary, IDs as NSMutableArray of NSDecimalNumber.
	
	Input: inputText (string) - the raw file contents
	Output: record with {rawRanges: NSMutableArray, availableIDs: NSMutableArray}
*)
on parseInputData(inputText)
	set nsText to current application's NSString's stringWithString:inputText
	set allLines to (nsText's componentsSeparatedByCharactersInSet:(current application's NSCharacterSet's newlineCharacterSet())) as list
	
	set rawRanges to current application's NSMutableArray's array()
	set availableIDs to current application's NSMutableArray's array()
	set inRangesSection to true
	
	repeat with aLine in allLines
		set lineContent to aLine as text
		
		if lineContent is "" then
			set inRangesSection to false
		else if inRangesSection then
			-- Parse range "start-end"
			set AppleScript's text item delimiters to {"-"}
			set rangeParts to text items of lineContent
			set AppleScript's text item delimiters to {""}
			
			if (count of rangeParts) is 2 then
				set startDec to (current application's NSDecimalNumber's decimalNumberWithString:(item 1 of rangeParts))
				set endDec to (current application's NSDecimalNumber's decimalNumberWithString:(item 2 of rangeParts))
				set rangeDict to current application's NSMutableDictionary's dictionary()
				(rangeDict's setObject:startDec forKey:"rangeStart")
				(rangeDict's setObject:endDec forKey:"rangeEnd")
				(rawRanges's addObject:rangeDict)
			end if
		else
			-- Parse available ID
			set idNum to (current application's NSDecimalNumber's decimalNumberWithString:lineContent)
			(availableIDs's addObject:idNum)
		end if
	end repeat
	
	return {rawRanges:rawRanges, availableIDs:availableIDs}
end parseInputData

(*
	sortAndMergeRanges
	
	Sorts ranges by start value, then merges overlapping/adjacent ranges
	into non-overlapping intervals. This dramatically reduces the number
	of ranges to check.
	
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
			(mergedDict's setObject:currentStart forKey:"rangeStart")
			(mergedDict's setObject:currentEnd forKey:"rangeEnd")
			(merged's addObject:mergedDict)
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
	binarySearchForID
	
	Uses binary search to determine if an ID falls within any merged range.
	Since ranges are sorted and non-overlapping, we can efficiently find
	if the ID is contained in any range.
	
	Input:
		idNum - NSDecimalNumber representing the ingredient ID
		ranges - NSArray of sorted, non-overlapping range dictionaries
	Output: boolean - true if ID is in any range
*)
on binarySearchForID(idNum, ranges)
	set lo to 0
	set hi to ((ranges's |count|()) as integer) - 1
	
	repeat while lo is less than or equal to hi
		set mid to (lo + hi) div 2
		set midRange to (ranges's objectAtIndex:mid)
		set rangeStart to (midRange's objectForKey:"rangeStart")
		set rangeEnd to (midRange's objectForKey:"rangeEnd")
		
		set cmpStart to (idNum's compare:rangeStart) as integer
		set cmpEnd to (idNum's compare:rangeEnd) as integer
		
		if cmpStart is greater than or equal to 0 and cmpEnd is less than or equal to 0 then
			-- ID is within this range
			return true
		else if cmpEnd > 0 then
			-- ID is greater than this range, search right
			set lo to mid + 1
		else
			-- ID is less than this range, search left
			set hi to mid - 1
		end if
	end repeat
	
	return false
end binarySearchForID

(*
	countFreshIngredients
	
	Counts how many of the available ingredient IDs are fresh using binary search.
	
	Input:
		availableIDs - NSArray of NSDecimalNumber ingredient IDs
		ranges - NSArray of sorted, merged range dictionaries
	Output: integer - count of fresh ingredients
*)
on countFreshIngredients(availableIDs, ranges)
	set freshCount to 0
	set idCount to (availableIDs's |count|()) as integer
	
	repeat with i from 0 to (idCount - 1)
		set idNum to (availableIDs's objectAtIndex:i)
		if binarySearchForID(idNum, ranges) then
			set freshCount to freshCount + 1
		end if
	end repeat
	
	return freshCount
end countFreshIngredients

(*
	Main execution
*)

-- Get the input file from user
set inputFile to choose file with prompt "Select the input file:" of type {"public.plain-text"}

-- Read and parse the input
set inputText to readFileContents(inputFile)
set parsedData to parseInputData(inputText)
set rawRanges to rawRanges of parsedData
set availableIDs to availableIDs of parsedData

-- Sort and merge ranges for efficient lookup
set mergedRanges to sortAndMergeRanges(rawRanges)

-- Count fresh ingredients using binary search
set freshCount to countFreshIngredients(availableIDs, mergedRanges)

-- Display result
display dialog "Number of fresh ingredient IDs: " & freshCount buttons {"OK"} default button 1

return freshCount