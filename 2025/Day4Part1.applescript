(*
	Paper Rolls Accessibility Counter
	
	This script solves the Advent of Code puzzle about finding accessible paper rolls.
	A paper roll (@) is accessible if it has fewer than 4 neighboring paper rolls
	in its 8 adjacent positions (including diagonals).
	
	The script prompts the user to select an input file, parses the grid,
	and counts how many rolls are accessible by forklifts.
*)

use framework "Foundation"
use scripting additions

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
	parseGrid
	
	Parses the input string into a list of strings, one per row.
	Each string represents a row of the grid.
	
	Input: inputText (string) - the raw file contents
	Output: list of strings - each string is a row of the grid
*)
on parseGrid(inputText)
	set gridRows to {}
	set currentRow to ""
	
	repeat with i from 1 to count of inputText
		set c to character i of inputText
		if c is linefeed or c is return then
			if (count of currentRow) > 0 then
				set end of gridRows to currentRow
			end if
			set currentRow to ""
		else
			set currentRow to currentRow & c
		end if
	end repeat
	
	-- Don't forget the last row if file doesn't end with newline
	if (count of currentRow) > 0 then
		set end of gridRows to currentRow
	end if
	
	return gridRows
end parseGrid

(*
	countNeighboringRolls
	
	Counts the number of paper rolls (@) in the 8 adjacent positions
	around a given cell.
	
	Inputs:
		gridRows (list of strings) - the grid data
		row (integer) - 1-based row index of the cell to check
		col (integer) - 1-based column index of the cell to check
		numRows (integer) - total number of rows in the grid
		numCols (integer) - total number of columns in the grid
	
	Output: integer - count of neighboring paper rolls (0-8)
*)
on countNeighboringRolls(gridRows, row, col, numRows, numCols)
	set neighborCount to 0
	
	-- Check all 8 directions: up, down, left, right, and 4 diagonals
	repeat with dRow from -1 to 1
		repeat with dCol from -1 to 1
			-- Skip the center cell itself
			if not (dRow = 0 and dCol = 0) then
				set newRow to row + dRow
				set newCol to col + dCol
				
				-- Check bounds
				if newRow ³ 1 and newRow ² numRows and newCol ³ 1 and newCol ² numCols then
					set neighborChar to character newCol of (item newRow of gridRows)
					if neighborChar is "@" then
						set neighborCount to neighborCount + 1
					end if
				end if
			end if
		end repeat
	end repeat
	
	return neighborCount
end countNeighboringRolls

(*
	countAccessibleRolls
	
	Counts all paper rolls that are accessible by forklifts.
	A roll is accessible if it has fewer than 4 neighboring rolls.
	
	Input: gridRows (list of strings) - the grid data
	Output: integer - count of accessible paper rolls
*)
on countAccessibleRolls(gridRows)
	set numRows to count of gridRows
	set numCols to count of (item 1 of gridRows)
	set accessibleCount to 0
	
	repeat with row from 1 to numRows
		set currentRowText to item row of gridRows
		repeat with col from 1 to numCols
			set cellChar to character col of currentRowText
			
			-- Only check paper rolls
			if cellChar is "@" then
				set neighbors to countNeighboringRolls(gridRows, row, col, numRows, numCols)
				-- Accessible if fewer than 4 neighbors
				if neighbors < 4 then
					set accessibleCount to accessibleCount + 1
				end if
			end if
		end repeat
	end repeat
	
	return accessibleCount
end countAccessibleRolls

(*
	Main execution
	
	Prompts user to select input file, processes the grid,
	and displays the result.
*)
on run
	-- Ask user to select the input file
	set inputFile to choose file with prompt "Select the puzzle input file:" of type {"public.plain-text"}
	set filePath to POSIX path of inputFile
	
	-- Read and parse the file
	set fileContents to readFileContents(filePath)
	set gridRows to parseGrid(fileContents)
	
	-- Count accessible rolls
	set result to countAccessibleRolls(gridRows)
	
	-- Display result
	display dialog "Number of accessible paper rolls: " & result buttons {"OK"} default button "OK"
	
	return result
end run