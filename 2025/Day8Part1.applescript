(*
	Junction Box Circuit Solver
	
	Uses Union-Find (Disjoint Set Union) to track circuits as we connect
	junction boxes. We connect the 1000 closest pairs, then find the
	three largest circuit sizes and multiply them.
	
	Uses NSMutableArray for efficient storage and sorting.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

-- Global arrays for Union-Find
property parentArray : missing value
property rankArray : missing value

on readFileContents(fileAlias)
	return read fileAlias as text
end readFileContents

on parseJunctionBoxes(inputText)
	set nsText to current application's NSString's stringWithString:inputText
	set lineArray to nsText's componentsSeparatedByCharactersInSet:(current application's NSCharacterSet's newlineCharacterSet())
	set allLines to lineArray as list
	
	set boxes to current application's NSMutableArray's array()
	
	repeat with aLine in allLines
		set lineText to aLine as text
		if (length of lineText) > 0 then
			set AppleScript's text item delimiters to ","
			set coords to text items of lineText
			set AppleScript's text item delimiters to ""
			
			if (length of coords) is 3 then
				set xVal to (item 1 of coords) as integer
				set yVal to (item 2 of coords) as integer
				set zVal to (item 3 of coords) as integer
				
				set boxDict to current application's NSMutableDictionary's dictionary()
				(boxDict's setObject:xVal forKey:"x")
				(boxDict's setObject:yVal forKey:"y")
				(boxDict's setObject:zVal forKey:"z")
				(boxes's addObject:boxDict)
			end if
		end if
	end repeat
	
	return boxes
end parseJunctionBoxes

on calcDistanceSquared(box1, box2)
	set x1 to (box1's objectForKey:"x") as integer
	set y1 to (box1's objectForKey:"y") as integer
	set z1 to (box1's objectForKey:"z") as integer
	set x2 to (box2's objectForKey:"x") as integer
	set y2 to (box2's objectForKey:"y") as integer
	set z2 to (box2's objectForKey:"z") as integer
	
	set dx to x2 - x1
	set dy to y2 - y1
	set dz to z2 - z1
	
	return (dx * dx) + (dy * dy) + (dz * dz)
end calcDistanceSquared

on initUnionFind(n)
	set parentArray to current application's NSMutableArray's array()
	set rankArray to current application's NSMutableArray's array()
	
	repeat with i from 0 to (n - 1)
		(parentArray's addObject:i)
		(rankArray's addObject:0)
	end repeat
end initUnionFind

on findRoot(i)
	set p to (parentArray's objectAtIndex:i) as integer
	if p is not i then
		set newRoot to findRoot(p)
		parentArray's replaceObjectAtIndex:i withObject:newRoot
		return newRoot
	end if
	return i
end findRoot

on unionSets(i, j)
	set rootI to findRoot(i)
	set rootJ to findRoot(j)
	
	if rootI is rootJ then
		return false -- Already in same set
	end if
	
	set rankI to (rankArray's objectAtIndex:rootI) as integer
	set rankJ to (rankArray's objectAtIndex:rootJ) as integer
	
	if rankI < rankJ then
		parentArray's replaceObjectAtIndex:rootI withObject:rootJ
	else if rankI > rankJ then
		parentArray's replaceObjectAtIndex:rootJ withObject:rootI
	else
		parentArray's replaceObjectAtIndex:rootJ withObject:rootI
		rankArray's replaceObjectAtIndex:rootI withObject:(rankI + 1)
	end if
	
	return true -- Union performed
end unionSets

on solveCircuits(boxes)
	set boxCount to (boxes's |count|()) as integer
	
	-- Generate all pairs with their distances
	set pairs to current application's NSMutableArray's array()
	
	repeat with i from 0 to (boxCount - 2)
		set box1 to (boxes's objectAtIndex:i)
		repeat with j from (i + 1) to (boxCount - 1)
			set box2 to (boxes's objectAtIndex:j)
			set dist to calcDistanceSquared(box1, box2)
			
			set pairDict to current application's NSMutableDictionary's dictionary()
			(pairDict's setObject:dist forKey:"dist")
			(pairDict's setObject:i forKey:"i")
			(pairDict's setObject:j forKey:"j")
			(pairs's addObject:pairDict)
		end repeat
	end repeat
	
	-- Sort pairs by distance
	set sortDesc to current application's NSSortDescriptor's sortDescriptorWithKey:"dist" ascending:true
	pairs's sortUsingDescriptors:{sortDesc}
	
	-- Initialize Union-Find
	initUnionFind(boxCount)
	
	-- Connect 1000 closest pairs
	set connectionsToMake to 1000
	set connectionsMade to 0
	set pairIdx to 0
	set pairCount to (pairs's |count|()) as integer
	
	repeat while connectionsMade < connectionsToMake and pairIdx < pairCount
		set pairInfo to (pairs's objectAtIndex:pairIdx)
		set boxI to (pairInfo's objectForKey:"i") as integer
		set boxJ to (pairInfo's objectForKey:"j") as integer
		
		-- Always count as a connection attempt (per problem statement)
		set connectionsMade to connectionsMade + 1
		
		-- Perform the union (may or may not actually merge)
		unionSets(boxI, boxJ)
		
		set pairIdx to pairIdx + 1
	end repeat
	
	-- Count circuit sizes
	set sizeCounts to current application's NSMutableDictionary's dictionary()
	
	repeat with i from 0 to (boxCount - 1)
		set root to findRoot(i)
		set rootKey to (root as text)
		set existingCount to (sizeCounts's objectForKey:rootKey)
		if existingCount is missing value then
			(sizeCounts's setObject:1 forKey:rootKey)
		else
			(sizeCounts's setObject:((existingCount as integer) + 1) forKey:rootKey)
		end if
	end repeat
	
	-- Get all sizes and sort descending
	set allSizes to (sizeCounts's allValues())
	set sortDescDesc to current application's NSSortDescriptor's sortDescriptorWithKey:"self" ascending:false
	set sortedSizes to (allSizes's sortedArrayUsingDescriptors:{sortDescDesc}) as list
	
	-- Multiply top 3 sizes
	set size1 to (item 1 of sortedSizes) as integer
	set size2 to (item 2 of sortedSizes) as integer
	set size3 to (item 3 of sortedSizes) as integer
	
	return size1 * size2 * size3
end solveCircuits

set inputFile to choose file with prompt "Select the input file:"
set inputText to readFileContents(inputFile)
set boxes to parseJunctionBoxes(inputText)

set result to solveCircuits(boxes)

display dialog "Product of three largest circuit sizes: " & result buttons {"OK"} default button 1
return result