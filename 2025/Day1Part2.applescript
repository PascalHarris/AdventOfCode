(*
	Safe Dial Puzzle Solver
	
	Simulates a circular dial (0-99) and counts how many times
	the dial lands on 0 after processing a sequence of rotations.
*)

(*
	selectInputFile
	
	Prompts the user to select the input file containing rotation instructions.
	
	Inputs: none
	Outputs: POSIX path to the selected file, or empty string if cancelled
*)
on selectInputFile()
	set chosenFile to choose file with prompt "Select the input file:" default location (path to desktop)
	return POSIX path of chosenFile
end selectInputFile

(*
	readFileContents
	
	Reads the entire contents of a file at the given POSIX path.
	
	Inputs: filePath - POSIX path string to the file
	Outputs: string containing the file contents
*)
on readFileContents(filePath)
	set fileContents to do shell script "cat " & quoted form of filePath
	return fileContents
end readFileContents

(*
	parseRotation
	
	Parses a single rotation instruction (e.g., "L68" or "R14").
	
	Inputs: instruction - string like "L68" or "R14"
	Outputs: record with direction ("L" or "R") and distance (integer)
*)
on parseRotation(instruction)
	set direction to character 1 of instruction
	set distance to (text 2 thru -1 of instruction) as integer
	return {direction:direction, distance:distance}
end parseRotation

(*
	countZeroCrossings
	
	Counts how many times the dial points at 0 during a rotation,
	including if it ends on 0. Does not count if we start at 0
	(since that's departing, not arriving).
	
	Inputs:
		startPos - starting position (0-99)
		dir - direction ("L" or "R")
		dist - distance to move (positive integer)
	Outputs: number of times dial points at 0
*)
on countZeroCrossings(startPos, dir, dist)
	set crossings to 0
	
	if dir is "L" then
		-- Moving left (toward lower numbers)
		-- We hit zero when we reach 0 from above
		
		-- Count full revolutions
		set fullRevs to dist div 100
		set crossings to fullRevs
		
		-- Check partial revolution: did we reach 0 or go past it?
		set remainder to dist mod 100
		if startPos is 0 then
			-- Starting at 0, we only cross again if we do a full loop back
			-- Already counted in fullRevs, no extra crossing from remainder
		else if remainder >= startPos then
			set crossings to crossings + 1
		end if
	else
		-- Moving right (toward higher numbers)
		-- We hit zero when we wrap from 99 to 0
		
		-- Count full revolutions
		set fullRevs to dist div 100
		set crossings to fullRevs
		
		-- Check partial revolution: did we pass 99 and reach 0?
		set remainder to dist mod 100
		if startPos is 0 then
			-- Starting at 0, we only cross again if we do a full loop back
			-- Already counted in fullRevs, no extra crossing from remainder
		else if (startPos + remainder) >= 100 then
			set crossings to crossings + 1
		end if
	end if
	
	return crossings
end countZeroCrossings

(*
	applyRotation
	
	Applies a rotation to the current dial position.
	L moves toward lower numbers, R moves toward higher numbers.
	The dial wraps around at 0 and 99.
	
	Inputs: 
		currentPosition - integer 0-99
		rot - record with direction and distance
	Outputs: new position as integer 0-99
*)
on applyRotation(currentPosition, rot)
	set dir to direction of rot
	set dist to distance of rot
	
	if dir is "L" then
		set newPosition to currentPosition - dist
	else
		set newPosition to currentPosition + dist
	end if
	
	-- Handle wrapping using modulo
	set newPosition to newPosition mod 100
	if newPosition < 0 then
		set newPosition to newPosition + 100
	end if
	
	return newPosition
end applyRotation

(*
	solvePuzzle
	
	Main solving routine. Processes all rotations and counts
	how many times the dial points at 0 (during or at end of rotations).
	
	Inputs: fileContents - string containing all rotation instructions
	Outputs: integer count of times dial pointed at 0
*)
on solvePuzzle(fileContents)
	set dialPosition to 50
	set zeroCount to 0
	
	-- Split into lines
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {linefeed, return}
	set rotationLines to text items of fileContents
	set AppleScript's text item delimiters to oldDelimiters
	
	-- Process each rotation
	repeat with rotationLine in rotationLines
		set trimmedLine to rotationLine as text
		
		-- Skip empty lines
		if trimmedLine is not "" then
			set rot to parseRotation(trimmedLine)
			set dir to direction of rot
			set dist to distance of rot
			
			-- Count zero crossings during this rotation
			set zeroCount to zeroCount + countZeroCrossings(dialPosition, dir, dist)
			
			-- Update position
			set dialPosition to applyRotation(dialPosition, rot)
		end if
	end repeat
	
	return zeroCount
end solvePuzzle

(*
	Main execution
*)
set inputPath to selectInputFile()
set fileContents to readFileContents(inputPath)
set answer to solvePuzzle(fileContents)

display dialog "The password is: " & answer buttons {"OK"} default button "OK"

return answer