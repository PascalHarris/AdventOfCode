

ImportInputData[defaultFile_String : ""] := Module[
  {file, data},
  (*Try default file first,or open dialog if not specified/not found*)
  file = If[defaultFile =!= "" && FileExistsQ[defaultFile],
    defaultFile,
    SystemDialogInput["FileOpen",
     WindowTitle -> "Select Input Data File",
     FileNameFilter -> {"Text files" -> {"*.txt"}, "All files" -> {"*"}}
     ]
    ];
  
  (*User cancelled the dialog*)
  If[file === $Canceled, Message[ImportInputData::cancelled];
   Abort[]
   ];
  (*File doesn't exist*)
  If[! FileExistsQ[file], Message[ImportInputData::notfound, file];
   Abort[]
   ];
  (*Attempt import*)data = Quiet[Import[file, {"Text", "Lines"}]];
  If[data === $Failed || ! ListQ[data], 
   Message[ImportInputData::importfail, file];
   Abort[]
   ];
  data
  ]

(*Define error messages*)
ImportInputData::cancelled = "File selection was cancelled.";
ImportInputData::notfound = "File not found: `1`";
ImportInputData::importfail = "Failed to import file: `1`";


data = ImportInputData["input-3.txt"];
bits = ToExpression[Characters[#]] & /@ data;

filter[list_, pos_, op_] := 
 Module[{keep}, If[Length[list] == 1, Return[list]];
  keep = Boole[op[2 Total[list[[All, pos]]], Length[list]]];
  Select[list, #[[pos]] == keep &]]

findRating[bits_, op_] := 
 Module[{remaining = bits, pos = 1}, 
  While[Length[remaining] > 1, remaining = filter[remaining, pos, op];
   pos++];
  FromDigits[First[remaining], 2]]

oxygen = findRating[bits, GreaterEqual];
co2 = findRating[bits, Less];
oxygen*co2