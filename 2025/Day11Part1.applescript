(*
	Path Counter - Count all paths from "you" to "out"
	
	Uses dynamic programming with memoisation.
	pathCount(node) = sum of pathCount(child) for all children
	pathCount("out") = 1
	
	Uses NSDecimalNumber for large path counts.
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
			-- Parse "node: child1 child2 child3"
			set AppleScript's text item delimiters to ":"
			set parts to text items of lineStr
			set AppleScript's text item delimiters to ""
			
			if (count of parts) ³ 2 then
				set nodeName to (item 1 of parts) as text
				-- Trim whitespace
				repeat while nodeName starts with " "
					set nodeName to text 2 thru -1 of nodeName
				end repeat
				repeat while nodeName ends with " "
					set nodeName to text 1 thru -2 of nodeName
				end repeat
				
				set childrenStr to (item 2 of parts) as text
				-- Trim and split by spaces
				repeat while childrenStr starts with " "
					set childrenStr to text 2 thru -1 of childrenStr
				end repeat
				repeat while childrenStr ends with " "
					set childrenStr to text 1 thru -2 of childrenStr
				end repeat
				
				set AppleScript's text item delimiters to " "
				set childList to text items of childrenStr
				set AppleScript's text item delimiters to ""
				
				-- Filter out empty strings and store as AppleScript list
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

on countPaths(nodeName)
	-- Base case: reached "out"
	if nodeName is "out" then
		return current application's NSDecimalNumber's one()
	end if
	
	-- Check memo cache
	set cached to memoDict's objectForKey:nodeName
	if cached is not missing value then
		return cached
	end if
	
	-- Get children
	set children to graphDict's objectForKey:nodeName
	if children is missing value then
		-- No children and not "out" = dead end, 0 paths
		set resultVal to current application's NSDecimalNumber's zero()
		memoDict's setObject:resultVal forKey:nodeName
		return resultVal
	end if
	
	-- Convert to AppleScript list
	set childList to children as list
	
	-- Sum paths through all children
	set totalPaths to current application's NSDecimalNumber's zero()
	
	repeat with childName in childList
		set childStr to childName as text
		set childPaths to countPaths(childStr)
		set totalPaths to (totalPaths's decimalNumberByAdding:childPaths)
	end repeat
	
	-- Cache and return
	memoDict's setObject:totalPaths forKey:nodeName
	return totalPaths
end countPaths

on solve(inputText)
	buildGraph(inputText)
	set memoDict to current application's NSMutableDictionary's dictionary()
	
	set pathCount to countPaths("you")
	return pathCount's stringValue() as text
end solve

set inputFile to choose file with prompt "Select the input file:"
set inputText to readFileContents(inputFile)

set totalPaths to solve(inputText)

display dialog "Total paths from 'you' to 'out': " & totalPaths buttons {"OK"} default button 1
return totalPaths