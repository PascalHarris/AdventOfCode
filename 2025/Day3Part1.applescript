(*
Main script to solve the battery joltage puzzle
Prompts user to select input file and calculates total maximum joltage
*)

use AppleScript version "2.4"
use scripting additions

-- Get the input file from user
set inputFile to choose file with prompt "Select the input.txt file:"
set batteryBanks to readInputFile(inputFile)

-- Calculate total joltage
set totalJoltage to calculateTotalJoltage(batteryBanks)

display dialog "Total output joltage: " & totalJoltage buttons {"OK"} default button 1

(*
Reads the input file and returns a list of battery bank strings
Input: fileAlias - alias to the input file
Output: list of strings, each representing a battery bank
*)
on readInputFile(fileAlias)
	set fileContent to read fileAlias as Çclass utf8È
	set AppleScript's text item delimiters to {return, linefeed}
	set lineList to text items of fileContent
	set AppleScript's text item delimiters to {""}
	
	-- Filter out empty lines
	set cleanLines to {}
	repeat with aLine in lineList
		set lineContent to contents of aLine
		if lineContent is not "" then
			set end of cleanLines to lineContent
		end if
	end repeat
	
	return cleanLines
end readInputFile

(*
Calculates total joltage from all battery banks
Input: bankList - list of battery bank strings
Output: integer representing total joltage
*)
on calculateTotalJoltage(bankList)
	set totalJoltage to 0
	
	repeat with bankLine in bankList
		set maxJoltage to findMaxJoltage(bankLine)
		set totalJoltage to totalJoltage + maxJoltage
	end repeat
	
	return totalJoltage
end calculateTotalJoltage

(*
Finds the maximum joltage possible from a battery bank
Strategy: Check all valid pairs of positions and find the maximum
Input: bankString - string of digits representing battery joltage ratings
Output: integer representing maximum joltage from this bank
*)
on findMaxJoltage(bankString)
	set bankLength to length of bankString
	
	if bankLength < 2 then return 0
	
	set maxJoltage to 0
	
	-- For each possible first position
	repeat with i from 1 to (bankLength - 1)
		set firstDigit to (character i of bankString) as integer
		
		-- For each possible second position after the first
		repeat with j from (i + 1) to bankLength
			set secondDigit to (character j of bankString) as integer
			
			set currentJoltage to firstDigit * 10 + secondDigit
			
			if currentJoltage > maxJoltage then
				set maxJoltage to currentJoltage
			end if
			
			-- Early exit optimization: can't do better than 99
			if maxJoltage = 99 then return 99
		end repeat
	end repeat
	
	return maxJoltage
end findMaxJoltage