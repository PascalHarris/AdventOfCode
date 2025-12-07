(*
	Quantum Tachyon Manifold Timeline Counter - Part 2
	
	Each particle takes BOTH paths at a splitter, creating new timelines.
	We need to count total number of timelines (paths) through the manifold.
	
	Instead of tracking which columns have beams, we track HOW MANY particles
	are at each column. When a particle hits a splitter, one particle goes
	left and one goes right (doubling timelines at that point).
	
	Uses NSMutableDictionary to map column -> particle count.
	Uses NSDecimalNumber for potentially large counts.
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

on countTimelines(gridRows)
	set numRows to length of gridRows
	if numRows is 0 then return 0
	
	set firstRow to item 1 of gridRows
	set numCols to length of firstRow
	
	-- Find starting column (where S is)
	set startCol to findStartColumn(firstRow)
	if startCol is 0 then return 0
	
	-- Track particle counts at each column: column (as string key) -> NSDecimalNumber count
	-- Start with 1 particle at the starting column
	set activeBeams to current application's NSMutableDictionary's dictionary()
	set one to current application's NSDecimalNumber's one()
	set zero to current application's NSDecimalNumber's zero()
	activeBeams's setObject:one forKey:(startCol as text)
	
	set totalTimelines to zero
	
	-- Process each row starting from row 2 (row 1 has S)
	repeat with rowIdx from 2 to numRows
		set currentRow to item rowIdx of gridRows
		set rowLen to length of currentRow
		
		-- New beam counts for next row
		set newBeams to current application's NSMutableDictionary's dictionary()
		
		-- Process each active beam column
		set beamKeys to (activeBeams's allKeys()) as list
		repeat with beamKey in beamKeys
			set beamCol to (beamKey as text) as integer
			set particleCount to (activeBeams's objectForKey:beamKey)
			
			-- Check if beam is still within grid
			if beamCol > 0 and beamCol is less than or equal to rowLen then
				set cellChar to character beamCol of currentRow
				
				if cellChar is "^" then
					-- Particle hits splitter: splits into left and right
					-- Each particle creates one left-going and one right-going particle
					
					-- Left beam (column - 1)
					set leftCol to beamCol - 1
					if leftCol > 0 then
						set leftKey to (leftCol as text)
						set existingLeft to newBeams's objectForKey:leftKey
						if existingLeft is missing value then
							newBeams's setObject:particleCount forKey:leftKey
						else
							newBeams's setObject:(existingLeft's decimalNumberByAdding:particleCount) forKey:leftKey
						end if
					else
						-- Particle exits left side, add to completed timelines
						set totalTimelines to totalTimelines's decimalNumberByAdding:particleCount
					end if
					
					-- Right beam (column + 1)
					set rightCol to beamCol + 1
					if rightCol is less than or equal to numCols then
						set rightKey to (rightCol as text)
						set existingRight to newBeams's objectForKey:rightKey
						if existingRight is missing value then
							newBeams's setObject:particleCount forKey:rightKey
						else
							newBeams's setObject:(existingRight's decimalNumberByAdding:particleCount) forKey:rightKey
						end if
					else
						-- Particle exits right side, add to completed timelines
						set totalTimelines to totalTimelines's decimalNumberByAdding:particleCount
					end if
					
				else if cellChar is "." or cellChar is " " then
					-- Particle continues downward
					set colKey to (beamCol as text)
					set existingCount to newBeams's objectForKey:colKey
					if existingCount is missing value then
						newBeams's setObject:particleCount forKey:colKey
					else
						newBeams's setObject:(existingCount's decimalNumberByAdding:particleCount) forKey:colKey
					end if
				else
					-- Particle exits or blocked, count as completed timeline
					set totalTimelines to totalTimelines's decimalNumberByAdding:particleCount
				end if
			else
				-- Particle exited grid bounds, count as completed timeline
				set totalTimelines to totalTimelines's decimalNumberByAdding:particleCount
			end if
		end repeat
		
		-- Update active beams for next row
		set activeBeams to newBeams
		
		-- If no more active beams, we're done
		if (activeBeams's |count|()) as integer is 0 then
			exit repeat
		end if
	end repeat
	
	-- Any remaining active beams have completed their journey (exited bottom)
	set remainingKeys to (activeBeams's allKeys()) as list
	repeat with beamKey in remainingKeys
		set particleCount to (activeBeams's objectForKey:beamKey)
		set totalTimelines to totalTimelines's decimalNumberByAdding:particleCount
	end repeat
	
	return totalTimelines
end countTimelines

set inputFile to choose file with prompt "Select the input file:"
set inputText to readFileContents(inputFile)
set gridRows to parseGrid(inputText)

set totalTimelines to countTimelines(gridRows)
set resultStr to (totalTimelines's stringValue()) as text

display dialog "Total timelines: " & resultStr buttons {"OK"} default button 1
return resultStr