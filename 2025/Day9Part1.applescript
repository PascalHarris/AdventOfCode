(*
	Largest Rectangle Finder
	
	Finds the largest rectangle where two red tiles form opposite corners.
	Area = |x2-x1| * |y2-y1|
	
	Uses NSDecimalNumber for large integer results.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

on readFileContents(fileAlias)
	return read fileAlias as text
end readFileContents

on parsePoints(inputText)
	set nsText to current application's NSString's stringWithString:inputText
	set lineArray to nsText's componentsSeparatedByCharactersInSet:(current application's NSCharacterSet's newlineCharacterSet())
	
	set xCoords to current application's NSMutableArray's array()
	set yCoords to current application's NSMutableArray's array()
	
	set lineCount to (lineArray's |count|()) as integer
	repeat with lineIdx from 0 to (lineCount - 1)
		set aLine to (lineArray's objectAtIndex:lineIdx)
		set trimmed to (aLine's stringByTrimmingCharactersInSet:(current application's NSCharacterSet's whitespaceCharacterSet()))
		if (trimmed's |length|()) as integer > 0 then
			set parts to trimmed's componentsSeparatedByString:","
			if (parts's |count|()) as integer is 2 then
				set xVal to ((parts's objectAtIndex:0)'s integerValue()) as integer
				set yVal to ((parts's objectAtIndex:1)'s integerValue()) as integer
				xCoords's addObject:xVal
				yCoords's addObject:yVal
			end if
		end if
	end repeat
	
	return {xCoords:xCoords, yCoords:yCoords}
end parsePoints

on findLargestRectangle(coordData)
	set xCoords to xCoords of coordData
	set yCoords to yCoords of coordData
	set pointCount to (xCoords's |count|()) as integer
	
	set maxArea to current application's NSDecimalNumber's zero()
	
	-- Check all pairs
	repeat with i from 0 to (pointCount - 2)
		set x1 to (xCoords's objectAtIndex:i) as integer
		set y1 to (yCoords's objectAtIndex:i) as integer
		
		repeat with j from (i + 1) to (pointCount - 1)
			set x2 to (xCoords's objectAtIndex:j) as integer
			set y2 to (yCoords's objectAtIndex:j) as integer
			
			-- Calculate |x2-x1| + 1 (tile count, not distance)
			set dx to x2 - x1
			if dx < 0 then set dx to -dx
			set dx to dx + 1
			
			-- Calculate |y2-y1| + 1 (tile count, not distance)
			set dy to y2 - y1
			if dy < 0 then set dy to -dy
			set dy to dy + 1
			
			-- Calculate area using NSDecimalNumber
			set dxDec to current application's NSDecimalNumber's decimalNumberWithString:(dx as text)
			set dyDec to current application's NSDecimalNumber's decimalNumberWithString:(dy as text)
			set area to dxDec's decimalNumberByMultiplyingBy:dyDec
			
			if (area's compare:maxArea) as integer > 0 then
				set maxArea to area
			end if
		end repeat
	end repeat
	
	return maxArea's stringValue() as text
end findLargestRectangle

set inputFile to choose file with prompt "Select the input file:"
set inputText to readFileContents(inputFile)
set coordData to parsePoints(inputText)

set maxArea to findLargestRectangle(coordData)

display dialog "Largest rectangle area: " & maxArea buttons {"OK"} default button 1
return maxArea