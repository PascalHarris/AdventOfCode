(*
	Junction Box Circuit Solver - Part 2
	
	Compiles and runs an Objective-C helper for speed.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

set inputFile to choose file with prompt "Select the input file:"
set inputPath to POSIX path of inputFile

set solverSourceFile to choose file with prompt "Select the junction_solver.m file:"
set solverSource to POSIX path of solverSourceFile

set tempDir to "/tmp/"
set solverBinary to tempDir & "junction_solver"

-- Compile
set compileTask to current application's NSTask's alloc()'s init()
compileTask's setLaunchPath:"/usr/bin/clang"
compileTask's setArguments:{"-framework", "Foundation", "-O2", "-o", solverBinary, solverSource}
compileTask's |launch|()
compileTask's waitUntilExit()

if (compileTask's terminationStatus()) as integer is not 0 then
	display dialog "Compilation failed!" buttons {"OK"} default button 1
	error "Compilation failed"
end if

-- Run solver
set solverTask to current application's NSTask's alloc()'s init()
solverTask's setLaunchPath:solverBinary
solverTask's setArguments:{inputPath}

set outputPipe to current application's NSPipe's pipe()
solverTask's setStandardOutput:outputPipe

solverTask's |launch|()
solverTask's waitUntilExit()

set outputData to outputPipe's fileHandleForReading()'s readDataToEndOfFile()
set outputString to (current application's NSString's alloc()'s initWithData:outputData encoding:(current application's NSUTF8StringEncoding)) as text

set AppleScript's text item delimiters to ","
set resultParts to text items of outputString
set AppleScript's text item delimiters to ""

set x1 to item 1 of resultParts
set x2 to item 2 of resultParts
set productVal to item 3 of resultParts

display dialog "Final pair X coords: " & x1 & " and " & x2 & return & "Product: " & productVal buttons {"OK"} default button 1