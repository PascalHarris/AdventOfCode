(*
	Paper Rolls Iterative Removal Counter - Optimized Version
	
	This script solves Part 2 of the Advent of Code puzzle about removing paper rolls.
	
	Optimizations:
	1. Uses NSMutableArray for O(1) array access instead of slow AppleScript lists
	2. Uses a flat 1D array with index calculation for faster access
	3. After each removal pass, only rechecks neighbors of removed cells
	4. Maintains a set of candidate cells to check rather than scanning entire grid
	
	The script prompts the user to select an input file, parses the grid,
	and counts how many total rolls can be removed through iterative processing.
*)

use framework "Foundation"
use scripting additions

-- Global variables for grid data
property gridArray : missing value -- NSMutableArray storing grid as flat array
property numRows : 0
property numCols : 0

(*
	readFileContents
	
	Reads the contents of a file and returns it as a string.
	
	Input: filePath (POSIX path string) - the path to the file to read
	Output: string - the contents of the file
*)
on readFileContents(filePath)
	set fileURL to current application's NSURL's fileURLWithPath:filePath
	set fileContents to current application's NSString's stringWithContentsOfURL:fileURL encoding:(current application's NSUTF8StringEncoding) |error|:(missing value)
	return fileContents as text
end readFileContents

(*
	indexForRowCol
	
	Converts 2D coordinates to 1D array index.
	
	Inputs:
		row (integer) - 0-based row index
		col (integer) - 0-based column index
	
	Output: integer - index into flat array
*)
on indexForRowCol(row, col)
	return row * numCols + col
end indexForRowCol

(*
	initializeGrid
	
	Parses input text and initializes the grid as a flat NSMutableArray.
	Also sets numRows and numCols properties.
	
	Input: inputText (string) - the raw file contents
	Output: none (sets gridArray, numRows, numCols properties)
*)
on initializeGrid(inputText)
	set gridArray to current application's NSMutableArray's alloc()'s init()
	set currentRowLength to 0
	set rowCount to 0
	
	repeat with i from 1 to count of inputText
		set c to character i of inputText
		if c is linefeed or c is return then
			if currentRowLength > 0 then
				set rowCount to rowCount + 1
				if numCols = 0 then set numCols to currentRowLength
				set currentRowLength to 0
			end if
		else
			if c is "@" then
				gridArray's addObject:1
			else
				gridArray's addObject:0
			end if
			set currentRowLength to currentRowLength + 1
		end if
	end repeat
	
	-- Handle last row if no trailing newline
	if currentRowLength > 0 then
		set rowCount to rowCount + 1
		if numCols = 0 then set numCols to currentRowLength
	end if
	
	set numRows to rowCount
end initializeGrid

(*
	countNeighborsAtIndex
	
	Counts neighboring paper rolls for a cell given its flat array index.
	
	Input: idx (integer) - flat array index
	Output: integer - count of neighboring rolls (0-8)
*)
on countNeighborsAtIndex(idx)
	set row to idx div numCols
	set col to idx mod numCols
	set neighborCount to 0
	
	repeat with dRow from -1 to 1
		set newRow to row + dRow
		if newRow >= 0 and newRow < numRows then
			repeat with dCol from -1 to 1
				if not (dRow = 0 and dCol = 0) then
					set newCol to col + dCol
					if newCol >= 0 and newCol < numCols then
						set neighborIdx to newRow * numCols + newCol
						if (gridArray's objectAtIndex:neighborIdx) as integer = 1 then
							set neighborCount to neighborCount + 1
						end if
					end if
				end if
			end repeat
		end if
	end repeat
	
	return neighborCount
end countNeighborsAtIndex

(*
	getNeighborIndices
	
	Returns list of valid neighbor indices for a given flat array index.
	
	Input: idx (integer) - flat array index
	Output: list of integers - indices of neighboring cells
*)
on getNeighborIndices(idx)
	set row to idx div numCols
	set col to idx mod numCols
	set neighbors to {}
	
	repeat with dRow from -1 to 1
		set newRow to row + dRow
		if newRow >= 0 and newRow < numRows then
			repeat with dCol from -1 to 1
				if not (dRow = 0 and dCol = 0) then
					set newCol to col + dCol
					if newCol >= 0 and newCol < numCols then
						set end of neighbors to (newRow * numCols + newCol)
					end if
				end if
			end repeat
		end if
	end repeat
	
	return neighbors
end getNeighborIndices

(*
	countTotalRemovableRolls
	
	Iteratively removes accessible rolls until no more can be removed.
	Uses optimized approach: after first pass, only checks neighbors of removed cells.
	
	Output: integer - total count of rolls removed
*)
on countTotalRemovableRolls()
	set totalRemoved to 0
	set totalCells to numRows * numCols
	
	-- First pass: check all cells, build initial accessible set
	set candidateSet to current application's NSMutableSet's alloc()'s init()
	
	repeat with idx from 0 to (totalCells - 1)
		if (gridArray's objectAtIndex:idx) as integer = 1 then
			candidateSet's addObject:idx
		end if
	end repeat
	
	repeat
		-- Find accessible rolls from candidates
		set toRemove to current application's NSMutableArray's alloc()'s init()
		set candidateArray to candidateSet's allObjects()
		set candidateCount to candidateArray's |count|() as integer
		
		repeat with i from 0 to (candidateCount - 1)
			set idx to (candidateArray's objectAtIndex:i) as integer
			if (gridArray's objectAtIndex:idx) as integer = 1 then
				if countNeighborsAtIndex(idx) < 4 then
					toRemove's addObject:idx
				end if
			end if
		end repeat
		
		set removeCount to toRemove's |count|() as integer
		if removeCount = 0 then exit repeat
		
		-- Remove rolls and collect neighbors for next iteration
		set nextCandidates to current application's NSMutableSet's alloc()'s init()
		
		repeat with i from 0 to (removeCount - 1)
			set idx to (toRemove's objectAtIndex:i) as integer
			gridArray's replaceObjectAtIndex:idx withObject:0
			
			-- Add neighbors as candidates for next round
			set neighborList to getNeighborIndices(idx)
			repeat with nIdx in neighborList
				if (gridArray's objectAtIndex:nIdx) as integer = 1 then
					nextCandidates's addObject:nIdx
				end if
			end repeat
		end repeat
		
		set totalRemoved to totalRemoved + removeCount
		set candidateSet to nextCandidates
	end repeat
	
	return totalRemoved
end countTotalRemovableRolls

(*
	Main execution
*)
on run
	-- Ask user to select the input file
	set inputFile to choose file with prompt "Select the puzzle input file:" of type {"public.plain-text"}
	set filePath to POSIX path of inputFile
	
	-- Read and parse the file
	set fileContents to readFileContents(filePath)
	initializeGrid(fileContents)
	
	-- Count total removable rolls
	set totalResult to countTotalRemovableRolls()
	
	-- Display result
	display dialog "Total rolls of paper that can be removed: " & totalResult buttons {"OK"} default button "OK"
	
	return totalResult
end run