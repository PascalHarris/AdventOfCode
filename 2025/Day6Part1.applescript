(*
	Cephalopod Math Worksheet Solver
	
	Solves math problems arranged vertically in columns.
	Problems are separated by space-only columns.
	Uses NSDecimalNumber for large integer arithmetic.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

on readFileContents(fileAlias)
	return read fileAlias as text
end readFileContents

on getCharAtColumn(lineText, col)
	set lineLen to length of lineText
	if col > lineLen then
		return " "
	end if
	return character col of lineText
end getCharAtColumn

on parseWorksheet(inputText)
	set nsText to current application's NSString's stringWithString:inputText
	set lineArray to nsText's componentsSeparatedByCharactersInSet:(current application's NSCharacterSet's newlineCharacterSet())
	set allLines to lineArray as list
	
	set nonEmptyLines to {}
	set maxLen to 0
	repeat with aLine in allLines
		set lineText to aLine as text
		set lineLen to length of lineText
		if lineLen > 0 then
			set nonEmptyLines to nonEmptyLines & {lineText}
			if lineLen > maxLen then
				set maxLen to lineLen
			end if
		end if
	end repeat
	
	set lineCount to length of nonEmptyLines
	set operatorLine to item lineCount of nonEmptyLines
	
	set dataLines to {}
	repeat with i from 1 to (lineCount - 1)
		set dataLines to dataLines & {item i of nonEmptyLines}
	end repeat
	
	return {dataLines:dataLines, operatorLine:operatorLine, lineLength:maxLen}
end parseWorksheet

on computeProblem(numList, op)
	set numCount to (numList's |count|()) as integer
	if numCount is 0 then
		return current application's NSDecimalNumber's zero()
	end if
	
	if op is "+" then
		set resultVal to current application's NSDecimalNumber's zero()
		repeat with i from 0 to (numCount - 1)
			set num to (numList's objectAtIndex:i)
			set resultVal to resultVal's decimalNumberByAdding:num
		end repeat
	else
		set resultVal to current application's NSDecimalNumber's one()
		repeat with i from 0 to (numCount - 1)
			set num to (numList's objectAtIndex:i)
			set resultVal to resultVal's decimalNumberByMultiplyingBy:num
		end repeat
	end if
	
	return resultVal
end computeProblem

on solveProblems(dataLines, operatorLine, lineLength)
	set grandTotal to current application's NSDecimalNumber's zero()
	set numDataLines to length of dataLines
	
	set currentNums to current application's NSMutableArray's array()
	set currentOperator to ""
	set inProblem to false
	
	set lineNumStrs to current application's NSMutableArray's array()
	repeat numDataLines times
		lineNumStrs's addObject:""
	end repeat
	
	repeat with col from 1 to lineLength
		set allSpaces to true
		
		set opChar to getCharAtColumn(operatorLine, col)
		if opChar is not " " then
			set allSpaces to false
			set currentOperator to opChar
		end if
		
		repeat with rowIdx from 1 to numDataLines
			set dataLine to item rowIdx of dataLines
			set c to getCharAtColumn(dataLine, col)
			
			if c is not " " then
				set allSpaces to false
				set accumulated to (lineNumStrs's objectAtIndex:(rowIdx - 1)) as text
				lineNumStrs's replaceObjectAtIndex:(rowIdx - 1) withObject:(accumulated & c)
			else
				set accumulated to (lineNumStrs's objectAtIndex:(rowIdx - 1)) as text
				if accumulated is not "" then
					set numDec to current application's NSDecimalNumber's decimalNumberWithString:accumulated
					currentNums's addObject:numDec
					lineNumStrs's replaceObjectAtIndex:(rowIdx - 1) withObject:""
				end if
			end if
		end repeat
		
		if allSpaces then
			if inProblem then
				repeat with rowIdx from 1 to numDataLines
					set accumulated to (lineNumStrs's objectAtIndex:(rowIdx - 1)) as text
					if accumulated is not "" then
						set numDec to current application's NSDecimalNumber's decimalNumberWithString:accumulated
						currentNums's addObject:numDec
						lineNumStrs's replaceObjectAtIndex:(rowIdx - 1) withObject:""
					end if
				end repeat
				
				set numCount to (currentNums's |count|()) as integer
				if numCount > 0 and currentOperator is not "" then
					set problemResult to computeProblem(currentNums, currentOperator)
					set grandTotal to grandTotal's decimalNumberByAdding:problemResult
				end if
				
				set currentNums to current application's NSMutableArray's array()
				set currentOperator to ""
				set inProblem to false
			end if
		else
			set inProblem to true
		end if
	end repeat
	
	if inProblem then
		repeat with rowIdx from 1 to numDataLines
			set accumulated to (lineNumStrs's objectAtIndex:(rowIdx - 1)) as text
			if accumulated is not "" then
				set numDec to current application's NSDecimalNumber's decimalNumberWithString:accumulated
				currentNums's addObject:numDec
				lineNumStrs's replaceObjectAtIndex:(rowIdx - 1) withObject:""
			end if
		end repeat
		
		set numCount to (currentNums's |count|()) as integer
		if numCount > 0 and currentOperator is not "" then
			set problemResult to computeProblem(currentNums, currentOperator)
			set grandTotal to grandTotal's decimalNumberByAdding:problemResult
		end if
	end if
	
	return grandTotal
end solveProblems

set inputFile to choose file with prompt "Select the input file:"
set inputText to readFileContents(inputFile)
set worksheetData to parseWorksheet(inputText)
set dataLines to dataLines of worksheetData
set operatorLine to operatorLine of worksheetData
set lineLength to lineLength of worksheetData

set grandTotal to solveProblems(dataLines, operatorLine, lineLength)
set resultStr to (grandTotal's stringValue()) as text

display dialog "Grand total: " & resultStr buttons {"OK"} default button 1
return resultStr