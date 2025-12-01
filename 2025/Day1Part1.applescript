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
	how many times the dial lands on 0.
	
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
			set dialPosition to applyRotation(dialPosition, rot)
			
			if dialPosition is 0 then
				set zeroCount to zeroCount + 1
			end if
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