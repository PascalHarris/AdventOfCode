(*
	Tachyon Manifold Beam Splitter Counter
	
	Simulates tachyon beams traveling through a manifold.
	Beams start at S and travel downward.
	When a beam hits a splitter (^), it stops and two new beams
	emerge going left and right from immediately beside the splitter.
	Count total number of splits.
	
	Uses NSMutableSet to track active beam columns efficiently.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

on readFileContents(fileAlias)
	return read fileAlias as text
end readFileContents

on parseGrid(inputText)
	set nsText to current application's NSString's stringWithString:inputText
	set lineArray to nsText's componentsSeparatedByCharactersInSet:(current application's NSCharacterSet's newlineCharacterSet())
	set allLines to lineArray as list
	
	set gridRows to {}
	repeat with aLine in allLines
		set lineText to aLine as text
		if (length of lineText) > 0 then
			set gridRows to gridRows & {lineText}
		end if
	end repeat
	
	return gridRows
end parseGrid

on findStartColumn(firstRow)
	set rowLen to length of firstRow
	repeat with col from 1 to rowLen
		if character col of firstRow is "S" then
			return col
		end if
	end repeat
	return 0
end findStartColumn

on countSplits(gridRows)
	set numRows to length of gridRows
	if numRows is 0 then return 0
	
	set firstRow to item 1 of gridRows
	set numCols to length of firstRow
	
	-- Find starting column (where S is)
	set startCol to findStartColumn(firstRow)
	if startCol is 0 then return 0
	
	-- Track active beam columns using NSMutableSet of NSNumber
	-- Beams travel downward; we track which columns have active beams
	set activeBeams to current application's NSMutableSet's setWithObject:(current application's NSNumber's numberWithInteger:startCol)
	
	set totalSplits to 0
	
	-- Process each row starting from row 2 (row 1 has S)
	repeat with rowIdx from 2 to numRows
		set currentRow to item rowIdx of gridRows
		set rowLen to length of currentRow
		
		-- New beams created this row
		set newBeams to current application's NSMutableSet's |set|()
		
		-- Check each active beam column
		set beamList to (activeBeams's allObjects()) as list
		repeat with beamColNum in beamList
			set beamCol to beamColNum as integer
			
			-- Check if beam is still within grid
			if beamCol > 0 and beamCol is less than or equal to rowLen then
				set cellChar to character beamCol of currentRow
				
				if cellChar is "^" then
					-- Beam hits splitter: count the split, emit two new beams
					set totalSplits to totalSplits + 1
					
					-- Left beam (column - 1)
					set leftCol to beamCol - 1
					if leftCol > 0 then
						(newBeams's addObject:(current application's NSNumber's numberWithInteger:leftCol))
					end if
					
					-- Right beam (column + 1)
					set rightCol to beamCol + 1
					if rightCol is less than or equal to numCols then
						(newBeams's addObject:(current application's NSNumber's numberWithInteger:rightCol))
					end if
				else if cellChar is "." or cellChar is " " then
					-- Beam continues downward
					(newBeams's addObject:(current application's NSNumber's numberWithInteger:beamCol))
				end if
				-- If cellChar is something else, beam stops (exits grid or blocked)
			end if
		end repeat
		
		-- Update active beams for next row
		set activeBeams to newBeams
		
		-- If no more active beams, we're done
		if (activeBeams's |count|()) as integer is 0 then
			exit repeat
		end if
	end repeat
	
	return totalSplits
end countSplits

set inputFile to choose file with prompt "Select the input file:"
set inputText to readFileContents(inputFile)
set gridRows to parseGrid(inputText)

set totalSplits to countSplits(gridRows)

display dialog "Total beam splits: " & totalSplits buttons {"OK"} default button 1
return totalSplits