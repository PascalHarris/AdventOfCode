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


processLine[line_] := Module[{stack = {}, corrupt = False},
  Do[
   Which[
    StringMatchQ[c, "(" | "[" | "{" | "<"],
    AppendTo[stack, c],
    stack === {} || match[Last[stack]] =!= c,
    corrupt = True; Break[],
    True,
    stack = Most[stack]
    ],
   {c, Characters[line]}
   ];
  If[corrupt, None, Reverse[stack]]
  ]

data = ImportInputData["input-10.txt"];
match = <|"(" -> ")", "[" -> "]", "{" -> "}", "<" -> ">"|>;
points2 = <|")" -> 1, "]" -> 2, "}" -> 3, ">" -> 4|>;

score[stack_] := Fold[5 #1 + points2[match[#2]] &, 0, stack]

stacks = Select[processLine /@ data, # =!= None &];
Median[score /@ stacks]