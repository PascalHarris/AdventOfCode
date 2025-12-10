(*
	Machine Initialization Solver
	
	For each machine, find minimum button presses to achieve target light pattern.
	Since pressing a button twice cancels out, each button is pressed 0 or 1 times.
	With max ~13 buttons, we can brute force all 2^13 = 8192 combinations.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

on readFileContents(fileAlias)
	return read fileAlias as text
end readFileContents

on powerOf2(n)
	set pwr to 1
	repeat n times
		set pwr to pwr * 2
	end repeat
	return pwr
end powerOf2

on bitXor(a, b)
	set xorResult to 0
	set place to 1
	repeat while a > 0 or b > 0
		set bitA to a mod 2
		set bitB to b mod 2
		if bitA is not bitB then
			set xorResult to xorResult + place
		end if
		set a to a div 2
		set b to b div 2
		set place to place * 2
	end repeat
	return xorResult
end bitXor

(*
	Parse a single machine line using simple string operations.
*)
on parseMachine(lineText)
	if length of lineText is 0 then return missing value
	
	-- Find [ and ] for pattern
	set bracketStart to 0
	set bracketEnd to 0
	repeat with i from 1 to length of lineText
		set c to character i of lineText
		if c is "[" then set bracketStart to i
		if c is "]" then
			set bracketEnd to i
			exit repeat
		end if
	end repeat
	
	if bracketStart is 0 or bracketEnd is 0 then return missing value
	
	-- Extract pattern
	set patternStr to text (bracketStart + 1) thru (bracketEnd - 1) of lineText
	set numLights to length of patternStr
	
	-- Convert pattern to target bits
	set targetBits to 0
	repeat with i from 1 to numLights
		if character i of patternStr is "#" then
			set targetBits to targetBits + powerOf2(i - 1)
		end if
	end repeat
	
	-- Find all button patterns in parentheses
	set buttons to {}
	set inParen to false
	set parenContent to ""
	
	repeat with i from 1 to length of lineText
		set c to character i of lineText
		if c is "(" then
			set inParen to true
			set parenContent to ""
		else if c is ")" then
			if inParen and length of parenContent > 0 then
				set buttonBits to 0
				set AppleScript's text item delimiters to ","
				set indices to text items of parenContent
				set AppleScript's text item delimiters to ""
				
				repeat with idx in indices
					set idxText to idx as text
					if length of idxText > 0 then
						try
							set lightIdx to idxText as integer
							set buttonBits to buttonBits + powerOf2(lightIdx)
						end try
					end if
				end repeat
				
				set buttons to buttons & {buttonBits}
			end if
			set inParen to false
		else if inParen then
			set parenContent to parenContent & c
		end if
	end repeat
	
	return {targetBits:targetBits, numLights:numLights, buttons:buttons}
end parseMachine

(*
	Find minimum button presses for a single machine.
	Brute force all 2^numButtons combinations.
*)
on solveOneMachine(machineData)
	set targetBits to targetBits of machineData
	set buttons to buttons of machineData
	set numButtons to length of buttons
	
	if numButtons is 0 then
		if targetBits is 0 then
			return 0
		else
			return 10000 -- Impossible
		end if
	end if
	
	set minPresses to 10000
	set numCombinations to powerOf2(numButtons)
	
	repeat with combo from 0 to (numCombinations - 1)
		set lightState to 0
		set pressCount to 0
		set comboTemp to combo
		
		repeat with b from 1 to numButtons
			if (comboTemp mod 2) is 1 then
				set pressCount to pressCount + 1
				set buttonBits to item b of buttons
				set lightState to bitXor(lightState, buttonBits)
			end if
			set comboTemp to comboTemp div 2
		end repeat
		
		if lightState is targetBits and pressCount < minPresses then
			set minPresses to pressCount
		end if
	end repeat
	
	if minPresses is 10000 then
		return 0 -- No solution found
	end if
	return minPresses
end solveOneMachine

on solve(inputText)
	set lineList to paragraphs of inputText
	
	set totalPresses to 0
	
	repeat with lineText in lineList
		set lineStr to lineText as text
		if length of lineStr > 0 then
			set machineData to parseMachine(lineStr)
			if machineData is not missing value then
				set presses to solveOneMachine(machineData)
				set totalPresses to totalPresses + presses
			end if
		end if
	end repeat
	
	return totalPresses
end solve

set inputFile to choose file with prompt "Select the input file:"
set inputText to readFileContents(inputFile)

set totalPresses to solve(inputText)

display dialog "Total minimum button presses: " & totalPresses buttons {"OK"} default button 1
return totalPresses