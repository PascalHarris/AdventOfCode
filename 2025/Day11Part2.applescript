(*
	Path Counter Part 2 - Count paths from "svr" to "out" through both "dac" and "fft"
	
	Strategy: Count paths for two cases (mutually exclusive):
	1. svr -> dac -> fft -> out
	2. svr -> fft -> dac -> out
	
	Total = paths(svr,dac) * paths(dac,fft) * paths(fft,out)
	      + paths(svr,fft) * paths(fft,dac) * paths(dac,out)
	
	Uses memoisation for counting paths between any two nodes.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

property graphDict : missing value
property memoDict : missing value

on readFileContents(fileAlias)
	return read fileAlias as text
end readFileContents

on buildGraph(inputText)
	set graphDict to current application's NSMutableDictionary's dictionary()
	
	set lineList to paragraphs of inputText
	
	repeat with lineText in lineList
		set lineStr to lineText as text
		if length of lineStr > 0 and lineStr contains ":" then
			set AppleScript's text item delimiters to ":"
			set parts to text items of lineStr
			set AppleScript's text item delimiters to ""
			
			if (count of parts) ³ 2 then
				set nodeName to (item 1 of parts) as text
				repeat while nodeName starts with " "
					set nodeName to text 2 thru -1 of nodeName
				end repeat
				repeat while nodeName ends with " "
					set nodeName to text 1 thru -2 of nodeName
				end repeat
				
				set childrenStr to (item 2 of parts) as text
				repeat while childrenStr starts with " "
					set childrenStr to text 2 thru -1 of childrenStr
				end repeat
				repeat while childrenStr ends with " "
					set childrenStr to text 1 thru -2 of childrenStr
				end repeat
				
				set AppleScript's text item delimiters to " "
				set childList to text items of childrenStr
				set AppleScript's text item delimiters to ""
				
				set filteredChildren to {}
				repeat with child in childList
					set childStr to child as text
					if length of childStr > 0 then
						set filteredChildren to filteredChildren & {childStr}
					end if
				end repeat
				
				(graphDict's setObject:filteredChildren forKey:nodeName)
			end if
		end if
	end repeat
end buildGraph

(*
	Count paths from nodeName to targetName
	Uses memoization with key "nodeName|targetName"
*)
on countPathsTo(nodeName, targetName)
	-- Base case: reached target
	if nodeName is targetName then
		return current application's NSDecimalNumber's one()
	end if
	
	-- Check memo cache
	set cacheKey to nodeName & "|" & targetName
	set cached to memoDict's objectForKey:cacheKey
	if cached is not missing value then
		return cached
	end if
	
	-- Get children
	set children to graphDict's objectForKey:nodeName
	if children is missing value then
		set resultVal to current application's NSDecimalNumber's zero()
		memoDict's setObject:resultVal forKey:cacheKey
		return resultVal
	end if
	
	set childList to children as list
	
	-- Sum paths through all children
	set totalPaths to current application's NSDecimalNumber's zero()
	
	repeat with childName in childList
		set childStr to childName as text
		set childPaths to countPathsTo(childStr, targetName)
		set totalPaths to (totalPaths's decimalNumberByAdding:childPaths)
	end repeat
	
	memoDict's setObject:totalPaths forKey:cacheKey
	return totalPaths
end countPathsTo

on solve(inputText)
	buildGraph(inputText)
	set memoDict to current application's NSMutableDictionary's dictionary()
	
	-- Case 1: svr -> dac -> fft -> out
	set svrToDac to countPathsTo("svr", "dac")
	set dacToFft to countPathsTo("dac", "fft")
	set fftToOut to countPathsTo("fft", "out")
	
	set case1 to svrToDac's decimalNumberByMultiplyingBy:dacToFft
	set case1 to case1's decimalNumberByMultiplyingBy:fftToOut
	
	-- Case 2: svr -> fft -> dac -> out
	set svrToFft to countPathsTo("svr", "fft")
	set fftToDac to countPathsTo("fft", "dac")
	set dacToOut to countPathsTo("dac", "out")
	
	set case2 to svrToFft's decimalNumberByMultiplyingBy:fftToDac
	set case2 to case2's decimalNumberByMultiplyingBy:dacToOut
	
	-- Total
	set totalPaths to case1's decimalNumberByAdding:case2
	
	return totalPaths's stringValue() as text
end solve

set inputFile to choose file with prompt "Select the input file:"
set inputText to readFileContents(inputFile)

set totalPaths to solve(inputText)

display dialog "Total paths from 'svr' to 'out' through both 'dac' and 'fft': " & totalPaths buttons {"OK"} default button 1
return totalPaths