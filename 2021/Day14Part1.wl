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


data = ImportInputData["input-14.txt"];
template = Characters[data[[1]]];
rules = <|Rule @@ StringSplit[#, " -> "] & /@ Drop[data, 2]|>;

step[poly_] := Module[{pairs, inserted}, pairs = Partition[poly, 2, 1];
  inserted = Lookup[rules, StringJoin /@ pairs, ""];
  Prepend[Flatten[Transpose[{inserted, pairs[[All, 2]]}]], poly[[1]]]]

result = Nest[step, template, 10];
counts = Counts[result];
Max[counts] - Min[counts]