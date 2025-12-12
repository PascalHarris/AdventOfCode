(*
	Present Packer Solver
	
	Determines how many regions can fit all their required present shapes.
	Uses compiled Objective-C for efficient backtracking search.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

set inputFile to choose file with prompt "Select the input file:"
set inputPath to POSIX path of inputFile

set solverSourceFile to choose file with prompt "Select the present_packer.m file:"
set solverSource to POSIX path of solverSourceFile

set solverBinary to "/tmp/present_packer"

-- Compile
set compileTask to current application's NSTask's alloc()'s init()
compileTask's setLaunchPath:"/usr/bin/clang"
compileTask's setArguments:{"-framework", "Foundation", "-O3", "-o", solverBinary, solverSource}
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
set errorPipe to current application's NSPipe's pipe()
solverTask's setStandardOutput:outputPipe
solverTask's setStandardError:errorPipe

solverTask's |launch|()
solverTask's waitUntilExit()

set outputData to outputPipe's fileHandleForReading()'s readDataToEndOfFile()
set outputNSString to current application's NSString's alloc()'s initWithData:outputData encoding:(current application's NSUTF8StringEncoding)
set outputString to (outputNSString's stringByTrimmingCharactersInSet:(current application's NSCharacterSet's whitespaceAndNewlineCharacterSet())) as text

display dialog "Regions that can fit all presents: " & outputString buttons {"OK"} default button 1
return outputString