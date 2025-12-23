ImportInputData[defaultFile_String : ""] := Module[{file, data},
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
  
  (*Attempt import*)
  data = Quiet[Import[file, {"Text", "Lines"}]];
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


findCorrupt[line_] := Module[{stack = {}, result = None},
  Do[
   Which[
    StringMatchQ[c, "(" | "[" | "{" | "<"],
    AppendTo[stack, c],
    stack === {},
    result = c; Break[],
    match[Last[stack]] =!= c,
    result = c; Break[],
    True, stack = Most[stack]
    ],
   {c, Characters[line]}
   ];
  result
  ]

data = ImportInputData["input-10.txt"];
match = <|"(" -> ")", "[" -> "]", "{" -> "}", "<" -> ">"|>;
points = <|")" -> 3, "]" -> 57, "}" -> 1197, ">" -> 25137|>;
openers = Keys[match];

Total[points /@ Select[findCorrupt /@ data, # =!= None &]]